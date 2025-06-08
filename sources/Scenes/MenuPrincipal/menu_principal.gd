extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	menu_principal___liberer_le_joueur_pour_la_campagne()
	_creer_tuiles_joueurs_campagne()
	_mettre_a_jour_configuration()
	pass # Replace with function body.


func _on_bouton_références_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/References/references.tscn")


func _on_bouton_scores_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Scores/scores.tscn")


func _on_nouveau_joueur_text_submitted(nom_nouveau_joueur: String) -> void:
	print("Nouveau joueur : ", nom_nouveau_joueur)
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.get_node("nouveau_joueur").clear()
	if not menu_principal___ajouter_un_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur):
		printerr("Erreur : Le nom '" + nom_nouveau_joueur + "' n'est pas libre")
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.get_node("nouveau_joueur").placeholder_text = 'Erreur !'
	else:
		menu_principal___initialiser_le_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur)
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.get_node("nouveau_joueur").placeholder_text = 'Ok !'
		_ajouter_une_tuile_pour_nouveau_joueur_campagne(nom_nouveau_joueur)
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.get_node("nouveau_joueur").placeholder_text = " Ajouter "


func _on_bouton_campagne_pressed() -> void:
	if $Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.is_visible_in_tree():
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.hide()
	else:
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.show()


func _creer_tuiles_joueurs_campagne():
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.columns = 2
	for nom_joueur in SauvegardeListeJoueurs.retourner_la_liste_des_joueurs():
		# Ajouter des boutons ou des tuiles de sélection de profil
		var button = Button.new()
		_creer_style_tuile_joueur_campagne(button, nom_joueur, _la_campagne_est_terminee_pour_joueur(nom_joueur))
		button.text = nom_joueur
		button.connect("pressed", _on_joueurs_campagne_pressed.bind(nom_joueur))
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.add_child(button)

	# Ajouter la tuile pour ajouter un nouveau joueur
	var nouveau_joueur = LineEdit.new()
	_creer_style_tuile_joueur_campagne(nouveau_joueur, "nouveau_joueur", false)
	nouveau_joueur.placeholder_text = " Ajouter "
	nouveau_joueur.text_submitted.connect(_on_nouveau_joueur_text_submitted)
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.add_child(nouveau_joueur)


func _ajouter_une_tuile_pour_nouveau_joueur_campagne(nom_joueur : String):
	# Ajouter la tuile de sélection du nouveau profil
	var button = Button.new()
	_creer_style_tuile_joueur_campagne(button, nom_joueur, _la_campagne_est_terminee_pour_joueur(nom_joueur))
	button.text = nom_joueur
	button.connect("pressed", _on_joueurs_campagne_pressed.bind(nom_joueur))
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.add_child(button)
	# Mettre en avant derniere position la tuile pour que l'ajout de nouveau joueur soit toujours dernier
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.move_child(button, -2)


# "Control" = parent de "Button" et "LineEdit"
func _creer_style_tuile_joueur_campagne(tuile : Control, nom : String, campagne_terminee : bool):
	tuile.name = nom
	tuile.add_theme_font_size_override("font_size", 21)
	
	# Code conditionnel
	if tuile is Button:
		pass
	if tuile is LineEdit:
		pass
	
	# Créer un StyleBoxFlat pour le hover et normal
	# La couleur de la tuile est grise si la campagne est terminée
	var normal_style = StyleBoxFlat.new()
	if campagne_terminee:
		normal_style.bg_color = Color.html("404040")
	else:
		normal_style.bg_color = Color.html("df00df")
	normal_style.content_margin_left = 10
	normal_style.content_margin_right = 10
	normal_style.content_margin_top = 5
	normal_style.content_margin_bottom = 5
	tuile.add_theme_stylebox_override("normal", normal_style)
	var hover_style = StyleBoxFlat.new()
	if campagne_terminee:
		hover_style.bg_color = Color.html("202020")
	else:
		hover_style.bg_color = Color.html("890089")
	hover_style.content_margin_left = 10
	hover_style.content_margin_right = 10
	hover_style.content_margin_top = 5
	hover_style.content_margin_bottom = 5
	tuile.add_theme_stylebox_override("hover", hover_style)


func _on_joueurs_campagne_pressed(nom_joueur: String) -> void:
	print("Campagne avec le joueur : ", nom_joueur)
	if not SauvegardeListeJoueurs.le_joueur_existe(nom_joueur):
		printerr("Erreur : Le nom '" + nom_joueur + "' n'existe pas")
	elif not _la_campagne_est_terminee_pour_joueur(nom_joueur):
		# Choisir le joueur pour la campagne
		menu_principal___choisir_le_joueur_pour_la_campagne(nom_joueur)
		get_tree().change_scene_to_file("res://Scenes/Campagne/campagne.tscn")
	else:
		printerr("Erreur : Le joueur '" + nom_joueur + "' a terminé la campagne")


func _mettre_a_jour_configuration():
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/VBoxContainer/BoutonMusiques.button_pressed = SauvegardeConfiguration.musiques_sont_actives()
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/VBoxContainer/BoutonEffetsSonores.button_pressed = SauvegardeConfiguration.effets_sonores_sont_actifs()
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/VBoxContainer/BoutonVibrations.button_pressed = SauvegardeConfiguration.vibrations_sont_actives()
	$Version.text = SauvegardeConfiguration.lire_la_version()

func _on_bouton_musiques_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SauvegardeConfiguration.activer_musiques()
	else:
		SauvegardeConfiguration.desactiver_musiques()

func _on_bouton_effets_sonores_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SauvegardeConfiguration.activer_effets_sonores()
	else:
		SauvegardeConfiguration.desactiver_effets_sonores()

func _on_bouton_vibrations_toggled(toggled_on: bool) -> void:
	if toggled_on:
		SauvegardeConfiguration.activer_vibrations()
	else:
		SauvegardeConfiguration.desactiver_vibrations()


# Traitement de données 'Sauvegarde*'
# spécifiques au menu principal pour la campagne
################################################

func _la_campagne_est_terminee_pour_joueur(nom_joueur : String) -> bool:
	if SauvegardeListeJoueurs.le_joueur_existe(nom_joueur):
		# Choisir le joueur pour la campagne
		var nom_fichier = SauvegardeListeJoueurs.retourner_le_fichier_de_sauvegarde(nom_joueur)
		SauvegardeBddJoueurs.choisir_le_joueur(nom_joueur, nom_fichier)
		return SauvegardeBddJoueurs.la_campagne_est_terminee()
	return false

func menu_principal___choisir_le_joueur_pour_la_campagne(nom_joueur : String) -> bool:
	if SauvegardeListeJoueurs.le_joueur_existe(nom_joueur):
		# Choisir le joueur pour la campagne
		var nom_fichier = SauvegardeListeJoueurs.retourner_le_fichier_de_sauvegarde(nom_joueur)
		if SauvegardeBddJoueurs.choisir_le_joueur(nom_joueur, nom_fichier):
			return true
	return false

func menu_principal___liberer_le_joueur_pour_la_campagne():
	SauvegardeBddJoueurs.liberer_le_joueur()

func menu_principal___ajouter_un_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur : String) -> bool:
	return not SauvegardeListeJoueurs.le_joueur_existe(nom_nouveau_joueur)

func menu_principal___initialiser_le_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur : String) -> bool:
	if not SauvegardeListeJoueurs.le_joueur_existe(nom_nouveau_joueur):
		# Ajouter le joueur dans la liste des joueurs
		if SauvegardeListeJoueurs.ajouter_un_nouveau_joueur(nom_nouveau_joueur):
			var nom_fichier = SauvegardeListeJoueurs.retourner_le_fichier_de_sauvegarde(nom_nouveau_joueur)
			# Ajouter la sauvegarde personnelle du joueur
			if SauvegardeBddJoueurs.ajouter_un_nouveau_joueur(nom_nouveau_joueur, nom_fichier):
				# Ajouter le joueur dans le tableau des scores
				if SauvegardeScores.ajouter_un_nouveau_joueur(nom_nouveau_joueur):
					return true
	return false
