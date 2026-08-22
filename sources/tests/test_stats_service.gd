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
		"campagne": {
			"niveau_1": [
				{"nom": "R1"},
				{"nom": "R2"}
			],
			"niveau_2": [
				{"nom": "R3"}
			]
		},
		"enregistrement_campagne": [
			{
				"nom": "niveau_1",
				"date_debut": 1700000000,
				"date_fin": 1700001000,
				"plateaux": [
					{"nom": "A", "date_debut": 1700000010, "duree": 10000, "difficulte": 1, "statut": "reussi"},
					{"nom": "B", "date_debut": 1700000020, "duree": 11000, "difficulte": 2, "statut": "abandonné"},
					{"nom": "C", "date_debut": 1700000030, "duree": 9000, "difficulte": 3, "statut": "reussi"}
				]
			},
			{
				"nom": "niveau_2",
				"date_debut": 1700002000,
				"date_fin": 0,
				"plateaux": [
					{"nom": "D", "date_debut": 1700002010, "duree": 15000, "difficulte": 2, "statut": "reussi"},
					{"nom": "A", "date_debut": 1700002020, "duree": 8000, "difficulte": 4, "statut": "reussi"}
				]
			}
		]
	}


func after_each():
	SauvegardeBddJoueursService.sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale


func test_campagne_et_niveau_statistiques():
	assert_eq(service.campagne_nom_joueur(), "Joueur Test")
	assert_true(abs(service.campagne_taux_completion() - (4.0 / 7.0)) < 0.0001)
	assert_true(abs(service.campagne_taux_reussite() - 0.8) < 0.0001)
	assert_eq(service.campagne_serie_max_reussite(), 3)

	assert_true(abs(service.niveau_taux_completion() - (2.0 / 3.0)) < 0.0001)
	assert_eq(service.niveau_terminees(), 1)
	assert_eq(service.niveau_longueur_max(), 2)

	var infos_taux = service.niveau_taux_reussite_infos()
	assert_true(abs(infos_taux.get("taux_min") - (2.0 / 3.0)) < 0.0001)
	assert_eq(infos_taux.get("taux_min_lg"), 2)
	assert_true(abs(infos_taux.get("taux_max") - 1.0) < 0.0001)
	assert_eq(infos_taux.get("taux_max_lg"), 2)


func test_plateau_statistiques():
	assert_true(abs(service.campagne_temps_total_en_s() - 53.0) < 0.0001)
	assert_true(abs(service.plateau_temps_moyen_en_s() - 10.6) < 0.0001)

	var plus_rapide = service.plateau_plus_rapide_infos()
	assert_true(abs(plus_rapide.get("temps_en_s") - 8.0) < 0.0001)
	assert_eq(plus_rapide.get("difficulte"), 4)

	var plus_lent = service.plateau_plus_lent_infos()
	assert_true(abs(plus_lent.get("temps_en_s") - 15.0) < 0.0001)
	assert_eq(plus_lent.get("difficulte"), 2)

	var plus_galere = service.plateau_plus_galere_infos()
	assert_eq(plus_galere.get("nom"), "A")
	assert_eq(plus_galere.get("essais"), 2)
	assert_eq(plus_galere.get("difficulte"), 1)
