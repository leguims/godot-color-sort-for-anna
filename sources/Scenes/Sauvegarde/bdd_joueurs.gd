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
	'plateaux': {  },
	'nombre_de_parties': {  },
	'ascensions': [ ]
}

# Exemple de sauvegarde avec une ascension en cours
# {
# 	"nom": "nom joueur",
# 	"nombre_de_parties": { "18": 5, "20": 4, "24": 4 },
# 	"plateaux": { "18": ['AA .BB .AB ', 'ABA.BAB.  '], "20": ['A .B .AB'], "24": ['AA .BB .CC .ABC'] },
# 	"ascensions": [ 
# 		{
# 			'niveau_debut': 18,
# 			'niveau_fin': 24,
# 			'niveau_courant': 20,
# 			'date_debut': 1748785865.997,
# 			'date_fin': 0.,
# 			'longueur_detour': 0,
# 			'score': { 'ascension': 500000, 'ascension_sans_detour': 500000},
# 			'plateaux': [
# 				{
# 					'nom': "AA .BB .AB ",
# 					'date_debut': 1748785865.997,
# 					'date_fin': 1748785855.0,
# 					'niveau': 18,
# 					'statut': 'reussi', # 'en cours', 'abandonné', 'reussi'
# 					'duree': 0,
# 					'score': { 'duree': 4000, 'ratio_reussite': 2000 },
# 					'coups joués': [
# 						{'depart': 2, 'arrivee': 1},
# 						{'depart': 2, 'arrivee': 0}
# 					]
# 				}
# 			]
# 		}
# 	]
# }

var fichier_sauvegarde = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# réalisé lors du choix du joueur
	pass

func _lire_sauvegarde_joueur(fichier : String) -> bool:
	# CONVERSION [V0.3.0 -> V0.3.1]
	# Effacer le fichier de sauvegarde obsolete qui devient incompatible.
	fichiers_json_gd.remove_json_file("user://sauvegarde.json")
	
	var lecture_sauvegarde_joueur = fichiers_json_gd.read_json_file("user://" + fichier)
	if lecture_sauvegarde_joueur:
		fichier_sauvegarde = fichier
		
		# CONVERSION [V0.3.0 -> V0.3.1] pour 'ascensions'
		#  - Si 'niveau' est à la racine => Conversion vers nouveau format avec 'ascensions' étoffé
		#  - Si 'durees' est à la racine => Conversion vers nouveau format avec 'ascensions' étoffé
		if 'niveau' in lecture_sauvegarde_joueur and 'durees' in lecture_sauvegarde_joueur:
			sauvegarde_joueur['nom'] = lecture_sauvegarde_joueur.get('nom')
			# Reset des informations 'plateaux' et 'nombre_de_parties'
			sauvegarde_joueur['plateaux'] = SauvegardeBddPlateaux.plateau_liste_difficulte_duplicate()
			sauvegarde_joueur['nombre_de_parties'] = {}
			# La conversion 'niveau' et 'durees' vers 'ascensions' n'est pas possible.
			sauvegarde_joueur['ascensions'] = []
			_enregistrer_sauvegarde_joueur()
			lecture_sauvegarde_joueur = fichiers_json_gd.read_json_file("user://" + fichier)
		
		sauvegarde_joueur = lecture_sauvegarde_joueur.duplicate(true)
		_print_bdd_joueurs()
		return true
	else:
		fichier_sauvegarde = ""
		printerr("Erreur de lecture de la sauvegarde du joueur actuel (user://" + fichier + ")")
	return false

func _print_bdd_joueurs() -> void:
	#print("sauvegarde_joueur '", sauvegarde_joueur['nom'],"' = ", sauvegarde_joueur)
	print("sauvegarde_joueur '", sauvegarde_joueur.get('nom'),"' :")
	print('\t', "plateaux=", lire_nom_plateau())
	print('\t', "nombre_de_parties=", sauvegarde_joueur.get('nombre_de_parties'))
	print('\t', "len(ascensions)=", len(sauvegarde_joueur.get('ascensions')))
	#if len(sauvegarde_joueur.get('ascensions')):
	#	print('\t', "derniere ascensions=", sauvegarde_joueur.get('ascensions').back())

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

func ajouter_un_nouveau_joueur(nom_nouveau_joueur : String, nom_nouveau_fichier : String) -> bool:
	"""Crée un nouveau joueur si le nom est libre"""
	# Vérifie que le nom est libre
	if not nom_nouveau_joueur:
		return false
	if not nom_nouveau_fichier or fichiers_json_gd.json_file_exists(nom_nouveau_fichier):
		return false
	# Crée le compte et l'enregistre
	sauvegarde_joueur = {
		'nom': nom_nouveau_joueur,
		'plateaux': {  },
		'nombre_de_parties': {  },
		'ascensions': [ ]
	}
	# Initialiser les plateaux avec 'BDD Plateaux'
	sauvegarde_joueur['plateaux'] = SauvegardeBddPlateaux.plateau_liste_difficulte_duplicate()
	
	fichier_sauvegarde = nom_nouveau_fichier
	_enregistrer_sauvegarde_joueur()
	return true


###############################################
# Nom
# "nom": "nom joueur"
###############################################

func lire_nom_joueur() -> String:
	if le_joueur_existe():
		return sauvegarde_joueur.get('nom')
	return ""

###############################################
# Indice des plateaux non joués
# "plateaux": { "18": ['AA .BB .AB ', 'ABA.BAB.  '], "20": ['A .B .AB'], "24": ['AA .BB .CC .ABC'] },
###############################################

func lire_plateau_aleatoire_pour_niveau_courant() -> String:
	"Désigne un plateau aléatoire du niveau courant"
	if le_joueur_existe():
		var str_niveau = str(lire_niveau_joueur())
		return sauvegarde_joueur.get('plateaux').get(str_niveau).pick_random()
	return ''

func supprimer_plateau_courant() -> bool:
	"Efface le plateau courant."
	if le_joueur_existe() and lire_statut_plateau() == 'en cours':
		var str_niveau = str(lire_niveau_joueur())
		var nom_plateau = lire_nom_plateau()
		sauvegarde_joueur.get('plateaux').get(str_niveau).erase(nom_plateau)
		if sauvegarde_joueur.get('plateaux').get(str_niveau).is_empty():
			# Le niveau est terminé, effacer sa reference dans les plateaux restants.
			sauvegarde_joueur.get('plateaux').erase(str_niveau)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func lire_nombre_de_plateaux_realisables_pour_niveau_courant() -> int:
	if le_joueur_existe():
		var str_niveau = str(lire_niveau_joueur())
		return len(sauvegarde_joueur.get('plateaux').get(str_niveau))
	return 0

func lire_nombre_de_niveaux_realisables() -> int:
	if le_joueur_existe():
		return len(sauvegarde_joueur.get('plateaux'))
	return 0

func le_niveau_est_termine(niveau : int) -> bool:
	if le_joueur_existe():
		var str_niveau = str(niveau)
		return str_niveau not in sauvegarde_joueur.get('plateaux') \
				or sauvegarde_joueur.get('plateaux').get(str_niveau).is_empty()
	return true

func la_campagne_est_terminee() -> bool:
	if le_joueur_existe():
		return sauvegarde_joueur.get('plateaux').is_empty()
	return true

###############################################
# Nombre de parties
# "nombre_de_parties": { "18": 5, "20": 4, "24": 4 }
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
			return sauvegarde_joueur.get('nombre_de_parties').get(str_niveau)
	return 0

func lire_nombre_de_parties_joueur_pour_niveau(niveau : int) -> int:
	if le_joueur_existe():
		var str_niveau = str(niveau)
		if str_niveau in sauvegarde_joueur.get('nombre_de_parties'):
			return sauvegarde_joueur.get('nombre_de_parties').get(str_niveau)
	return 0




###############################################
# Ascensions
# 	"ascensions": [ 
# 		{
# 			'niveau_debut': 18,
# 			'niveau_fin': 24,
# 			'niveau_courant': 20,
# 			'date_debut': 1748785865.997,
# 			'date_fin': 0.,
# 			'longueur_detour': 0,
# 			'score': { 'ascension': 500000, 'ascension_sans_detour': 500000},
# 			'plateaux': [
# 				{
# 					'nom': "AA .BB .AB ",
# 					'date_debut': 1748785865.997,
# 					'date_fin': 1748785855.0,
# 					'niveau': 18,
# 					'statut': 'reussi', # 'en cours', 'abandonné', 'reussi'
# 					'duree': 0,
# 					'score': { 'duree': 4000, 'ratio_reussite': 2000 },
# 					'coups joués': [
# 						{'depart': 2, 'arrivee': 1},
# 						{'depart': 2, 'arrivee': 0}
# 					]
# 				}
# 			]
# 		}
# 	]
###############################################

func ascension_existe() -> bool:
	"Indique si une ascension existe"
	return le_joueur_existe() and not sauvegarde_joueur.get('ascensions').is_empty()

func ascension_en_cours() -> bool:
	"Indique si une ascension est en cours de réalisation"
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		return not ascension.get('date_fin')
	return false

func initialiser_une_nouvelle_ascension(niveau_debut : int,
										niveau_fin : int) -> bool:
	"Crée et initialise une nouvelle ascension"
	if not ascension_en_cours():
		var ascension = {
			'niveau_debut': niveau_debut,
			'niveau_fin': niveau_fin,
			'niveau_courant': niveau_debut,
			'date_debut': Time.get_unix_time_from_system(), # Timestamp
			'date_fin': 0.,
			'longueur_detour': 0,
			'score': {},
			'plateaux': []
			}
		sauvegarde_joueur['ascensions'].append(ascension)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func terminer_ascension() -> void:
	"Enregistre la date de fin d'une ascension"
	if ascension_en_cours():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		ascension['date_fin'] = Time.get_unix_time_from_system() # Timestamp
		_enregistrer_sauvegarde_joueur()

func lire_nombre_ascensions() -> int:
	"Retourne le nombre d'ascensions achevées"
	if ascension_existe():
		if ascension_en_cours():
			return len(sauvegarde_joueur['ascensions']) - 1
		else:
			return len(sauvegarde_joueur['ascensions'])
	return 0

###############################################
# Ascensions / Niveau debut
# Ascensions / Niveau fin
# Ascensions / Niveau courant
###############################################

func modifier_niveau_joueur(niveau : int) -> void:
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		ascension['niveau_courant'] = niveau
		_enregistrer_sauvegarde_joueur()

func lire_niveau_joueur() -> int:
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		return ascension.get('niveau_courant')
	return 0

func lire_niveau_debut_ascension() -> int:
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		return ascension.get('niveau_debut')
	return 0

func lire_niveau_fin_ascension() -> int:
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		return ascension.get('niveau_fin')
	return 0

func lire_niveau_ascension_longueur_totale() -> int:
	var longueur_totale = 0
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		for niveau in range(ascension.get('niveau_debut'), ascension.get('niveau_fin')+1):
			if str(niveau) in sauvegarde_joueur.get('plateaux'):
				longueur_totale += 1
	return longueur_totale

func lire_niveau_ascension_longueur_realisee() -> int:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var liste_niveaux = []
		for plateau in ascension.get('plateaux'):
			var niveau = plateau.get('niveau')
			if not le_niveau_est_termine(niveau) :
				if niveau not in liste_niveaux \
					and plateau.get('statut') == 'reussi':
					 # Ajouter le niveau réussi
					liste_niveaux.append(niveau)
				elif plateau.get('statut') == 'abandonné':
					 # Supprimer le precedent niveau quand le niveau courant est abandonné
					liste_niveaux.pop_back()
		return len(liste_niveaux)
	return 0

func lire_niveau_ascension_longueur_restante() -> int:
	var longueur_totale = 0
	if ascension_en_cours():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		for niveau in range(ascension.get('niveau_courant'), ascension.get('niveau_fin')+1):
			if str(niveau) in sauvegarde_joueur.get('plateaux'):
				longueur_totale += 1
	return longueur_totale

func lire_pourcentage_ascension_realise() -> int:
	"Pourcentage de réalisation (retourne 99 pour 99%, 15 pour 15% ...)"
	if ascension_en_cours():
		var nb_niveaux_totaux = lire_niveau_ascension_longueur_totale()
		var nb_niveaux_realises = lire_niveau_ascension_longueur_realisee()
		return roundi(100. * nb_niveaux_realises / nb_niveaux_totaux)
	return 0

###############################################
# Ascensions / Date debut
# Ascensions / Date fin
###############################################

func lire_date_debut_ascension() -> float:
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		return ascension.get('date_debut')
	return 0

func lire_date_fin_ascension() -> float:
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		return ascension.get('date_fin')
	return 0

###############################################
# Ascensions / Longueur detour
###############################################

func incrementer_longueur_detour_ascension() -> void:
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		ascension['longueur_detour'] += 1
		_enregistrer_sauvegarde_joueur()

func lire_longueur_detour_ascension() -> int:
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		return ascension.get('longueur_detour')
	return 0

###############################################
# Ascensions / Score / Ascension et Ascension sans détour
# 'score': { 'ascension': 500000, 'ascension_sans_detour': 500000},
###############################################

func modifier_score_ascension(score : int) -> void:
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		ascension['score']['ascension'] = score
		_enregistrer_sauvegarde_joueur()

func modifier_score_ascension_sans_detour(score : int) -> void:
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		ascension['score']['ascension_sans_detour'] = score
		_enregistrer_sauvegarde_joueur()

func lire_score_ascension() -> int:
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		if ascension.get('score') and ascension.get('score').get('ascension'):
			return ascension.get('score').get('ascension')
	return 0

func lire_score_ascension_sans_detour() -> int:
	if ascension_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		if ascension.get('score') and ascension.get('score').get('ascension_sans_detour'):
			return ascension.get('score').get('ascension_sans_detour')
	return 0


###############################################
# Ascensions / Plateaux
# 	'plateaux': [
# 		{
# 			'nom': "AA .BB .AB ",
# 			'date_debut': 1748785865.997,
# 			'date_fin': 1748785855.0,
# 			'niveau': 18,
# 			'statut': 'reussi', # 'en cours', 'abandonné', 'reussi'
# 			'duree': 0,
# 			'score': { 'duree': 4000, 'ratio_reussite': 2000 },
# 			'coups joués': [
# 				{'depart': 2, 'arrivee': 1},
# 				{'depart': 2, 'arrivee': 0}
# 			]
# 		}
# 	]
###############################################

func plateau_existe() -> bool:
	"Indique si un plateau existe"
	return ascension_existe() and not sauvegarde_joueur.get('ascensions').back().get('plateaux').is_empty()

func plateau_en_cours() -> bool:
	"Indique si un plateau est en cours de réalisation"
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		return not plateau.get('date_fin')
	return false

func initialiser_un_nouveau_plateau(nom : String,
									niveau : int) -> bool:
	"Crée et initialise un nouveau plateau"
	if not plateau_en_cours():
		var nouveau_plateau = {
			'nom': nom,
			'date_debut': Time.get_unix_time_from_system(), # Timestamp
			'date_fin': 0.,
			'niveau': niveau,
			'statut': 'en cours', # 'en cours', 'abandonné', 'reussi'
			'duree': 0,
			'score': {},
			'coups joués': []
			}
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateaux = ascension.get('plateaux')
		plateaux.append(nouveau_plateau)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func terminer_plateau() -> void:
	"Enregistre la date de fin d'une ascension"
	if plateau_en_cours():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		plateau['date_fin'] = Time.get_unix_time_from_system() # Timestamp
		_enregistrer_sauvegarde_joueur()

func lire_nombre_plateaux() -> int:
	"Retourne le nombre de plateaux achevées"
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		if plateau_en_cours():
			return len(ascension.get('plateaux')) - 1
		else:
			return len(ascension.get('plateaux'))
	return 0

###############################################
# Ascensions / Plateaux / Nom
# Ascensions / Plateaux / Date debut
# Ascensions / Plateaux / Date fin
# Ascensions / Plateaux / Niveau
###############################################

func lire_nom_plateau() -> String:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		return plateau.get('nom')
	return ""

func lire_date_debut_plateau() -> float:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		return plateau.get('date_debut')
	return 0

func lire_date_fin_plateau() -> float:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		return plateau.get('date_fin')
	return 0

func lire_niveau_plateau() -> float:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		return plateau.get('niveau')
	return 0

###############################################
# Ascensions / Plateaux / Statut
# 'statut': 'en cours', # 'en cours', 'abandonné', 'reussi'
###############################################

func modifier_statut_plateau(statut : String) -> void:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		plateau['statut'] = statut
		_enregistrer_sauvegarde_joueur()

func lire_statut_plateau() -> String:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		return plateau.get('statut')
	return 'en cours'

###############################################
# Ascensions / Plateaux / Durée de partie
###############################################

func modifier_duree_plateau(duree_en_ms : int) -> void:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		plateau['duree'] = duree_en_ms
		_enregistrer_sauvegarde_joueur()

func ajouter_duree_plateau(duree_en_ms : int) -> void:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		plateau['duree'] += duree_en_ms
		_enregistrer_sauvegarde_joueur()

func lire_duree_plateau() -> int:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		return plateau.get('duree')
	return 0

func lire_le_temps_du_joueur() -> String:
	"""Formater la durée en une chaîne de caractères lisible."""
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		var duree_sec = plateau.get('duree') / 1000
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

###############################################
# Ascensions / Score / Ascension et Ascension sans détour
# 'score': { 'duree': 4000, 'ratio_reussite': 2000 }
###############################################

func modifier_score_duree_plateau(score : int) -> void:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		plateau['score']['duree'] = score
		_enregistrer_sauvegarde_joueur()

func modifier_score_ratio_reussite_plateau(score : int) -> void:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		plateau['score']['ratio_reussite'] = score
		_enregistrer_sauvegarde_joueur()

func lire_score_duree_plateau() -> int:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		if plateau.get('score') and plateau.get('score').get('duree'):
			return plateau.get('score').get('duree')
	return 0

func lire_score_ratio_reussite_plateau() -> int:
	if plateau_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		if plateau.get('score') and plateau.get('score').get('ratio_reussite'):
			return plateau.get('score').get('ratio_reussite')
	return 0

###############################################
# Ascensions / Plateaux / Coups joués
# 	'coups joués': [
# 		{'depart': 2, 'arrivee': 1},
# 		{'depart': 2, 'arrivee': 0}
# 	]
###############################################

func coup_existe() -> bool:
	"Indique si un coup existe"
	return plateau_existe() and not sauvegarde_joueur.get('ascensions').back().get('plateaux').back().get('coups joués').is_empty()

func coup_en_cours() -> bool:
	"Indique si un coup est en cours de réalisation"
	# Le cycle de vie du plateau est celui des coups joués
	return plateau_en_cours()

func ajouter_un_nouveau_coup(depart : int,
							arrivee : int) -> bool:
	"Ajouter un nouveau coup joué"
	if plateau_en_cours():
		var nouveau_coup = {'depart': depart, 'arrivee': arrivee}
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		var coups = plateau.get('coups joués')
		coups.append(nouveau_coup)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func terminer_coups() -> void:
	"Enregistre la date de fin des coups joués"
	# Le cycle de vie du plateau est celui des coups joués
	terminer_plateau()

func lire_nombre_coups() -> int:
	"Retourne le nombre de coups joués"
	if coup_existe():
		var ascension = sauvegarde_joueur.get('ascensions').back()
		var plateau = ascension.get('plateaux').back()
		return len(plateau.get('coups joués'))
	return 0
