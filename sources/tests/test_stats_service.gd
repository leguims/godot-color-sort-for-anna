extends GutTest

var service
var sauvegarde_joueur_initiale
var fichier_sauvegarde_initial
var configuration_initiale


func before_each():
	service = load("res://Singletons/stats_service.gd").new()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService.sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)

	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	SauvegardeBddJoueursService.fichier_sauvegarde = "test_stats_service.json"
	SauvegardeBddJoueursService.sauvegarde_joueur = {
		"nom": "Joueur Test",
		# Nouvelle convention : 'campagne' ne contient que les niveaux actifs.
		# Les niveaux terminés sont archivés dans 'enregistrement_campagne' et sortis de la campagne active.
		# En jeu libre, les plateaux sortis sont indexés par leur difficulté dans 'plateaux_libres'.
		"campagne": {
			"niveau_2": [
				{"nom": "R3", "difficulte": 2}
			],
			"niveau_3": [
				{"nom": "R1", "difficulte": 1},
				{"nom": "R2", "difficulte": 2}
			]
		},
		"enregistrement_campagne": [
			{
				"nom": "niveau_1",
				"date_debut": 1700000000,
				"date_fin": 1700001000,
				"plateaux": [
					{"nom": "A1", "date_debut": 1700000010, "duree": 10000, "difficulte": 1, "statut": "reussi"},
					{"nom": "B", "date_debut": 1700000020, "duree": 11000, "difficulte": 2, "statut": "abandonné"},
					{"nom": "B", "date_debut": 1700000030, "duree": 15000, "difficulte": 2, "statut": "reussi"},
					{"nom": "C", "date_debut": 1700000040, "duree": 9000, "difficulte": 3, "statut": "reussi"}
				]
			},
			{
				"nom": "niveau_2",
				"date_debut": 1700002000,
				"date_fin": 0,
				"plateaux": [
					{"nom": "D", "date_debut": 1700002010, "duree": 15000, "difficulte": 2, "statut": "reussi"},
					{"nom": "A2", "date_debut": 1700002020, "duree": 8000, "difficulte": 4, "statut": "reussi"}
				]
			}
		],
		"plateaux_libres": {
			"1": [{"nom": "A1"}],
			"2": [{"nom": "B"}, {"nom": "D"}],
			"3": [{"nom": "C"}],
			"4": [{"nom": "A2"}]
		}
	}


func after_each():
	SauvegardeBddJoueursService.sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale


func test_campagne_et_niveau_statistiques():
	var campagne = SauvegardeBddJoueursService.sauvegarde_joueur.get("campagne", {})
	var historique = SauvegardeBddJoueursService.sauvegarde_joueur.get("enregistrement_campagne", [])

	assert_false("niveau_1" in campagne)
	assert_true("niveau_2" in campagne)
	assert_true("niveau_3" in campagne)
	assert_true(historique.size() >= 1)
	assert_eq(historique[0].get("nom"), "niveau_1")
	assert_true("1" in SauvegardeBddJoueursService.sauvegarde_joueur.get("plateaux_libres", {}))
	assert_true("2" in SauvegardeBddJoueursService.sauvegarde_joueur.get("plateaux_libres", {}))
	assert_true("3" in SauvegardeBddJoueursService.sauvegarde_joueur.get("plateaux_libres", {}))
	assert_true("4" in SauvegardeBddJoueursService.sauvegarde_joueur.get("plateaux_libres", {}))

	assert_eq(service.campagne_nom_joueur(), "Joueur Test")
	assert_eq(service.nombre_de_plateau_inacheves(), 3)
	assert_eq(service.nombre_de_plateau_acheves(), 5)
	assert_true(abs(service.campagne_taux_completion() - (5.0 / 8.0)) < 0.0001)
	assert_true(abs(service.campagne_taux_reussite() - (5.0 / 6.0)) < 0.0001)
	assert_eq(service.campagne_serie_max_reussite(), 4)

	assert_true(abs(service.niveau_taux_completion() - (2.0 / 3.0)) < 0.0001)
	assert_eq(service.niveau_terminees(), 1)
	assert_eq(service.niveau_longueur_max(), 3)

	var infos_taux = service.niveau_taux_reussite_infos()
	assert_true(abs(infos_taux.get("taux_min") - 0.75) < 0.0001)
	assert_eq(infos_taux.get("taux_min_lg"), 3)
	assert_true(abs(infos_taux.get("taux_max") - 1.0) < 0.0001)
	assert_eq(infos_taux.get("taux_max_lg"), 2)


func test_plateau_statistiques():
	assert_true(abs(service.campagne_temps_total_en_s() - 68.0) < 0.0001)
	assert_true(abs(service.plateau_temps_moyen_en_s() - (68.0 / 6.0)) < 0.0001)

	var plus_rapide = service.plateau_plus_rapide_infos()
	assert_true(abs(plus_rapide.get("temps_en_s") - 8.0) < 0.0001)
	assert_eq(plus_rapide.get("difficulte"), 4)

	var plus_lent = service.plateau_plus_lent_infos()
	assert_true(abs(plus_lent.get("temps_en_s") - 15.0) < 0.0001)
	assert_eq(plus_lent.get("difficulte"), 2)

	var plus_galere = service.plateau_plus_galere_infos()
	assert_eq(plus_galere.get("nom"), "B")
	assert_eq(plus_galere.get("essais"), 2)
	assert_eq(plus_galere.get("difficulte"), 2)
