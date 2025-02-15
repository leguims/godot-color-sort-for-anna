extends CanvasLayer

class_name Menu

# Notifie la scene `Plateau` que le bouton est pressé
signal commencer_plateau
signal saisie_plateau

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mettre_a_jour_infos_joueur()

func mettre_a_jour_infos_joueur() -> void:
	var nom = GestionScore.lire_le_nom_du_joueur_actuel()
	var niveau = str(GestionScore.lire_le_niveau_du_joueur_actuel())
	var indice_plateau = str(GestionScore.lire_indice_plateau_du_joueur_actuel())
	var score = str(GestionScore.lire_le_score_du_joueur_actuel())

	var texte = "[center][font_size=30]"
	texte += "Joueur: " + nom + "\n"
	texte += "Niveau: " + niveau + "." + indice_plateau
	texte += " - Score: " + score
	texte += "[/font_size][/center]"
	$InfosDuJoueur/TexteInfosDuJoueur.bbcode_text = texte
	
# Méthodes d'ajustement de la scene
func modifier_tempo_message(nouvelle_tempo: float) -> void:
	$TempoMessage.wait_time = nouvelle_tempo

func modifier_message_vertical_align(alignement : VerticalAlignment) -> void:
	$Message.vertical_alignment = alignement

func cacher_accueil():
	$Message.hide()
	$EditeurPlateau.hide()
	$BoutonMenuPrincipal.hide()
	$InfosDuJoueur.hide()
	$BoutonCommencer.hide()

func _afficher_message(texte : String, temporaire : bool = true):
	$Message.hide()
	$Message.text = texte
	$Message.show()
	if temporaire:
		$TempoMessage.start()


func _on_tempo_message_timeout() -> void:
	$Message.hide()

func _on_bouton_commencer_pressed() -> void:
	commencer_plateau.emit()

func _on_saisie_edition_plateau_text_submitted(new_text: String) -> void:
	saisie_plateau.emit(new_text)

func _on_bouton_menu_principal_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")
