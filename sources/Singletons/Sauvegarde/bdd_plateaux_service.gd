extends Node

var chemin_campagne = "res://campagne.json"
var plateau_campagne = {
	#"description_Campagne": "Sequence des niveaux de la campagne",
	#"description_gameplay": ["CLASSIQUE", "MEMOIRE", "DEFI_DU_GOSSE", "DEFI_DU_BOSS", "QUI_PERD_GAGNE", "FLEMMARD", "DOUBLE_FACE", "DICO"],
	#"description_coups_min": "[Facultatif] Longueur de resolution la plus courte",
	#"description_dico": "[Facultatif] Mot à réaliser pour le DICO",
	#"niveau_1": [
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
	#"niveau_2": [
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
	# Lire la liste des plateaux classés par niveaux
	var fichier_plateaux = FichiersJsonService.read_json_file(chemin_campagne)
	# LogService.log_debug(fichier_plateaux)
	
	# Copier les niveaux lus
	if fichier_plateaux:
		if 'liste difficulte des plateaux' in fichier_plateaux:
			LogService.log_erreur("Le fichier des plateaux est obsolète")
		if 'campagne' in fichier_plateaux:
			var dico_campagne = fichier_plateaux.get('campagne')
			for niveau in dico_campagne.keys():
				# Copie tous les niveaux, sauf 'None'
				plateau_campagne[niveau] = dico_campagne.get(niveau).duplicate(true)

func plateau_liste_difficulte_duplicate() -> Dictionary:
	return plateau_campagne.duplicate(true)

func niveau_min() -> int: # TODO : INUTILISE !
	for i in range(0, 300):
		if niveau_existe(i):
			return i
	return -1

func niveau_max() -> int: # TODO : INUTILISE !
	for i in range(300, 0, -1):
		if niveau_existe(i):
			return i
	return -1

func nb_niveaux() -> int: # TODO : INUTILISE !
	return len(plateau_campagne.keys())

func nom_niveau(niveau : int) -> String:
	return 'niveau_'+str(niveau)

func lire_liste_plateaux_du_niveau(niveau : int) -> Array:
	if niveau_existe(niveau):
		return plateau_campagne.get(nom_niveau(niveau))
	return []

func niveau_existe(niveau : int) -> bool:
	return nom_niveau(niveau) in plateau_campagne

func nombre_plateaux_pour_le_niveau(niveau : int) -> int: # TODO : INUTILISE !
	if niveau_existe(niveau):
		return len(lire_liste_plateaux_du_niveau(niveau))
	return 0

func plateau_existe(niveau : int, indice : int) -> bool:
	return niveau_existe(niveau) && indice < len(lire_liste_plateaux_du_niveau(niveau))

# TODO : Ou est-ce utilisé ? Comment ajuster le code ?
func lire_plateau(niveau : int, indice : int) -> String: # TODO : INUTILISE !
	if plateau_existe(niveau, indice):
		return lire_liste_plateaux_du_niveau(niveau)[indice].get("nom")
	return ""
