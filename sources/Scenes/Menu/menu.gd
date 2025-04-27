extends CanvasLayer

class_name Menu

# Notifie la scene `Plateau` que le bouton est pressé
signal commencer_plateau
signal saisie_plateau

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mettre_a_jour_infos_joueur()

func _pourcentage_en_led(pourcentage : int, led_sombre, led_lumineuse) -> String:
	var nb_max_leds = 10
	var tranche_pourcentage = 100./nb_max_leds
	var leds : String = ''
	for i in range(roundi(1.*pourcentage/tranche_pourcentage)):
		leds += led_lumineuse
	for i in range(roundi(1.*pourcentage/tranche_pourcentage), nb_max_leds):
		leds += led_sombre
	return leds

func mettre_a_jour_infos_joueur() -> void:
	var emoji_carre_blanc = String.chr(0x25FD)
	var emoji_carre_noir = String.chr(0x25FE)
	var emoji_montagne = String.chr(0x1F3D4)
	var trophee = GestionScore.lire_le_trophee_du_joueur_actuel()
	var nom = GestionScore.lire_le_nom_du_joueur_actuel()
	var ascension = _pourcentage_en_led(
		roundi(GestionScore.lire_pourcentage_ascension_realise_du_joueur_actuel()),
		emoji_carre_noir,
		emoji_carre_blanc)
	var nb_ascensions_recentes =  GestionScore.compter_ascensions_du_joueur_actuel_depuis(24 * 3600.0)
	var score = GestionScore.lire_le_score_du_joueur_actuel()
	var score_texte = GestionScore.nombre_avec_separateur_de_milliers(score, ' ')
	var texte = "[center][font_size=30]"
	texte += nom + " " + trophee + " " + score_texte + "\n"
	texte += ascension + "\n"
	if nb_ascensions_recentes:
		for i in range(nb_ascensions_recentes):
			texte += emoji_montagne
		texte += "\n"
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
