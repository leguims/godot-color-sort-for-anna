extends GutTest

var singleton

func before_all():
	# Charger ton singleton
	singleton = load("res://Singletons/Sauvegarde/bdd_plateaux_service.gd").new()

func before_each():
	# Réinitialiser le chemin JSON avant chaque test
	singleton.chemin_campagne = "res://tests/bdd_plateaux_service_campagne.json"

	# Réinitialiser le singleton
	singleton.plateau_campagne.clear()
	singleton._initialiser_les_plateaux()

# ---------------------------------------------------------
# TESTS
# ---------------------------------------------------------

func test_duplicate_retourne_une_copie():
	var copie = singleton.plateau_liste_niveaux_duplicate()
	assert_eq(copie, singleton.plateau_campagne)
	# Modifier le contenu pour voir que c'est disjoint.
	copie[singleton.nom_niveau(1)][0]["difficulte"] += 1
	assert_ne(copie, singleton.plateau_campagne)
	assert_eq(copie[singleton.nom_niveau(1)][0]["nom"], "AAA.BBB.CCC")
