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



func _on_bouton_campagne_pressed() -> void:
	if $Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/TexteCampagne.is_visible_in_tree():
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/TexteCampagne.hide()
	else:
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/TexteCampagne.show()


func _on_texte_campagne_text_submitted(nom_joueur: String) -> void:
	print("Campagne avec le joueur : ", nom_joueur)
	$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/TexteCampagne.clear()
	if not GestionScore.choisir_le_joueur(nom_joueur):
		print("Erreur : Le nom '" + nom_joueur + "' n'existe pas")
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/TexteCampagne.placeholder_text = 'Erreur !'
	else:
		$Marge/HBoxContainer/VBoxContainer/Marge/VBoxContainer/TexteCampagne.placeholder_text = 'Ok !'
		get_tree().change_scene_to_file("res://Scenes/Campagne/campagne.tscn")


func _on_bouton_editer_plateau_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/EditerUnPlateau/editer_un_plateau.tscn")
