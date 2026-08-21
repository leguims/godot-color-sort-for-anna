extends Node

var liste_des_joueurs = [
	{
		'indice': 0,
		'nom': 'Alain Konu',
		'fichier_sauvegarde': 'sauvegarde_joueur_00.json'
	}
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialiser_la_liste_des_joueurs()
	# Maintient de compatibilité
	_corriger_absence_indice()

func _initialiser_la_liste_des_joueurs() -> void:
	var lecture_liste_des_joueurs = FichiersJsonService.read_json_file("user://liste_des_joueurs.json")
	if lecture_liste_des_joueurs:
		liste_des_joueurs = lecture_liste_des_joueurs.duplicate(true)
		LogService.log_debug("liste_des_joueurs = ", liste_des_joueurs)
	else:
		LogService.log_erreur("Erreur de lecture de la sauvegarde de la liste des joueurs")

func _corriger_absence_indice() -> void:
	if not liste_des_joueurs.is_empty():
		var maj: bool = false
		for joueur in liste_des_joueurs:
			if 'indice' not in joueur:
				var indice_str = joueur.get('fichier_sauvegarde').remove_chars('sauvegarde_joueur_').remove_chars('.json')
				joueur['indice'] = indice_str.to_int()
				maj = true
		if maj:
			_enregistrer_la_liste_des_joueurs()

func _enregistrer_la_liste_des_joueurs() -> bool:
	var succes = FichiersJsonService.write_json_file("user://liste_des_joueurs.json", liste_des_joueurs.duplicate(true))
	if succes:
		LogService.log_debug("Liste des joueurs sauvegardée")
	return succes

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

	# Definir l'indice du joueur
	var indice: int = 0
	if not liste_des_joueurs.is_empty():
		var dernier_joueur: Dictionary = liste_des_joueurs.back()
		indice = dernier_joueur.get('indice', 0) + 1
	# Crée le compte et l'enregistre
	var compte = {
		'indice': indice,
		'nom': nom_nouveau_joueur,
		'fichier_sauvegarde': 'sauvegarde_joueur_' + str(indice).pad_zeros(2) + '.json'
	}
	liste_des_joueurs.append(compte.duplicate(true))
	if _enregistrer_la_liste_des_joueurs():
		return true
	liste_des_joueurs.pop_back()
	return false

func supprimer_un_joueur(nom_joueur : String, fichier_joueur : String) -> bool:
	"""Supprime un joueur"""
	var compte_a_restaurer: Dictionary = {}
	var indice_a_restaurer: int = -1
	for indice in range(liste_des_joueurs.size()):
		var joueur = liste_des_joueurs[indice]
		if joueur.get('nom') == nom_joueur and joueur.get('fichier_sauvegarde') == fichier_joueur:
			compte_a_restaurer = joueur.duplicate(true)
			indice_a_restaurer = indice
			break
	# Effacer le joueur
	var succes: bool = supprimer_un_joueur_orphelin_de_sauvegarde(nom_joueur, fichier_joueur)
	if succes:
		# Effacer le fichier
		succes = FichiersJsonService.remove_json_file("user://" + fichier_joueur)
		if not succes and indice_a_restaurer >= 0:
			liste_des_joueurs.insert(indice_a_restaurer, compte_a_restaurer)
			_enregistrer_la_liste_des_joueurs()
	return succes

func supprimer_un_joueur_orphelin_de_sauvegarde(nom_joueur : String, fichier_joueur : String) -> bool:
	"""Supprime un joueur qui pointe sur un fichier à probleme"""
	if not nom_joueur:
		return false
	if not fichier_joueur:
		return false
	for joueur in liste_des_joueurs:
		if joueur.get('nom') == nom_joueur and joueur.get('fichier_sauvegarde') == fichier_joueur:
			var indice = liste_des_joueurs.find(joueur)
			liste_des_joueurs.erase(joueur)
			if _enregistrer_la_liste_des_joueurs():
				return true
			# Restaurer le compte en mémoire si l'enregistrement de la suppression échoue.
			liste_des_joueurs.insert(indice, joueur)
			return false
	return false
