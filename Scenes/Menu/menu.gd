extends CanvasLayer

# Notifie la scene `Plateau` que le bouton est pressé
signal commencer_plateau

var plateau_actuel = 0
var plateaux = [
	"AA .BB .CC .ABC",
	"AB .BA .BA ",
	"AB .AC .CBA.CB ",
	#"ABBA.AB  .AB  ", # IMPOSSIBLE => TODO : corriger bug sur les outils python
	#"BAAB.BA  .BA  ", # IMPOSSIBLE => TODO : corriger bug sur les outils python
	"AAB .AB  .BBA ",
	"ABB  .BA   .BBAAA"
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_tempo_message_timeout() -> void:
	$Message.hide()

func afficher_accueil():
	_afficher_message("Range les couleurs!", false)
	# Attendre l'échéance d'une temporisation libre
	await get_tree().create_timer(1.0).timeout
	$EditeurPlateau/SaisieEditionPlateau.text = plateaux[plateau_actuel]
	$EditeurPlateau.show()
	await get_tree().create_timer(1.0).timeout
	$BoutonCommencer.show()

func afficher_victoire():
	_afficher_message("Bravo!")
	# Attendre l'échéance de la temporisation
	await $TempoMessage.timeout

	_afficher_message("Fin de Partie")
	# Attendre l'échéance de la temporisation
	await $TempoMessage.timeout
	
	# Victoire : passer au niveau suivant
	if plateau_actuel < (len(plateaux)-1):
		plateau_actuel += 1
	elif plateau_actuel == (len(plateaux)-1):
		_afficher_message("C'était le dernier plateau!")
		await $TempoMessage.timeout
		_afficher_message("Vous êtes au sommet...")
		await $TempoMessage.timeout
		_afficher_message("...de l'Everest!")
		await $TempoMessage.timeout
	afficher_accueil()

func afficher_abandon():
	_afficher_message("Perdu!")
	await $TempoMessage.timeout
	
	_afficher_message("Fin de Partie")
	await $TempoMessage.timeout
	
	if 0 < plateau_actuel:
		plateau_actuel -= 1
	afficher_accueil()

func afficher_plateau_invalide():
	_afficher_message("Plateau Invalide!")
	# Attendre l'échéance de la temporisation
	await $TempoMessage.timeout
	afficher_accueil()

func cacher_accueil():
	$Message.hide()
	$EditeurPlateau.hide()
	$BoutonCommencer.hide()

func _on_bouton_commencer_pressed() -> void:
	commencer_plateau.emit()

func _afficher_message(texte : String, temporaire : bool = true):
	$Message.hide()
	$Message.text = texte
	$Message.show()
	if temporaire:
		$TempoMessage.start()
