extends CanvasLayer

class_name MenuCampagne

# Notifie la scene `Plateau` que le bouton est pressé
signal commencer_plateau
# TODO : Effacer partout 'saisie_plateau' !!
#signal saisie_plateau

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mettre_a_jour_infos_joueur()


# InfosDuJoueur
###############

func _pourcentage_en_led(pourcentage : int, led_sombre, led_lumineuse) -> String:
	var nb_max_leds = 10
	var tranche_pourcentage = 100./nb_max_leds
	var leds : String = ''
	for i in range(floori(1.*pourcentage/tranche_pourcentage)):
		leds += led_lumineuse
	for i in range(floori(1.*pourcentage/tranche_pourcentage), nb_max_leds):
		leds += led_sombre
	print("Tranche=", tranche_pourcentage, "%", \
		", Pourcentage=", pourcentage, "%", \
		", lumineuses=", floori(1.*pourcentage/tranche_pourcentage), \
		", sombres=", nb_max_leds - floori(1.*pourcentage/tranche_pourcentage))
	return leds
# WALKING PERSON :
# U+1F6B6
# U+1F6B6 U+200D U+2642 U+FE0F
# U+1F6B6 U+200D U+2640 U+FE0F
# U+1F6B6 U+200D U+27A1 U+FE0F
# U+1F6B6 U+200D U+2640 U+FE0F U+200D U+27A1 U+FE0F
# U+1F6B6 U+200D U+2642 U+FE0F U+200D U+27A1 U+FE0F

# FOOT PRINT : U+1F463

# ROCK : U+1FAA8

# PUZZLE PIECE : U+1F9E9

# BLACK LARGE SQUARE : U+2B1B
# WHITE LARGE SQUARE : U+2B1C
# BLACK MEDIUM SQUARE : U+25FC
# WHITE MEDIUM SQUARE : U+25FB
# BLACK SMALL SQUARE : U+25FE
# WHITE SMALL SQUARE : U+25FD

# Tenter de representer l'avancement ainsi : 
# LARGE = 20%
# MEDIUM = 10 %
# SMALL = 1 plateau

# Infos joueur
###############
var nom : String = ""
var trophee : String = ""
var pourcentage_ascension_realise : int = 0
var nb_ascensions : int = 0
var score_texte : String = "0"

func enregistrer_infos_joueur(	_nom : String = "",
								_trophee : String = "",
								_pourcentage_ascension_realise : int = 0,
								_nb_ascensions : int = 0,
								_score_texte : String = "0") -> void:
	nom = _nom
	trophee = _trophee
	pourcentage_ascension_realise = _pourcentage_ascension_realise
	nb_ascensions = _nb_ascensions
	score_texte = _score_texte

func mettre_a_jour_infos_joueur() -> void:
	var emoji_carre_blanc = String.chr(0x25FD)
	var emoji_carre_noir = String.chr(0x25FE)
	var emoji_montagne = String.chr(0x1F3D4)
	# var emoji_globe = String.chr(0x1F30D)
	var ascension = _pourcentage_en_led(
		pourcentage_ascension_realise,
		emoji_carre_noir,
		emoji_carre_blanc)
	var texte = "[center][font_size=30]"
	texte += nom + " " + trophee + " " + score_texte + "\n"
	texte += ascension + "\n"
	#texte += campagne + "\n"
	if nb_ascensions:
		for i in range(nb_ascensions):
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
	$BoutonMenuPrincipal.hide()
	$InfosDuJoueur.hide()
	$BoutonCommencer.hide()

func afficher_accueil():
	# Initialisation du menu de campagne
	$Message.size.y = $Message.size.y + 100
	
	$BoutonMenuPrincipal.show()
	mettre_a_jour_infos_joueur()
	$InfosDuJoueur.show()
	
	_afficher_message("Mode Campagne!", false)
	# Attendre l'échéance d'une temporisation libre
	await get_tree().create_timer(1.0).timeout
	$BoutonCommencer.show()

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

func _on_bouton_menu_principal_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")



func afficher_plateau_suivant(texte : String):
	_afficher_message(texte, false)
	mettre_a_jour_infos_joueur()
	$BoutonMenuPrincipal.show()
	$InfosDuJoueur.show()
	$BoutonCommencer.show()

func afficher_plateau_invalide():
	# Pas de plateau invalide en campagne
	pass

func afficher_abandon():
	_afficher_message("Perdu!")
	await $TempoMessage.timeout
	_afficher_message("Fin de Partie")
	await $TempoMessage.timeout
	afficher_plateau_suivant("Plateau suivant!")

func afficher_victoire(duree : int) -> void:
	_afficher_message("Bravo!")
	await $TempoMessage.timeout
	_afficher_message("Gagné en " + str(duree) + "s")
	await $TempoMessage.timeout
	afficher_plateau_suivant("Plateau suivant!")

func afficher_fin_ascension():
	_afficher_message("Bravo!")
	# Attendre l'échéance de la temporisation
	await $TempoMessage.timeout
	modifier_tempo_message(3.0)
	_afficher_message("C'était le dernier plateau!")
	await $TempoMessage.timeout
	_afficher_message("Vous êtes au sommet...")
	await $TempoMessage.timeout
	_afficher_message("...de l'Everest!")
	await $TempoMessage.timeout
	modifier_tempo_message(1.0)
	afficher_plateau_suivant("Ascension suivante!")

func afficher_fin_campagne():
	_afficher_message("Félicitation!")
	# Attendre l'échéance de la temporisation
	await $TempoMessage.timeout
	modifier_tempo_message(5.0)
	_afficher_message("C'était le dernier plateau...")
	await $TempoMessage.timeout
	_afficher_message("...de la dernière ascension.")
	await $TempoMessage.timeout
	_afficher_message("Savourez l'instant.", false)
	#await $TempoMessage.timeout
	modifier_tempo_message(1.0)
	$BoutonMenuPrincipal.show()
	mettre_a_jour_infos_joueur()
	$InfosDuJoueur.show()
	#$BoutonCommencer.show()
