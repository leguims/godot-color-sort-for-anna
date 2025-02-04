extends Node

###############################################
# Gestion des niveaux et des plateaux à jouer
###############################################
var nombre_de_partie = 0
var niveau_actuel = 3
var plateau_actuel = { '3': 0 }
var plateau_victoire_dernier_plateau = false

# Dico : {'difficulte': [liste_plateaux]}
var plateau_liste_difficulte = {
	'3': [
		"AA .BB .CC .ABC",
		"AB .BA .BA ",
		"AB .AC .CBA.CB ",
		"AAB .AB  .BBA ",
		"ABB  .BA   .BBAAA",
		"ABA.BAB.   ",
		"ABA.ABC.CBC.   ",
		"BABA.BA  .BA  ",
		"ABAB .ABAB .AB   "
	]
}

func initialiser_les_plateaux() -> void:
	# Lire la liste des plateaux classés par niveaux
	var fichier_plateaux = _read_json_file("res://Solutions_classees.json")
	# print(fichier_plateaux)
	
	# Copier les niveaux lus
	if fichier_plateaux:
		if 'liste difficulte des plateaux' in fichier_plateaux:
			var dico_difficulte = fichier_plateaux.get('liste difficulte des plateaux')
			for difficulte in dico_difficulte.keys():
				# Copie tous les niveaux, sauf 'None'
				if difficulte not in ['None', '0', '1', '2', '3'] :
					plateau_liste_difficulte[difficulte] = dico_difficulte.get(difficulte).duplicate()
				print("Difficulté : ", difficulte)
				var cpt = 0
				for plateau in dico_difficulte.get(difficulte):
					print("   - plateaux : ", plateau)
					cpt += 1
					if cpt >= 5:
						break

func _read_json_file(chemin) -> Variant:
	var fichier = null
	var contenu_texte = null
	
	# Lecture du fichier
	if FileAccess.file_exists(chemin):
		fichier = FileAccess.open(chemin, FileAccess.READ)
		if not fichier:
			print("read_json_file : ERREUR sur le chemin : ", chemin)
			return null
		contenu_texte = fichier.get_as_text()
		if not contenu_texte :
			print("read_json_file : ERREUR sur le contenu : ", chemin, " erreur = ", fichier.get_as_text())
			return null
		fichier.close()
		# print("contenu_texte = ", contenu_texte)
		
		# Decodage JSON
		var json = JSON.new()
		var error = json.parse(contenu_texte)
		# print("error = ", error)
		if error == OK:
			return json.get_data()
		print("read_json_file : ERREUR sur le décodage JSON: ", json.get_error_message(), " in ", chemin, " at line ", json.get_error_line())
	else:
		print("read_json_file : ERREUR, le fichier '", chemin, "' n'existe pas ")
	return null

func _write_json_file(chemin, contenu) -> void:
	var fichier = null
	
	# Ouverture du fichier
	fichier = FileAccess.open(chemin, FileAccess.WRITE)
	if not fichier:
		print("write_json_file : ERREUR sur le chemin : ", chemin)
		return
	# Encodage JSON
	var json = JSON.new()
	var json_string = json.stringify(contenu)
	# print("json_string = ", json_string)
	# Ecriture du fichier
	fichier.store_string(json_string)
	fichier.close()

func commencer() -> void:
	nombre_de_partie += 1
	print("Nombre de parties = ", nombre_de_partie)
	_enregistrer_sauvegarde_joueur()

func gagner() -> void:
	var sauvegarder = false
	# Augmenter le plateau du niveau courant
	if _est_dernier_plateau():
		plateau_victoire_dernier_plateau = true
		sauvegarder = true
	if plateau_actuel.get(str(niveau_actuel)) < (len(plateau_liste_difficulte.get(str(niveau_actuel)))-1):
		plateau_actuel[str(niveau_actuel)] += 1
		sauvegarder = true
	
	# Augmenter le niveau courant
	if str(niveau_actuel + 1) in plateau_liste_difficulte:
		niveau_actuel += 1
		if str(niveau_actuel) not in plateau_actuel:
			plateau_actuel[str(niveau_actuel)] = 0
		sauvegarder = true
	
	print("Niveau = ", niveau_actuel, " - indice Plateau = ", plateau_actuel.get(str(niveau_actuel)), " - Nombre de parties = ", nombre_de_partie)
	if sauvegarder:
		_enregistrer_sauvegarde_joueur()

func abandonner() -> void:
	# Diminuer le niveau courant
	if str(niveau_actuel - 1) in plateau_liste_difficulte:
		niveau_actuel -= 1
		_enregistrer_sauvegarde_joueur()
	print("Niveau = ", niveau_actuel, " indice Plateau = ", plateau_actuel.get(str(niveau_actuel)))

func lire_plateau_courant() -> String:
	var indice_plateau = plateau_actuel.get(str(niveau_actuel))
	return plateau_liste_difficulte.get(str(niveau_actuel))[indice_plateau]

func _est_dernier_plateau() -> bool:
	return lire_plateau_courant() == plateau_liste_difficulte.get(str(niveau_actuel)).back()

func est_victoire_dernier_plateau() -> bool:
	return plateau_victoire_dernier_plateau

func lire_sauvegarde_joueur() -> void:
	var sauvegarde_joueur = _read_json_file("user://sauvegarde.json")
	if sauvegarde_joueur:
		print("sauvegarde_joueur = ", sauvegarde_joueur)
		if 'nombre_de_partie' in sauvegarde_joueur:
			nombre_de_partie = sauvegarde_joueur['nombre_de_partie']
		if 'niveau_actuel' in sauvegarde_joueur:
			niveau_actuel = sauvegarde_joueur['niveau_actuel']
		if 'plateau_actuel' in sauvegarde_joueur:
			plateau_actuel = sauvegarde_joueur['plateau_actuel'].duplicate(true)
		if 'plateau_victoire_dernier_plateau' in sauvegarde_joueur:
			plateau_victoire_dernier_plateau = sauvegarde_joueur['plateau_victoire_dernier_plateau']
	else:
		print("Erreur de la lecture de la sauvegarde du joueur")

func _enregistrer_sauvegarde_joueur() -> void:
	var sauvegarde_joueur = {
		'nombre_de_partie' : nombre_de_partie,
		'niveau_actuel' : niveau_actuel,
		'plateau_actuel' : plateau_actuel,
		'plateau_victoire_dernier_plateau' : plateau_victoire_dernier_plateau
	}
	_write_json_file("user://sauvegarde.json", sauvegarde_joueur)
	print("enregistrer_sauvegarde_joueur")

func score() -> int:
	"""Cette méthode retourne le score du joueur"""
	var score : int = 0
	for niveau in range(100, 0, -1):
		if str(niveau) in  plateau_actuel:
			var plateau = plateau_actuel.get(str(niveau))
			score += 1000 * niveau * plateau
	if nombre_de_partie:
		return int(score / nombre_de_partie)
	else:
		return 0
