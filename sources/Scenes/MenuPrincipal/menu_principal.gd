extends Control

var _noms_joueurs: Array = []
var _champ_nouveau_joueur: LineEdit

func _ready() -> void:
	ProgressionCampagneService.liberer_le_joueur_pour_la_campagne()
	_noms_joueurs = SauvegardeListeJoueursService.retourner_la_liste_des_joueurs()
	_configurer_joueurs()
	_configurer_navigation()
	_configurer_ajout_joueur()
	_capturer_si_demande()

func _configurer_joueurs() -> void:
	for indice in range(2):
		var carte := $Habillage.find_child("Joueur%d" % indice, true, false) as Control
		if carte == null:
			continue
		carte.visible = indice < _noms_joueurs.size()
		if not carte.visible:
			continue
		var nom := str(_noms_joueurs[indice])
		(carte.get_node("NomJoueur") as Label).text = nom
		var zone := carte.get_node("ZoneClic") as Button
		zone.pressed.connect(_on_joueurs_campagne_pressed.bind(nom))

func _configurer_navigation() -> void:
	var scores := $Habillage.find_child("BoutonScores", true, false) as Button
	var references := $Habillage.find_child("BoutonReferences", true, false) as Button
	var continuer := $Habillage.find_child("BoutonContinuer", true, false) as Button
	scores.pressed.connect(_on_bouton_scores_pressed)
	references.pressed.connect(_on_bouton_references_pressed)
	# Le produit existant lance la campagne au clic sur le joueur. Le bouton
	# reste purement visuel tant qu'un nouveau workflow n'est pas validé.
	continuer.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _configurer_ajout_joueur() -> void:
	var carte := $Habillage.find_child("AjouterJoueur", true, false) as Control
	for enfant in carte.get_children():
		if enfant is Label and "Ajouter" in enfant.text:
			enfant.hide()
	_champ_nouveau_joueur = LineEdit.new()
	_champ_nouveau_joueur.name = "nouveau_joueur"
	_champ_nouveau_joueur.position = Vector2(50, 6)
	_champ_nouveau_joueur.size = Vector2(202, 40)
	_champ_nouveau_joueur.placeholder_text = "Ajouter un joueur"
	_champ_nouveau_joueur.add_theme_font_size_override("font_size", 14)
	_champ_nouveau_joueur.add_theme_color_override("font_color", Color("183653"))
	_champ_nouveau_joueur.add_theme_color_override("font_placeholder_color", Color("183653"))
	_champ_nouveau_joueur.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	_champ_nouveau_joueur.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_champ_nouveau_joueur.text_submitted.connect(_on_nouveau_joueur_text_submitted)
	if OS.has_feature("web") and _is_ios():
		_champ_nouveau_joueur.focus_entered.connect(_nouveau_joueur_on_focus_entered)
	carte.add_child(_champ_nouveau_joueur)

func _on_bouton_references_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/References/references.tscn")
	AudioService.son_menu_click()

func _on_bouton_scores_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/Scores/scores.tscn")
	AudioService.son_menu_click()

func _on_joueurs_campagne_pressed(nom_joueur: String) -> void:
	LogService.log_debug("Campagne avec le joueur : ", nom_joueur)
	if not SauvegardeListeJoueursService.le_joueur_existe(nom_joueur):
		LogService.log_erreur("Erreur : Le nom *" + nom_joueur + "* n'existe pas")
	elif not ProgressionCampagneService.la_campagne_est_terminee_pour_joueur(nom_joueur):
		if ProgressionCampagneService.choisir_le_joueur_pour_la_campagne(nom_joueur):
			AudioService.son_menu_click()
			get_tree().change_scene_to_file("res://Scenes/Campagne/campagne.tscn")
		else:
			LogService.log_erreur("Erreur : Impossible de choisir le joueur *" + nom_joueur + ".")
	else:
		AudioService.son_menu_click()
		get_tree().change_scene_to_file("res://Scenes/Statistiques/statistiques.tscn")

func _on_nouveau_joueur_text_submitted(nom: String) -> void:
	_on_clavier_pseudo_annule()
	if ScoreService.nouveau_joueur_est_nom_anna_triche(nom):
		nom = ScoreService.lire_nom_anna_triche()
	_champ_nouveau_joueur.clear()
	if not ProgressionCampagneService.ajouter_un_nouveau_joueur_pour_la_campagne(nom):
		_champ_nouveau_joueur.placeholder_text = "Erreur !"
		return
	ProgressionCampagneService.initialiser_le_nouveau_joueur_pour_la_campagne(nom)
	get_tree().reload_current_scene()

func _nouveau_joueur_on_focus_entered() -> void:
	$Clavier.ouvrir()

func _on_clavier_pseudo_valide(pseudo: String) -> void:
	$Clavier.fermer()
	_on_nouveau_joueur_text_submitted(pseudo)

func _on_clavier_pseudo_annule() -> void:
	$Clavier.fermer()

func _is_ios() -> bool:
	var ua = JavaScriptBridge.eval("navigator.userAgent")
	return ua.find("iPhone") != -1 or ua.find("iPad") != -1 or ua.find("iPod") != -1

func _capturer_si_demande() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			await get_tree().process_frame
			await get_tree().process_frame
			get_viewport().get_texture().get_image().save_png(argument.trim_prefix("--capture="))
			get_tree().quit()
