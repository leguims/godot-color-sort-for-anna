extends Node

var fichiers_json_gd = preload("res://Scenes/Sauvegarde/fichiers_json.gd").new()

var liste_des_joueurs = [
	{
		'nom': 'Alain Konu',
		'fichier_sauvegarde': 'sauvegarde_joueur_00.json'
	}
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialiser_la_liste_des_joueurs()

func _initialiser_la_liste_des_joueurs() -> void:
	var lecture_liste_des_joueurs = fichiers_json_gd.read_json_file("user://liste_des_joueurs.json")
	if lecture_liste_des_joueurs:
		liste_des_joueurs = lecture_liste_des_joueurs.duplicate(true)
		print("liste_des_joueurs = ", liste_des_joueurs)
	else:
		# CONVERSION [V0.3.0 -> V0.3.1]
		var ancienne_sauvegarde = fichiers_json_gd.read_json_file("user://sauvegarde.json")
		if ancienne_sauvegarde:
			# Convertir l'ancienne sauvegarde vers ce nouveau fichier
			liste_des_joueurs = []
			for joueur in ancienne_sauvegarde:
				ajouter_un_nouveau_joueur(joueur.get('nom'))
			print("[V0.3.0 -> V0.3.1] Conversion de l'ancien fichier 'sauvegarde.json' vers 'liste_des_joueurs.json'")
			# TODO : Effacer l'ancien fichier 'sauvegarde.json'
			
			# Conversion du fichier 'sauvegarde.json' pour 'BddJoueurs'
			for nom in retourner_la_liste_des_joueurs():
				var nom_fichier = retourner_le_fichier_de_sauvegarde(nom)
				print(nom_fichier)
				SauvegardeBddJoueurs.choisir_le_joueur(nom, nom_fichier)
				print('fin')
		else:
			printerr("Erreur de lecture de la sauvegarde de la liste des joueurs")

func _enregistrer_la_liste_des_joueurs() -> void:
	fichiers_json_gd.write_json_file("user://liste_des_joueurs.json", liste_des_joueurs.duplicate(true))
	print("Liste des joueurs sauvegardée")


func le_joueur_existe(nom_joueur : String) -> bool:
	"""Verifie si le joueur existe"""
	for joueur in liste_des_joueurs:
		if joueur.get('nom') == nom_joueur:
			return true
	return false

func retourner_le_fichier_de_sauvegarde(nom_joueur : String) -> String:
	"""Retourne le nom du fichier de sauvegarde du joueur"""
	for joueur in liste_des_joueurs:
		if joueur.get('nom') == nom_joueur:
			return joueur.get('fichier_sauvegarde')
	return ""

func retourner_la_liste_des_joueurs() -> Variant:
	var liste_noms_des_joueurs = []
	for joueur in liste_des_joueurs:
		liste_noms_des_joueurs.append(joueur.get('nom'))
	return liste_noms_des_joueurs.duplicate(false)

func ajouter_un_nouveau_joueur(nom_nouveau_joueur : String) -> bool:
	"""Crée un nouveau joueur si le nom est libre"""
	# Vérifie que le nom est libre
	if not nom_nouveau_joueur:
		return false
	if le_joueur_existe(nom_nouveau_joueur):
		return false
	# Crée le compte et l'enregistre
	var compte = {
		'nom': nom_nouveau_joueur,
		'fichier_sauvegarde': 'sauvegarde_joueur_' + str(len(liste_des_joueurs)).pad_zeros(2) + '.json'
	}
	liste_des_joueurs.append(compte.duplicate(true))
	_enregistrer_la_liste_des_joueurs()
	return true
