extends Node

var chemin_campagne = "res://campagne.json"
var plateau_campagne = {
	#"description_Campagne": "Sequence des DIFFICULTES de la campagne",
	#"description_gameplay": ["CLASSIQUE", "MEMOIRE", "DEFI_DU_GOSSE", "DEFI_DU_BOSS", "QUI_PERD_GAGNE", "FLEMMARD", "DOUBLE_FACE", "DICO"],
	#"description_coups_min": "[Facultatif] Longueur de resolution la plus courte",
	#"description_dico": "[Facultatif] Mot à réaliser pour le DICO",
	#"DIFFICULTE_1": [
		#{
			#"difficulte": 10,
			#"gameplay": "CLASSIQUE",
			#"nom": "DDA.CCB.AAB.   .DBC"
		#},
		#{
			#"difficulte": 11,
			#"gameplay": "QUI_PERD_GAGNE",
			#"nom": "AC.BD.CD.EA.FB.FE.  "
		#}
	#],
	#"DIFFICULTE_2": [
		#{
			#"difficulte": 10,
			#"gameplay": "CLASSIQUE",
			#"nom": "DC .ABC.BBA.C  .DAD"
		#},
		#{
			#"difficulte": 11,
			#"gameplay": "QUI_PERD_GAGNE",
			#"nom": " AAC.CB .DB .DDC.BA "
		#}
	#]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialiser_les_plateaux()

func _initialiser_les_plateaux() -> void:
	# Lire la liste des plateaux classés par DIFFICULTES
	var fichier_plateaux = FichiersJsonService.read_json_file(chemin_campagne)
	# LogService.log_debug(fichier_plateaux)
	
	# Copier les DIFFICULTES lus
	if fichier_plateaux:
		if 'liste difficulte des plateaux' in fichier_plateaux:
			LogService.log_erreur("Le fichier des plateaux est obsolète")
		if 'campagne' in fichier_plateaux:
			var dico_campagne = fichier_plateaux.get('campagne')
			for DIFFICULTE in dico_campagne.keys():
				# Copie tous les DIFFICULTES, sauf 'None'
				plateau_campagne[DIFFICULTE] = dico_campagne.get(DIFFICULTE).duplicate(true)

func plateau_liste_difficulte_duplicate() -> Dictionary:
	return plateau_campagne.duplicate(true)

func DIFFICULTE_min() -> int: # TODO : INUTILISE !
	for i in range(0, 300):
		if DIFFICULTE_existe(i):
			return i
	return -1

func DIFFICULTE_max() -> int: # TODO : INUTILISE !
	for i in range(300, 0, -1):
		if DIFFICULTE_existe(i):
			return i
	return -1

func nb_DIFFICULTES() -> int: # TODO : INUTILISE !
	return len(plateau_campagne.keys())

func nom_DIFFICULTE(DIFFICULTE : int) -> String:
	return 'DIFFICULTE_'+str(DIFFICULTE)

func lire_liste_plateaux_du_DIFFICULTE(DIFFICULTE : int) -> Array:
	if DIFFICULTE_existe(DIFFICULTE):
		return plateau_campagne.get(nom_DIFFICULTE(DIFFICULTE))
	return []

func DIFFICULTE_existe(DIFFICULTE : int) -> bool:
	return nom_DIFFICULTE(DIFFICULTE) in plateau_campagne

func nombre_plateaux_pour_le_DIFFICULTE(DIFFICULTE : int) -> int: # TODO : INUTILISE !
	if DIFFICULTE_existe(DIFFICULTE):
		return len(lire_liste_plateaux_du_DIFFICULTE(DIFFICULTE))
	return 0

func plateau_existe(DIFFICULTE : int, indice : int) -> bool:
	return DIFFICULTE_existe(DIFFICULTE) && indice < len(lire_liste_plateaux_du_DIFFICULTE(DIFFICULTE))

# TODO : Ou est-ce utilisé ? Comment ajuster le code ?
func lire_plateau(DIFFICULTE : int, indice : int) -> String: # TODO : INUTILISE !
	if plateau_existe(DIFFICULTE, indice):
		return lire_liste_plateaux_du_DIFFICULTE(DIFFICULTE)[indice].get("nom")
	return ""

# Compatibility wrappers for older "niveau"-based API used in tests and callers
func nom_niveau(niveau : int) -> String:
	return nom_DIFFICULTE(niveau)

func lire_liste_plateaux_du_niveau(niveau : int) -> Array:
	return lire_liste_plateaux_du_DIFFICULTE(niveau)

func niveau_existe(niveau : int) -> bool:
	return DIFFICULTE_existe(niveau)

func nb_niveaux() -> int:
	return nb_DIFFICULTES()

func niveau_min() -> int:
	return DIFFICULTE_min()

func niveau_max() -> int:
	return DIFFICULTE_max()

