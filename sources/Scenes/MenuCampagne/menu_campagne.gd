extends CanvasLayer

class_name MenuCampagne

# Notifie la scene `Plateau` que le bouton est pressé
signal commencer_plateau

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
	$BoutonMenuPrincipal.hide()
	$InfosDuJoueur.hide()
	$Message.hide()
	$BoutonCommencer.hide()
	$LongueurAscension.hide()
	$MessageRiche.hide()

func afficher_accueil_nouvelle_ascension():
	$BoutonMenuPrincipal.show()
	# Reset le max de la jauge de plateaux
	reset_jauge_LongueurAscension()
	$LongueurAscension.show()
	
	_afficher_message("", false)
	# Attendre l'échéance d'une temporisation libre
	await get_tree().create_timer(1.0).timeout
	$BoutonCommencer.show()

func afficher_accueil_ascension_en_cours():
	$BoutonMenuPrincipal.show()
	mettre_a_jour_infos_joueur()
	$InfosDuJoueur.show()
	
	_afficher_message("Poursuivre l'ascension!", false)
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
	$MessageRiche.show()
	await get_tree().create_timer(5.0).timeout
	$MessageRiche.hide()
	afficher_plateau_suivant("Plateau suivant!")

func afficher_fin_ascension():
	_afficher_message("Bravo!")
	# Attendre l'échéance de la temporisation
	await $TempoMessage.timeout
	$MessageRiche.show()
	await get_tree().create_timer(5.0).timeout
	$MessageRiche.hide()
	modifier_tempo_message(3.0)
	_afficher_message("C'était le dernier plateau!")
	await $TempoMessage.timeout
	_afficher_message("Vous êtes au sommet...")
	await $TempoMessage.timeout
	_afficher_message("...de l'Everest!")
	await $TempoMessage.timeout
	modifier_tempo_message(1.0)
	afficher_plateau_suivant("Ascension suivante!")
	modifier_tempo_message(1.0)
	afficher_accueil_nouvelle_ascension()

func afficher_fin_campagne():
	_afficher_message("Félicitation!")
	# Attendre l'échéance de la temporisation
	await $TempoMessage.timeout
	$MessageRiche.show()
	await get_tree().create_timer(5.0).timeout
	$MessageRiche.hide()
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


# LongueurAscension
###################

var longueur_max_ascension : int = 0

func enregistrer_longueur_max_ascension(max : int) -> void:
	longueur_max_ascension = max

func reset_jauge_LongueurAscension():
	var pourcentage_min = 100. / longueur_max_ascension
	# Incrément par plateau
	$LongueurAscension/VBox/Curseur.step = pourcentage_min
	# 1 plateau minimum
	$LongueurAscension/VBox/Curseur.min_value = pourcentage_min
	
	# Initialisé à 100% par défaut
	$LongueurAscension/VBox/Curseur.value = 100
	$LongueurAscension/VBox/Pourcentage.value = 100
	_on_h_slider_value_changed(100.)

func _on_h_slider_value_changed(value: float) -> void:
	# Repercuter sur la valeur
	$LongueurAscension/VBox/Pourcentage.value = value
	# Repercuter sur le nombre de plateaux
	var nb_plateaux = roundi(value / 100. * longueur_max_ascension)
	if nb_plateaux > 1:
		$LongueurAscension/VBox/NombreDePlateaux.text = str(nb_plateaux) +" plateaux"
	else:
		$LongueurAscension/VBox/NombreDePlateaux.text = str(nb_plateaux) +" plateau"


# MessageRiche
##############

func afficher_detail_score(detail_score : Dictionary) -> void:
	# Afficher le détail du score.
	var bbcode_complet = ''
	var score_total = 0
	var size_y = 300

	# Entete
	bbcode_complet += """[color=#efefef][font_size=30][center][b]Score[/b][/center][/font_size]"""

	# 'duree'
	var bbcode_duree = """[left][font_size=20][b]Temps[/b] :
[ul] Référence: #duree_ref#s[/ul]
[ul] Réalisé: #duree_real#s[/ul]
[ul] #duree_pts# points[/ul]"""
	bbcode_duree = bbcode_duree.replace('#duree_ref#', str(detail_score.get('duree').get('reference')))
	bbcode_duree = bbcode_duree.replace('#duree_real#', str( snapped(detail_score.get('duree').get('realise'), 0.1) ))
	var points_txt = SauvegardeScores.nombre_avec_separateur_de_milliers(detail_score.get('duree').get('points'), '.')
	bbcode_duree = bbcode_duree.replace('#duree_pts#', points_txt)
	bbcode_complet += bbcode_duree
	score_total += detail_score.get('duree').get('points')

	# ratio_reussite
	var bbcode_ratio_reussite = """[b]Ratio Réussite[/b]
[ul] Réalisé: #ratio_real#%[/ul]
[ul] #ratio_pts# points[/ul]"""
	bbcode_ratio_reussite = bbcode_ratio_reussite.replace('#ratio_real#', str(detail_score.get('ratio_reussite').get('ratio')))
	points_txt = SauvegardeScores.nombre_avec_separateur_de_milliers(detail_score.get('ratio_reussite').get('points'), '.')
	bbcode_ratio_reussite = bbcode_ratio_reussite.replace('#ratio_pts#', points_txt)
	bbcode_complet += bbcode_ratio_reussite
	score_total += detail_score.get('ratio_reussite').get('points')

	# ascension
	if detail_score.get('ascension'):
		var bbcode_ascension = """[b]Ascension[/b]
[ul] Longueur: #asc_long# plateaux[/ul]
[ul] #asc_pts# points[/ul]"""
		bbcode_ascension = bbcode_ascension.replace('#asc_long#', str(detail_score.get('ascension').get('longueur')))
		points_txt = SauvegardeScores.nombre_avec_separateur_de_milliers(detail_score.get('ascension').get('points'), '.')
		bbcode_ascension = bbcode_ascension.replace('#asc_pts#', points_txt)
		bbcode_complet += bbcode_ascension
		score_total += detail_score.get('ascension').get('points')
		size_y += 80

	# ascension_sans_detour
	if detail_score.get('ascension_sans_detour'):
		var bbcode_ascension_sans_detour = """[b]Ascension sans détour[/b]
[ul] Bonus: #asc_detour_bonus#[/ul]
[ul] #asc_detour_pts# points[/ul]"""
		bbcode_ascension_sans_detour = bbcode_ascension_sans_detour.replace('#asc_detour_bonus#', str(detail_score.get('ascension_sans_detour').get('bonus')))
		points_txt = SauvegardeScores.nombre_avec_separateur_de_milliers(detail_score.get('ascension_sans_detour').get('points'), '.')
		bbcode_ascension_sans_detour = bbcode_ascension_sans_detour.replace('#asc_detour_pts#', points_txt)
		bbcode_complet += bbcode_ascension_sans_detour
		score_total += detail_score.get('ascension_sans_detour').get('points')
		size_y += 80

	# campagne
	if  detail_score.get('campagne'):
		var bbcode_campagne = """[b]Campagne[/b]
[ul] #campag_pts# points[/ul]"""
		points_txt = SauvegardeScores.nombre_avec_separateur_de_milliers(detail_score.get('campagne').get('points'), '.')
		bbcode_campagne = bbcode_campagne.replace('#campag_pts#', points_txt)
		bbcode_complet += bbcode_campagne
		score_total += detail_score.get('campagne').get('points')
		size_y += 60

	# total
	var bbcode_total = """[/font_size][/left][font_size=30][center][b]Total : #total_pts#[/b][/center][/font_size][/color]"""
	points_txt = SauvegardeScores.nombre_avec_separateur_de_milliers(score_total, '.')
	bbcode_total = bbcode_total.replace('#total_pts#', points_txt)
	bbcode_complet += bbcode_total

	# Afficher le score
	$MessageRiche.text = bbcode_complet
	$MessageRiche.size.y = size_y
