extends GutTest

var service
var sauvegarde_joueur_initiale
var fichier_sauvegarde_initial
var configuration_initiale
var tableau_scores_initial
const RACINE_TEST = "tests/test_score_service"

func _nettoyer_fichiers_utilisateur():
	FichiersJsonService.effacer_racine_utilisateur()

func _activer_joueur_test():
	FichiersJsonService.write_json_file("test_score_service.json", SauvegardeBddJoueursService._sauvegarde_joueur)
	assert_true(SauvegardeBddJoueursService.choisir_le_joueur("Joueur Test", "test_score_service.json"))

func before_each():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_utilisateur()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	tableau_scores_initial = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	service = add_child_autofree(load("res://Singletons/score_service.gd").new())

	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	var nom_anna = service.lire_nom_anna_triche()
	SauvegardeTableauDesScoresService.liste_des_scores = [
		{"nom": "Joueur Test", "rang": 1, "score": 0, "score_txt": "0"},
		{"nom": nom_anna, "rang": 2, "score": 0, "score_txt": "0"}
	]
	SauvegardeBddJoueursService._sauvegarde_joueur = {
		"nom": "Joueur Test",
		"nom_campagne": "campagne_test",
		"campagne": {
			"niveau_2": [{"nom": "R3", "difficulte": 2, "gameplay": "CLASSIQUE"}],
			"niveau_3": [{"nom": "R1", "difficulte": 1, "gameplay": "DEFI_DU_GOSSE"}, {"nom": "R2", "difficulte": 2, "gameplay": "DEFI_DU_BOSS"}]
		},
		"enregistrement_campagne": [
			{
				"campagne": "campagne_test",
				"date_debut": 1700000000,
				"date_fin": 0,
				"score": {},
				"niveaux": [
					{
						"niveau": "niveau_1",
						"date_debut": 1700000000,
						"date_fin": 1700001000,
						"score": {},
						"plateaux": [
							{"nom": "A1", "date_debut": 1700000010, "date_fin": 1700010010, "duree": 10000, "difficulte": 1, "statut": "reussi"},
							{"nom": "B", "date_debut": 1700000020, "date_fin": 1700011020, "duree": 11000, "difficulte": 2, "statut": "abandonné"},
							{"nom": "B2", "date_debut": 1700000030, "date_fin": 1700015030, "duree": 15000, "difficulte": 2, "statut": "reussi"},
							{"nom": "C", "date_debut": 1700000040, "date_fin": 1700009040, "duree": 9000, "difficulte": 3, "statut": "reussi"}
						]
					},
					{
						"niveau": "niveau_2",
						"date_debut": 1700002000,
						"date_fin": 0,
						"score": {},
						"plateaux": [
							{"nom": "D", "date_debut": 1700002010, "date_fin": 1700017010, "duree": 15000, "difficulte": 2, "statut": "reussi"},
							{"nom": "A2", "date_debut": 1700002020, "date_fin": 0, "duree": 8000, "difficulte": 4, "statut": "en_cours"}
						]
					}
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
	_activer_joueur_test()

func after_each():
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale
	SauvegardeTableauDesScoresService.liste_des_scores = tableau_scores_initial
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _niveau_en_cours_avec_plateau_actif() -> void:
	var niveau = SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne")[0].get("niveaux").back()
	var dernier_plateau = niveau.get("plateaux").back()
	dernier_plateau["statut"] = "en_cours"
	dernier_plateau["duree"] = 8000
	dernier_plateau["difficulte"] = 4
	SauvegardeBddJoueursService._enregistrer_sauvegarde_joueur()

func test_mettre_a_jour_score_duree_et_ratio_reussite_sont_calcules():
	var score_duree = service.mettre_a_jour_score_duree()
	assert_eq(score_duree.get("type"), "duree")
	assert_true(score_duree.get("points", 0) >= 0)

	var score_ratio = service.mettre_a_jour_score_ratio_reussite()
	assert_eq(score_ratio.get("type"), "ratio_reussite")
	assert_true(score_ratio.get("points", 0) >= 0)

func test_mettre_a_jour_score_duree_couvre_les_seuils_de_difficulte():
	for diff in [5, 9, 15, 30, 55, 75, 90, 120]:
		_set_last_plateau_difficulte(diff)
		var score = service.mettre_a_jour_score_duree()
		assert_eq(score.get("type"), "duree")
		assert_true(score.get("points", 0) >= 0)

func test_mettre_a_jour_score_ratio_reussite_est_calcule_avec_precision():
	# Niveau_2 (le dernier de l'enregistrement) : 1 plateau réussi ("D") sur
	# 1 plateau achevé (le second, "A2", est encore "en cours" et n'est pas
	# comptabilisé) : ratio = 100%, niveau = 2.
	var score_ratio = service.mettre_a_jour_score_ratio_reussite()
	assert_eq(score_ratio.get("ratio"), 100)
	assert_eq(score_ratio.get("points"), 1000) # 500 * niveau(2) * ratio(1.0)

func test_mettre_a_jour_score_duree_avec_duree_totale_nulle_ne_rapporte_aucun_point():
	# Un plateau achevé ("date_fin" non nul) avec "duree" à 0 protège la
	# division (ratio_temps = 0) : aucun bonus de durée ne doit être accordé.
	var niveau = SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne")[0].get("niveaux").back()
	var plateau_courant = niveau.get("plateaux").back()
	plateau_courant["date_fin"] = 1700010020
	plateau_courant["duree"] = 0

	var score_duree = service.mettre_a_jour_score_duree()
	assert_eq(score_duree.get("points"), 0)

func test_mettre_a_jour_score_pour_victoire_retourne_une_grille_complete():
	_level_finishes_current_level_as_won()
	var score = service.mettre_a_jour_score_pour_victoire()

	assert_true(score.has("duree"))
	assert_true(score.has("ratio_reussite"))
	assert_true(score.has("niveau"))
	assert_true(score.has("niveau_parfait"))
	assert_true(score.has("campagne"))
	assert_true(score.get("duree").get("points", 0) >= 0)
	assert_true(score.get("ratio_reussite").get("points", 0) >= 0)
	assert_true(score.get("niveau").get("points", 0) >= 0)

func test_mettre_a_jour_score_niveau_ne_declenche_pas_si_niveau_encore_en_cours():
	var niveau = SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne")[0].get("niveaux").back()
	niveau["date_fin"] = 0
	var result = service.mettre_a_jour_score_niveau()
	assert_eq(result, {})

func test_mettre_a_jour_score_niveau_declenche_quand_le_niveau_est_acheve():
	var niveau = SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne")[0].get("niveaux").back()
	niveau["date_fin"] = 1700003000
	var result = service.mettre_a_jour_score_niveau()
	assert_eq(result.get("type"), "niveau")
	assert_true(result.get("points", 0) >= 0)

func test_mettre_a_jour_score_niveau_parfait_ne_declenche_pas_si_niveau_encore_en_cours():
	var niveau = SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne")[0].get("niveaux").back()
	niveau["date_fin"] = 0
	niveau["plateaux"] = [{"nom": "D", "date_debut": 1700002010, "date_fin": 1700017010, "duree": 15000, "difficulte": 2, "statut": "reussi"}]
	var result = service.mettre_a_jour_score_niveau_parfait()
	assert_eq(result, {})

func test_mettre_a_jour_score_niveau_parfait_ne_declenche_pas_si_le_niveau_nest_pas_parfait():
	# Un plateau "abandonné" dans le niveau fait chuter le ratio de réussite
	# sous 100% : le bonus "niveau_parfait" ne doit pas se déclencher.
	var niveau = SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne")[0].get("niveaux").back()
	niveau["date_fin"] = 1700003000
	niveau["plateaux"] = [
		{"nom": "D", "date_debut": 1700002010, "date_fin": 1700017010, "duree": 15000, "difficulte": 2, "statut": "reussi"},
		{"nom": "D2", "date_debut": 1700002020, "date_fin": 1700017020, "duree": 10000, "difficulte": 2, "statut": "abandonné"}
	]
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"].erase("niveau_2")
	var result = service.mettre_a_jour_score_niveau_parfait()
	assert_eq(result, {})

func test_mettre_a_jour_score_niveau_parfait_declenche_quand_le_niveau_est_parfait():
	var niveau = SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne")[0].get("niveaux").back()
	niveau["date_fin"] = 1700003000
	niveau["plateaux"] = [{"nom": "D", "date_debut": 1700002010, "date_fin": 1700017010, "duree": 15000, "difficulte": 2, "statut": "reussi"}]
	# Terminer le niveau dans la campagne
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"].erase("niveau_2")
	var result = service.mettre_a_jour_score_niveau_parfait()
	assert_eq(result.get("type"), "niveau_parfait")
	assert_true(result.get("points", 0) >= 0)

func test_mettre_a_jour_score_campagne_ne_declenche_pas_si_campagne_incomplete():
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"] = {"niveau_4": [{"nom": "R4", "difficulte": 1}]}
	var result = service.mettre_a_jour_score_campagne()
	assert_eq(result, {})

func test_mettre_a_jour_score_campagne_declenche_si_la_campagne_est_terminee():
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"] = {}
	var score_avant = SauvegardeTableauDesScoresService.lire_score_joueur("Joueur Test")
	var result = service.mettre_a_jour_score_campagne()
	var points_attendus = roundi(service.FIN_CAMPAGNE * StatsService.campagne_taux_reussite())
	assert_eq(result.get("type"), "campagne")
	assert_eq(result.get("points"), points_attendus)
	assert_eq(SauvegardeTableauDesScoresService.lire_score_joueur("Joueur Test"), score_avant + points_attendus)

func test_nouveau_joueur_est_nom_anna_triche():
	assert_true(service.nouveau_joueur_est_nom_anna_triche("Anna"))
	assert_true(service.nouveau_joueur_est_nom_anna_triche("anna"))
	assert_false(service.nouveau_joueur_est_nom_anna_triche("Joueur Test"))

func test_lire_nom_anna_triche_contient_anna():
	var nom = service.lire_nom_anna_triche()
	assert_true(nom.to_lower().find("anna") >= 0)

func test_bonus_score_anna_damour_multiplie_le_total():
	var nom_anna = service.lire_nom_anna_triche()
	SauvegardeBddJoueursService._sauvegarde_joueur["nom"] = nom_anna
	var score_global = {
		'duree': {'points': 10},
		'ratio_reussite': {'points': 20},
		'niveau': {'points': 30},
		'niveau_parfait': {'points': 40},
		'campagne': {'points': 50}
	}
	var score_avant = SauvegardeTableauDesScoresService.lire_score_joueur(nom_anna)
	service.bonus_score_anna_damour(score_global)
	var score_apres = SauvegardeTableauDesScoresService.lire_score_joueur(nom_anna)
	# bonus = (10+20+30+40+50) * 3 = 450
	assert_eq(score_apres, score_avant + 450)

func test_bonus_score_anna_damour_ne_fait_rien_pour_un_autre_joueur():
	SauvegardeBddJoueursService._sauvegarde_joueur["nom"] = "Joueur Test"
	var score_global = {'duree': {'points': 10}, 'ratio_reussite': {'points': 20}, 'niveau': {'points': 30}}
	var score_avant = SauvegardeTableauDesScoresService.lire_score_joueur("Joueur Test")
	service.bonus_score_anna_damour(score_global)
	var score_apres = SauvegardeTableauDesScoresService.lire_score_joueur("Joueur Test")
	assert_eq(score_apres, score_avant)

func test_mettre_a_jour_score_pour_victoire_applique_le_bonus_anna_pour_ce_joueur():
	# Vérifie l'intégration complète : quand le joueur courant est "Anna",
	# le score final correspond à tous les points détaillés, bonus inclus.
	var nom_anna = service.lire_nom_anna_triche()
	SauvegardeBddJoueursService._sauvegarde_joueur["nom"] = nom_anna
	_level_finishes_current_level_as_won()

	var score_avant = SauvegardeTableauDesScoresService.lire_score_joueur(nom_anna)
	var score = service.mettre_a_jour_score_pour_victoire()
	var score_apres = SauvegardeTableauDesScoresService.lire_score_joueur(nom_anna)

	var total_points_grille = 0
	for detail in score.values():
		total_points_grille += detail.get("points", 0)
	assert_eq(score_apres, score_avant + total_points_grille)

func _set_last_plateau_difficulte(difficulte):
	var niveau = SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne")[0].get("niveaux").back()
	var plateau = niveau.get("plateaux").back()
	plateau["difficulte"] = difficulte
	SauvegardeBddJoueursService._enregistrer_sauvegarde_joueur()

func _level_finishes_current_level_as_won():
	var niveau = SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne")[0].get("niveaux").back()
	niveau["plateaux"] = [
		{"nom": "D", "date_debut": 1700002010, "duree": 15000, "difficulte": 2, "statut": "reussi"},
		{"nom": "A2", "date_debut": 1700002020, "duree": 8000, "difficulte": 4, "statut": "reussi"}
	]
	niveau["date_fin"] = 1700003000
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"].erase("niveau_2")
	SauvegardeBddJoueursService._enregistrer_sauvegarde_joueur()


# ---------------------------------------------------------
# mettre_a_jour_score_pour_import
# ---------------------------------------------------------

func _score(nom: String = "Joueur Test") -> int:
	return SauvegardeTableauDesScoresService.lire_score_joueur(nom)

func _niveau_importe(plateaux) -> Dictionary:
	return {"niveau": "niveau_7", "score": {"niveau": 3500, "niveau_parfait": 3500}, "plateaux": plateaux}

func test_import_additionne_campagne_niveau_niveau_parfait_et_plateaux():
	var campagne = {"score": {"fin_campagne": 400000}}
	var niveau = _niveau_importe([
		{"nom": "P1", "score": {"duree": 120, "ratio_reussite": 800}},
		{"nom": "P2", "score": {"duree": 30, "ratio_reussite": 500}}
	])
	service.mettre_a_jour_score_pour_import("Joueur Test", campagne, niveau)
	assert_eq(_score(), 400000 + 3500 + 3500 + 120 + 800 + 30 + 500)

func test_import_ne_modifie_pas_les_donnees_importees():
	var campagne = {"score": {"fin_campagne": 10}}
	var niveau = _niveau_importe([{"nom": "P1", "score": {"duree": 1, "ratio_reussite": 2}}])
	var campagne_avant = campagne.duplicate(true)
	var niveau_avant = niveau.duplicate(true)
	service.mettre_a_jour_score_pour_import("Joueur Test", campagne, niveau)
	assert_eq(campagne, campagne_avant)
	assert_eq(niveau, niveau_avant)

func test_import_ne_modifie_pas_la_sauvegarde_du_joueur_courant():
	var sauvegarde_avant = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	service.mettre_a_jour_score_pour_import("Joueur Test", {"score": {"fin_campagne": 10}}, _niveau_importe([]))
	assert_eq(SauvegardeBddJoueursService._sauvegarde_joueur, sauvegarde_avant)

func test_import_met_a_jour_le_texte_et_le_rang():
	service.mettre_a_jour_score_pour_import("Joueur Test", {"score": {"fin_campagne": 1234567}}, {})
	assert_eq(SauvegardeTableauDesScoresService.lire_score_txt_joueur("Joueur Test"), "1.234.567")
	assert_eq(SauvegardeTableauDesScoresService.retourner_classement()[0].get("nom"), "Joueur Test")

func test_import_campagne_et_niveau_vides_n_ajoute_rien():
	service.mettre_a_jour_score_pour_import("Joueur Test", {}, {})
	assert_eq(_score(), 0)

func test_import_sans_cle_plateaux_ne_compte_que_campagne_et_niveau():
	service.mettre_a_jour_score_pour_import("Joueur Test", {"score": {"fin_campagne": 100}}, {"score": {"niveau": 10, "niveau_parfait": 1}})
	assert_eq(_score(), 111)

func test_import_plateaux_vide_ne_compte_que_campagne_et_niveau():
	service.mettre_a_jour_score_pour_import("Joueur Test", {"score": {"fin_campagne": 100}}, {"score": {"niveau": 10, "niveau_parfait": 1}, "plateaux": []})
	assert_eq(_score(), 111)

func test_import_plateaux_non_tableau_est_ignore():
	for valeur in ["texte", {"a": 1}, 12, true]:
		SauvegardeTableauDesScoresService.modifier_score_joueur("Joueur Test", 0)
		service.mettre_a_jour_score_pour_import("Joueur Test", {}, {"score": {"niveau": 10}, "plateaux": valeur})
		assert_eq(_score(), 10)

func test_import_plateaux_null_est_ignore():
	service.mettre_a_jour_score_pour_import("Joueur Test", {}, {"score": {"niveau": 10}, "plateaux": null})
	assert_eq(_score(), 10)

func test_import_ignore_les_plateaux_qui_ne_sont_pas_des_dictionnaires():
	var niveau = _niveau_importe([5, "texte", null, [1, 2], {"score": {"duree": 7, "ratio_reussite": 3}}])
	service.mettre_a_jour_score_pour_import("Joueur Test", {}, niveau)
	assert_eq(_score(), 3500 + 3500 + 7 + 3)

func test_import_plateau_sans_score_ou_score_partiel():
	var niveau = {"plateaux": [
		{"nom": "A"},
		{"nom": "B", "score": {}},
		{"nom": "C", "score": {"duree": 4}},
		{"nom": "D", "score": {"ratio_reussite": 6}},
		{"nom": "E", "score": {"duree": 0, "ratio_reussite": 0}}
	]}
	service.mettre_a_jour_score_pour_import("Joueur Test", {}, niveau)
	assert_eq(_score(), 10)

func test_import_scores_a_zero_n_ajoutent_rien():
	service.mettre_a_jour_score_pour_import("Joueur Test", {"score": {"fin_campagne": 0}}, {"score": {"niveau": 0, "niveau_parfait": 0}, "plateaux": []})
	assert_eq(_score(), 0)

func test_import_cumule_sur_le_score_existant_et_sur_plusieurs_appels():
	SauvegardeTableauDesScoresService.modifier_score_joueur("Joueur Test", 1000)
	service.mettre_a_jour_score_pour_import("Joueur Test", {"score": {"fin_campagne": 5}}, {})
	service.mettre_a_jour_score_pour_import("Joueur Test", {"score": {"fin_campagne": 5}}, {})
	assert_eq(_score(), 1010)

func test_import_joueur_inconnu_ne_plante_pas_et_ne_modifie_aucun_score():
	service.mettre_a_jour_score_pour_import("Inconnu", {"score": {"fin_campagne": 100}}, _niveau_importe([{"score": {"duree": 1, "ratio_reussite": 1}}]))
	assert_eq(_score("Inconnu"), 0)
	assert_eq(_score(), 0)
	assert_eq(_score(service.lire_nom_anna_triche()), 0)

func test_import_nom_vide_ne_plante_pas():
	service.mettre_a_jour_score_pour_import("", {"score": {"fin_campagne": 100}}, {})
	assert_eq(_score(), 0)

func test_import_n_applique_pas_le_bonus_anna():
	var nom_anna = service.lire_nom_anna_triche()
	service.mettre_a_jour_score_pour_import(nom_anna, {"score": {"fin_campagne": 100}}, {"score": {"niveau": 10, "niveau_parfait": 1}, "plateaux": [{"score": {"duree": 2, "ratio_reussite": 3}}]})
	assert_eq(_score(nom_anna), 116)

func test_import_score_nul_ou_non_entier_dans_la_campagne():
	service.mettre_a_jour_score_pour_import("Joueur Test", {"score": null}, {"score": null, "plateaux": []})
	assert_eq(_score(), 0)

func test_import_scores_negatifs_sont_retranches():
	SauvegardeTableauDesScoresService.modifier_score_joueur("Joueur Test", 100)
	service.mettre_a_jour_score_pour_import("Joueur Test", {}, {"score": {"niveau": -30}})
	assert_eq(_score(), 70)


# ---------------------------------------------------------
# mettre_a_jour_score_pour_passer
# ---------------------------------------------------------

func _preparer_plateau_a_passer(duree: float = 20., difficulte: int = 4) -> void:
	_level_finishes_current_level_as_won()
	var niveau = SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne")[0].get("niveaux").back()
	var plateau = niveau.get("plateaux").back()
	plateau["date_fin"] = 1700002040
	plateau["duree"] = duree
	plateau["difficulte"] = difficulte
	SauvegardeBddJoueursService._enregistrer_sauvegarde_joueur()

func _dernier_plateau() -> Dictionary:
	return SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne")[0].get("niveaux").back().get("plateaux").back()

func test_passer_met_a_zero_les_points_de_duree_et_de_ratio_dans_le_resultat():
	_preparer_plateau_a_passer()
	var score = service.mettre_a_jour_score_pour_passer()
	assert_eq(score.get("duree").get("points"), 0)
	assert_eq(score.get("duree").get("recommence"), 0)
	assert_eq(score.get("duree").get("realise"), 0)
	assert_eq(score.get("duree").get("type"), "duree")
	assert_eq(score.get("ratio_reussite").get("points"), 0)
	assert_eq(score.get("ratio_reussite").get("ratio"), 0)
	assert_eq(score.get("ratio_reussite").get("type"), "ratio_reussite")

func test_passer_conserve_les_points_de_niveau_et_niveau_parfait():
	_preparer_plateau_a_passer()
	var score = service.mettre_a_jour_score_pour_passer()
	assert_eq(score.get("niveau").get("points"), 1000)
	assert_eq(score.get("niveau_parfait").get("points"), 1000)
	assert_eq(score.get("campagne"), {})
	assert_false(score.has("bonus_anna"))

func test_passer_retranche_les_points_de_duree_et_ratio_du_tableau_des_scores():
	_preparer_plateau_a_passer()
	var avant = _score()
	service.mettre_a_jour_score_pour_passer()
	assert_eq(_score(), avant + 1000 + 1000)

func test_passer_met_a_zero_les_scores_du_plateau_en_base():
	_preparer_plateau_a_passer()
	service.mettre_a_jour_score_pour_passer()
	var plateau = _dernier_plateau()
	assert_eq(plateau.get("score").get("duree"), 0)
	assert_eq(plateau.get("score").get("ratio_reussite"), 0)

func test_passer_est_inferieur_a_une_victoire_de_la_valeur_de_duree_et_ratio():
	_preparer_plateau_a_passer()
	var avant = _score()
	var victoire = service.mettre_a_jour_score_pour_victoire()
	var gain_victoire = _score() - avant
	assert_gt(victoire.get("duree").get("points"), 0)
	assert_gt(victoire.get("ratio_reussite").get("points"), 0)
	SauvegardeTableauDesScoresService.modifier_score_joueur("Joueur Test", avant)
	service.mettre_a_jour_score_pour_passer()
	var gain_passer = _score() - avant
	assert_eq(gain_victoire - gain_passer, victoire.get("duree").get("points") + victoire.get("ratio_reussite").get("points"))

func test_passer_plateau_milieu_de_niveau_ne_laisse_aucun_point():
	var niveau = SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne")[0].get("niveaux").back()
	niveau["plateaux"] = [
		{"nom": "D", "date_debut": 1700002010, "date_fin": 1700002030, "duree": 20, "difficulte": 2, "statut": "reussi"},
		{"nom": "A2", "date_debut": 1700002020, "date_fin": 1700002050, "duree": 30, "difficulte": 4, "statut": "reussi"}
	]
	niveau["date_fin"] = 0
	SauvegardeBddJoueursService._enregistrer_sauvegarde_joueur()
	var avant = _score()
	var score = service.mettre_a_jour_score_pour_passer()
	assert_eq(_score(), avant)
	assert_eq(score.get("niveau"), {})
	assert_eq(score.get("niveau_parfait"), {})
	assert_eq(score.get("campagne"), {})
	assert_eq(score.get("duree").get("points"), 0)

func test_passer_en_fin_de_campagne_conserve_le_bonus_de_campagne():
	_preparer_plateau_a_passer()
	SauvegardeBddJoueursService._sauvegarde_joueur["campagne"] = {}
	var avant = _score()
	var score = service.mettre_a_jour_score_pour_passer()
	var points_campagne = roundi(service.FIN_CAMPAGNE * StatsService.campagne_taux_reussite())
	assert_eq(score.get("campagne").get("type"), "campagne")
	assert_eq(score.get("campagne").get("points"), points_campagne)
	assert_eq(_score(), avant + 1000 + 1000 + points_campagne)

func test_passer_avec_bonus_anna_recalcule_le_bonus_sans_duree_ni_ratio():
	var nom_anna = service.lire_nom_anna_triche()
	SauvegardeBddJoueursService._sauvegarde_joueur["nom"] = nom_anna
	_preparer_plateau_a_passer()
	var avant = _score(nom_anna)
	var score = service.mettre_a_jour_score_pour_passer()
	assert_true(score.has("bonus_anna"))
	assert_eq(score.get("bonus_anna").get("type"), "bonus_anna")
	assert_eq(score.get("bonus_anna").get("points"), (1000 + 1000) * 3)
	assert_eq(_score(nom_anna), avant + 1000 + 1000 + (1000 + 1000) * 3)

func test_passer_avec_bonus_anna_hors_fin_de_niveau_donne_un_bonus_nul():
	var nom_anna = service.lire_nom_anna_triche()
	SauvegardeBddJoueursService._sauvegarde_joueur["nom"] = nom_anna
	var niveau = SauvegardeBddJoueursService._sauvegarde_joueur.get("enregistrement_campagne")[0].get("niveaux").back()
	niveau["plateaux"] = [
		{"nom": "D", "date_debut": 1700002010, "date_fin": 1700002030, "duree": 20, "difficulte": 2, "statut": "reussi"},
		{"nom": "A2", "date_debut": 1700002020, "date_fin": 1700002050, "duree": 30, "difficulte": 4, "statut": "reussi"}
	]
	SauvegardeBddJoueursService._enregistrer_sauvegarde_joueur()
	var avant = _score(nom_anna)
	var score = service.mettre_a_jour_score_pour_passer()
	assert_eq(score.get("bonus_anna").get("points"), 0)
	assert_eq(_score(nom_anna), avant)

func test_passer_est_idempotent_sur_le_tableau_des_scores_net():
	_preparer_plateau_a_passer()
	var avant = _score()
	service.mettre_a_jour_score_pour_passer()
	var apres_premier = _score()
	service.mettre_a_jour_score_pour_passer()
	assert_eq(_score(), apres_premier + 1000 + 1000)
	assert_eq(apres_premier, avant + 1000 + 1000)

func test_passer_sans_duree_realisee_ne_retranche_rien_de_trop():
	_preparer_plateau_a_passer(0.)
	var avant = _score()
	var score = service.mettre_a_jour_score_pour_passer()
	assert_eq(score.get("duree").get("points"), 0)
	assert_eq(_score(), avant + 1000 + 1000)

func test_passer_difficulte_elevee_ne_laisse_aucun_point_de_duree():
	_preparer_plateau_a_passer(5., 100)
	var avant = _score()
	service.mettre_a_jour_score_pour_passer()
	assert_eq(_score(), avant + 1000 + 1000)

func test_passer_joueur_absent_du_tableau_des_scores_ne_plante_pas():
	SauvegardeTableauDesScoresService.liste_des_scores = []
	_preparer_plateau_a_passer()
	var score = service.mettre_a_jour_score_pour_passer()
	assert_eq(score.get("duree").get("points"), 0)
	assert_eq(_score(), 0)


# ---------------------------------------------------------
# Cas limites complémentaires
# ---------------------------------------------------------

func test_score_duree_difficulte_superieure_a_cent_reste_calcule():
	_set_last_plateau_difficulte(150)
	var score = service.mettre_a_jour_score_duree()
	assert_eq(score.get("type"), "duree")
	assert_eq(score.get("reference"), 9.0)

func test_score_duree_reference_par_difficulte():
	var cas = {1: 9.0, 9: 9.0, 10: 12.0, 20: 14.0, 30: 16.0, 40: 18.0, 50: 20.0, 60: 25.0, 71: 30.0, 81: 60.0, 100: 120.0}
	for difficulte in cas:
		_set_last_plateau_difficulte(difficulte)
		assert_eq(service.mettre_a_jour_score_duree().get("reference"), cas[difficulte], "difficulté %d" % difficulte)

func test_score_duree_points_exacts():
	_preparer_plateau_a_passer(18., 4)
	var avant = _score()
	var score = service.mettre_a_jour_score_duree()
	assert_eq(score.get("points"), roundi(100 * 4 * 9. / 18.))
	assert_eq(_score(), avant + score.get("points"))
	assert_eq(_dernier_plateau().get("score").get("duree"), score.get("points"))

func test_score_ratio_reussite_est_enregistre_dans_le_plateau_et_le_tableau():
	var avant = _score()
	var score = service.mettre_a_jour_score_ratio_reussite()
	assert_eq(_score(), avant + score.get("points"))
	assert_eq(_dernier_plateau().get("score").get("ratio_reussite"), score.get("points"))

func test_score_niveau_points_egaux_a_500_fois_la_longueur():
	_level_finishes_current_level_as_won()
	var score = service.mettre_a_jour_score_niveau()
	assert_eq(score.get("longueur"), 2)
	assert_eq(score.get("points"), 1000)

func test_score_niveau_parfait_double_le_score_du_niveau():
	_preparer_plateau_a_passer()
	service.mettre_a_jour_score_niveau()
	var score = service.mettre_a_jour_score_niveau_parfait()
	assert_eq(score.get("points"), 1000)
	assert_eq(score.get("bonus"), "x2")

func test_score_niveau_sans_joueur_retourne_zero_point_et_niveau_parfait_vide():
	# Comportement actuel (discutable) : sans niveau enregistré, le niveau est considéré terminé et renvoie 0 point.
	SauvegardeBddJoueursService.liberer_le_joueur()
	assert_eq(service.mettre_a_jour_score_niveau(), {"type": "niveau", "longueur": 0, "points": 0})
	assert_eq(service.mettre_a_jour_score_niveau_parfait(), {})

func test_bonus_anna_sans_points_dans_la_grille():
	var nom_anna = service.lire_nom_anna_triche()
	SauvegardeBddJoueursService._sauvegarde_joueur["nom"] = nom_anna
	var bonus = service.bonus_score_anna_damour({"niveau": {}, "campagne": {}})
	assert_eq(bonus.get("points"), 0)
	assert_eq(bonus.get("type"), "bonus_anna")

func test_bonus_anna_nom_insensible_a_la_casse():
	var nom_anna = service.lire_nom_anna_triche()
	SauvegardeBddJoueursService._sauvegarde_joueur["nom"] = nom_anna.to_upper()
	var bonus = service.bonus_score_anna_damour({"niveau": {"points": 10}})
	assert_eq(bonus.get("points"), 30)

func test_bonus_anna_grille_vide():
	var nom_anna = service.lire_nom_anna_triche()
	SauvegardeBddJoueursService._sauvegarde_joueur["nom"] = nom_anna
	assert_eq(service.bonus_score_anna_damour({}).get("points"), 0)

func test_bonus_anna_retourne_vide_pour_un_autre_joueur():
	assert_eq(service.bonus_score_anna_damour({"niveau": {"points": 10}}), {})

func test_nouveau_joueur_est_nom_anna_triche_nom_vide_et_nom_decore():
	assert_false(service.nouveau_joueur_est_nom_anna_triche(""))
	assert_false(service.nouveau_joueur_est_nom_anna_triche(service.lire_nom_anna_triche()))
	assert_true(service.nouveau_joueur_est_nom_anna_triche("ANNA"))
	assert_false(service.nouveau_joueur_est_nom_anna_triche(" Anna"))

func test_lire_nom_anna_triche_est_stable():
	assert_eq(service.lire_nom_anna_triche(), service.lire_nom_anna_triche())
	assert_ne(service.lire_nom_anna_triche().to_lower(), "anna")

func test_fin_campagne_vaut_500000():
	assert_eq(service.FIN_CAMPAGNE, 500000)
