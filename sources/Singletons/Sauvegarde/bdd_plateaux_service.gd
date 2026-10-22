extends Node

var chemin_campagne = "res://campagne.json"
var _nom_campagne : String = ""
var niveaux_campagne = {
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
		for cle_nom_campagne in fichier_plateaux.keys():
			if 'campagne' in cle_nom_campagne:
				_nom_campagne = cle_nom_campagne
				var dico_campagne = fichier_plateaux.get(_nom_campagne)
				if dico_campagne:
					niveaux_campagne.clear() # Reset de la precedente campagne inachevée
					for cle_nom_niveau in dico_campagne.keys():
						if 'niveau' in cle_nom_niveau:
							# Copie tous les niveaux, sauf 'None'
							niveaux_campagne[cle_nom_niveau] = dico_campagne.get(cle_nom_niveau).duplicate(true)

func nom_campagne() -> String:
	return _nom_campagne

func nom_niveau(niveau : int) -> String:
	if niveau > 0:
		return 'niveau_' + str(niveau)
	return ""

func plateau_liste_niveaux_duplicate() -> Dictionary:
	return niveaux_campagne.duplicate(true)
