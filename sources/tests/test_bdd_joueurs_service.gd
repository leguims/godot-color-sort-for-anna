extends GutTest

var singleton
const RACINE_TEST = "tests/test_bdd_joueurs_service"

func _nettoyer_fichiers_utilisateur():
	FichiersJsonService.remove_json_file("test_sauvegarde_joueur_XX.json")
	FichiersJsonService.remove_json_file("sauvegarde_joueur_00.json")
	FichiersJsonService.remove_json_file("liste_des_joueurs.json")
	FichiersJsonService.remove_json_file("scores.json")

func before_all():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_utilisateur()

func before_each():
	_nettoyer_fichiers_utilisateur()
	singleton = add_child_autofree(load("res://Singletons/Sauvegarde/bdd_joueurs_service.gd").new())
	var contenu = FichiersJsonService.read_json_file("res://tests/bdd_plateaux_service_campagne_sauvegarde_joueur_XX.json")
	FichiersJsonService.write_json_file("test_sauvegarde_joueur_XX.json", contenu)
	singleton._lire_sauvegarde_joueur("test_sauvegarde_joueur_XX.json")

func after_each():
	_nettoyer_fichiers_utilisateur()

func after_all():
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()


# ---------------------------------------------------------
# TESTS SUR LE JOUEUR
# ---------------------------------------------------------

func test_nom_joueur():
	assert_eq(singleton.lire_nom_joueur(), "Alain Konu")


func test_le_joueur_existe():
	assert_true(singleton.le_joueur_existe())


# ---------------------------------------------------------
# TESTS SUR LA CAMPAGNE
# ---------------------------------------------------------

func test_nombre_de_niveaux_realisables():
	assert_eq(singleton.lire_nombre_de_niveaux_realisables(), 3)


func test_la_campagne_est_terminee():
	assert_false(singleton.la_campagne_est_terminee())


func test_le_niveau_est_termine():
	assert_true(singleton.le_niveau_est_termine(1))
	assert_false(singleton.le_niveau_est_termine(2))
	assert_false(singleton.le_niveau_est_termine(3))
	assert_false(singleton.le_niveau_est_termine(4))
	assert_true(singleton.le_niveau_est_termine(999))


# ---------------------------------------------------------
# TESTS SUR Le niveau
# ---------------------------------------------------------

func test_niveau_existe():
	assert_true(singleton.niveau_existe())


func test_niveau_en_cours():
	assert_true(singleton.niveau_en_cours())


func test_lire_niveau_joueur():
	assert_eq(singleton.lire_niveau_joueur(), 14)


func test_ratio_reussite():
	var ratio = singleton.lire_ratio_reussite_niveau()
	assert_true(ratio >= 0 and ratio <= 100)


# ---------------------------------------------------------
# TESTS SUR LES PLATEAUX
# ---------------------------------------------------------

func test_plateau_existe():
	assert_true(singleton.plateau_existe())


func test_plateau_en_cours():
	assert_false(singleton.plateau_en_cours()) # dernier plateau a une date_fin != 0


func test_lire_nom_plateau():
	assert_eq(singleton.lire_nom_plateau(), "AC.BD.CD.EA.FB.FE.  ")


func test_lire_duree_plateau():
	assert_eq(singleton.lire_duree_plateau(), 15098)


func test_lire_score_duree_plateau():
	assert_eq(singleton.lire_score_duree_plateau(), 1020)


func test_lire_score_ratio_reussite_plateau():
	assert_eq(singleton.lire_score_ratio_reussite_plateau(), 77)


func test_lire_nombre_coups():
	assert_eq(singleton.lire_nombre_coups(), 7)


# ---------------------------------------------------------
# TESTS SUR LES COUPS
# ---------------------------------------------------------

func test_ajouter_un_nouveau_coup():
	# Pas de plateau en cours pour ajouter un nouveau coup
	assert_false(singleton.ajouter_un_nouveau_coup(9, 9))

	# TODO : completer le test
	# On ajoute un coup sur le nouveau plateau
	# singleton.commencer_un_plateau()
	# var plateau_avant = singleton.lire_nombre_coups()
	# assert_true(singleton.ajouter_un_nouveau_coup(1, 2))
	# var plateau_apres = singleton.lire_nombre_coups()
	# assert_eq(plateau_apres, plateau_avant + 1)
