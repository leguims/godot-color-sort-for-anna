###############################################
# Gestion des sauvegardes de joueurs
###############################################

extends Node

var fichiers_json_gd = preload("res://Scenes/Sauvegarde/fichiers_json.gd").new()

###############################################
# Gestion des niveaux et des plateaux à jouer
###############################################
var sauvegarde_joueur = {
	'nom': 'Alain Konu',
	'niveau': null,
	'plateaux': {  },
	'nombre_de_parties': {  },
	'durees': {  },
	'ascensions': [ ]
}

var fichier_sauvegarde = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# réalisé lors du choix du joueur
	pass

func _lire_sauvegarde_joueur(fichier : String) -> bool:
	var lecture_sauvegarde_joueur = fichiers_json_gd.read_json_file("user://" + fichier)
	if lecture_sauvegarde_joueur:
		fichier_sauvegarde = fichier
		sauvegarde_joueur = lecture_sauvegarde_joueur.duplicate(true)
		print("sauvegarde_joueur = ", sauvegarde_joueur)
		return true
	else:
		# CONVERSION [V0.3.0 -> V0.3.1]
		var ancienne_sauvegarde = fichiers_json_gd.read_json_file("user://sauvegarde.json")
		if ancienne_sauvegarde:
			# Convertir l'ancienne sauvegarde vers ce nouveau fichier
			var numero_joueur = 0
			for joueur in ancienne_sauvegarde:
				if joueur and 'nom' in joueur:
					var nom_fichier = 'sauvegarde_joueur_' + str(numero_joueur).pad_zeros(2) + '.json'
					ajouter_un_nouveau_joueur(joueur.get('nom'), nom_fichier, int(joueur.get('niveau')))

					# Ajouter chaque champs
					sauvegarde_joueur = joueur.duplicate(true)
					_enregistrer_sauvegarde_joueur()
					
					numero_joueur += 1
					print("[V0.3.0 -> V0.3.1] Conversion de l'ancien fichier 'sauvegarde.json' vers '" + nom_fichier + "'")
					# TODO : Effacer l'ancien fichier 'sauvegarde.json'
			var deuxieme_lecture_sauvegarde_joueur = fichiers_json_gd.read_json_file("user://" + fichier)
			if deuxieme_lecture_sauvegarde_joueur:
				fichier_sauvegarde = fichier
				sauvegarde_joueur = deuxieme_lecture_sauvegarde_joueur.duplicate(true)
				print("(Apres conversions) sauvegarde_joueur = ", sauvegarde_joueur)
				return true
		else:
			fichier_sauvegarde = ""
			print("Erreur de lecture de la sauvegarde du joueur actuel (user://" + fichier + ")")
	return false

func _enregistrer_sauvegarde_joueur() -> void:
	if fichier_sauvegarde:
		fichiers_json_gd.write_json_file("user://" + fichier_sauvegarde, sauvegarde_joueur.duplicate(true))
		print("Progression sauvegardée")

func le_joueur_existe() -> bool:
	return fichier_sauvegarde != ""

func choisir_le_joueur(nom : String, fichier : String) -> bool:
	return  _lire_sauvegarde_joueur(fichier) and nom == lire_nom_joueur()

func liberer_le_joueur():
	fichier_sauvegarde = ""

func ajouter_un_nouveau_joueur(nom_nouveau_joueur : String, nom_nouveau_fichier : String, niveau_initial : int) -> bool:
	"""Crée un nouveau joueur si le nom est libre"""
	# Vérifie que le nom est libre
	if not nom_nouveau_joueur:
		return false
	if not nom_nouveau_fichier or fichiers_json_gd.json_file_exists(nom_nouveau_fichier):
		return false
	# Crée le compte et l'enregistre
	sauvegarde_joueur = {
		'nom': nom_nouveau_joueur,
		'niveau': niveau_initial,
		'plateaux': {  },
		'nombre_de_parties': {  },
		'durees': {  },
		'ascensions': [ ]
	}
	fichier_sauvegarde = nom_nouveau_fichier
	_enregistrer_sauvegarde_joueur()
	return true


###############################################
# Nom
###############################################

func lire_nom_joueur() -> String:
	if le_joueur_existe():
		return sauvegarde_joueur['nom']
	return ""

###############################################
# Niveau courant
###############################################

func modifier_niveau_joueur(niveau : int) -> void:
	if le_joueur_existe():
		sauvegarde_joueur['niveau'] = niveau
		_enregistrer_sauvegarde_joueur()

func incrementer_niveau_courant() -> void:
	if le_joueur_existe():
		var str_niveau = str(lire_niveau_joueur())
		if str_niveau not in sauvegarde_joueur.get('plateaux'):
			sauvegarde_joueur['plateaux'][str_niveau] = -1
		sauvegarde_joueur['plateaux'][str_niveau] += 1
		_enregistrer_sauvegarde_joueur()

func lire_niveau_joueur() -> int:
	if le_joueur_existe() and sauvegarde_joueur.get('niveau'):
		return sauvegarde_joueur['niveau']
	return 0

###############################################
# Ascension
###############################################

func ajouter_ascension_joueur() -> void:
	"""Cette méthode enregistre la date courante dans les ascensions"""
	if le_joueur_existe():
		sauvegarde_joueur['ascensions'].append(Time.get_unix_time_from_system()) # Timestamp
		_enregistrer_sauvegarde_joueur()

func lire_nombre_ascension_joueur() -> int:
	if le_joueur_existe():
		return len(sauvegarde_joueur['ascensions'])
	return 0

###############################################
# Indice des plateaux non joués
###############################################

func incrementer_indice_plateau_joueur_pour_niveau_courant() -> void:
	if le_joueur_existe():
		var str_niveau = str(lire_niveau_joueur())
		if str_niveau not in sauvegarde_joueur.get('plateaux'):
			sauvegarde_joueur['plateaux'][str_niveau] = -1
		sauvegarde_joueur['plateaux'][str_niveau] += 1
		_enregistrer_sauvegarde_joueur()

func lire_indice_plateau_joueur_pour_niveau_courant() -> int:
	if le_joueur_existe():
		var str_niveau = str(lire_niveau_joueur())
		if str_niveau in sauvegarde_joueur.get('plateaux'):
			return sauvegarde_joueur['plateaux'][str_niveau]
	return -1

func lire_indice_plateau_joueur_pour_niveau(niveau : int) -> int:
	if le_joueur_existe():
		var str_niveau = str(niveau)
		if str_niveau in sauvegarde_joueur.get('plateaux'):
			return sauvegarde_joueur['plateaux'][str_niveau]
	return -1


###############################################
# Nombre de parties
###############################################

func incrementer_nombre_de_parties_joueur_pour_niveau_courant() -> void:
	if le_joueur_existe():
		var str_niveau = str(lire_niveau_joueur())
		if str_niveau not in sauvegarde_joueur.get('nombre_de_parties'):
			sauvegarde_joueur['nombre_de_parties'][str_niveau] = 0
		sauvegarde_joueur['nombre_de_parties'][str_niveau] += 1
		_enregistrer_sauvegarde_joueur()

func lire_nombre_de_parties_joueur_pour_niveau_courant() -> int:
	if le_joueur_existe():
		var str_niveau = str(lire_niveau_joueur())
		if str_niveau in sauvegarde_joueur.get('nombre_de_parties'):
			return sauvegarde_joueur['nombre_de_parties'][str_niveau]
	return 0

func lire_nombre_de_parties_joueur_pour_niveau(niveau : int) -> int:
	if le_joueur_existe():
		var str_niveau = str(niveau)
		if str_niveau in sauvegarde_joueur.get('nombre_de_parties'):
			return sauvegarde_joueur['nombre_de_parties'][str_niveau]
	return 0



###############################################
# Durée de partie
###############################################

func ajouter_duree_de_partie_joueur_pour_niveau_courant(duree_en_ms : int) -> void:
	if le_joueur_existe():
		var str_niveau = str(lire_niveau_joueur())
		if str_niveau not in sauvegarde_joueur.get('durees'):
			sauvegarde_joueur['durees'][str_niveau] = 0
		sauvegarde_joueur['durees'][str_niveau] += duree_en_ms
		_enregistrer_sauvegarde_joueur()

func lire_duree_de_partie_joueur_pour_niveau_courant() -> int:
	if le_joueur_existe():
		var str_niveau = str(lire_niveau_joueur())
		if str_niveau in sauvegarde_joueur.get('durees'):
			return sauvegarde_joueur['durees'][str_niveau]
	return 0

func lire_duree_de_partie_joueur_pour_niveau(niveau : int) -> int:
	if le_joueur_existe():
		var str_niveau = str(niveau)
		if str_niveau in sauvegarde_joueur.get('durees'):
			return sauvegarde_joueur['durees'][str_niveau]
	return 0

func lire_le_temps_du_joueur(niveau : int) -> String:
	"""Formater la durée en une chaîne de caractères lisible."""
	if le_joueur_existe():
		if str(niveau) in sauvegarde_joueur.get('durees'):
			var duree_sec = sauvegarde_joueur.get('durees').get(str(niveau)) / 1000
			if duree_sec < 60:
				return str(duree_sec) + " secondes"
			else:
				var minutes = duree_sec / 60
				var secondes = duree_sec % 60

				var heures = minutes / 60
				minutes = minutes % 60

				var jours = heures / 60
				heures = heures % 60
				if jours > 0:
					return str(jours) + " jours " + str(heures) + " heures"
				elif heures > 0:
					return str(heures) + " heures " + str(minutes) + " minutes"
				else:
					return str(minutes) + " minutes " + str(secondes) + " secondes"
	return ""
