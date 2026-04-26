extends Node

const MUSIQUE_SOLVE_THE_PUZZLE = preload("res://Art/Musique/Solve The Puzzle.ogg")
const MUSIQUE_DREAMING = preload("res://Art/Musique/Dreaming.ogg")
const MUSIQUE_GREAT_LITTLE_CHALLENGE = preload("res://Art/Musique/Great Little Challenge.ogg")
const MUSIQUE_HUMBLE_MATCH = preload("res://Art/Musique/Humble Match.ogg")
const MUSIQUE_SU_TURNO = preload("res://Art/Musique/Su Turno.ogg")
const MUSIQUE_THE_THREE_PRINCESSES_OF_LILAC_MEADOW = preload("res://Art/Musique/The Three Princesses of Lilac Meadow.ogg")

const SON_COMMENCER = preload("res://Art/EffetSonore/game-start.mp3")
const SON_FIN_DE_PARTIE = preload("res://Art/EffetSonore/win.mp3")
const SON_ECHEC = preload("res://Art/EffetSonore/fail-jingle.mp3")

var musique: AudioStreamPlayer
var effet_sonore: AudioStreamPlayer

####################################
# Musiques
####################################

func _ready() -> void:
	musique = AudioStreamPlayer.new()
	add_child(musique)

	effet_sonore = AudioStreamPlayer.new()
	add_child(effet_sonore)

func _musique_play(stream: AudioStream):
	musique.stream = stream
	musique.play()

func _musique_stop():
	musique.stop()

func _effet_sonore_play(stream: AudioStream):
	effet_sonore.stream = stream
	effet_sonore.play()

# API externe
func jouer_la_musique():
	if not SauvegardeConfigurationService.musiques_sont_actives():
		return
	var pourcentage_ascension = SauvegardeBddJoueursService.lire_pourcentage_ascension_realise()
	if pourcentage_ascension <= 100.*1/6:
		_musique_play(MUSIQUE_DREAMING)
	elif pourcentage_ascension <= 100.*2/6:
		_musique_play(MUSIQUE_SU_TURNO)
	elif pourcentage_ascension <= 100.*3/6:
		_musique_play(MUSIQUE_THE_THREE_PRINCESSES_OF_LILAC_MEADOW)
	elif pourcentage_ascension <= 100.*4/6:
		_musique_play(MUSIQUE_SOLVE_THE_PUZZLE)
	elif pourcentage_ascension <= 100.*5/6:
		_musique_play(MUSIQUE_HUMBLE_MATCH)
	else:
		_musique_play(MUSIQUE_GREAT_LITTLE_CHALLENGE)

func arreter_la_musique():
	if SauvegardeConfigurationService.musiques_sont_actives():
		_musique_stop()

func son_demarrer_la_partie():
	if SauvegardeConfigurationService.effets_sonores_sont_actifs():
		_effet_sonore_play(SON_COMMENCER)

func son_abandonner_la_partie():
	if SauvegardeConfigurationService.effets_sonores_sont_actifs():
		_effet_sonore_play(SON_ECHEC)

func son_gagner_la_partie():
	if SauvegardeConfigurationService.effets_sonores_sont_actifs():
		_effet_sonore_play(SON_FIN_DE_PARTIE)
