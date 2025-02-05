extends CanvasLayer

# Notifie la scene `Plateau` que le bouton est pressé
signal commencer_plateau

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GestionScore.initialiser_les_plateaux()
	GestionScore.lire_sauvegarde_joueurs()
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
	$EditeurPlateau/SaisieEditionPlateau.text = GestionScore.lire_plateau_courant()
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
	
	# Mettre à jour les plateaux à jouer
	GestionScore.gagner()
	if GestionScore.est_victoire_dernier_plateau():
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
	
	# Mettre à jour les plateaux à jouer
	GestionScore.abandonner()
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
	GestionScore.commencer()
	commencer_plateau.emit()

func _afficher_message(texte : String, temporaire : bool = true):
	$Message.hide()
	$Message.text = texte
	$Message.show()
	if temporaire:
		$TempoMessage.start()
