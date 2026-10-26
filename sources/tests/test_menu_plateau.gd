extends GutTest

const SCENE_MENU_PLATEAU = preload("res://Scenes/MenuPrincipal/Campagne/GamePlay/Classique/menu_plateau_classique.tscn")
const RACINE_TEST := "tests/test_menu_plateau"

var sauvegarde_joueur_initiale: Dictionary
var fichier_sauvegarde_initial: String
var configuration_initiale: Dictionary
var menu: MenuPlateau

func _plateau(duree: float, date_fin: float, coups: Array) -> Dictionary:
	return {
		"nom": "AAA.BBB",
		"gameplay": "CLASSIQUE",
		"difficulte": 1,
		"date_debut": Time.get_unix_time_from_system() - 5.0,
		"date_fin": date_fin,
		"duree": duree,
		"statut": "en_cours" if date_fin == 0.0 else "reussi",
		"coups joués": coups
	}

func _definir_plateau(plateau: Dictionary) -> void:
	SauvegardeBddJoueursService._sauvegarde_joueur["enregistrement_campagne"] = [{
		"campagne": "campagne_test",
		"date_debut": 100,
		"date_fin": 0,
		"niveaux": [{"niveau": "niveau_1", "date_debut": 100, "date_fin": 0, "plateaux": [plateau]}]
	}]

func before_each() -> void:
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	FichiersJsonService.effacer_racine_utilisateur()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	SauvegardeBddJoueursService._sauvegarde_joueur = {
		"nom": "Joueuse test",
		"campagne": {"niveau_1": [{"nom": "AAA.BBB.CCC", "gameplay": "CLASSIQUE", "difficulte": 1}]},
		"nombre_de_parties": {},
		"enregistrement_campagne": [],
		"plateaux_libres": {}
	}
	SauvegardeBddJoueursService.fichier_sauvegarde = "joueuse_menu_plateau.json"
	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	menu = add_child_autofree(SCENE_MENU_PLATEAU.instantiate())

func after_each() -> void:
	var scene_courante := get_tree().current_scene
	if scene_courante != null:
		scene_courante.queue_free()
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func test_enregistrer_gameplay_ecrit_le_texte_et_la_taille_de_police() -> void:
	menu.enregistrer_gameplay("Classique")
	assert_eq(menu.get_node("BandeauEnJeu/Gameplay").text, "Classique")
	assert_eq(menu.get_node("BandeauEnJeu/Gameplay").get_theme_font_size("font_size"), 18)

	menu.enregistrer_gameplay("Qui perd gagne", 12)
	assert_eq(menu.get_node("BandeauEnJeu/Gameplay").text, "Qui perd gagne")
	assert_eq(menu.get_node("BandeauEnJeu/Gameplay").get_theme_font_size("font_size"), 12)

func test_enregistrer_sous_titre_gameplay_ecrit_le_texte_et_la_taille_de_police() -> void:
	menu.enregistrer_sous_titre_gameplay("Un sous-titre")
	assert_eq(menu.get_node("BandeauEnJeu/SousTitreGameplay").text, "Un sous-titre")
	assert_eq(menu.get_node("BandeauEnJeu/SousTitreGameplay").get_theme_font_size("font_size"), 15)

	menu.enregistrer_sous_titre_gameplay("Autre", 10)
	assert_eq(menu.get_node("BandeauEnJeu/SousTitreGameplay").get_theme_font_size("font_size"), 10)

func test_enregistrer_chrono_formate_minutes_secondes_decisecondes() -> void:
	menu.enregistrer_chrono("01", "23", "4")

	assert_eq(menu.get_node("BandeauEnJeu/Chrono").text, "01:23.4")

func test_enregistrer_coups_ecrit_le_texte() -> void:
	menu.enregistrer_coups("7 Coups")

	assert_eq(menu.get_node("BandeauEnJeu/Coups").text, "7 Coups")

func test_le_bandeau_menu_memorise_joueur_niveau_et_pourcentage() -> void:
	menu.enregistrer_joueur("Alice")
	menu.enregistrer_niveau("NIVEAU 03")
	menu.enregistrer_pourcentage("42%")

	assert_eq(menu.get_node("BandeauMenu/Joueur").text, "Alice")
	assert_eq(menu.get_node("BandeauMenu/Niveau").text, "NIVEAU 03")
	assert_eq(menu.lire_niveau(), "NIVEAU 03")
	assert_eq(menu.get_node("BandeauMenu/Pourcentage").text, "42%")

func test_show_menu_affiche_tous_les_elements_du_bandeau_menu() -> void:
	menu.show_jeu()
	menu.show_menu()

	for chemin in ["Fond", "BandeauMenu", "BandeauMenu/Fond", "BandeauMenu/Joueur", "BandeauMenu/Niveau",
			"BandeauMenu/Pourcentage", "BandeauMenu/BoutonMenuPrincipal", "BandeauMenu/BoutonCommencer",
			"BandeauMenu/BoutonStatistiques"]:
		assert_true(menu.get_node(chemin).visible, chemin)
	for chemin in ["BandeauEnJeu", "BandeauEnJeu/Fond", "BandeauEnJeu/Gameplay", "BandeauEnJeu/SousTitreGameplay",
			"BandeauEnJeu/Chrono", "BandeauEnJeu/BoutonRecommencer", "BandeauEnJeu/BoutonPasser"]:
		assert_false(menu.get_node(chemin).visible, chemin)

func test_show_jeu_affiche_tous_les_elements_du_bandeau_en_jeu() -> void:
	menu.show_menu()
	menu.show_jeu()

	for chemin in ["Fond", "BandeauEnJeu", "BandeauEnJeu/Fond", "BandeauEnJeu/Gameplay", "BandeauEnJeu/SousTitreGameplay",
			"BandeauEnJeu/Chrono", "BandeauEnJeu/BoutonRecommencer", "BandeauEnJeu/BoutonPasser"]:
		assert_true(menu.get_node(chemin).visible, chemin)
	for chemin in ["BandeauMenu", "BandeauMenu/Fond", "BandeauMenu/Joueur", "BandeauMenu/Niveau",
			"BandeauMenu/Pourcentage", "BandeauMenu/BoutonMenuPrincipal", "BandeauMenu/BoutonCommencer",
			"BandeauMenu/BoutonStatistiques"]:
		assert_false(menu.get_node(chemin).visible, chemin)

func test_hide_cache_le_fond_et_les_deux_bandeaux() -> void:
	menu.show_menu()

	menu.hide()

	assert_false(menu.get_node("Fond").visible)
	assert_false(menu.get_node("BandeauMenu").visible)
	assert_false(menu.get_node("BandeauEnJeu").visible)

func test_show_fond_ne_laisse_que_le_fond_visible() -> void:
	menu.show_jeu()

	menu.show_fond()

	assert_true(menu.get_node("Fond").visible)
	assert_false(menu.get_node("BandeauMenu").visible)
	assert_false(menu.get_node("BandeauEnJeu").visible)

func test_hide_bandeau_en_jeu_puis_show_bandeau_en_jeu_sont_symetriques() -> void:
	menu.show_bandeau_en_jeu()
	assert_true(menu.get_node("BandeauEnJeu/BoutonPasser").visible)

	menu.hide_bandeau_en_jeu()
	assert_false(menu.get_node("BandeauEnJeu").visible)
	assert_false(menu.get_node("BandeauEnJeu/BoutonPasser").visible)

func test_hide_bandeau_menu_puis_show_bandeau_menu_sont_symetriques() -> void:
	menu.show_bandeau_menu()
	assert_true(menu.get_node("BandeauMenu/BoutonCommencer").visible)

	menu.hide_bandeau_menu()
	assert_false(menu.get_node("BandeauMenu").visible)
	assert_false(menu.get_node("BandeauMenu/BoutonCommencer").visible)

func test_le_chrono_affiche_zero_sans_plateau() -> void:
	menu._maj_chrono()

	assert_eq(menu.get_node("BandeauEnJeu/Chrono").text, "00:00.0")

func test_le_chrono_formate_la_duree_d_un_plateau_termine() -> void:
	_definir_plateau(_plateau(75.34, 200.0, []))

	menu._maj_chrono()

	assert_eq(menu.get_node("BandeauEnJeu/Chrono").text, "01:15.3")

func test_le_chrono_reporte_l_arrondi_des_decisecondes_sur_les_secondes_et_les_minutes() -> void:
	_definir_plateau(_plateau(9.97, 200.0, []))
	menu._maj_chrono()
	assert_eq(menu.get_node("BandeauEnJeu/Chrono").text, "00:10.0")

	_definir_plateau(_plateau(59.96, 200.0, []))
	menu._maj_chrono()
	assert_eq(menu.get_node("BandeauEnJeu/Chrono").text, "01:00.0")

func test_le_chrono_d_un_plateau_en_cours_suit_l_horloge() -> void:
	_definir_plateau(_plateau(0.0, 0.0, []))

	menu._maj_chrono()

	assert_true(menu.get_node("BandeauEnJeu/Chrono").text.begins_with("00:05."), menu.get_node("BandeauEnJeu/Chrono").text)

func test_les_coups_sont_comptes_avec_pluriel() -> void:
	menu._maj_coups()
	assert_eq(menu.get_node("BandeauEnJeu/Coups").text, "0 Coup")

	_definir_plateau(_plateau(1.0, 200.0, [{"depart": 0, "arrivee": 1}]))
	menu._maj_coups()
	assert_eq(menu.get_node("BandeauEnJeu/Coups").text, "1 Coup")

	_definir_plateau(_plateau(1.0, 200.0, [{"depart": 0, "arrivee": 1}, {"depart": 1, "arrivee": 2}]))
	menu._maj_coups()
	assert_eq(menu.get_node("BandeauEnJeu/Coups").text, "2 Coups")

func test_process_met_a_jour_chrono_et_coups_a_chaque_frame() -> void:
	_definir_plateau(_plateau(12.3, 200.0, [{"depart": 0, "arrivee": 1}, {"depart": 1, "arrivee": 2}, {"depart": 2, "arrivee": 3}]))

	await wait_process_frames(2)

	assert_eq(menu.get_node("BandeauEnJeu/Chrono").text, "00:12.3")
	assert_eq(menu.get_node("BandeauEnJeu/Coups").text, "3 Coups")

func test_recommencer_emet_abandon_et_ne_montre_que_le_fond() -> void:
	var abandons := [0]
	menu.abandon.connect(func() -> void: abandons[0] += 1)
	menu.show_jeu()

	menu.get_node("BandeauEnJeu/BoutonRecommencer").emit_signal("pressed")

	assert_eq(abandons[0], 1)
	assert_true(menu.get_node("Fond").visible)
	assert_false(menu.get_node("BandeauEnJeu").visible)
	assert_false(menu.get_node("BandeauMenu").visible)

func test_passer_emet_passe_et_ne_montre_que_le_fond() -> void:
	var passes := [0]
	menu.passe.connect(func() -> void: passes[0] += 1)
	menu.show_jeu()

	menu.get_node("BandeauEnJeu/BoutonPasser").emit_signal("pressed")

	assert_eq(passes[0], 1)
	assert_true(menu.get_node("Fond").visible)
	assert_false(menu.get_node("BandeauEnJeu").visible)

func test_commencer_emet_le_signal_quand_la_campagne_a_commence() -> void:
	var demandes := [0]
	menu.commencer_plateau.connect(func() -> void: demandes[0] += 1)

	menu.get_node("BandeauMenu/BoutonCommencer").emit_signal("pressed")

	assert_eq(demandes[0], 1)

func test_commencer_ne_fait_rien_avant_la_date_de_debut_de_campagne() -> void:
	var demandes := [0]
	menu.commencer_plateau.connect(func() -> void: demandes[0] += 1)
	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2099-01-01 00:00:00"

	menu.get_node("BandeauMenu/BoutonCommencer").emit_signal("pressed")

	assert_eq(demandes[0], 0)

func test_clic_gauche_sur_le_fond_deselectionne_la_pile() -> void:
	var deselections := [0]
	menu.deselection_pile.connect(func() -> void: deselections[0] += 1)
	var clic := InputEventMouseButton.new()
	clic.button_index = MOUSE_BUTTON_LEFT
	clic.pressed = true

	menu._on_fond_gui_input(clic)

	assert_eq(deselections[0], 1)

func test_les_autres_evenements_sur_le_fond_sont_ignores() -> void:
	var deselections := [0]
	menu.deselection_pile.connect(func() -> void: deselections[0] += 1)
	var droit := InputEventMouseButton.new()
	droit.button_index = MOUSE_BUTTON_RIGHT
	droit.pressed = true
	var relache := InputEventMouseButton.new()
	relache.button_index = MOUSE_BUTTON_LEFT
	relache.pressed = false

	menu._on_fond_gui_input(droit)
	menu._on_fond_gui_input(relache)
	menu._on_fond_gui_input(InputEventKey.new())

	assert_eq(deselections[0], 0)

func test_le_bouton_menu_principal_charge_le_menu_principal() -> void:
	menu.get_node("BandeauMenu/BoutonMenuPrincipal").emit_signal("pressed")
	await wait_process_frames(3)

	assert_not_null(get_tree().current_scene)
	assert_eq(get_tree().current_scene.scene_file_path, "res://Scenes/MenuPrincipal/menu_principal.tscn")

func test_le_bouton_statistiques_charge_la_scene_statistiques() -> void:
	menu.get_node("BandeauMenu/BoutonStatistiques").emit_signal("pressed")
	await wait_process_frames(3)

	assert_not_null(get_tree().current_scene)
	assert_eq(get_tree().current_scene.scene_file_path, "res://Scenes/MenuPrincipal/Campagne/Statistiques/statistiques.tscn")
