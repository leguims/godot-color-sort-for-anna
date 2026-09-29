extends GutTest

const LOGIQUE_PARTAGE = preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_logic.gd")
const API_PARTAGE = preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_api.gd")
const SCENE_PARTAGE = preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_ui.tscn")
const SCENE_MENU_CAMPAGNE = preload("res://Scenes/MenuPrincipal/Campagne/MenuCampagne/menu_campagne.tscn")

var logique: PartagePerformancesLogic

func before_each() -> void:
	logique = LOGIQUE_PARTAGE.new()

func test_qr_code_reel_depuis_appli() -> void:
	var donnees : String = "{\"niveau\":{\"date_debut\":1790715101.25958,\"date_fin\":1790715118.80644,\"niveau\":\"niveau_3\",\"plateaux\":[{\"coups joués\":[{\"arrivee\":2,\"depart\":3},{\"arrivee\":3,\"depart\":4},{\"arrivee\":2,\"depart\":1},{\"arrivee\":1,\"depart\":0},{\"arrivee\":2,\"depart\":0},{\"arrivee\":0,\"depart\":1},{\"arrivee\":4,\"depart\":1}],\"date_debut\":1790715101.2635,\"date_fin\":1790715110.20952,\"difficulte\":10,\"duree\":8.94602203369141,\"gameplay\":\"CLASSIQUE\",\"nom\":\"DBD.CDB.   .AAB.CCA\",\"score\":{\"duree\":1341,\"ratio_reussite\":1500},\"statut\":\"reussi\"},{\"coups joués\":[{\"arrivee\":0,\"depart\":4}],\"date_debut\":1790715112.16423,\"date_fin\":1790715118.80384,\"difficulte\":11,\"duree\":6.63960909843445,\"gameplay\":\"QUI_PERD_GAGNE\",\"nom\":\"AB .AA .DCC.BDC.DB \",\"score\":{\"duree\":2319,\"ratio_reussite\":1500},\"statut\":\"reussi\"}],\"score\":{\"niveau\":1000,\"niveau_parfait\":1000}},\"nom\":\"Alain Konu\"}"
	var signature : String = "9e515a6810a3799ca689d2e8b1bba4a84a77fc49bff65dd76d95820d3f804187"
	var cle_hmac : String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	var msg_authentique : bool = logique.verifier_hmac(donnees, signature, cle_hmac)
	assert_true(msg_authentique)

func test_calculer_hmac_projet() -> void:
	var donnees : String = "The quick brown fox jumps over the lazy dog"
	var cle_hmac : String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	var signature : String = logique.calculer_hmac(donnees, cle_hmac)
	var msg_authentique : bool = logique.verifier_hmac(donnees, signature, cle_hmac)
	assert_true(msg_authentique)

func test_calculer_hmac_correspond_au_vecteur_sha256_connu() -> void:
	var signature := logique.calculer_hmac(
		"The quick brown fox jumps over the lazy dog",
		"key"
	)

	assert_eq(signature, "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8")

func test_preparer_enveloppe_emballe_les_donnees_et_leur_signature() -> void:
	var enregistrements := {"niveau": 3, "plateaux": [{"duree": 18.5, "coups": 24}]}
	var resultat: Dictionary = logique.preparer_enveloppe(enregistrements, "cle-de-test")
	var enveloppe: Dictionary = JSON.parse_string(resultat.get("contenu_qr", ""))

	assert_true(resultat.get("succes", false))
	assert_eq(enveloppe.get("version"), 1.0)
	assert_eq(enveloppe.get("algorithme"), "HMAC-SHA256")
	var donnees_decodees: Dictionary = JSON.parse_string(enveloppe.get("donnees_json", ""))
	var premier_plateau: Dictionary = donnees_decodees.get("plateaux", [])[0]
	assert_eq(donnees_decodees.get("niveau"), 3.0)
	assert_eq(premier_plateau.get("duree"), 18.5)
	assert_eq(premier_plateau.get("coups"), 24.0)
	assert_true(logique.verifier_hmac(
		enveloppe.get("donnees_json", ""),
		enveloppe.get("signature", ""),
		"cle-de-test"
	))

func test_preparer_enveloppe_refuse_les_donnees_vides_et_une_cle_absente() -> void:
	var resultat_sans_donnees: Dictionary = logique.preparer_enveloppe({}, "cle")
	var resultat_sans_cle: Dictionary = logique.preparer_enveloppe({"niveau": 1}, "")

	assert_false(resultat_sans_donnees.get("succes", true))
	assert_false(resultat_sans_cle.get("succes", true))

func test_verifier_hmac_refuse_une_signature_modifiee_ou_mal_formee() -> void:
	var signature := logique.calculer_hmac("donnees", "cle")

	assert_false(logique.verifier_hmac("donnees modifiees", signature, "cle"))
	assert_false(logique.verifier_hmac("donnees", "abc", "cle"))
	assert_false(logique.verifier_hmac("donnees", signature, ""))

func test_url_courriel_contient_le_destinataire_et_un_corps_encode() -> void:
	var url: String = logique.creer_url_courriel()

	assert_true(url.begins_with("mailto:rangelescouleurspouranna@gmail.com?"))
	assert_true(url.contains("subject="))
	assert_true(url.contains("body="))
	assert_true(url.contains("%0A"))

func test_api_utilise_la_cle_configuree_dans_le_projet() -> void:
	var api: PartagePerformancesAPI = add_child_autofree(API_PARTAGE.new())
	var resultat: Dictionary = api.preparer_partage({"niveau": 4})

	assert_true(resultat.get("succes", false))
	assert_true(logique.verifier_hmac(
		resultat.get("donnees_json", ""),
		resultat.get("signature", ""),
		ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	))

func test_api_lit_le_nom_du_joueur_et_le_dernier_niveau() -> void:
	var api: PartagePerformancesAPI = add_child_autofree(API_PARTAGE.new())
	var donnees: Dictionary = api.lire_donnees_dernier_niveau()

	assert_eq(donnees.get("nom"), SauvegardeBddJoueursService.lire_nom_joueur())
	assert_eq(donnees.get("niveau"), SauvegardeBddJoueursService.enregistrement_lire_dernier_niveau())

func test_panneau_explique_lindisponibilite_du_qr_sur_une_plateforme_non_supportee() -> void:
	if Engine.has_singleton("QRPlugin"):
		return

	var panneau: PartagePerformancesUI = add_child_autofree(SCENE_PARTAGE.instantiate())
	var partage_reussi: bool = panneau.afficher({"niveau": 4})
	var message: Label = panneau.get_node("Message")

	assert_false(partage_reussi)
	assert_true(message.visible)
	assert_true(message.text.contains("Android et iOS"))

func test_menu_campagne_affiche_le_panneau_avec_les_enregistrements_fournis() -> void:
	var menu: MenuCampagne = add_child_autofree(SCENE_MENU_CAMPAGNE.instantiate())

	menu.afficher_partage_performances({"niveau": 4})

	assert_true(menu.get_node("Centrer").visible)
	assert_true(menu.get_node("Centrer/PanneauPartagePerformances").visible)

func test_fin_de_niveau_affiche_le_partage_apres_le_panneau_de_score() -> void:
	var menu: MenuCampagne = add_child_autofree(SCENE_MENU_CAMPAGNE.instantiate())
	var panneau_partage: Control = menu.get_node("Centrer/PanneauPartagePerformances")
	var panneau_niveau: Control = menu.get_node("Centrer/PanneauVictoireNiveau")

	panneau_niveau.show()
	menu._on_panneau_victoire_niveau_continuer()

	assert_false(panneau_niveau.visible)
	assert_true(panneau_partage.visible)
	assert_false(menu.get_node("BoutonCommencer").visible)

	menu._on_panneau_partage_performances_fermer()

	assert_false(panneau_partage.visible)
	assert_true(menu.get_node("BoutonCommencer").visible)

func test_fin_de_campagne_affiche_le_partage_avant_les_statistiques() -> void:
	var menu: MenuCampagne = add_child_autofree(SCENE_MENU_CAMPAGNE.instantiate())
	var panneau_partage: Control = menu.get_node("Centrer/PanneauPartagePerformances")
	var panneau_campagne: Control = menu.get_node("Centrer/PanneauVictoireCampagne")

	panneau_campagne.show()
	menu._on_panneau_victoire_campagne_continuer()

	assert_false(panneau_campagne.visible)
	assert_true(panneau_partage.visible)
	assert_false(menu.get_node("BoutonCommencer").visible)
