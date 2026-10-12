extends Node

class_name MenuPlateau

signal abandon
signal passe
signal deselection_pile

func _process(_delta: float) -> void:
	# Afficher le temps
	_maj_chrono()
	# Afficher le nombre de coups
	_maj_coups()

# #############
# API Gameplay
func enregistrer_gameplay(gameplay : String, font_size : int = 30):
	$Bandeau/Gameplay.text = gameplay
	$Bandeau/Gameplay.add_theme_font_size_override("font_size", font_size)

func enregistrer_sous_titre_gameplay(sous_titre_gameplay : String, font_size : int = 18):
	$Bandeau/SousTitreGameplay.text = sous_titre_gameplay
	$Bandeau/SousTitreGameplay.add_theme_font_size_override("font_size", font_size)

func enregistrer_chrono(minutes : String,
						secondes : String,
						decisecondes : String):
	var text_chrono : String = minutes + ':' + secondes + '.' + decisecondes
	$Bandeau/Chrono.text = text_chrono

func enregistrer_coups(coups : String):
	$Bandeau/Coups.text = coups

func show():
	$Fond.show()
	$Bandeau.show()
	$Bandeau/Fond.show()
	$Bandeau/Gameplay.show()
	$Bandeau/SousTitreGameplay.show()
	$Bandeau/Chrono.show()
	# $Bandeau/Coups.show()
	$Bandeau/BoutonRecommencer.show()
	$Bandeau/BoutonPasser.show()

func hide():
	$Fond.hide()
	$Bandeau.hide()
	$Bandeau/Fond.hide()
	$Bandeau/Gameplay.hide()
	$Bandeau/SousTitreGameplay.hide()
	$Bandeau/Chrono.hide()
	# $Bandeau/Coups.hide()
	$Bandeau/BoutonRecommencer.hide()
	$Bandeau/BoutonPasser.hide()

func cacher_accueil():
	hide()
	$Fond.show()

# ########
# Interne
func _maj_chrono() -> void:
	"Met à jour le temps du plateau en direct"
	var temps_ecoule_en_s : float = SauvegardeBddJoueursService.enregistrement_lire_duree_plateau()
	var minutes : int = floori(temps_ecoule_en_s / 60.)
	var secondes : int = floori(temps_ecoule_en_s - 60 * minutes)
	var decisecondes : int = roundi( (temps_ecoule_en_s - 60 * minutes - secondes) * 10.)
	# Gerer l'arrondi des decisecondes
	if decisecondes == 10:
		decisecondes = 0; secondes += 1
	if secondes == 60:
		secondes = 0; minutes += 1
	
	enregistrer_chrono(	str(minutes).pad_zeros(2),
						str(secondes).pad_zeros(2),
						str(decisecondes))

func _maj_coups() -> void:
	"Met à jour le nombre de coups du plateau en direct"
	var nb_coups = SauvegardeBddJoueursService.lire_nombre_coups()
	var pluriel = "" if nb_coups < 2 else "s"
	enregistrer_coups(str(nb_coups) + " Coup" + pluriel)

# ########
# Usine >>
func _on_bouton_recommencer_pressed() -> void:
	$Bandeau/BoutonRecommencer.hide()
	$Bandeau/BoutonPasser.hide()
	abandon.emit()

func _on_bouton_passer_pressed() -> void:
	$Bandeau/BoutonRecommencer.hide()
	$Bandeau/BoutonPasser.hide()
	passe.emit()

func _on_fond_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# LogService.log_debug("Clique souris sur le fond du plateau")
			# Parcourir les piles et déselectionner la pile (comme "timeout" sur la selection)
			deselection_pile.emit()
