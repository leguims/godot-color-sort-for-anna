extends GutTest

const DOSSIER := "res://Scenes/MenuPrincipal/Campagne/Statistiques/"
const SCENE_STATISTIQUES = preload(DOSSIER + "statistiques.tscn")
const SCENE_CARTE_SCORE = preload(DOSSIER + "carte_score.tscn")
const SCENE_CARTE_CAMPAGNE = preload(DOSSIER + "carte_campagne.tscn")
const SCENE_CARTE_NIVEAU = preload(DOSSIER + "carte_niveau.tscn")
const SCENE_CARTE_MODE = preload(DOSSIER + "carte_mode.tscn")
const SCENE_CARTE_PLATEAU = preload(DOSSIER + "carte_plateau.tscn")
const RACINE_TEST := "tests/test_statistiques_ui"
const ICONES := "res://Art/UI/icons/grades/"

class FauxPartage:
	extends Node
	var disponible := true
	var accepte := true
	var chemins: Array[String] = []
	var type_mime := ""

	func is_available() -> bool:
		return disponible

	func share_file(chemin: String, mime: String, _titre: String, _sujet: String, _contenu: String) -> bool:
		chemins.append(chemin)
		type_mime = mime
		return accepte

var sauvegarde_joueur_initiale: Dictionary
var fichier_sauvegarde_initial: String
var configuration_initiale: Dictionary
var liste_des_scores_initiale: Array

func _donnees_joueur() -> Dictionary:
	return {
		"nom": "Joueur Test",
		"nom_campagne": "campagne_test",
		"campagne": {
			"niveau_2": [{"nom": "R3", "difficulte": 2}],
			"niveau_3": [{"nom": "R1", "difficulte": 1}, {"nom": "R2", "difficulte": 2}]
		},
		"enregistrement_campagne": [{
			"campagne": "campagne_test",
			"date_debut": 1700000000,
			"date_fin": 0,
			"score": {"niveau": 20, "niveau_parfait": 0},
			"niveaux": [
				{
					"niveau": "niveau_1",
					"date_debut": 1700000000,
					"date_fin": 1700001000,
					"score": {"niveau": 100, "niveau_parfait": 50},
					"plateaux": [
						{"nom": "A1", "date_debut": 1700000010, "date_fin": 1700000020, "duree": 10, "difficulte": 1, "statut": "reussi", "gameplay": "CLASSIQUE", "score": {"duree": 20, "ratio_reussite": 80}},
						{"nom": "B", "date_debut": 1700000020, "date_fin": 1700000031, "duree": 11, "difficulte": 2, "statut": "abandonné", "gameplay": "QUI_PERD_GAGNE", "score": {"duree": 5, "ratio_reussite": 10}},
						{"nom": "B", "date_debut": 1700000030, "date_fin": 1700000045, "duree": 15, "difficulte": 2, "statut": "reussi", "gameplay": "QUI_PERD_GAGNE", "score": {"duree": 30, "ratio_reussite": 90}},
						{"nom": "C", "date_debut": 1700000040, "date_fin": 1700000049, "duree": 9, "difficulte": 3, "statut": "reussi", "gameplay": "CLASSIQUE", "score": {"duree": 15, "ratio_reussite": 70}}
					]
				},
				{
					"niveau": "niveau_2",
					"date_debut": 1700002000,
					"date_fin": 0,
					"score": {"niveau": 20, "niveau_parfait": 0},
					"plateaux": [
						{"nom": "D", "date_debut": 1700002010, "date_fin": 1700002025, "duree": 15, "difficulte": 2, "statut": "reussi", "gameplay": "CLASSIQUE", "score": {"duree": 25, "ratio_reussite": 85}},
						{"nom": "A2", "date_debut": 1700002020, "date_fin": 1700002028, "duree": 8, "difficulte": 4, "statut": "reussi", "gameplay": "QUI_PERD_GAGNE", "score": {"duree": 40, "ratio_reussite": 95}}
					]
				}
			]
		}],
		"plateaux_libres": {}
	}

func _activer_joueur(donnees: Dictionary) -> void:
	SauvegardeBddJoueursService._sauvegarde_joueur = donnees
	FichiersJsonService.write_json_file("test_statistiques_ui.json", donnees)
	assert_true(SauvegardeBddJoueursService.choisir_le_joueur("Joueur Test", "test_statistiques_ui.json"))

func before_each() -> void:
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	FichiersJsonService.effacer_racine_utilisateur()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	liste_des_scores_initiale = SauvegardeTableauDesScoresService.liste_des_scores.duplicate(true)
	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	SauvegardeTableauDesScoresService.liste_des_scores = [
		{"nom": "Joueur Test", "rang": 1, "score": 1000, "score_txt": "1.000"}
	]
	_activer_joueur(_donnees_joueur())

func after_each() -> void:
	var scene_courante := get_tree().current_scene
	if scene_courante != null:
		scene_courante.queue_free()
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale
	SauvegardeTableauDesScoresService.liste_des_scores = liste_des_scores_initiale
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _ecran() -> Control:
	return add_child_autofree(SCENE_STATISTIQUES.instantiate())

func _valeur(ecran: Node, chemin: String) -> String:
	return ecran.get_node("Scroll/Content/" + chemin).text

# ------------------------------------------------------------------
# Formateurs

func test_pourcentage_une_decimale_sous_dix_pour_cent() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_pourcentage(0.0), "0%")
	assert_eq(ecran.str_arrondir_pourcentage(0.05), "5.0%")
	assert_eq(ecran.str_arrondir_pourcentage(0.034), "3.4%")

func test_pourcentage_sans_decimale_a_partir_de_dix_pour_cent() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_pourcentage(0.1), "10%")
	assert_eq(ecran.str_arrondir_pourcentage(0.625), "63%")
	assert_eq(ecran.str_arrondir_pourcentage(0.8333), "83%")
	assert_eq(ecran.str_arrondir_pourcentage(1.0), "100%")

func test_temps_en_millisecondes_sous_une_seconde() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_temps_en_s(0.0), "0ms")
	assert_eq(ecran.str_arrondir_temps_en_s(0.5), "500ms")
	assert_eq(ecran.str_arrondir_temps_en_s(0.1234), "123ms")

func test_temps_en_secondes_avec_une_decimale_sous_dix_secondes() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_temps_en_s(1.0), "1.0s")
	assert_eq(ecran.str_arrondir_temps_en_s(2.26), "2.3s")
	assert_eq(ecran.str_arrondir_temps_en_s(9.4), "9.4s")

func test_temps_en_secondes_entieres_sous_une_minute() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_temps_en_s(10.0), "10s")
	assert_eq(ecran.str_arrondir_temps_en_s(11.4), "11s")
	assert_eq(ecran.str_arrondir_temps_en_s(59.0), "59s")

func test_temps_en_minutes_et_secondes_sous_une_heure() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_temps_en_s(60.0), "1min 0s")
	assert_eq(ecran.str_arrondir_temps_en_s(68.0), "1min 8s")
	assert_eq(ecran.str_arrondir_temps_en_s(125.4), "2min 5s")
	assert_eq(ecran.str_arrondir_temps_en_s(3599.0), "59min 59s")

func test_temps_en_heures_et_minutes_a_partir_d_une_heure() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_temps_en_s(3600.0), "1h 0min")
	assert_eq(ecran.str_arrondir_temps_en_s(3725.0), "1h 2min")
	assert_eq(ecran.str_arrondir_temps_en_s(86400.0), "24h 0min")

func test_temps_arrondi_ne_deborde_pas_sur_soixante_secondes() -> void:
	var ecran := _ecran()

	assert_eq(ecran.str_arrondir_temps_en_s(119.4), "1min 59s")
	assert_eq(ecran.str_arrondir_temps_en_s(119.5), "2min 0s")
	assert_eq(ecran.str_arrondir_temps_en_s(119.6), "2min 0s")
	assert_eq(ecran.str_arrondir_temps_en_s(3599.4), "59min 59s")
	assert_eq(ecran.str_arrondir_temps_en_s(3599.6), "1h 0min")

# ------------------------------------------------------------------
# Cartes

func test_carte_score_ecrit_chaque_indicateur() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_SCORE.instantiate())

	carte.medaille("Bronze")
	carte.nom_joueur("Alice")
	carte.score("1 234")
	carte.rapidite("12%")
	carte.reussite("34%")
	carte.niveau("56%")
	carte.parfait("7.8%")
	carte.campagne("90%")

	assert_eq(carte.get_node("GradeIdentite/NomGrade").text, "Bronze")
	assert_eq(carte.get_node("GradeIdentite/PlayerName").text, "Alice")
	assert_eq(carte.get_node("Score/Valeur").text, "1 234")
	assert_eq(carte.get_node("Rapidite/Valeur").text, "12%")
	assert_eq(carte.get_node("Reussite/Valeur").text, "34%")
	assert_eq(carte.get_node("Niveau/Valeur").text, "56%")
	assert_eq(carte.get_node("Parfait/Valeur").text, "7.8%")
	assert_eq(carte.get_node("Campagne/Valeur").text, "90%")

func test_carte_score_choisit_la_medaille_selon_le_grade() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_SCORE.instantiate())

	for grade in ["bronze", "argent", "or", "diamant"]:
		carte.medaille(grade)
		assert_eq(carte.get_node("GradeIdentite/Medaille").texture.resource_path, ICONES + "medaille_%s_60.png" % grade)
		assert_eq(carte.get_node("GradeIdentite/NomGrade").text, grade.capitalize())

func test_carte_score_ignore_la_casse_du_grade() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_SCORE.instantiate())

	carte.medaille("DIAMANT")

	assert_eq(carte.get_node("GradeIdentite/Medaille").texture.resource_path, ICONES + "medaille_diamant_60.png")
	assert_eq(carte.get_node("GradeIdentite/NomGrade").text, "Diamant")

func test_carte_score_conserve_la_medaille_pour_un_grade_inconnu() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_SCORE.instantiate())
	carte.medaille("or")
	var texture_or = carte.get_node("GradeIdentite/Medaille").texture

	carte.medaille("platine")

	assert_eq(carte.get_node("GradeIdentite/Medaille").texture, texture_or)

func test_carte_campagne_ecrit_chaque_indicateur() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_CAMPAGNE.instantiate())

	carte.completion("63%")
	carte.temps("1min 8s")
	carte.serie_max("4")
	carte.reussite("83%")

	assert_eq(carte.get_node("Completion/Valeur").text, "63%")
	assert_eq(carte.get_node("Temps/Valeur").text, "1min 8s")
	assert_eq(carte.get_node("SerieMax/Valeur").text, "4")
	assert_eq(carte.get_node("Reussite/Valeur").text, "83%")

func test_carte_niveau_ecrit_chaque_indicateur() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_NIVEAU.instantiate())

	carte.en_cours("2")
	carte.completion("67%")
	carte.taux_reussite_minimum("75%")
	carte.difficulte_reussite_minimum("1")
	carte.taux_reussite_maximum("100%")
	carte.difficulte_reussite_maximum("2")

	assert_eq(carte.get_node("EnCours/Valeur").text, "2")
	assert_eq(carte.get_node("Completion/Valeur").text, "67%")
	assert_eq(carte.get_node("Tableau/ReussiteMinimum/Pourcent").text, "75%")
	assert_eq(carte.get_node("Tableau/ReussiteMinimum/Difficulte").text, "1")
	assert_eq(carte.get_node("Tableau/ReussiteMaximum/Pourcent").text, "100%")
	assert_eq(carte.get_node("Tableau/ReussiteMaximum/Difficulte").text, "2")

func _verifier_carte_de_plateaux(carte: Control) -> void:
	carte.nb_plateaux("6")
	carte.nb_essais("8")
	carte.temps_moyen("11s")
	carte.taux_reussite("83%")
	carte.plus_rapide_temps("8.0s")
	carte.plus_rapide_niveau("4")
	carte.plus_lent_temps("15s")
	carte.plus_lent_niveau("2")
	carte.plus_galere_essais("3")
	carte.plus_galere_niveau("5")

	assert_eq(carte.get_node("Nombre/Valeur").text, "6")
	assert_eq(carte.get_node("Essais/Valeur").text, "8")
	assert_eq(carte.get_node("TempsMoyen/Valeur").text, "11s")
	assert_eq(carte.get_node("Reussite/Valeur").text, "83%")
	assert_eq(carte.get_node("Tableau/PlusRapide/Temps").text, "8.0s")
	assert_eq(carte.get_node("Tableau/PlusRapide/Niveau").text, "4")
	assert_eq(carte.get_node("Tableau/PlusLent/Temps").text, "15s")
	assert_eq(carte.get_node("Tableau/PlusLent/Niveau").text, "2")
	assert_eq(carte.get_node("Tableau/PlusGalere/Essais").text, "3")
	assert_eq(carte.get_node("Tableau/PlusGalere/Niveau").text, "5")

func test_carte_plateau_ecrit_chaque_indicateur() -> void:
	_verifier_carte_de_plateaux(add_child_autofree(SCENE_CARTE_PLATEAU.instantiate()))

func test_carte_mode_ecrit_chaque_indicateur() -> void:
	_verifier_carte_de_plateaux(add_child_autofree(SCENE_CARTE_MODE.instantiate()))

func test_carte_mode_applique_le_titre_avant_et_apres_ready() -> void:
	var carte: Control = SCENE_CARTE_MODE.instantiate()
	carte.titre("Classique")
	add_child_autofree(carte)
	assert_eq(carte.get_node("Titre").text, "Classique")

	carte.titre("Qui perd gagne")
	assert_eq(carte.get_node("Titre").text, "Qui perd gagne")
	assert_eq(carte._titre, "Qui perd gagne")

# ------------------------------------------------------------------
# Écran

func test_l_ecran_affiche_le_score_du_joueur() -> void:
	var ecran := _ecran()

	assert_eq(_valeur(ecran, "Score/GradeIdentite/PlayerName"), "Joueur Test")
	assert_eq(_valeur(ecran, "Score/GradeIdentite/NomGrade"), "Bronze")
	assert_eq(_valeur(ecran, "Score/Score/Valeur"), "735")

func test_l_ecran_separe_les_milliers_du_score_par_une_espace() -> void:
	var donnees := _donnees_joueur()
	donnees["enregistrement_campagne"][0]["niveaux"][0]["plateaux"][0]["score"]["ratio_reussite"] = 1500
	_activer_joueur(donnees)

	var ecran := _ecran()

	assert_eq(_valeur(ecran, "Score/Score/Valeur"), "2 155")

func test_l_ecran_affiche_les_pourcentages_du_score_arrondis() -> void:
	var ecran := _ecran()

	assert_eq(_valeur(ecran, "Score/Rapidite/Valeur"), ecran.str_arrondir_pourcentage(StatsService.score_pourcentage_rapidite()))
	assert_eq(_valeur(ecran, "Score/Reussite/Valeur"), ecran.str_arrondir_pourcentage(StatsService.score_pourcentage_reussite()))
	assert_eq(_valeur(ecran, "Score/Niveau/Valeur"), ecran.str_arrondir_pourcentage(StatsService.score_pourcentage_niveau()))
	assert_eq(_valeur(ecran, "Score/Parfait/Valeur"), ecran.str_arrondir_pourcentage(StatsService.score_pourcentage_niveau_parfait()))
	assert_eq(_valeur(ecran, "Score/Campagne/Valeur"), ecran.str_arrondir_pourcentage(StatsService.score_pourcentage_fin_campagne()))

func test_l_ecran_affiche_les_statistiques_de_campagne() -> void:
	var ecran := _ecran()

	assert_eq(_valeur(ecran, "Campagne/Completion/Valeur"), "63%")
	assert_eq(_valeur(ecran, "Campagne/Temps/Valeur"), "1min 8s")
	assert_eq(_valeur(ecran, "Campagne/Reussite/Valeur"), "83%")
	assert_eq(_valeur(ecran, "Campagne/SerieMax/Valeur"), "4")

func test_l_ecran_propose_le_partage_d_une_campagne_terminee_non_partagee() -> void:
	var donnees := _donnees_joueur()
	donnees["enregistrement_campagne"][0]["campagne"] = "[test]campagne_2"
	donnees["enregistrement_campagne"][0]["date_fin"] = 1700003000
	_activer_joueur(donnees)
	var ecran := _ecran()

	if not OS.has_feature("android"):
		assert_false(ecran.get_node("PanneauPartagePerformances").visible)
		ecran._afficher_le_partage()
	assert_true(ecran.get_node("PanneauPartagePerformances").visible)
	ecran.get_node("PanneauPartagePerformances/Panneau/Contenu/BoutonRetourStatistiques").emit_signal("pressed")
	assert_false(ecran.get_node("PanneauPartagePerformances").visible)
	assert_true(ecran.get_node("Scroll/Content/Campagne").visible)

func test_l_ecran_ne_propose_pas_le_partage_d_une_campagne_deja_partagee() -> void:
	var donnees := _donnees_joueur()
	donnees["enregistrement_campagne"][0]["campagne"] = "[test]campagne_2"
	donnees["enregistrement_campagne"][0]["date_fin"] = 1700003000
	_activer_joueur(donnees)
	var api: PartagePerformancesAPI = add_child_autofree(
		load("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_api.gd").new()
	)
	var empreinte := api._calculer_empreinte_campagne(donnees["enregistrement_campagne"][0])
	assert_true(SauvegardeBddJoueursService.enregistrement_campagne_marquer_fichier_partage(empreinte))
	assert_true(api.campagne_a_deja_ete_partagee(api.lire_donnees_derniere_campagne()))

	var ecran := _ecran()

	assert_false(ecran.get_node("PanneauPartagePerformances").visible)

func test_l_ecran_ne_propose_pas_le_partage_hors_de_la_campagne_de_test() -> void:
	var donnees := _donnees_joueur()
	donnees["enregistrement_campagne"][0]["date_fin"] = 1700003000
	_activer_joueur(donnees)

	var ecran := _ecran()

	assert_false(ecran.get_node("PanneauPartagePerformances").visible)

func test_partage_manuel_transmet_la_derniere_campagne_en_cours_sans_modifier_le_suivi() -> void:
	var donnees := _donnees_joueur()
	donnees["enregistrement_campagne"][0]["campagne"] = "[test]partage_%s" % Time.get_ticks_usec()
	var ancienne: Dictionary = donnees["enregistrement_campagne"][0].duplicate(true)
	ancienne["campagne"] = "ancienne"
	donnees["enregistrement_campagne"].push_front(ancienne)
	_activer_joueur(donnees)
	var ecran := _ecran()
	var share: FauxPartage = add_child_autofree(FauxPartage.new())
	var api: PartagePerformancesAPI = ecran.get_node("PanneauPartagePerformances/PartagePerformancesAPI")
	var campagne_attendue: Dictionary = api.lire_donnees_derniere_campagne()["campagne"]

	ecran._partager_derniere_campagne(share)

	assert_eq(share.chemins.size(), 1)
	assert_eq(share.type_mime, "application/json")
	assert_false(ecran.get_node("PanneauPartagePerformances").visible)
	assert_false(ecran.get_node("DialogueErreurPartage").visible)
	if not share.chemins.is_empty():
		var contenu := FileAccess.get_file_as_string(share.chemins[0])
		var resultat := api.decoder_fichier_signe(contenu)
		assert_true(resultat.get("succes", false))
		assert_eq(resultat.get("donnees", {}).get("campagne"), JSON.parse_string(JSON.stringify(campagne_attendue)))
		assert_eq(resultat.get("donnees", {}).get("campagne", {}).get("date_fin"), 0.0)
		DirAccess.remove_absolute(share.chemins[0])
	ShareService.share_completed.emit("test")
	assert_false(api.campagne_a_deja_ete_partagee(api.lire_donnees_derniere_campagne()))

func test_partage_manuel_affiche_uniquement_les_erreurs_et_pas_l_annulation() -> void:
	var donnees := _donnees_joueur()
	donnees["enregistrement_campagne"][0]["campagne"] = "partage_%s" % Time.get_ticks_usec()
	_activer_joueur(donnees)
	var ecran := _ecran()
	var share: FauxPartage = add_child_autofree(FauxPartage.new())
	var dialogue: AcceptDialog = ecran.get_node("DialogueErreurPartage")
	var panneau: Control = ecran.get_node("PanneauPartagePerformances")

	share.disponible = false
	ecran._partager_derniere_campagne(share)
	assert_true(dialogue.visible)
	assert_false(panneau.visible)
	dialogue.hide()

	share.disponible = true
	ecran._partager_derniere_campagne(share)
	ShareService.share_canceled.emit()
	assert_false(dialogue.visible)
	ecran._partager_derniere_campagne(share)
	ShareService.share_failed.emit("Erreur Android")
	assert_true(dialogue.visible)
	assert_true(dialogue.dialog_text.contains("Erreur Android"))
	assert_false(panneau.visible)
	assert_false(panneau.get_node("Panneau/Contenu/Message").visible)
	for chemin in share.chemins:
		DirAccess.remove_absolute(chemin)

func test_partage_manuel_ne_supprime_pas_l_invitation_de_test() -> void:
	var donnees := _donnees_joueur()
	donnees["enregistrement_campagne"][0]["campagne"] = "[test]partage_%s" % Time.get_ticks_usec()
	donnees["enregistrement_campagne"][0]["date_fin"] = 1700003000
	_activer_joueur(donnees)
	var ecran := _ecran()
	var share: FauxPartage = add_child_autofree(FauxPartage.new())
	ecran.get_node("PanneauPartagePerformances").hide()

	ecran._partager_derniere_campagne(share)
	ShareService.share_completed.emit("test")
	ecran._afficher_le_partage()

	assert_true(ecran.get_node("PanneauPartagePerformances").visible)
	for chemin in share.chemins:
		DirAccess.remove_absolute(chemin)

func test_partage_manuel_sans_campagne_affiche_une_erreur() -> void:
	var ecran := _ecran()
	var share: FauxPartage = add_child_autofree(FauxPartage.new())
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"] = []

	ecran._partager_derniere_campagne(share)

	assert_true(ecran.get_node("DialogueErreurPartage").visible)
	assert_eq(ecran.get_node("DialogueErreurPartage").dialog_text, "Aucune campagne à partager.")
	assert_true(share.chemins.is_empty())

func test_partage_manuel_refuse_un_second_partage_et_signale_un_echec_immediat() -> void:
	var donnees := _donnees_joueur()
	donnees["enregistrement_campagne"][0]["campagne"] = "partage_%s" % Time.get_ticks_usec()
	_activer_joueur(donnees)
	var ecran := _ecran()
	var share: FauxPartage = add_child_autofree(FauxPartage.new())
	var dialogue: AcceptDialog = ecran.get_node("DialogueErreurPartage")

	ecran._partager_derniere_campagne(share)
	ecran._partager_derniere_campagne(share)
	assert_eq(share.chemins.size(), 1)
	assert_true(dialogue.dialog_text.contains("déjà en cours"))
	ShareService.share_canceled.emit()
	dialogue.hide()
	share.accepte = false
	ecran._partager_derniere_campagne(share)
	assert_true(dialogue.visible)
	assert_true(dialogue.dialog_text.contains("SHARE"))
	for chemin in share.chemins:
		if FileAccess.file_exists(chemin):
			DirAccess.remove_absolute(chemin)

func test_bouton_partager_hors_android_ne_fait_rien() -> void:
	if OS.has_feature("android"):
		return
	var ecran := _ecran()
	ecran.get_node("Scroll/Content/BoutonPartager").pressed.emit()
	assert_false(ecran.get_node("PanneauPartagePerformances").visible)
	assert_false(ecran.get_node("DialogueErreurPartage").visible)

func test_partage_test_conserve_son_suivi_et_ses_erreurs_dans_le_panneau() -> void:
	var donnees := _donnees_joueur()
	donnees["enregistrement_campagne"][0]["campagne"] = "[test]partage_%s" % Time.get_ticks_usec()
	_activer_joueur(donnees)
	var ecran := _ecran()
	var share: FauxPartage = add_child_autofree(FauxPartage.new())
	var api: PartagePerformancesAPI = ecran.get_node("PanneauPartagePerformances/PartagePerformancesAPI")
	var campagne := api.lire_donnees_derniere_campagne()
	ecran._afficher_le_partage()

	assert_true(api.partager_campagne(share, campagne).get("succes", false))
	ShareService.share_failed.emit("Erreur test")
	assert_true(ecran.get_node("PanneauPartagePerformances/Panneau/Contenu/Message").visible)
	assert_false(ecran.get_node("DialogueErreurPartage").visible)
	assert_false(api.campagne_a_deja_ete_partagee(campagne))
	assert_true(api.partager_campagne(share, campagne).get("succes", false))
	ShareService.share_canceled.emit()
	assert_false(api.campagne_a_deja_ete_partagee(campagne))
	assert_true(api.partager_campagne(share, campagne).get("succes", false))
	ShareService.share_completed.emit("test")
	assert_true(api.campagne_a_deja_ete_partagee(campagne))
	for chemin in share.chemins:
		DirAccess.remove_absolute(chemin)

func test_l_ecran_affiche_les_statistiques_de_niveau() -> void:
	var ecran := _ecran()
	var infos: Dictionary = StatsService.niveau_taux_reussite_infos()

	assert_eq(_valeur(ecran, "Niveau/EnCours/Valeur"), "2")
	assert_eq(_valeur(ecran, "Niveau/Completion/Valeur"), "67%")
	assert_eq(_valeur(ecran, "Niveau/Tableau/ReussiteMinimum/Pourcent"), "75%")
	assert_eq(_valeur(ecran, "Niveau/Tableau/ReussiteMinimum/Difficulte"), str(infos.get("taux_min_niveau")))
	assert_eq(_valeur(ecran, "Niveau/Tableau/ReussiteMaximum/Pourcent"), "100%")
	assert_eq(_valeur(ecran, "Niveau/Tableau/ReussiteMaximum/Difficulte"), str(infos.get("taux_max_niveau")))

func test_l_ecran_affiche_les_statistiques_de_tous_les_plateaux() -> void:
	var ecran := _ecran()

	# 5 plateaux joués (réussis) pour 6 essais (dont 1 abandonné) ; temps cumulé de tous les essais / plateaux réussis
	assert_eq(_valeur(ecran, "Plateau/Nombre/Valeur"), "5")
	assert_eq(_valeur(ecran, "Plateau/Essais/Valeur"), "6")
	assert_eq(_valeur(ecran, "Plateau/TempsMoyen/Valeur"), "14s")
	assert_eq(_valeur(ecran, "Plateau/Reussite/Valeur"), "83%")
	assert_eq(_valeur(ecran, "Plateau/Tableau/PlusRapide/Temps"), "8.0s")
	assert_eq(_valeur(ecran, "Plateau/Tableau/PlusRapide/Niveau"), "2")
	assert_eq(_valeur(ecran, "Plateau/Tableau/PlusLent/Temps"), "26s")
	assert_eq(_valeur(ecran, "Plateau/Tableau/PlusLent/Niveau"), "1")
	assert_eq(_valeur(ecran, "Plateau/Tableau/PlusGalere/Essais"), "2 essais")
	assert_eq(_valeur(ecran, "Plateau/Tableau/PlusGalere/Niveau"), "1")

func test_l_ecran_affiche_les_statistiques_du_gameplay_classique() -> void:
	var ecran := _ecran()

	assert_eq(_valeur(ecran, "Classique/Nombre/Valeur"), "3")
	assert_eq(_valeur(ecran, "Classique/Essais/Valeur"), "3")
	assert_eq(_valeur(ecran, "Classique/TempsMoyen/Valeur"), "11s")
	assert_eq(_valeur(ecran, "Classique/Reussite/Valeur"), "100%")
	assert_eq(_valeur(ecran, "Classique/Tableau/PlusRapide/Temps"), "9.0s")
	assert_eq(_valeur(ecran, "Classique/Tableau/PlusRapide/Niveau"), "1")
	assert_eq(_valeur(ecran, "Classique/Tableau/PlusLent/Temps"), "15s")
	assert_eq(_valeur(ecran, "Classique/Tableau/PlusLent/Niveau"), "2")
	assert_eq(_valeur(ecran, "Classique/Tableau/PlusGalere/Essais"), "1 essai")
	assert_eq(_valeur(ecran, "Classique/Tableau/PlusGalere/Niveau"), "1")

func test_l_ecran_affiche_les_statistiques_du_gameplay_qui_perd_gagne() -> void:
	var ecran := _ecran()

	assert_eq(_valeur(ecran, "QuiPerdGagne/Nombre/Valeur"), "2")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Essais/Valeur"), "3")
	assert_eq(_valeur(ecran, "QuiPerdGagne/TempsMoyen/Valeur"), "17s")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Reussite/Valeur"), "67%")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Tableau/PlusRapide/Temps"), "8.0s")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Tableau/PlusRapide/Niveau"), "2")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Tableau/PlusLent/Temps"), "26s")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Tableau/PlusLent/Niveau"), "1")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Tableau/PlusGalere/Essais"), "2 essais")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Tableau/PlusGalere/Niveau"), "1")

func test_l_ecran_s_affiche_sans_enregistrement_de_campagne() -> void:
	var donnees := _donnees_joueur()
	donnees["enregistrement_campagne"] = []
	_activer_joueur(donnees)

	var ecran := _ecran()

	assert_eq(_valeur(ecran, "Niveau/EnCours/Valeur"), "0")
	assert_eq(_valeur(ecran, "Plateau/Nombre/Valeur"), "0")
	assert_eq(_valeur(ecran, "Plateau/Essais/Valeur"), "0")
	assert_eq(_valeur(ecran, "Plateau/Reussite/Valeur"), "0%")
	assert_eq(_valeur(ecran, "Campagne/SerieMax/Valeur"), "0")
	assert_eq(_valeur(ecran, "Classique/Nombre/Valeur"), "0")
	assert_eq(_valeur(ecran, "Classique/Essais/Valeur"), "0")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Nombre/Valeur"), "0")
	assert_eq(_valeur(ecran, "QuiPerdGagne/Essais/Valeur"), "0")

func test_retour_ramene_au_menu_de_campagne_tant_que_la_campagne_n_est_pas_terminee() -> void:
	var ecran := _ecran()
	assert_false(ProgressionCampagneService.la_campagne_est_terminee())

	ecran.get_node("Scroll/Content/BoutonRetour").emit_signal("pressed")
	await wait_process_frames(3)

	assert_not_null(get_tree().current_scene)
	assert_eq(get_tree().current_scene.scene_file_path, "res://Scenes/MenuPrincipal/Campagne/campagne.tscn")

func test_retour_ramene_au_menu_principal_quand_la_campagne_est_terminee() -> void:
	var donnees := _donnees_joueur()
	donnees["campagne"] = {}
	_activer_joueur(donnees)
	var ecran := _ecran()
	assert_true(ProgressionCampagneService.la_campagne_est_terminee())

	ecran.get_node("Scroll/Content/BoutonRetour").emit_signal("pressed")
	await wait_process_frames(3)

	assert_not_null(get_tree().current_scene)
	assert_eq(get_tree().current_scene.scene_file_path, "res://Scenes/MenuPrincipal/menu_principal.tscn")
