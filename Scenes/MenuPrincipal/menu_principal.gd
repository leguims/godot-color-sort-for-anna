extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GestionScore.initialiser_les_plateaux()
	GestionScore.lire_sauvegarde_joueurs()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bouton_références_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/References/references.tscn")


func _on_bouton_scores_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Scores/scores.tscn")


func _on_bouton_joueur_pressed() -> void:
	if $Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/TexteJoueur.is_visible_in_tree():
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/TexteJoueur.hide()
	else:
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/TexteJoueur.show()


func _on_texte_joueur_text_submitted(nom_nouveau_joueur: String) -> void:
	print("Nouveau joueur : ", nom_nouveau_joueur)
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/TexteJoueur.clear()
	if not GestionScore.ajouter_un_nouveau_joueur(nom_nouveau_joueur):
		print("Erreur : Le nom '" + nom_nouveau_joueur + "' n'est pas libre")
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/TexteJoueur.placeholder_text = 'Erreur !'
	else:
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/TexteJoueur.placeholder_text = 'Ok !'
		_mettre_a_jour_boutons_joueurs_campagne()


func _on_bouton_campagne_pressed() -> void:
	if $Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.is_visible_in_tree():
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.hide()
		_effacer_boutons_joueurs_campagne()
	else:
		_creer_boutons_joueurs_campagne()
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.show()

func _mettre_a_jour_boutons_joueurs_campagne():
	_effacer_boutons_joueurs_campagne()
	_creer_boutons_joueurs_campagne()

func _creer_boutons_joueurs_campagne():
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.columns = 2
	for nom_joueur in GestionScore.liste_des_joueurs():
		# Ajouter des boutons ou des tuiles de sélection de profil
		var button = Button.new()
		button.text = nom_joueur
		button.add_theme_font_size_override("font_size", 21)
		
		# Créer un StyleBoxFlat pour le hover et normal
		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color = Color.html("df00df")
		normal_style.content_margin_left = 10
		normal_style.content_margin_right = 10
		normal_style.content_margin_top = 5
		normal_style.content_margin_bottom = 5
		button.add_theme_stylebox_override("normal", normal_style)
		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = Color.html("890089")
		hover_style.content_margin_left = 10
		hover_style.content_margin_right = 10
		hover_style.content_margin_top = 5
		hover_style.content_margin_bottom = 5
		button.add_theme_stylebox_override("hover", hover_style)

		button.connect("pressed", _on_joueurs_campagne_pressed.bind(nom_joueur))
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.add_child(button)


func _effacer_boutons_joueurs_campagne():
	for child in $Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/JoueursCampagne.get_children():
		if child is Button:
			remove_child(child)
			child.queue_free()


func _on_joueurs_campagne_pressed(nom_joueur: String) -> void:
	print("Campagne avec le joueur : ", nom_joueur)
	if not GestionScore.choisir_le_joueur(nom_joueur):
		print("Erreur : Le nom '" + nom_joueur + "' n'existe pas")
	else:
		get_tree().change_scene_to_file("res://Scenes/Campagne/campagne.tscn")


func _on_bouton_editer_plateau_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/EditerUnPlateau/editer_un_plateau.tscn")
