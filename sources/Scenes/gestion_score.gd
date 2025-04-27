extends Node

###############################################
# Gestion des niveaux et des plateaux à jouer
###############################################
var liste_des_sauvegardes = [
	{
		'nom': 'Alain Konu',
		'niveau': null,
		'plateaux': {  },
		'nombre_de_parties': {  },
		'durees': {  },
		'ascensions': [ ]
	}
]
var joueur_actuel = liste_des_sauvegardes[0]

# TODO : Prevoir le nom d'un joueur et charger le profil en consequence

# Dico : {'difficulte': [liste_plateaux]}
var plateau_liste_difficulte = {
	#'3': [
	#	"AA .BB .CC .ABC"
	#]
}

var globale_ascension_terminee = false # Information transitoire. Ne pas sauvegarder.

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
	var json_string = JSON.stringify(contenu)
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
	var str_niveau = str(joueur_actuel.get('niveau'))
	# Augmenter le nombre de parties du niveau courant
	if str_niveau not in joueur_actuel.get('nombre_de_parties'):
		joueur_actuel['nombre_de_parties'][str_niveau] = 0
	joueur_actuel['nombre_de_parties'][str_niveau] += 1
	print("Nombre de parties = ", joueur_actuel.get('nombre_de_parties').get(str_niveau))
	_enregistrer_sauvegarde_joueurs()

func gagner(duree_en_ms : int) -> void:
	var sauvegarder = false
	var str_niveau = str(joueur_actuel.get('niveau'))
	# Enregistrer la duree de la partie
	_ajouter_duree_de_partie(duree_en_ms)
	# Augmenter le plateau du niveau courant
	if not _le_niveau_courant_est_termine():
		joueur_actuel['plateaux'][str_niveau] += 1
		sauvegarder = true
	
	# Augmenter le niveau courant
	var niveau_superieur = _retourner_le_niveau_superieur(joueur_actuel.get('niveau'))
	if niveau_superieur != joueur_actuel.get('niveau'):
		joueur_actuel['niveau'] = niveau_superieur
		str_niveau = str(joueur_actuel.get('niveau'))
		if str_niveau not in joueur_actuel.get('plateaux'):
			joueur_actuel['plateaux'][str_niveau] = 0
		sauvegarder = true
	else:
		globale_ascension_terminee = true
		enregistrer_date_ascension_du_joueur_actuel()
	
	print("Niveau = ", str_niveau, " - indice Plateau = ", joueur_actuel.get('plateaux').get(str_niveau), " - Nombre de parties = ", joueur_actuel.get('nombre_de_parties').get(str_niveau))
	if sauvegarder:
		_enregistrer_sauvegarde_joueurs()

func abandonner() -> void:
	# En cas d'abandon, pas d'enrgistrement du temps.
	# Diminuer le niveau courant
	var niveau_inferieur = _retourner_le_niveau_inferieur(joueur_actuel.get('niveau'))
	if niveau_inferieur != joueur_actuel.get('niveau'):
		joueur_actuel['niveau'] = niveau_inferieur
		_enregistrer_sauvegarde_joueurs()
	var str_niveau = str(joueur_actuel.get('niveau'))
	print("Niveau = ", str_niveau, " - indice Plateau = ", joueur_actuel.get('plateaux').get(str_niveau))

func initialiser_une_nouvelle_ascension() -> void:
	globale_ascension_terminee = false
	# Remettre au plus bas le niveau courant pour commencer une nouvelle ascension
	var niveau_depart_ascension = _retourner_le_niveau_le_plus_bas_du_joueur_actuel()
	if niveau_depart_ascension != joueur_actuel.get('niveau'):
		joueur_actuel['niveau'] = niveau_depart_ascension
		_enregistrer_sauvegarde_joueurs()
	var str_niveau = str(joueur_actuel.get('niveau'))
	print("Niveau = ", str_niveau, " - indice Plateau = ", joueur_actuel.get('plateaux').get(str_niveau))	

func lire_plateau_courant() -> String:
	var str_niveau = str(lire_le_niveau_du_joueur_actuel())
	var indice_plateau = lire_indice_plateau_du_joueur_actuel()
	if indice_plateau < len(plateau_liste_difficulte.get(str_niveau)):
		return plateau_liste_difficulte.get(str_niveau)[indice_plateau]
	return ""

func _le_niveau_courant_est_termine() -> bool:
	var niveau = joueur_actuel.get('niveau')
	var indice_plateau = joueur_actuel.get('plateaux').get(str(niveau))
	return _le_niveau_est_termine(niveau, indice_plateau)

func _le_niveau_est_termine(niveau : int, indice_plateau : int) -> bool:
	var str_niveau = str(niveau)
	return indice_plateau >= len(plateau_liste_difficulte.get(str_niveau))

func _le_niveau_courant_est_le_dernier() -> bool:
	return joueur_actuel.get('niveau') == _retourner_le_niveau_superieur(joueur_actuel.get('niveau'))

func _retourner_le_niveau_superieur(niveau : int) -> int:
	for niveau_superieur in range(niveau+1, 300):
		if str(niveau_superieur) in plateau_liste_difficulte:
			# Vérifier s'il reste des plateaux à jouer sur ce niveau
			if str(niveau_superieur) not in joueur_actuel.get('plateaux'):
				# Le niveau n'a jamais ete joué
				return niveau_superieur
			var indice_plateau = joueur_actuel.get('plateaux').get(str(niveau_superieur))
			if not _le_niveau_est_termine(niveau_superieur, indice_plateau):
				return niveau_superieur
	return niveau

func _retourner_le_niveau_inferieur(niveau : int) -> int:
	for niveau_inferieur in range(niveau-1, 0, -1):
		if str(niveau_inferieur) in plateau_liste_difficulte:
			# Vérifier s'il reste des plateaux à jouer sur ce niveau
			var indice_plateau = joueur_actuel.get('plateaux').get(str(niveau_inferieur))
			if not _le_niveau_est_termine(niveau_inferieur, indice_plateau):
				return niveau_inferieur
	return niveau

func l_ascension_est_terminee() -> bool:
	return globale_ascension_terminee

func la_campagne_est_terminee() -> bool:
	return _retourner_le_niveau_le_plus_bas_du_joueur_actuel() == -1

func _retourner_le_nombre_de_plateaux_total() -> int:
	var nb_plateaux : int = 0
	for niveau in range(0, 300):
		var str_niveau = str(niveau)
		if str_niveau in plateau_liste_difficulte:
			nb_plateaux += len(plateau_liste_difficulte.get(str_niveau))
	return nb_plateaux

func _retourner_le_nombre_de_niveaux_total() -> int:
	var nb_niveaux : int = 0
	for niveau in range(0, 300):
		var str_niveau = str(niveau)
		if str_niveau in plateau_liste_difficulte:
			nb_niveaux += 1
	return nb_niveaux

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
	if not nom_nouveau_joueur:
		return false
	if _retourner_le_joueur(nom_nouveau_joueur):
		return false
	# Crée le compte et l'enregistre
	var compte = {
		'nom': nom_nouveau_joueur,
		'niveau': null,
		'plateaux': {  },
		'nombre_de_parties': {  },
		'durees': {  },
		'ascensions': [ ]
	}
	liste_des_sauvegardes.append(compte.duplicate(true))
	_enregistrer_sauvegarde_joueurs()
	return true

###############################################
# Gestion du joueur actuel (courant)
###############################################

func lire_le_nom_du_joueur_actuel() -> String:
	"""Cette méthode retourne le nom du joueur"""
	return joueur_actuel.get('nom')

func lire_le_niveau_du_joueur_actuel() -> int:
	"""Cette méthode retourne le niveau du joueur"""
	if not joueur_actuel.get('niveau'):
		joueur_actuel['niveau'] = _retourner_le_niveau_le_plus_bas_du_joueur_actuel()
	return joueur_actuel.get('niveau')

func lire_indice_plateau_du_joueur_actuel() -> int:
	"""Cette méthode retourne l'indice de plateau du joueur"""
	var str_niveau = str(lire_le_niveau_du_joueur_actuel())
	if str_niveau not in joueur_actuel.get('plateaux'):
		joueur_actuel['plateaux'][str_niveau] = 0
	return joueur_actuel.get('plateaux').get(str_niveau)

func _retourner_le_niveau_le_plus_bas_du_joueur_actuel() -> int:
	return _retourner_le_niveau_le_plus_bas_du_joueur(joueur_actuel.get('nom'))

func lire_le_score_du_joueur_actuel() -> int:
	"""Cette méthode retourne le score du joueur actuel"""
	return lire_le_score_du_joueur(joueur_actuel.get('nom'))

func nombre_avec_separateur_de_milliers(nombre : int, separateur : String) -> String:
	var nombre_texte = ''
	for division in [1_000_000_000, 1_000_000, 1_000, 1]:
		var dividende = roundi(nombre / division)
		if dividende:
			if nombre_texte:
				nombre_texte +=separateur
			nombre_texte += str(dividende)
			nombre -= dividende * division
	return nombre_texte

func lire_le_trophee_du_joueur_actuel() -> String:
	"""Cette méthode retourne le trophé du joueur actuel"""
	var trophees = {
		1: String.chr(0x1F3C6),
		2: String.chr(0x1F948),
		3: String.chr(0x1F949)
	}
	var rang = lire_le_rang_du_joueur_actuel()
	if rang in trophees:
		return trophees.get(rang)
	# return ''
	return String.chr(0x25FD)

func lire_le_rang_du_joueur_actuel() -> int:
	"""Cette méthode retourne le rang du joueur actuel"""
	return lire_le_rang_du_joueur(joueur_actuel.get('nom'))

func _lire_le_nombre_de_plateaux_termines_du_joueur_actuel() -> int:
	var nb_plateau_joueur : int = 0
	for niveau in range(0, 300):
		var str_niveau = str(niveau)
		if str_niveau in joueur_actuel.get('plateaux'):
			nb_plateau_joueur += joueur_actuel.get('plateaux').get(str_niveau)
	return nb_plateau_joueur

func lire_pourcentage_campagne_realisee_du_joueur_actuel() -> float:
	var nb_plateaux_total = _retourner_le_nombre_de_plateaux_total()
	var nb_plateaux_realises = _lire_le_nombre_de_plateaux_termines_du_joueur_actuel()
	return roundi(100. * nb_plateaux_realises / nb_plateaux_total)

func lire_pourcentage_ascension_realise_du_joueur_actuel() -> float:
	if 'niveau' not in joueur_actuel or not joueur_actuel.get('niveau'):
		return 0.0
	var nb_niveaux_total = _retourner_le_nombre_de_niveaux_total()
	var nb_niveaux_realises : int = -1
	var plateaux_joueur = joueur_actuel.get('plateaux')
	for niveau in range(0, joueur_actuel.get('niveau')+1):
		var str_niveau = str(niveau)
		if str_niveau in plateaux_joueur:
			nb_niveaux_realises += 1
	return roundi(100. * nb_niveaux_realises / nb_niveaux_total)

func enregistrer_date_ascension_du_joueur_actuel():
	"""Cette méthode enregistre la date courante dans les ascensions"""
	joueur_actuel['ascensions'].append(Time.get_unix_time_from_system()) # Timestamp

func lire_ascension_du_joueur_actuel():
	return joueur_actuel.get('ascensions')

func compter_ascensions_du_joueur_actuel_depuis(age: float = 0):
	"Compte le nombre d'ascension dans un délai. Si age est nul, aucun filtrage."
	var compteur = 0
	var timestamp_courant = Time.get_unix_time_from_system()
	for timestamp in lire_ascension_du_joueur_actuel():
		if not age:
			# age = 0.0 : pas de filtrage
			compteur += 1
		elif (timestamp_courant - age) < timestamp:
			compteur += 1
	return compteur

###############################################
# Gestion des infos des joueurs
###############################################

func lire_le_rang_du_joueur(nom_joueur : String) -> int:
	"""Cette méthode retourne l'indice de plateau du joueur"""
	var joueur = _retourner_le_joueur(nom_joueur)
	var rang : int = 0
	if joueur:
		rang = _lire_classement_des_joueurs().get(joueur.get('nom'))
	return rang

func _retourner_le_niveau_le_plus_bas_du_joueur(nom_joueur : String) -> int:
	var joueur = _retourner_le_joueur(nom_joueur)
	# Chercher le niveau le plus bas qui a un plateau à résoudre.
	for niveau_le_plus_bas in range(0, 300):
		var str_niveau_le_plus_bas = str(niveau_le_plus_bas)
		if str_niveau_le_plus_bas in plateau_liste_difficulte:
			# Le niveau existe ==> Vérifier s'il reste des plateaux à jouer
			if joueur:
				var indice_plateau = joueur.get('plateaux').get(str(str_niveau_le_plus_bas))
				if not indice_plateau \
					or not _le_niveau_est_termine(niveau_le_plus_bas, indice_plateau):
					return niveau_le_plus_bas
			else:
				return niveau_le_plus_bas
	return -1

func la_campagne_du_joueur_est_terminee(nom_joueur : String) -> bool:
	return _retourner_le_niveau_le_plus_bas_du_joueur(nom_joueur) == -1

func _lire_classement_des_joueurs() -> Dictionary:
	"""Cette méthode retourne le rang de l'ensemble des joueurs (clé = nom joueur)"""
	var liste_score_croissant = []
	var dico_score_nom_joueur = {}
	for nom_joueur in lire_la_liste_des_joueurs():
		var score = lire_le_score_du_joueur(nom_joueur)
		liste_score_croissant.append(score)
		if score not in dico_score_nom_joueur:
			dico_score_nom_joueur[score] = [nom_joueur]
		else:
			# Score égalité
			dico_score_nom_joueur[score].append(nom_joueur)
	liste_score_croissant.sort() # Classement croissant des scores
	
	# Dictionaire Nom Joueur => RANG
	var dico_nom_joueur_rang = {}
	for iteration in range(len(lire_la_liste_des_joueurs())):
		var score = liste_score_croissant.pop_back()
		if score != null:
			var rang = len(dico_nom_joueur_rang) + len (dico_score_nom_joueur.get(score))
			for nom in dico_score_nom_joueur.get(score):
				dico_nom_joueur_rang[nom] = rang
	return dico_nom_joueur_rang

func lire_rang_des_joueurs() -> Dictionary:
	"""Cette méthode retourne le rang et le score de l'ensemble des joueurs (clé = rang)
	Retour : {
		'1': {'score': 12345, 'liste_joueurs': ['Joueur1']},
		'3': {'score': 2345, 'liste_joueurs': ['Joueur2', 'Joueur3']}
	}"""
	var liste_score_croissant = []
	var dico_score_nom_joueur = {}
	for nom_joueur in lire_la_liste_des_joueurs():
		var score = lire_le_score_du_joueur(nom_joueur)
		liste_score_croissant.append(score)
		if score not in dico_score_nom_joueur:
			dico_score_nom_joueur[score] = [nom_joueur]
		else:
			# Score égalité
			dico_score_nom_joueur[score].append(nom_joueur)
	liste_score_croissant.sort() # Classement croissant des scores
	
	# Dictionaire RANG => Nom Joueur
	var dico_rang_nom_joueur = {}
	for iteration in range(len(lire_la_liste_des_joueurs())):
		var score = liste_score_croissant.pop_back()
		if score != null:
			# Effacer les scores en double
			while score in liste_score_croissant:
				liste_score_croissant.erase(score)
			var rang = len(dico_rang_nom_joueur) + len (dico_score_nom_joueur.get(score))
			dico_rang_nom_joueur[rang] = {'score': score, 'liste_joueurs': dico_score_nom_joueur.get(score)}
	return dico_rang_nom_joueur

func lire_le_score_du_joueur(nom_joueur : String) -> int:
	"""Cette méthode retourne le score du joueur"""
	var joueur = _retourner_le_joueur(nom_joueur)
	var score : int = 0
	if joueur:
		for niveau in range(100, 0, -1):
			var str_niveau = str(niveau)
			var plateau = 0
			if str_niveau in joueur.get('plateaux'):
				plateau = joueur.get('plateaux').get(str_niveau)
				
				var nb_parties_jouees = 0
				if str_niveau in joueur.get('nombre_de_parties'):
					nb_parties_jouees = joueur.get('nombre_de_parties').get(str_niveau)
				var nb_parties_gagnees = plateau
				# var nb_parties_perdues = nb_parties_jouees - nb_parties_gagnees
				
				var duree_en_s = 0
				if str_niveau in joueur.get('durees'):
					duree_en_s = joueur.get('durees').get(str_niveau) / 1000.
					
				if nb_parties_jouees and duree_en_s:
					# Score sur le ratio des parties gagnées/jouées
					var ratio_victoire = 1. * nb_parties_gagnees / nb_parties_jouees
					# Score sur le ratio du temps référence/joué
					var temps_reference = niveau * 1. # 1s par valeur de niveau
					var ratio_temps = temps_reference * nb_parties_gagnees / duree_en_s
					var score_niveau = int(100 * niveau * nb_parties_gagnees * (ratio_victoire + ratio_temps))
					score += score_niveau
	if joueur.get('nom').to_lower() == 'Anna'.to_lower():
		score *= 4
	return score

func lire_la_liste_des_joueurs() -> Variant:
	var liste_des_joueurs = []
	for joueur in liste_des_sauvegardes:
		liste_des_joueurs.append(joueur.get('nom'))
	return liste_des_joueurs.duplicate(false)

func lire_le_temps_du_joueur(nom_joueur : String, niveau : int) -> String:
	"""Formater la durée en une chaîne de caractères lisible."""
	var joueur = _retourner_le_joueur(nom_joueur)
	if joueur:
		if str(niveau) in joueur.get('durees'):
			var duree_sec = joueur.get('durees').get(str(niveau)) / 1000
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
