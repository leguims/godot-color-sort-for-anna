extends Node

class_name MenuPlateau

signal abandon
signal deselection_pile

var chronometre : int = 0

# #############
# API Gameplay
func enregistrer_gameplay(gameplay : String):
	$Top/Gameplay.text = gameplay

func enregistrer_chrono(chrono : String):
	$Top/Chrono.text = chrono

func enregistrer_coups(coups : String):
	$Top/Coups.text = coups

func show():
	$Fond.show()
	$Top.show()
	$Top/BoutonAbandonner.show()

func hide():
	$Fond.hide()
	$Top.hide()
	$Top/BoutonAbandonner.hide()

func cacher_accueil():
	hide()
	$Fond.show()

func demarrer_chronometre():
	chronometre = -1
	_on_chronometre_timeout()

func arreter_chronometre():
	$Chronometre.stop()

# ########
# Usine >>
func _on_bouton_abandonner_pressed() -> void:
	$Top/BoutonAbandonner.hide()
	abandon.emit()

func _on_fond_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# LogService.log_debug("Clique souris sur le fond du plateau")
			# Parcourir les piles et déselectionner la pile (comme "timeout" sur la selection)
			deselection_pile.emit()

func _on_chronometre_timeout() -> void:
	# Relance le chronometre
	$Chronometre.start()
	# Incrémente le compteur
	chronometre += 1
	# MàJ affichage
	enregistrer_chrono(str(chronometre)+'s')
