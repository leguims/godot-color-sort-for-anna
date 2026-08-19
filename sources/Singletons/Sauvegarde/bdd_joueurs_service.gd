###############################################
# Gestion des sauvegardes de joueurs
###############################################

extends Node

###############################################
# Gestion des DIFFICULTES et des plateaux à jouer
###############################################
var sauvegarde_joueur = {
	# Créé dans '_ready()'
	#'nom': 'Alain Konu',
	#'campagne': {  },
	#'nombre_de_parties': {  },
	#'enregistrement_campagne': [ ],
	#'plateaux_libres': {  },
}

# Exemple de sauvegarde avec Un DIFFICULTE en cours
# {
# 	"nom": "nom joueur",
# 	"nombre_de_parties": { "18": 5, "20": 4, "24": 4 },
#	"campagne": {
#        "DIFFICULTE_1": [
#            {"difficulte": 1, "gameplay": "CLASSIQUE", "nom": "AAA.BBB.CCC"},
#            {"difficulte": 2, "gameplay": "MEMOIRE", "nom": "DDD.EEE.FFF"}
#        ],
#        "DIFFICULTE_2": [
#            {"difficulte": 3, "gameplay": "DEFI_DU_GOSSE", "nom": "GGG.HHH.III"}
#        ],
#        "DIFFICULTE_10": [
#            {"difficulte": 5, "gameplay": "DEFI_DU_BOSS", "nom": "GGG.HHH.III"}
#        ]
#    },
# 	"enregistrement_campagne": [ 
# 		{
# 			'DIFFICULTE': 20, # TODO : Transformer pour y ecrire le nom du DIFFICULTE
# 			'date_debut': 1748785865.997,
# 			'date_fin': 0.,
# 			'score': { 'ascension': 500000, 'ascension_sans_detour': 500000},
# 			'plateaux': [
# 				{
# 					'nom': "AA .BB .AB ",
#					TODO : 'gameplay': 'CLASSIQUE', # 'CLASSIQUE', 'MEMOIRE', 'DEFI_DU_GOSSE', 'DEFI_DU_BOSS', 'QUI_PERD_GAGNE', 'FLEMMARD', 'DOUBLE_FACE', 'DICO'
# 					'date_debut': 1748785865.997,
# 					'date_fin': 1748785855.0,
# 					'difficulte': 18,
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
	# Connecter les signaux attendus
	var pcs = get_node("/root/ProgressionCampagneService")
	pcs.fin_DIFFICULTE.connect(_on_progression_campagne_service_fin_DIFFICULTE)

	# Creation compte initial 'Alain Konu'
	if not FichiersJsonService.json_file_exists("user://sauvegarde_joueur_00.json"):
		ajouter_un_nouveau_joueur('Alain Konu', 'sauvegarde_joueur_00.json')

func _on_progression_campagne_service_fin_DIFFICULTE():
	_terminer_DIFFICULTE()

func _lire_sauvegarde_joueur(fichier : String) -> bool:
	var lecture_sauvegarde_joueur = FichiersJsonService.read_json_file("user://" + fichier)
	if lecture_sauvegarde_joueur:
		fichier_sauvegarde = fichier
		sauvegarde_joueur = lecture_sauvegarde_joueur.duplicate(true)
		_print_bdd_joueurs()
		return true
	else:
		fichier_sauvegarde = ""
		LogService.log_erreur("Erreur de lecture de la sauvegarde du joueur actuel (user://" + fichier + ")")
	return false

func _print_bdd_joueurs() -> void:
	#LogService.log_debug("sauvegarde_joueur *", sauvegarde_joueur['nom'],"* = ", sauvegarde_joueur)
	LogService.log_debug("sauvegarde_joueur *", sauvegarde_joueur.get('nom', ''),"* :")
	LogService.log_debug('\t', "plateau=", lire_nom_plateau())
	LogService.log_debug('\t', "nombre_de_parties=", sauvegarde_joueur.get('nombre_de_parties', 0))
	LogService.log_debug('\t', "len(enregistrement_campagne)=", len(sauvegarde_joueur.get('enregistrement_campagne', [])))
	#if len(sauvegarde_joueur.get('enregistrement_campagne')):
	#	LogService.log_debug('\t', "derniere campagne=", sauvegarde_joueur.get('enregistrement_campagne').back())

func _enregistrer_sauvegarde_joueur() -> void:
	if fichier_sauvegarde:
		FichiersJsonService.write_json_file("user://" + fichier_sauvegarde, sauvegarde_joueur.duplicate(true))
		LogService.log_debug("Progression sauvegardée")

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
	if not nom_nouveau_fichier or FichiersJsonService.json_file_exists(nom_nouveau_fichier):
		return false
	# Crée le compte et l'enregistre
	sauvegarde_joueur = {
		'nom': nom_nouveau_joueur,
		'campagne': {  },
		'nombre_de_parties': {  },
		'enregistrement_campagne': [ ],
		'plateaux_libres': {  }
	}
	# Initialiser les plateaux avec 'BDD Plateaux'
	sauvegarde_joueur['campagne'] = SauvegardeBddPlateauxService.plateau_liste_difficulte_duplicate()
	
	fichier_sauvegarde = nom_nouveau_fichier
	_enregistrer_sauvegarde_joueur()
	return true

func remplacer_campagne_des_joueurs():
	"""Parcourir tous les joueurs et remplacer les plateaux à jouer par ceux du fichier courant"""
	# Parcourir chaque joueurs
	for nom_joueur in SauvegardeListeJoueursService.retourner_la_liste_des_joueurs():
		fichier_sauvegarde = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(nom_joueur)
		_lire_sauvegarde_joueur(fichier_sauvegarde)
		# Clore toute DIFFICULTE en cours.
		terminer_plateau()
		_terminer_DIFFICULTE()
		# Remplacer les plateaux residuels d'une ancienne campagne.
		# avec les plateaux de la nouvelle campagne
		sauvegarde_joueur['campagne'] = SauvegardeBddPlateauxService.plateau_liste_difficulte_duplicate()
		# Enregistrer les changements
		_enregistrer_sauvegarde_joueur()
		liberer_le_joueur()
		LogService.log_debug("Remplacement de campagne pour le joueur :", nom_joueur)


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
#	"campagne": {
#        "DIFFICULTE_1": [
#            {"difficulte": 1, "gameplay": "CLASSIQUE", "nom": "AAA.BBB.CCC"},
#            {"difficulte": 2, "gameplay": "MEMOIRE", "nom": "DDD.EEE.FFF"}
#        ],....
###############################################

func _lire_prochain_plateau_pour_DIFFICULTE_courant() -> Dictionary:
	"Désigne le prochain plateau de campagne à jouer pour le DIFFICULTE courant"
	if le_joueur_existe():
		var str_DIFFICULTE = lire_nom_DIFFICULTE_joueur()
		return sauvegarde_joueur.get('campagne').get(str_DIFFICULTE).pop_front()
	return {}

func _supprimer_plateau_courant() -> bool:
	"Efface le plateau courant."
	if le_joueur_existe() and _lire_statut_plateau() == 'en cours':
		var str_DIFFICULTE = lire_nom_DIFFICULTE_joueur()
		var nom_plateau = lire_nom_plateau()
		if nom_plateau in sauvegarde_joueur.get('campagne').get(str_DIFFICULTE):
			var difficulte_plateau = lire_difficulte_plateau()
			# Ajouter le plateau effacé dans les plateaux libres
			if difficulte_plateau in sauvegarde_joueur.get('plateaux_libres'):
				sauvegarde_joueur.get('plateaux_libres').get(str_DIFFICULTE).append(nom_plateau)
			else:
				sauvegarde_joueur.get('plateaux_libres')[str_DIFFICULTE] = [nom_plateau]
			# Effacer le plateau
			sauvegarde_joueur.get('campagne').get(str_DIFFICULTE).erase(nom_plateau)
		if sauvegarde_joueur.get('campagne').get(str_DIFFICULTE).is_empty():
			# Le DIFFICULTE est terminé, effacer sa reference dans les plateaux restants.
			sauvegarde_joueur.get('campagne').erase(str_DIFFICULTE)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func lire_nombre_de_plateaux_realisables_pour_DIFFICULTE_courant() -> int: # TODO : INUTILISE !
	if le_joueur_existe():
		var str_DIFFICULTE = lire_nom_DIFFICULTE_joueur()
		return len(sauvegarde_joueur.get('campagne').get(str_DIFFICULTE))
	return 0

func lire_nombre_de_DIFFICULTES_realisables() -> int:
	if le_joueur_existe():
		return len(sauvegarde_joueur.get('campagne'))
	return 0

func le_DIFFICULTE_est_termine(DIFFICULTE : int) -> bool:
	if le_joueur_existe():
		var str_DIFFICULTE = lire_nom_DIFFICULTE(DIFFICULTE)
		return str_DIFFICULTE not in sauvegarde_joueur.get('campagne') \
				or sauvegarde_joueur.get('campagne').get(str_DIFFICULTE).is_empty()
	return true

func la_campagne_est_terminee() -> bool:
	if le_joueur_existe():
		return sauvegarde_joueur.get('campagne').is_empty()
	return true

###############################################
# Nombre de parties
# "nombre_de_parties": { "18": 5, "20": 4, "24": 4 }
###############################################

func _incrementer_nombre_de_parties_joueur_pour_DIFFICULTE_courant() -> void:
	if le_joueur_existe():
		var str_DIFFICULTE = lire_nom_DIFFICULTE_joueur()
		if str_DIFFICULTE not in sauvegarde_joueur.get('nombre_de_parties'):
			sauvegarde_joueur['nombre_de_parties'][str_DIFFICULTE] = 0
		sauvegarde_joueur['nombre_de_parties'][str_DIFFICULTE] += 1
		_enregistrer_sauvegarde_joueur()

func lire_nombre_de_parties_joueur_pour_DIFFICULTE_courant() -> int:
	if le_joueur_existe():
		var str_DIFFICULTE = lire_nom_DIFFICULTE_joueur()
		if str_DIFFICULTE in sauvegarde_joueur.get('nombre_de_parties'):
			return sauvegarde_joueur.get('nombre_de_parties').get(str_DIFFICULTE)
	return 0

func lire_nombre_de_parties_joueur_pour_DIFFICULTE(DIFFICULTE : int) -> int: # TODO : INUTILISE !
	if le_joueur_existe():
		var str_DIFFICULTE = lire_nom_DIFFICULTE(DIFFICULTE)
		if str_DIFFICULTE in sauvegarde_joueur.get('nombre_de_parties'):
			return sauvegarde_joueur.get('nombre_de_parties').get(str_DIFFICULTE)
	return 0




###############################################
# DIFFICULTES
# 	"enregistrement_campagne": [ 
# 		{
# 			'DIFFICULTE': 20,
#			'date_debut': 1748785865.997,
# 			'date_fin': 0.,
# 			'score': { 'DIFFICULTE': 500000, 'DIFFICULTE_sans_detour': 500000},
# 			'plateaux': [
# 				{
# 					'nom': "AA .BB .AB ",
# 					'date_debut': 1748785865.997,
# 					'date_fin': 1748785855.0,
# 					'difficulte': 18,
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

func DIFFICULTE_existe() -> bool:
	"Indique si un DIFFICULTE existe"
	return le_joueur_existe() \
			and 'enregistrement_campagne' in sauvegarde_joueur \
			and not sauvegarde_joueur.get('enregistrement_campagne').is_empty()

func lire_dernier_DIFFICULTE() -> Dictionary:
	"Retourne le dernier DIFFICULTE"
	if DIFFICULTE_existe():
		var enregistrement_campagne = sauvegarde_joueur.get('enregistrement_campagne').back()
		return enregistrement_campagne
	return {}

func DIFFICULTE_en_cours() -> bool:
	"Indique si un DIFFICULTE est en cours de réalisation"
	var enregistrement_campagne = lire_dernier_DIFFICULTE()
	if enregistrement_campagne:
		return not enregistrement_campagne.get('date_fin')
	return false

func initialiser_un_nouveau_DIFFICULTE(DIFFICULTE : int) -> bool:
	"Crée et initialise un nouveau DIFFICULTE"
	if not DIFFICULTE_en_cours():
		var enregistrement_DIFFICULTE = {
			'DIFFICULTE': DIFFICULTE,
			'date_debut': Time.get_unix_time_from_system(), # Timestamp
			'date_fin': 0.,
			'score': {},
			'plateaux': []
			}
		if 'enregistrement_campagne' not in sauvegarde_joueur:
			sauvegarde_joueur['enregistrement_campagne'] = []
		sauvegarde_joueur['enregistrement_campagne'].append(enregistrement_DIFFICULTE)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func _terminer_DIFFICULTE() -> void:
	"Enregistre la date de fin d'un DIFFICULTE"
	var enregistrement_campagne = lire_dernier_DIFFICULTE()
	if enregistrement_campagne:
		enregistrement_campagne['date_fin'] = Time.get_unix_time_from_system() # Timestamp
		_enregistrer_sauvegarde_joueur()

func lire_nombre_DIFFICULTES() -> int: # TODO : INUTILISE !
	"Retourne le nombre de DIFFICULTES achevés"
	if DIFFICULTE_existe():
		if DIFFICULTE_en_cours():
			return len(sauvegarde_joueur['enregistrement_campagne']) - 1
		else:
			return len(sauvegarde_joueur['enregistrement_campagne'])
	return 0

###############################################
# DIFFICULTES / DIFFICULTE debut
# DIFFICULTES / DIFFICULTE fin
# DIFFICULTES / DIFFICULTE courant
###############################################

func modifier_DIFFICULTE_joueur(DIFFICULTE : int) -> void: # TODO : INUTILISE !
	var enregistrement_campagne = lire_dernier_DIFFICULTE()
	if enregistrement_campagne:
		enregistrement_campagne['DIFFICULTE'] = DIFFICULTE
		_enregistrer_sauvegarde_joueur()

func lire_DIFFICULTE_joueur() -> int:
	var enregistrement_campagne = lire_dernier_DIFFICULTE()
	if enregistrement_campagne:
		return enregistrement_campagne.get('DIFFICULTE')
	return 0

func lire_nom_DIFFICULTE_joueur() -> String:
	return SauvegardeBddPlateauxService.nom_DIFFICULTE(lire_DIFFICULTE_joueur())

func lire_nom_DIFFICULTE(DIFFICULTE : int) -> String:
	return SauvegardeBddPlateauxService.nom_DIFFICULTE(DIFFICULTE)

func lire_DIFFICULTE_longueur_realisee() -> int:
	var dernier_DIFFICULTE = lire_dernier_DIFFICULTE()
	if dernier_DIFFICULTE:
		var liste_DIFFICULTES = []
		# TODO : Revoir l'algo !
		for plateau in dernier_DIFFICULTE.get('plateaux'):
			var DIFFICULTE = plateau.get('difficulte')
			if not le_DIFFICULTE_est_termine(DIFFICULTE) :
				if DIFFICULTE not in liste_DIFFICULTES \
					and plateau.get('statut') == 'reussi':
					 # Ajouter le DIFFICULTE réussi
					liste_DIFFICULTES.append(DIFFICULTE)
				elif plateau.get('statut') == 'abandonné':
					 # Supprimer le precedent DIFFICULTE quand le DIFFICULTE courant est abandonné
					liste_DIFFICULTES.pop_back()
		return len(liste_DIFFICULTES)
	return 0

func lire_nombre_de_niveaux_realisables() -> int:
	return lire_nombre_de_DIFFICULTES_realisables()

func le_niveau_est_termine(niveau : int) -> bool:
	return le_DIFFICULTE_est_termine(niveau)

func niveau_existe(niveau : int = -1) -> bool:
	# If called without argument, return whether any DIFFICULTE is available
	if niveau == -1:
		return lire_nombre_de_DIFFICULTES_realisables() > 0
	return SauvegardeBddPlateauxService.DIFFICULTE_existe(niveau)

func niveau_en_cours() -> bool:
	return DIFFICULTE_en_cours()

func lire_niveau_joueur() -> int:
	return lire_DIFFICULTE_joueur()

# Functions that extract campagne metadata (debut/fin/longueurs/ratio) from the
# current 'enregistrement_campagne' structure. Tests historically used names with
# "niveau"; provide these names and read the underlying (possibly renamed) keys.
func lire_difficulte_debut_niveau() -> int:
	var enregs = sauvegarde_joueur.get('enregistrement_campagne', [])
	if len(enregs) > 0:
		var v = enregs[0].get('niveau_debut', enregs[0].get('difficulte_debut', 0))
		return int(v)
	return 0

func lire_difficulte_fin_niveau() -> int:
	var enregs = sauvegarde_joueur.get('enregistrement_campagne', [])
	if len(enregs) > 0:
		var v = enregs[0].get('niveau_fin', enregs[0].get('difficulte_fin', 0))
		return int(v)
	return 0

func lire_longueur_detour_niveau() -> int:
	var enregs = sauvegarde_joueur.get('enregistrement_campagne', [])
	if len(enregs) > 0:
		var v = enregs[0].get('longueur_detour', enregs[0].get('difficulte_longueur_detour', 0))
		return int(v)
	return 0

func lire_niveau_longueur_initiale() -> int:
	var enregs = sauvegarde_joueur.get('enregistrement_campagne', [])
	if len(enregs) > 0:
		var v = enregs[0].get('longueur_initiale', enregs[0].get('difficulte_longueur_initiale', 0))
		return int(v)
	return 0

func lire_ratio_reussite_niveau() -> int:
	# Try to read an aggregated ratio from the current enregistrement, fallback to 0
	var enregs = sauvegarde_joueur.get('enregistrement_campagne', [])
	if len(enregs) > 0:
		var score = enregs[0].get('score', {})
		var ratio = score.get('ratio_reussite', score.get('difficulte_ratio_reussite', 0))
		return int(ratio)
	return 0

	
	var dernier_DIFFICULTE = lire_dernier_DIFFICULTE()
	if dernier_DIFFICULTE:
		var liste_DIFFICULTES = []
		# TODO : Revoir l'algo !
		for plateau in dernier_DIFFICULTE.get('plateaux'):
			var DIFFICULTE = plateau.get('difficulte')
			if not le_DIFFICULTE_est_termine(DIFFICULTE) :
				if DIFFICULTE not in liste_DIFFICULTES \
					and plateau.get('statut') == 'reussi':
					 # Ajouter le DIFFICULTE réussi
					liste_DIFFICULTES.append(DIFFICULTE)
				elif plateau.get('statut') == 'abandonné':
					 # Supprimer le precedent DIFFICULTE quand le DIFFICULTE courant est abandonné
					liste_DIFFICULTES.pop_back()
		return len(liste_DIFFICULTES)
	return 0

func lire_DIFFICULTE_longueur_restante() -> int: # TODO : INUTILISE !
	return lire_nombre_de_plateaux_realisables_pour_DIFFICULTE_courant()

func lire_pourcentage_DIFFICULTE_realise() -> int:
	"Pourcentage de réalisation (retourne 99 pour 99%, 15 pour 15% ...)"
	if DIFFICULTE_en_cours():
		var nb_DIFFICULTES_realises = lire_DIFFICULTE_longueur_realisee()
		var nb_DIFFICULTES_restant = lire_DIFFICULTE_longueur_restante()
		var nb_DIFFICULTES_totaux = nb_DIFFICULTES_realises + nb_DIFFICULTES_restant
		return roundi(100. * nb_DIFFICULTES_realises / nb_DIFFICULTES_totaux)
	return 0

###############################################
# DIFFICULTES / Date debut
# DIFFICULTES / Date fin
###############################################

func lire_date_debut_DIFFICULTE() -> float: # TODO : INUTILISE !
	var enregistrement_campagne = lire_dernier_DIFFICULTE()
	if enregistrement_campagne:
		return enregistrement_campagne.get('date_debut')
	return 0

func lire_date_fin_DIFFICULTE() -> float: # TODO : INUTILISE !
	var enregistrement_campagne = lire_dernier_DIFFICULTE()
	if enregistrement_campagne:
		return enregistrement_campagne.get('date_fin')
	return 0

###############################################
# DIFFICULTES / Longueur detour
###############################################

func lire_ratio_reussite_DIFFICULTE() -> int:
	"Pourcentage de réussite du DIFFICULTE (retourne 99 pour 99%, 15 pour 15% ...)"
	if DIFFICULTE_existe():
		# TODO : Revoir l'algo !
		var nb_essais  = _lire_nombre_plateaux()
		var nb_succes = lire_DIFFICULTE_longueur_realisee()
		return roundi(100. * nb_essais / nb_essais)
	return 0

###############################################
# DIFFICULTES / Score / DIFFICULTE et DIFFICULTE sans détour
# 'score': { 'DIFFICULTE': 500000, 'DIFFICULTE_sans_detour': 500000},
###############################################

func modifier_score_DIFFICULTE(score : int) -> void:
	var enregistrement_campagne = lire_dernier_DIFFICULTE()
	if enregistrement_campagne:
		enregistrement_campagne['score']['DIFFICULTE'] = score
		_enregistrer_sauvegarde_joueur()

func modifier_score_DIFFICULTE_sans_detour(score : int) -> void:
	var enregistrement_campagne = lire_dernier_DIFFICULTE()
	if enregistrement_campagne:
		enregistrement_campagne['score']['DIFFICULTE_sans_detour'] = score
		_enregistrer_sauvegarde_joueur()

func lire_score_DIFFICULTE() -> int:
	var enregistrement_campagne = lire_dernier_DIFFICULTE()
	if enregistrement_campagne:
		if enregistrement_campagne.get('score') and enregistrement_campagne.get('score').get('DIFFICULTE'):
			return enregistrement_campagne.get('score').get('DIFFICULTE')
	return 0

func lire_score_DIFFICULTE_sans_detour() -> int: # TODO : INUTILISE !
	var enregistrement_campagne = lire_dernier_DIFFICULTE()
	if enregistrement_campagne:
		if enregistrement_campagne.get('score') and enregistrement_campagne.get('score').get('DIFFICULTE_sans_detour'):
			return enregistrement_campagne.get('score').get('DIFFICULTE_sans_detour')
	return 0


###############################################
# DIFFICULTES / Plateaux
# 	'plateaux': [
# 		{
# 			'nom': "AA .BB .AB ",
# 			'date_debut': 1748785865.997,
# 			'date_fin': 1748785855.0,
# 			'difficulte': 18,
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
	return DIFFICULTE_existe() and not lire_dernier_DIFFICULTE().get('plateaux').is_empty()

func plateau_en_cours() -> bool:
	"Indique si un plateau est en cours de réalisation"
	if plateau_existe():
		var enregistrement_campagne = lire_dernier_DIFFICULTE()
		var plateau = enregistrement_campagne.get('plateaux').back()
		return not plateau.get('date_fin')
	return false

func _initialiser_un_nouveau_plateau(nom : String,
									gameplay : String,
									difficulte : int) -> bool:
	"Crée et initialise un nouveau plateau"
	if not plateau_en_cours():
		var nouveau_plateau = {
			'nom': nom,
			'gameplay': gameplay,
			'date_debut': Time.get_unix_time_from_system(), # Timestamp
			'date_fin': 0.,
			'difficulte': difficulte,
			'statut': 'en cours', # 'en cours', 'abandonné', 'reussi'
			'duree': 0,
			'score': {},
			'coups joués': []
			}
		var enregistrement_campagne = lire_dernier_DIFFICULTE()
		var plateaux = enregistrement_campagne.get('plateaux')
		plateaux.append(nouveau_plateau)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func terminer_plateau() -> void:
	"Enregistre la date de fin d'Un DIFFICULTE"
	if plateau_en_cours():
		var enregistrement_campagne = lire_dernier_DIFFICULTE()
		var plateau = enregistrement_campagne.get('plateaux').back()
		plateau['date_fin'] = Time.get_unix_time_from_system() # Timestamp
		_enregistrer_sauvegarde_joueur()

func _lire_nombre_plateaux() -> int:
	"Retourne le nombre de plateaux achevées"
	if plateau_existe():
		var enregistrement_campagne = lire_dernier_DIFFICULTE()
		if plateau_en_cours():
			return len(enregistrement_campagne.get('plateaux')) - 1
		else:
			return len(enregistrement_campagne.get('plateaux'))
	return 0

###############################################
# DIFFICULTES / Plateaux / Nom
# DIFFICULTES / Plateaux / Date debut
# DIFFICULTES / Plateaux / Date fin
# DIFFICULTES / Plateaux / DIFFICULTE
###############################################

func lire_dernier_plateau() -> Dictionary:
	if plateau_existe():
		var enregistrement_campagne = lire_dernier_DIFFICULTE()
		var plateau = enregistrement_campagne.get('plateaux').back()
		return plateau
	return {}

func lire_nom_plateau() -> String:
	var plateau = lire_dernier_plateau()
	if plateau:
		return plateau.get('nom')
	return ""

func lire_date_debut_plateau() -> float: # TODO : INUTILISE !
	var plateau = lire_dernier_plateau()
	if plateau:
		return plateau.get('date_debut')
	return 0

func lire_date_fin_plateau() -> float: # TODO : INUTILISE !
	var plateau = lire_dernier_plateau()
	if plateau:
		return plateau.get('date_fin')
	return 0

func lire_difficulte_plateau() -> float:
	var plateau = lire_dernier_plateau()
	if plateau:
		return plateau.get('difficulte')
	return 0

###############################################
# DIFFICULTES / Plateaux / Statut
# 'statut': 'en cours', # 'en cours', 'abandonné', 'reussi'
###############################################

func modifier_statut_plateau(statut : String) -> void:
	var plateau = lire_dernier_plateau()
	if plateau:
		plateau['statut'] = statut
		_enregistrer_sauvegarde_joueur()

func _lire_statut_plateau() -> String:
	var plateau = lire_dernier_plateau()
	if plateau:
		return plateau.get('statut')
	return 'en cours'

###############################################
# DIFFICULTES / Plateaux / Durée de partie
###############################################

func modifier_duree_plateau(duree_en_ms : int) -> void: # TODO : INUTILISE !
	var plateau = lire_dernier_plateau()
	if plateau:
		plateau['duree'] = duree_en_ms
		_enregistrer_sauvegarde_joueur()

func _ajouter_duree_plateau(duree_en_ms : int) -> void:
	var plateau = lire_dernier_plateau()
	if plateau:
		plateau['duree'] += duree_en_ms
		_enregistrer_sauvegarde_joueur()

func lire_duree_plateau() -> int: # TODO : INUTILISE !
	var plateau = lire_dernier_plateau()
	if plateau:
		return plateau.get('duree')
	return 0

func lire_le_temps_du_joueur() -> String: # TODO : INUTILISE !
	"""Formater la durée en une chaîne de caractères lisible."""
	var plateau = lire_dernier_plateau()
	if plateau:
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
# DIFFICULTES / Score / DIFFICULTE et DIFFICULTE sans détour
# 'score': { 'duree': 4000, 'ratio_reussite': 2000 }
###############################################

func modifier_score_duree_plateau(score : int) -> void:
	var plateau = lire_dernier_plateau()
	if plateau:
		plateau['score']['duree'] = score
		_enregistrer_sauvegarde_joueur()

func modifier_score_ratio_reussite_plateau(score : int) -> void:
	var plateau = lire_dernier_plateau()
	if plateau:
		plateau['score']['ratio_reussite'] = score
		_enregistrer_sauvegarde_joueur()

func lire_score_duree_plateau() -> int: # TODO : INUTILISE !
	var plateau = lire_dernier_plateau()
	if plateau:
		if plateau.get('score') and plateau.get('score').get('duree'):
			return plateau.get('score').get('duree')
	return 0

func lire_score_ratio_reussite_plateau() -> int: # TODO : INUTILISE !
	var plateau = lire_dernier_plateau()
	if plateau:
		if plateau.get('score') and plateau.get('score').get('ratio_reussite'):
			return plateau.get('score').get('ratio_reussite')
	return 0

###############################################
# DIFFICULTES / Plateaux / Coups joués
# 	'coups joués': [
# 		{'depart': 2, 'arrivee': 1},
# 		{'depart': 2, 'arrivee': 0}
# 	]
###############################################

func _coup_existe() -> bool:
	"Indique si un coup existe"
	return plateau_existe() and not lire_dernier_plateau().get('coups joués').is_empty()

func coup_en_cours() -> bool: # TODO : INUTILISE !
	"Indique si un coup est en cours de réalisation"
	# Le cycle de vie du plateau est celui des coups joués
	return plateau_en_cours()

func ajouter_un_nouveau_coup(depart : int,
							arrivee : int) -> bool:
	"Ajouter un nouveau coup joué"
	if plateau_en_cours():
		var nouveau_coup = {'depart': depart, 'arrivee': arrivee}
		var plateau = lire_dernier_plateau()
		var coups = plateau.get('coups joués')
		coups.append(nouveau_coup)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func terminer_coups() -> void: # TODO : INUTILISE !
	"Enregistre la date de fin des coups joués"
	# Le cycle de vie du plateau est celui des coups joués
	terminer_plateau()

func lire_nombre_coups() -> int: # TODO : INUTILISE !
	"Retourne le nombre de coups joués"
	if _coup_existe():
		var plateau = lire_dernier_plateau()
		return len(plateau.get('coups joués'))
	return 0


# API externe
func gagner_un_plateau(duree_en_ms : int) -> void:
	# Valider le plateau courant (effacer de la liste des plateaux jouables)
	_supprimer_plateau_courant()

	# Ajouter le temps de jeu dans le DIFFICULTE courant
	_ajouter_duree_plateau(duree_en_ms)
	modifier_statut_plateau('reussi')
	terminer_plateau()

func abandonner_un_plateau() -> void:
	# En cas d'abandon, pas d'enrgistrement du temps.
	modifier_statut_plateau('abandonné')
	terminer_plateau()

func commencer_un_plateau() -> void:
	# Ajouter le nouveau plateau
	var prochain_plateau = _lire_prochain_plateau_pour_DIFFICULTE_courant()
	_initialiser_un_nouveau_plateau(
				prochain_plateau.get('nom'),
				prochain_plateau.get('gameplay'),
				prochain_plateau.get('difficulte')
				)

	# Incrémenter le compteur de parties du DIFFICULTE courant
	_incrementer_nombre_de_parties_joueur_pour_DIFFICULTE_courant()

