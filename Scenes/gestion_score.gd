extends Node

###############################################
# Gestion des niveaux et des plateaux à jouer
###############################################
var liste_des_sauvegardes = [
	{
		'nom': 'Alain Konu',
		'nombre_de_parties': 0,
		'niveau': 3,
		'plateaux': { '3': 0 },
		'durees': { '3': 0 },
		'plateau_victoire_dernier_plateau': false
	}
]
var joueur_actuel = liste_des_sauvegardes[0]

# TODO : Prevoir le nom d'un joueur et charger le profil en consequence

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
				# TODO : DEBUG - if difficulte not in ['None', '0', '1', '2', '5', '6', '7', '8', '9'] :
					plateau_liste_difficulte[difficulte] = dico_difficulte.get(difficulte).duplicate(true)
				# Afficher un apercu du niveau
				#print("Difficulté : ", difficulte)
				#var cpt = 0
				#for plateau in dico_difficulte.get(difficulte):
					#print("   - plateaux : ", plateau)
					#cpt += 1
					#if cpt >= 5:
						#break

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

func _ajouter_duree_de_partie(duree_en_ms : int) -> void:
	var str_niveau = str(joueur_actuel.get('niveau'))
	# Augmenter la duree du niveau courant
	if str_niveau not in joueur_actuel.get('durees'):
		joueur_actuel['durees'][str_niveau] = 0
	joueur_actuel['durees'][str_niveau] += duree_en_ms

func commencer() -> void:
	joueur_actuel['nombre_de_parties'] += 1
	print("Nombre de parties = ", joueur_actuel.get('nombre_de_parties'))
	_enregistrer_sauvegarde_joueurs()

func gagner(duree_en_ms : int) -> void:
	var sauvegarder = false
	var str_niveau = str(joueur_actuel.get('niveau'))
	var str_niveau_plus_1 = str(joueur_actuel.get('niveau') + 1)
	# Enregistrer la duree de la partie
	_ajouter_duree_de_partie(duree_en_ms)
	# Augmenter le plateau du niveau courant
	if _est_dernier_plateau():
		joueur_actuel['plateau_victoire_dernier_plateau'] = true
		sauvegarder = true
	if joueur_actuel.get('plateaux').get(str_niveau) <= (len(plateau_liste_difficulte.get(str_niveau))-1):
		joueur_actuel['plateaux'][str_niveau] += 1
		sauvegarder = true
	
	# Augmenter le niveau courant
	if str_niveau_plus_1 in plateau_liste_difficulte:
		joueur_actuel['niveau'] += 1
		str_niveau = str(joueur_actuel.get('niveau'))
		if str_niveau not in joueur_actuel.get('plateaux'):
			joueur_actuel['plateaux'][str_niveau] = 0
		sauvegarder = true
	
	print("Niveau = ", str_niveau, " - indice Plateau = ", joueur_actuel.get('plateaux').get(str_niveau), " - Nombre de parties = ", joueur_actuel.get('nombre_de_parties'))
	if sauvegarder:
		_enregistrer_sauvegarde_joueurs()

func abandonner(duree_en_ms : int) -> void:
	# Enregistrer la duree de la partie
	_ajouter_duree_de_partie(duree_en_ms)
	# Diminuer le niveau courant
	if str(joueur_actuel.get('niveau') - 1) in plateau_liste_difficulte:
		joueur_actuel['niveau'] -= 1
		_enregistrer_sauvegarde_joueurs()
	var str_niveau = str(joueur_actuel.get('niveau'))
	print("Niveau = ", str_niveau, " - indice Plateau = ", joueur_actuel.get('plateaux').get(str_niveau))

func lire_plateau_courant() -> String:
	var str_niveau = str(joueur_actuel.get('niveau'))
	var indice_plateau = joueur_actuel.get('plateaux').get(str_niveau)
	if indice_plateau < len(plateau_liste_difficulte.get(str_niveau)):
		return plateau_liste_difficulte.get(str_niveau)[indice_plateau]
	return ""

func _est_dernier_plateau() -> bool:
	var str_niveau = str(joueur_actuel.get('niveau'))
	return lire_plateau_courant() == plateau_liste_difficulte.get(str_niveau).back()

func est_victoire_dernier_plateau() -> bool:
	return joueur_actuel.get('plateau_victoire_dernier_plateau')


###############################################
# Gestion des sauvegardes
###############################################

func lire_sauvegarde_joueurs() -> void:
	var lecture_liste_des_sauvegardes = _read_json_file("user://sauvegarde.json")
	if lecture_liste_des_sauvegardes:
		liste_des_sauvegardes = lecture_liste_des_sauvegardes.duplicate(true)
		# Joueur par defaut
		joueur_actuel = liste_des_sauvegardes[0]
		print("liste_des_sauvegardes = ", liste_des_sauvegardes)
	else:
		print("Erreur de lecture des sauvegardes des joueurs")

func _enregistrer_sauvegarde_joueurs() -> void:
	_write_json_file("user://sauvegarde.json", liste_des_sauvegardes.duplicate(true))
	print("Progression sauvegardée")

func _retourner_le_joueur(nom_joueur) -> Dictionary:
	"""Choisit le joueur et le retourne"""
	for compte_joueur in liste_des_sauvegardes:
		if compte_joueur.get('nom') == nom_joueur:
			return compte_joueur
	return {}

func choisir_le_joueur(nom_joueur) -> bool:
	"""Choisit le joueur courant sinon retourne 'false'"""
	var compte = _retourner_le_joueur(nom_joueur)
	if compte:
		joueur_actuel = compte
		return true
	return false

func ajouter_un_nouveau_joueur(nom_nouveau_joueur : String) -> bool:
	"""Crée un nouveau joueur si le nom est libre"""
	# Vérifie que le nom est libre
	if _retourner_le_joueur(nom_nouveau_joueur):
		return false
	# Crée le compte et l'enregistre
	var compte = {
		'nom': nom_nouveau_joueur,
		'nombre_de_parties': 0,
		'niveau': 3,
		'plateaux': { '3': 0 },
		'durees': { '3': 0 },
		'plateau_victoire_dernier_plateau': false
	}
	liste_des_sauvegardes.append(compte.duplicate(true))
	_enregistrer_sauvegarde_joueurs()
	return true

func lire_nom_joueur_actuel() -> String:
	"""Cette méthode retourne le nom du joueur"""
	return joueur_actuel.get('nom')

func lire_le_score_du_joueur_actuel() -> int:
	"""Cette méthode retourne le score du joueur actuel"""
	return lire_le_score_du_joueur(joueur_actuel.get('nom'))

func lire_le_score_du_joueur(nom_joueur : String) -> int:
	"""Cette méthode retourne le score du joueur"""
	var joueur = _retourner_le_joueur(nom_joueur)
	if joueur:
		var nb_parties = joueur.get('nombre_de_parties')
		if nb_parties:
			var score : int = 0
			for niveau in range(100, 0, -1):
				if str(niveau) in joueur.get('plateaux'):
					var plateau = joueur.get('plateaux').get(str(niveau))
					score += 1000 * niveau * plateau
			return int(score / nb_parties)
	return 0

func liste_des_joueurs() -> Variant:
	var liste_des_joueurs = []
	for joueur in liste_des_sauvegardes:
		liste_des_joueurs.append(joueur.get('nom'))
	return liste_des_joueurs.duplicate(false)
