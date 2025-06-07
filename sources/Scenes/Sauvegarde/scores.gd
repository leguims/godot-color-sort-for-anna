extends Node

var fichiers_json_gd = preload("res://Scenes/Sauvegarde/fichiers_json.gd").new()

var liste_des_scores = [
	{
		'nom': 'Alain Konu',
		'rang': 1,
		'score': 0,
		'score_txt': "0"
	}
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialiser_la_liste_des_scores()

func _initialiser_la_liste_des_scores() -> void:
	var lecture_liste_des_scores = fichiers_json_gd.read_json_file("user://scores.json")
	if lecture_liste_des_scores:
		liste_des_scores = lecture_liste_des_scores.duplicate(true)
		print("liste_des_scores = ", liste_des_scores)
		
		# CONVERSION [V0.3.0 -> V0.3.1]
		# 'Score' est le dernier lecteur de "user://sauvegarde.json" à s'initialiser
		# Effacer le fichier de sauvegarde obsolete "user://sauvegarde.json"
		fichiers_json_gd.remove_json_file("user://sauvegarde.json")
	else:
		# CONVERSION [V0.3.0 -> V0.3.1]
		var ancienne_sauvegarde = fichiers_json_gd.read_json_file("user://sauvegarde.json")
		if ancienne_sauvegarde:
			# Convertir l'ancienne sauvegarde vers ce nouveau fichier
			liste_des_scores = []
			for joueur in ancienne_sauvegarde:
				ajouter_un_nouveau_joueur(joueur.get('nom'))
			_mettre_a_jour_les_rangs()
			print("[V0.3.0 -> V0.3.1] Conversion de l'ancien fichier 'sauvegarde.json' vers 'scores.json'")
			# TODO : Effacer l'ancien fichier 'sauvegarde.json'
		else:
			printerr("Erreur de lecture de la sauvegarde des scores")

func _enregistrer_la_liste_des_scores() -> void:
	fichiers_json_gd.write_json_file("user://scores.json", liste_des_scores.duplicate(true))
	print("Scores sauvegardés")


func _retourner_le_joueur(nom_joueur : String) -> Dictionary:
	for joueur in liste_des_scores:
		if joueur.get('nom') == nom_joueur:
			return joueur
	return {}

func le_joueur_existe(nom_joueur : String) -> bool:
	"""Verifie si le joueur existe"""
	return _retourner_le_joueur(nom_joueur) != {}

func ajouter_un_nouveau_joueur(nom_nouveau_joueur : String) -> bool:
	"""Crée un nouveau joueur si le nom est libre"""
	# Vérifie que le nom est libre
	if not nom_nouveau_joueur:
		return false
	if le_joueur_existe(nom_nouveau_joueur):
		return false
	# Crée le score et l'enregistre
	var score = {
		'nom': nom_nouveau_joueur,
		'rang': len(liste_des_scores)+1,
		'score': 0,
		'score_txt': "0"
	}
	liste_des_scores.append(score.duplicate(true))
	_mettre_a_jour_les_rangs()
	return true

func lire_rang_joueur(nom_joueur : String) -> int:
	var joueur = _retourner_le_joueur(nom_joueur)
	if joueur:
		return joueur.get('rang')
	return 0

func lire_le_trophee_du_joueur(nom_joueur : String) -> String:
	"""Cette méthode retourne le trophé du joueur"""
	var rang = lire_rang_joueur(nom_joueur)
	return lire_le_trophee_du_rang(rang)

func lire_le_trophee_du_rang(rang : int) -> String:
	"""Cette méthode retourne le trophé du rang"""
	# Unicode : https://www.unicode.org/emoji/charts/emoji-list.html
	var trophees = {
		1: String.chr(0x1F3C6), # 1er
		2: String.chr(0x1F948), # 2eme
		3: String.chr(0x1F949)  # 3eme
	}
	return trophees.get(rang, String.chr(0x25FD)) # = hors podium

func lire_score_joueur(nom_joueur : String) -> int:
	var joueur = _retourner_le_joueur(nom_joueur)
	if joueur:
		return joueur.get('score')
	return 0

func lire_score_txt_joueur(nom_joueur : String) -> String:
	var joueur = _retourner_le_joueur(nom_joueur)
	if joueur:
		return joueur.get('score_txt')
	return "0"

func modifier_score_joueur(nom_joueur : String, nouveau_score : int) -> void:
	var joueur = _retourner_le_joueur(nom_joueur)
	if joueur:
		joueur['score'] = nouveau_score
		joueur['score_txt'] = nombre_avec_separateur_de_milliers(nouveau_score, '.')
		_mettre_a_jour_les_rangs()

func incrementer_score_joueur(nom_joueur : String, increment_score : int) -> void:
	var joueur = _retourner_le_joueur(nom_joueur)
	if joueur:
		joueur['score'] += increment_score
		joueur['score_txt'] = nombre_avec_separateur_de_milliers(joueur.get('score'), '.')
		_mettre_a_jour_les_rangs()

func retourner_classement() -> Array:
	"""Retourner une liste de score avec :
		[
			{'rang': 1, 'score': 99999, 'score_txt': '99 999', 'nom': 'Joueur2'},
			{'rang': 2, 'score': 12345, 'score_txt': '12 345', 'nom': 'Joueur1'},
			{'rang': 2, 'score': 12345, 'score_txt': '12 345', 'nom': 'Joueur3'}
		]"""
	var classement = []
	for rang in range(1, len(liste_des_scores)+1):
		for joueur in liste_des_scores:
			if joueur.get('rang') == rang:
				classement.append(joueur.duplicate(true))
	return classement

func _mettre_a_jour_les_rangs() -> void:
	"""Cette méthode met à jour les rangs dans la liste des scores"""
	# Cartographier les scores et les joueurs
	var liste_score_decroissant = []
	var dico_score_nom_joueur = {}
	for joueur in liste_des_scores:
		var nom_joueur = joueur.get('nom')
		var score = int(joueur.get('score'))
		if score not in liste_score_decroissant:
			liste_score_decroissant.append(score)
		if score not in dico_score_nom_joueur:
			dico_score_nom_joueur[score] = [nom_joueur]
		else:
			# Score égalité
			dico_score_nom_joueur[score].append(nom_joueur)
	# Classer les scores par ordre decraoissant
	liste_score_decroissant.sort() # Classement croissant des scores
	liste_score_decroissant.reverse() # Classement decroissant des scores
	
	# Attribuer les rangs
	var rang : int = 1
	for score in liste_score_decroissant:
		for joueur in liste_des_scores:
			if joueur.get('score') == score:
				joueur['rang'] = rang
		rang += len(dico_score_nom_joueur[score])
	
	_enregistrer_la_liste_des_scores()

func nombre_avec_separateur_de_milliers(nombre : int, separateur : String) -> String:
	var nombre_texte = ''
	for division in [1_000_000_000, 1_000_000, 1_000, 1]:
		var dividende = roundi(nombre / division)
		if dividende or nombre_texte:
			# Dès que nombre_texte est peuplé, écrire les zéros.
			if nombre_texte:
				nombre_texte += separateur
				nombre_texte += str(dividende).pad_zeros(3)
			else :
				# Premiere partie du nombre : pas de séparateur entre milliers ou de remplissage de zero.
				nombre_texte += str(dividende)
			nombre -= dividende * division
	return nombre_texte
