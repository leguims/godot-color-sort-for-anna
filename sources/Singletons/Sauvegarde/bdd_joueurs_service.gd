###############################################
# Gestion des sauvegardes de joueurs
###############################################

extends Node

###############################################
# Gestion des niveaux et des plateaux à jouer
###############################################
var sauvegarde_joueur = {
	# Créé dans '_ready()'
	#'nom': 'Alain Konu',
	#'campagne': {  },
	#'nombre_de_parties': {  },
	#'enregistrement_campagne': [ ],
	#'plateaux_libres': {  },
}

# Exemple de sauvegarde avec Un niveau en cours
# {
# 	"nom": "nom joueur",
# 	"nombre_de_parties": { "18": 5, "20": 4, "24": 4 },
#	"campagne": {
#        "niveau_1": [
#            {"difficulte": 1, "gameplay": "CLASSIQUE", "nom": "AAA.BBB.CCC"},
#            {"difficulte": 2, "gameplay": "MEMOIRE", "nom": "DDD.EEE.FFF"}
#        ],
#        "niveau_2": [
#            {"difficulte": 3, "gameplay": "DEFI_DU_GOSSE", "nom": "GGG.HHH.III"}
#        ],
#        "niveau_10": [
#            {"difficulte": 5, "gameplay": "DEFI_DU_BOSS", "nom": "GGG.HHH.III"}
#        ]
#    },
# 	"enregistrement_campagne": [ 
# 		{
# 			'niveau': 20, # TODO : Transformer pour y ecrire le nom du niveau
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
	pcs.fin_niveau.connect(_on_progression_campagne_service_fin_niveau)

	# Creation compte initial 'Alain Konu'
	if not FichiersJsonService.json_file_exists("user://sauvegarde_joueur_00.json"):
		ajouter_un_nouveau_joueur('Alain Konu', 'sauvegarde_joueur_00.json')

func _on_progression_campagne_service_fin_niveau():
	_terminer_niveau()

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
		# Clore toute niveau en cours.
		terminer_plateau()
		_terminer_niveau()
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
#        "niveau_1": [
#            {"difficulte": 1, "gameplay": "CLASSIQUE", "nom": "AAA.BBB.CCC"},
#            {"difficulte": 2, "gameplay": "MEMOIRE", "nom": "DDD.EEE.FFF"}
#        ],....
###############################################

func _lire_prochain_plateau_pour_niveau_courant() -> Dictionary:
	"Désigne le prochain plateau de campagne à jouer pour le niveau courant"
	if le_joueur_existe():
		var str_niveau = lire_nom_niveau_joueur()
		return sauvegarde_joueur.get('campagne').get(str_niveau).pop_front()
	return {}

func _supprimer_plateau_courant() -> bool:
	"Efface le plateau courant."
	if le_joueur_existe() and _lire_statut_plateau() == 'en cours':
		var str_niveau = lire_nom_niveau_joueur()
		var nom_plateau = lire_nom_plateau()
		if nom_plateau in sauvegarde_joueur.get('campagne').get(str_niveau):
			var difficulte_plateau = lire_difficulte_plateau()
			# Ajouter le plateau effacé dans les plateaux libres
			if difficulte_plateau in sauvegarde_joueur.get('plateaux_libres'):
				sauvegarde_joueur.get('plateaux_libres').get(str_niveau).append(nom_plateau)
			else:
				sauvegarde_joueur.get('plateaux_libres')[str_niveau] = [nom_plateau]
			# Effacer le plateau
			sauvegarde_joueur.get('campagne').get(str_niveau).erase(nom_plateau)
		if sauvegarde_joueur.get('campagne').get(str_niveau).is_empty():
			# Le niveau est terminé, effacer sa reference dans les plateaux restants.
			sauvegarde_joueur.get('campagne').erase(str_niveau)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func lire_nombre_de_plateaux_realisables_pour_niveau_courant() -> int: # TODO : INUTILISE !
	if le_joueur_existe():
		var str_niveau = lire_nom_niveau_joueur()
		return len(sauvegarde_joueur.get('campagne').get(str_niveau))
	return 0

func lire_nombre_de_niveaux_realisables() -> int:
	if le_joueur_existe():
		return len(sauvegarde_joueur.get('campagne'))
	return 0

func le_niveau_est_termine(niveau : int) -> bool:
	if le_joueur_existe():
		var str_niveau = lire_nom_niveau(niveau)
		return str_niveau not in sauvegarde_joueur.get('campagne') \
				or sauvegarde_joueur.get('campagne').get(str_niveau).is_empty()
	return true

func la_campagne_est_terminee() -> bool:
	if le_joueur_existe():
		return sauvegarde_joueur.get('campagne').is_empty()
	return true

###############################################
# Nombre de parties
# "nombre_de_parties": { "18": 5, "20": 4, "24": 4 }
###############################################

func _incrementer_nombre_de_parties_joueur_pour_niveau_courant() -> void:
	if le_joueur_existe():
		var str_niveau = lire_nom_niveau_joueur()
		if str_niveau not in sauvegarde_joueur.get('nombre_de_parties'):
			sauvegarde_joueur['nombre_de_parties'][str_niveau] = 0
		sauvegarde_joueur['nombre_de_parties'][str_niveau] += 1
		_enregistrer_sauvegarde_joueur()

func lire_nombre_de_parties_joueur_pour_niveau_courant() -> int:
	if le_joueur_existe():
		var str_niveau = lire_nom_niveau_joueur()
		if str_niveau in sauvegarde_joueur.get('nombre_de_parties'):
			return sauvegarde_joueur.get('nombre_de_parties').get(str_niveau)
	return 0

func lire_nombre_de_parties_joueur_pour_niveau(niveau : int) -> int: # TODO : INUTILISE !
	if le_joueur_existe():
		var str_niveau = lire_nom_niveau(niveau)
		if str_niveau in sauvegarde_joueur.get('nombre_de_parties'):
			return sauvegarde_joueur.get('nombre_de_parties').get(str_niveau)
	return 0




###############################################
# Niveaux
# 	"enregistrement_campagne": [ 
# 		{
# 			'niveau': 20,
#			'date_debut': 1748785865.997,
# 			'date_fin': 0.,
# 			'score': { 'niveau': 500000, 'niveau_sans_detour': 500000},
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

func niveau_existe() -> bool:
	"Indique si un niveau existe"
	return le_joueur_existe() \
			and 'enregistrement_campagne' in sauvegarde_joueur \
			and not sauvegarde_joueur.get('enregistrement_campagne').is_empty()

func lire_dernier_niveau() -> Dictionary:
	"Retourne le dernier niveau"
	if niveau_existe():
		var enregistrement_campagne = sauvegarde_joueur.get('enregistrement_campagne').back()
		return enregistrement_campagne
	return {}

func niveau_en_cours() -> bool:
	"Indique si un niveau est en cours de réalisation"
	var enregistrement_campagne = lire_dernier_niveau()
	if enregistrement_campagne:
		return not enregistrement_campagne.get('date_fin')
	return false

func initialiser_un_nouveau_niveau(niveau : int) -> bool:
	"Crée et initialise un nouveau niveau"
	if not niveau_en_cours():
		var enregistrement_niveau = {
			'niveau': niveau,
			'date_debut': Time.get_unix_time_from_system(), # Timestamp
			'date_fin': 0.,
			'score': {},
			'plateaux': []
			}
		if 'enregistrement_campagne' not in sauvegarde_joueur:
			sauvegarde_joueur['enregistrement_campagne'] = []
		sauvegarde_joueur['enregistrement_campagne'].append(enregistrement_niveau)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func _terminer_niveau() -> void:
	"Enregistre la date de fin d'un niveau"
	var enregistrement_campagne = lire_dernier_niveau()
	if enregistrement_campagne:
		enregistrement_campagne['date_fin'] = Time.get_unix_time_from_system() # Timestamp
		_enregistrer_sauvegarde_joueur()

func lire_nombre_niveaux() -> int: # TODO : INUTILISE !
	"Retourne le nombre de niveaux achevés"
	if niveau_existe():
		if niveau_en_cours():
			return len(sauvegarde_joueur['enregistrement_campagne']) - 1
		else:
			return len(sauvegarde_joueur['enregistrement_campagne'])
	return 0

###############################################
# Niveaux / Niveau debut
# Niveaux / Niveau fin
# Niveaux / Niveau courant
###############################################

func modifier_niveau_joueur(niveau : int) -> void: # TODO : INUTILISE !
	var enregistrement_campagne = lire_dernier_niveau()
	if enregistrement_campagne:
		enregistrement_campagne['niveau'] = niveau
		_enregistrer_sauvegarde_joueur()

func lire_niveau_joueur() -> int:
	var enregistrement_campagne = lire_dernier_niveau()
	if enregistrement_campagne:
		return enregistrement_campagne.get('niveau')
	return 0

func lire_nom_niveau_joueur() -> String:
	return SauvegardeBddPlateauxService.nom_niveau(lire_niveau_joueur())

func lire_nom_niveau(niveau : int) -> String:
	return SauvegardeBddPlateauxService.nom_niveau(niveau)

func lire_niveau_longueur_realisee() -> int:
	var dernier_niveau = lire_dernier_niveau()
	if dernier_niveau:
		var liste_niveaux = []
		# TODO : Revoir l'algo !
		for plateau in dernier_niveau.get('plateaux'):
			var niveau = plateau.get('difficulte')
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

func lire_niveau_longueur_restante() -> int: # TODO : INUTILISE !
	return lire_nombre_de_plateaux_realisables_pour_niveau_courant()

func lire_pourcentage_niveau_realise() -> int:
	"Pourcentage de réalisation (retourne 99 pour 99%, 15 pour 15% ...)"
	if niveau_en_cours():
		var nb_niveaux_realises = lire_niveau_longueur_realisee()
		var nb_niveaux_restant = lire_niveau_longueur_restante()
		var nb_niveaux_totaux = nb_niveaux_realises + nb_niveaux_restant
		return roundi(100. * nb_niveaux_realises / nb_niveaux_totaux)
	return 0

###############################################
# Niveaux / Date debut
# Niveaux / Date fin
###############################################

func lire_date_debut_niveau() -> float: # TODO : INUTILISE !
	var enregistrement_campagne = lire_dernier_niveau()
	if enregistrement_campagne:
		return enregistrement_campagne.get('date_debut')
	return 0

func lire_date_fin_niveau() -> float: # TODO : INUTILISE !
	var enregistrement_campagne = lire_dernier_niveau()
	if enregistrement_campagne:
		return enregistrement_campagne.get('date_fin')
	return 0

###############################################
# Niveaux / Longueur detour
###############################################

func lire_ratio_reussite_niveau() -> int:
	"Pourcentage de réussite du niveau (retourne 99 pour 99%, 15 pour 15% ...)"
	if niveau_existe():
		# TODO : Revoir l'algo !
		var nb_essais  = _lire_nombre_plateaux()
		var nb_succes = lire_niveau_longueur_realisee()
		return roundi(100. * nb_essais / nb_essais)
	return 0

###############################################
# Niveaux / Score / Niveau et Niveau sans détour
# 'score': { 'niveau': 500000, 'niveau_sans_detour': 500000},
###############################################

func modifier_score_niveau(score : int) -> void:
	var enregistrement_campagne = lire_dernier_niveau()
	if enregistrement_campagne:
		enregistrement_campagne['score']['niveau'] = score
		_enregistrer_sauvegarde_joueur()

func modifier_score_niveau_sans_detour(score : int) -> void:
	var enregistrement_campagne = lire_dernier_niveau()
	if enregistrement_campagne:
		enregistrement_campagne['score']['niveau_sans_detour'] = score
		_enregistrer_sauvegarde_joueur()

func lire_score_niveau() -> int:
	var enregistrement_campagne = lire_dernier_niveau()
	if enregistrement_campagne:
		if enregistrement_campagne.get('score') and enregistrement_campagne.get('score').get('niveau'):
			return enregistrement_campagne.get('score').get('niveau')
	return 0

func lire_score_niveau_sans_detour() -> int: # TODO : INUTILISE !
	var enregistrement_campagne = lire_dernier_niveau()
	if enregistrement_campagne:
		if enregistrement_campagne.get('score') and enregistrement_campagne.get('score').get('niveau_sans_detour'):
			return enregistrement_campagne.get('score').get('niveau_sans_detour')
	return 0


###############################################
# Niveaux / Plateaux
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
	return niveau_existe() and not lire_dernier_niveau().get('plateaux').is_empty()

func plateau_en_cours() -> bool:
	"Indique si un plateau est en cours de réalisation"
	if plateau_existe():
		var enregistrement_campagne = lire_dernier_niveau()
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
		var enregistrement_campagne = lire_dernier_niveau()
		var plateaux = enregistrement_campagne.get('plateaux')
		plateaux.append(nouveau_plateau)
		_enregistrer_sauvegarde_joueur()
		return true
	return false

func terminer_plateau() -> void:
	"Enregistre la date de fin d'Un niveau"
	if plateau_en_cours():
		var enregistrement_campagne = lire_dernier_niveau()
		var plateau = enregistrement_campagne.get('plateaux').back()
		plateau['date_fin'] = Time.get_unix_time_from_system() # Timestamp
		_enregistrer_sauvegarde_joueur()

func _lire_nombre_plateaux() -> int:
	"Retourne le nombre de plateaux achevées"
	if plateau_existe():
		var enregistrement_campagne = lire_dernier_niveau()
		if plateau_en_cours():
			return len(enregistrement_campagne.get('plateaux')) - 1
		else:
			return len(enregistrement_campagne.get('plateaux'))
	return 0

###############################################
# Niveaux / Plateaux / Nom
# Niveaux / Plateaux / Date debut
# Niveaux / Plateaux / Date fin
# Niveaux / Plateaux / Niveau
###############################################

func lire_dernier_plateau() -> Dictionary:
	if plateau_existe():
		var enregistrement_campagne = lire_dernier_niveau()
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
# Niveaux / Plateaux / Statut
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
# Niveaux / Plateaux / Durée de partie
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
# Niveaux / Score / Niveau et Niveau sans détour
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
# Niveaux / Plateaux / Coups joués
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

	# Ajouter le temps de jeu dans le niveau courant
	_ajouter_duree_plateau(duree_en_ms)
	modifier_statut_plateau('reussi')
	terminer_plateau()

func abandonner_un_plateau() -> void:
	# En cas d'abandon, pas d'enrgistrement du temps.
	modifier_statut_plateau('abandonné')
	terminer_plateau()

func commencer_un_plateau() -> void:
	# Ajouter le nouveau plateau
	var prochain_plateau = _lire_prochain_plateau_pour_niveau_courant()
	_initialiser_un_nouveau_plateau(
				prochain_plateau.get('nom'),
				prochain_plateau.get('gameplay'),
				prochain_plateau.get('difficulte')
				)

	# Incrémenter le compteur de parties du niveau courant
	_incrementer_nombre_de_parties_joueur_pour_niveau_courant()
