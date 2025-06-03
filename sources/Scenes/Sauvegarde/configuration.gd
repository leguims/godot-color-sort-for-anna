####################################
# Gestion de la confiruation du jeu
####################################

extends Node

# class_name Configuration

var fichiers_json_gd = preload("res://Scenes/Sauvegarde/fichiers_json.gd").new()

# Dico : {'caracteristique': reglage}
var configuration_du_jeu = {
	'musiques': true,
	'effets sonores': true,
	'vibrations': true
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialiser_la_configuration()


func _initialiser_la_configuration() -> void:
	# Lire la configuration du jeu
	var fichier_configuration = fichiers_json_gd.read_json_file("user://configuration_du_jeu.json")
	# print(fichier_configuration)
	
	# Copier les niveaux lus
	if fichier_configuration:
		if 'musiques' in fichier_configuration:
			configuration_du_jeu['musiques'] = fichier_configuration.get('musiques')
		if 'effets sonores' in fichier_configuration:
			configuration_du_jeu['effets sonores'] = fichier_configuration.get('effets sonores')
		if 'vibrations' in fichier_configuration:
			configuration_du_jeu['vibrations'] = fichier_configuration.get('vibrations')
	print("fichier_configuration = ", fichier_configuration)

func _enregistrer_la_configuration() -> void:
	print("configuration.gd : _enregistrer_la_configuration")
	fichiers_json_gd.write_json_file("user://configuration_du_jeu.json", configuration_du_jeu.duplicate(true))
	print("Configuration sauvegardée")

func activer_musiques() -> void:
	print("configuration.gd : activer_musiques")
	if not configuration_du_jeu.get('musiques', true):
		configuration_du_jeu['musiques'] = true
		_enregistrer_la_configuration()

func activer_effets_sonores() -> void:
	print("configuration.gd : activer_effets_sonores")
	if not configuration_du_jeu.get('effets sonores', true):
		configuration_du_jeu['effets sonores'] = true
		_enregistrer_la_configuration()

func activer_vibrations() -> void:
	print("configuration.gd : activer_vibrations")
	if not configuration_du_jeu.get('vibrations', true):
		configuration_du_jeu['vibrations'] = true
		_enregistrer_la_configuration()

func desactiver_musiques() -> void:
	if configuration_du_jeu.get('musiques', true):
		configuration_du_jeu['musiques'] = false
		_enregistrer_la_configuration()

func desactiver_effets_sonores() -> void:
	if configuration_du_jeu.get('effets sonores', true):
		configuration_du_jeu['effets sonores'] = false
		_enregistrer_la_configuration()

func desactiver_vibrations() -> void:
	if configuration_du_jeu.get('vibrations', true):
		configuration_du_jeu['vibrations'] = false
		_enregistrer_la_configuration()

func musiques_sont_actives() -> bool:
	return configuration_du_jeu.get('musiques', true)

func effets_sonores_sont_actifs() -> bool:
	return configuration_du_jeu.get('effets sonores', true)

func vibrations_sont_actives() -> bool:
	return configuration_du_jeu.get('vibrations', true)
