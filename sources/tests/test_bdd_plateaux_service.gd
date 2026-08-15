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

func test_initialisation_charge_les_niveaux():
	assert_true(singleton.niveau_existe(1))
	assert_true(singleton.niveau_existe(2))
	assert_true(singleton.niveau_existe(10))
	assert_eq(singleton.nb_niveaux(), 3)

func test_niveau_min_et_max():
	assert_eq(singleton.niveau_min(), 1)
	assert_eq(singleton.niveau_max(), 10)

func test_lire_liste_plateaux_du_niveau():
	var liste = singleton.lire_liste_plateaux_du_niveau(1)
	assert_eq(len(liste), 2)
	assert_eq(liste[0]["difficulte"], 1)
	assert_eq(liste[0]["nom"], "AAA.BBB.CCC")
	assert_eq(liste[0]["gameplay"], "CLASSIQUE")
	assert_eq(liste[1]["difficulte"], 2)
	assert_eq(liste[1]["nom"], "DDD.EEE.FFF")
	assert_eq(liste[1]["gameplay"], "MEMOIRE")

	liste = singleton.lire_liste_plateaux_du_niveau(10)
	assert_eq(len(liste), 1)
	assert_eq(liste[0]["difficulte"], 5)
	assert_eq(liste[0]["nom"], "GGG.HHH.III")
	assert_eq(liste[0]["gameplay"], "DEFI_DU_BOSS")

func test_nombre_plateaux_pour_le_niveau():
	assert_eq(singleton.nombre_plateaux_pour_le_niveau(1), 2)
	assert_eq(singleton.nombre_plateaux_pour_le_niveau(2), 1)
	assert_eq(singleton.nombre_plateaux_pour_le_niveau(10), 1)
	assert_eq(singleton.nombre_plateaux_pour_le_niveau(999), 0)

func test_plateau_existe():
	assert_true(singleton.plateau_existe(1, 0))
	assert_true(singleton.plateau_existe(1, 1))
	assert_false(singleton.plateau_existe(1, 2))
	assert_false(singleton.plateau_existe(999, 0))

func test_lire_plateau():
	assert_eq(singleton.lire_plateau(1, 0), "AAA.BBB.CCC")
	assert_eq(singleton.lire_plateau(1, 1), "DDD.EEE.FFF")
	assert_eq(singleton.lire_plateau(1, 99), "")

func test_duplicate_retourne_une_copie():
	var copie = singleton.plateau_liste_difficulte_duplicate()
	assert_eq(copie, singleton.plateau_campagne)
	# Modifier le contenu pour voir que c'est disjoint.
	copie[singleton.nom_niveau(1)][0]["difficulte"] += 1
	assert_ne(copie, singleton.plateau_campagne)
	assert_eq(copie[singleton.nom_niveau(1)][0]["nom"], "AAA.BBB.CCC")
