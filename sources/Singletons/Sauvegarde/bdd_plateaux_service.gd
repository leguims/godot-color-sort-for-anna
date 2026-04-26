extends Node

# Dico : {'difficulte': [liste_plateaux]}
var plateau_liste_difficulte = {
	#'3': [
	#	"AA .BB .CC .ABC"
	#]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialiser_les_plateaux()

func _initialiser_les_plateaux() -> void:
	# Lire la liste des plateaux classés par niveaux
	var fichier_plateaux = FichiersJsonService.read_json_file("res://Solutions_classees.json")
	# print(fichier_plateaux)
	
	# Copier les niveaux lus
	if fichier_plateaux:
		if 'liste difficulte des plateaux' in fichier_plateaux:
			var dico_difficulte = fichier_plateaux.get('liste difficulte des plateaux')
			for difficulte in dico_difficulte.keys():
				# Copie tous les niveaux, sauf 'None'
				plateau_liste_difficulte[difficulte] = dico_difficulte.get(difficulte).duplicate(true)
				# # Afficher un apercu du niveau
				# print("Difficulté : ", difficulte)
				# var cpt = 0
				# for plateau in dico_difficulte.get(difficulte):
				# 	print("   - plateaux : ", plateau)
				# 	cpt += 1
				# 	if cpt >= 5:
				# 		break

func plateau_liste_difficulte_duplicate() -> Dictionary:
	return plateau_liste_difficulte.duplicate(true)

func niveau_min() -> int:
	for i in range(0, 300):
		if niveau_existe(i):
			return i
	return -1

func niveau_max() -> int:
	for i in range(300, 0, -1):
		if niveau_existe(i):
			return i
	return -1

func nb_niveaux() -> int:
	var nb_niveaux = 0
	for i in range(0, 300):
		if niveau_existe(i):
			nb_niveaux += 1
	return nb_niveaux

func niveau_existe(niveau : int) -> bool:
	return str(niveau) in plateau_liste_difficulte

func nombre_plateaux_pour_le_niveau(niveau : int) -> int:
	if niveau_existe(niveau):
		return len(plateau_liste_difficulte.get(str(niveau)))
	return 0

func plateau_existe(niveau : int, indice : int) -> bool:
	return niveau_existe(niveau) && indice < len(plateau_liste_difficulte.get(str(niveau)))

func lire_plateau(niveau : int, indice : int) -> String:
	if plateau_existe(niveau, indice):
		return plateau_liste_difficulte.get(str(niveau))[indice]
	return ""
