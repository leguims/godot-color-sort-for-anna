extends Node

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
	var lecture_liste_des_joueurs = FichiersJsonService.read_json_file("user://liste_des_joueurs.json")
	if lecture_liste_des_joueurs:
		liste_des_joueurs = lecture_liste_des_joueurs.duplicate(true)
		LogService.log_debug("liste_des_joueurs = ", liste_des_joueurs)
	else:
		LogService.log_erreur("Erreur de lecture de la sauvegarde de la liste des joueurs")

func _enregistrer_la_liste_des_joueurs() -> void:
	FichiersJsonService.write_json_file("user://liste_des_joueurs.json", liste_des_joueurs.duplicate(true))
	LogService.log_debug("Liste des joueurs sauvegardée")


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

func supprimer_un_joueur(nom_joueur : String, fichier_joueur : String) -> bool:
	"""Supprime un joueur"""
	if not nom_joueur:
		return false
	if not fichier_joueur:
		return false
	# Vérifie que le nom est libre
	if le_joueur_existe(nom_joueur):
		# Effacer le fichier
		FichiersJsonService.remove_json_file(fichier_joueur)
		# Crée le compte à effacer
		var compte = {
			'nom': nom_joueur,
			'fichier_sauvegarde': fichier_joueur
		}
		liste_des_joueurs.erase(compte)
		_enregistrer_la_liste_des_joueurs()
	return true
