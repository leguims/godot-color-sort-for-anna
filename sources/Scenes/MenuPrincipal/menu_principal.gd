extends Control

var _noms_joueurs: Array = []
var _champ_nouveau_joueur: LineEdit
var _cartes_joueurs: Array[Control] = []
var _nom_joueur_selectionne := ""
static var _nom_joueur_selectionne_memoire := ""

func _ready() -> void:
	ProgressionCampagneService.liberer_le_joueur_pour_la_campagne()
	_noms_joueurs = SauvegardeListeJoueursService.retourner_la_liste_des_joueurs()
	_preparer_cartes_joueurs()
	_configurer_joueurs()
	_initialiser_joueur_selectionne()
	_configurer_navigation()
	_configurer_ajout_joueur()
	_capturer_si_demande()

func _configurer_joueurs() -> void:
	for indice in range(_cartes_joueurs.size()):
		var carte := _cartes_joueurs[indice]
		var nom := str(_noms_joueurs[indice])
		(carte.get_node("NomJoueur") as Label).text = nom
		var zone := carte.get_node("ZoneClic") as Button
		zone.pressed.connect(_on_carte_joueur_pressed.bind(nom))

func _initialiser_joueur_selectionne() -> void:
	if _nom_joueur_selectionne_memoire in _noms_joueurs:
		_nom_joueur_selectionne = _nom_joueur_selectionne_memoire
	else:
		for indice in range(_cartes_joueurs.size()):
			for enfant in _cartes_joueurs[indice].get_children():
				if enfant.has_meta("selectionne") and enfant.get_meta("selectionne"):
					_nom_joueur_selectionne = str(_noms_joueurs[indice])
					break
			if not _nom_joueur_selectionne.is_empty():
				break
	if not _nom_joueur_selectionne.is_empty():
		_nom_joueur_selectionne_memoire = _nom_joueur_selectionne
		var indice_selectionne := _noms_joueurs.find(_nom_joueur_selectionne)
		if indice_selectionne >= 0 and indice_selectionne < 2:
			$Habillage._selectionner_joueur_poc(indice_selectionne)

func _on_carte_joueur_pressed(nom_joueur: String) -> void:
	_nom_joueur_selectionne = nom_joueur
	_nom_joueur_selectionne_memoire = nom_joueur
	_on_joueurs_campagne_pressed(nom_joueur)

func _preparer_cartes_joueurs() -> void:
	var carte_principale := $Habillage.find_child("CartePrincipale", true, false) as Control
	var modele_normal := $Habillage.find_child("Joueur0", true, false) as Control
	var modele_selectionne := $Habillage.find_child("Joueur1", true, false) as Control
	if _noms_joueurs.size() <= 2:
		_cartes_joueurs = [modele_normal, modele_selectionne]
		for indice in range(_cartes_joueurs.size()):
			_cartes_joueurs[indice].visible = indice < _noms_joueurs.size()
		return

	var defilement := ScrollContainer.new()
	defilement.name = "ListeJoueursDefilante"
	defilement.position = Vector2(14, 51)
	defilement.size = Vector2(266, 111)
	defilement.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	defilement.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	carte_principale.add_child(defilement)

	var liste := VBoxContainer.new()
	liste.name = "CartesJoueurs"
	liste.custom_minimum_size = Vector2(254, 0)
	liste.add_theme_constant_override("separation", 7)
	defilement.add_child(liste)

	for indice in range(_noms_joueurs.size()):
		var carte: Control
		if indice == 0:
			carte = modele_normal
		elif indice == 1:
			carte = modele_selectionne
		else:
			carte = modele_normal.duplicate()
			carte.name = "Joueur%d" % indice
		if carte.get_parent() == null:
			liste.add_child(carte)
		elif carte.get_parent() != liste:
			carte.reparent(liste)
		carte.position = Vector2.ZERO
		carte.custom_minimum_size = Vector2(254, 52)
		carte.size = Vector2(254, 52)
		carte.visible = true
		_cartes_joueurs.append(carte)

	await get_tree().process_frame
	defilement.scroll_vertical = int(defilement.get_v_scroll_bar().max_value)

func _configurer_navigation() -> void:
	var scores := $Habillage.find_child("BoutonScores", true, false) as Button
	var references := $Habillage.find_child("BoutonReferences", true, false) as Button
	var continuer := $Habillage.find_child("BoutonContinuer", true, false) as Button
	scores.pressed.connect(_on_bouton_scores_pressed)
	references.pressed.connect(_on_bouton_references_pressed)
	continuer.disabled = _nom_joueur_selectionne.is_empty()
	continuer.pressed.connect(_on_bouton_continuer_pressed)

func _on_bouton_continuer_pressed() -> void:
	if not _nom_joueur_selectionne.is_empty():
		_on_joueurs_campagne_pressed(_nom_joueur_selectionne)

func _configurer_ajout_joueur() -> void:
	var carte := $Habillage.find_child("AjouterJoueur", true, false) as Control
	carte.mouse_filter = Control.MOUSE_FILTER_STOP
	carte.gui_input.connect(_on_ajouter_joueur_gui_input)
	for enfant in carte.get_children():
		if enfant is Label and "Ajouter" in enfant.text:
			enfant.hide()
	_champ_nouveau_joueur = LineEdit.new()
	_champ_nouveau_joueur.name = "nouveau_joueur"
	_champ_nouveau_joueur.position = Vector2(50, 6)
	_champ_nouveau_joueur.size = Vector2(202, 40)
	_champ_nouveau_joueur.placeholder_text = "Nom du joueur"
	_champ_nouveau_joueur.add_theme_font_size_override("font_size", 14)
	_champ_nouveau_joueur.add_theme_color_override("font_color", Color("183653"))
	_champ_nouveau_joueur.add_theme_color_override("font_placeholder_color", Color("183653"))
	_champ_nouveau_joueur.add_theme_color_override("caret_color", Color("183653"))
	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = Color("fff8e9")
	style_normal.border_width_left = 1
	style_normal.border_width_top = 1
	style_normal.border_width_right = 1
	style_normal.border_width_bottom = 1
	style_normal.border_color = Color("d8c39f")
	style_normal.corner_radius_top_left = 9
	style_normal.corner_radius_top_right = 9
	style_normal.corner_radius_bottom_left = 9
	style_normal.corner_radius_bottom_right = 9
	style_normal.content_margin_left = 10
	style_normal.content_margin_right = 10
	var style_focus := style_normal.duplicate() as StyleBoxFlat
	style_focus.bg_color = Color("fff4df")
	style_focus.border_width_left = 2
	style_focus.border_width_top = 2
	style_focus.border_width_right = 2
	style_focus.border_width_bottom = 2
	style_focus.border_color = Color("183653")
	_champ_nouveau_joueur.add_theme_stylebox_override("normal", style_normal)
	_champ_nouveau_joueur.add_theme_stylebox_override("focus", style_focus)
	_champ_nouveau_joueur.text_submitted.connect(_on_nouveau_joueur_text_submitted)
	if OS.has_feature("web") and _is_ios():
		_champ_nouveau_joueur.focus_entered.connect(_nouveau_joueur_on_focus_entered)
	carte.add_child(_champ_nouveau_joueur)

func _on_ajouter_joueur_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_champ_nouveau_joueur.grab_focus()
		accept_event()

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
