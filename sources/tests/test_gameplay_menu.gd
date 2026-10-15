extends GutTest

const SCENE_CLASSIQUE = preload("res://Scenes/MenuPrincipal/Campagne/GamePlay/Classique/classique.tscn")
const SCENE_QUI_PERD_GAGNE = preload("res://Scenes/MenuPrincipal/Campagne/GamePlay/QuiPerdGagne/qui_perd_gagne.tscn")
const SCENES_GAMEPLAY = [SCENE_CLASSIQUE, SCENE_QUI_PERD_GAGNE]

var sauvegarde_joueur_initiale: Dictionary
var fichier_sauvegarde_initial: String
var configuration_initiale: Dictionary

func before_each():
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService.sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)

	SauvegardeBddJoueursService.sauvegarde_joueur = {
		"nom": "Joueuse test",
		"campagne": {
			"niveau_1": [
				{"nom": "AAA.BBB.CCC", "gameplay": "CLASSIQUE", "difficulte": 1}
			]
		},
		"nombre_de_parties": {},
		"enregistrement_campagne": [],
		"plateaux_libres": {}
	}
	SauvegardeBddJoueursService.fichier_sauvegarde = "joueuse_test.json"
	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"

func after_each():
	SauvegardeBddJoueursService.sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale

func test_les_gameplays_affichent_le_menu_et_les_donnees_du_niveau_avant_la_partie():
	for scene in SCENES_GAMEPLAY:
		var gameplay = add_child_autofree(scene.instantiate())
		var menu = gameplay.get_node("MenuPlateau")

		assert_true(menu.get_node("BandeauMenu").visible)
		assert_false(menu.get_node("BandeauEnJeu").visible)
		assert_eq(menu.get_node("BandeauMenu/Joueur").text, "Joueuse test")
		assert_eq(menu.get_node("BandeauMenu/Pourcentage").text, "0%")

		if gameplay is Classique:
			assert_eq(menu.get_node("BandeauMenu/Niveau").text, "NIVEAU 1")
		else:
			assert_eq(menu.get_node("BandeauMenu/Niveau").text, "1")

func test_le_bouton_commencer_emet_le_signal_du_gameplay_sans_lancer_directement_le_plateau():
	var gameplay = add_child_autofree(SCENE_CLASSIQUE.instantiate())
	var nombre_de_demandes := [0]
	gameplay.commencer_plateau.connect(func() -> void: nombre_de_demandes[0] += 1)

	gameplay.get_node("MenuPlateau/BandeauMenu/BoutonCommencer").emit_signal("pressed")

	assert_eq(nombre_de_demandes[0], 1)
	assert_true(gameplay.get_node("MenuPlateau/BandeauMenu").visible)
	assert_false(gameplay.get_node("MenuPlateau/BandeauEnJeu").visible)

func test_le_bouton_commencer_ne_demarre_pas_avant_la_date_debut_de_campagne():
	var gameplay = add_child_autofree(SCENE_CLASSIQUE.instantiate())
	var nombre_de_demandes := [0]
	gameplay.commencer_plateau.connect(func() -> void: nombre_de_demandes[0] += 1)
	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2099-01-01 00:00:00"

	gameplay.get_node("MenuPlateau/BandeauMenu/BoutonCommencer").emit_signal("pressed")
	assert_eq(nombre_de_demandes[0], 0)

	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	gameplay.get_node("MenuPlateau/BandeauMenu/BoutonCommencer").emit_signal("pressed")
	assert_eq(nombre_de_demandes[0], 1)

func test_show_menu_show_jeu_et_show_fond_basculent_les_bandeaux_pour_chaque_gameplay():
	for scene in SCENES_GAMEPLAY:
		var gameplay = add_child_autofree(scene.instantiate())
		var menu = gameplay.get_node("MenuPlateau")

		menu.show_jeu()
		assert_true(menu.get_node("Fond").visible)
		assert_true(menu.get_node("BandeauEnJeu").visible)
		assert_false(menu.get_node("BandeauMenu").visible)

		menu.show_menu()
		assert_true(menu.get_node("BandeauMenu").visible)
		assert_false(menu.get_node("BandeauEnJeu").visible)

		menu.show_fond()
		assert_true(menu.get_node("Fond").visible)
		assert_false(menu.get_node("BandeauMenu").visible)
		assert_false(menu.get_node("BandeauEnJeu").visible)

func test_les_boutons_recommencer_et_passer_emettent_leur_signal_et_affichent_le_fond():
	var menu = add_child_autofree(load(
		"res://Scenes/MenuPrincipal/Campagne/GamePlay/Classique/menu_plateau_classique.tscn"
	).instantiate())
	var abandons := [0]
	var passes := [0]
	menu.abandon.connect(func() -> void: abandons[0] += 1)
	menu.passe.connect(func() -> void: passes[0] += 1)

	menu.show_jeu()
	menu.get_node("BandeauEnJeu/BoutonRecommencer").emit_signal("pressed")
	assert_eq(abandons[0], 1)
	assert_true(menu.get_node("Fond").visible)
	assert_false(menu.get_node("BandeauEnJeu").visible)

	menu.show_jeu()
	menu.get_node("BandeauEnJeu/BoutonPasser").emit_signal("pressed")
	assert_eq(passes[0], 1)
	assert_true(menu.get_node("Fond").visible)
	assert_false(menu.get_node("BandeauEnJeu").visible)

func test_fond_ne_deselectionne_que_sur_un_clic_gauche_enfonce():
	var menu = add_child_autofree(load(
		"res://Scenes/MenuPrincipal/Campagne/GamePlay/Classique/menu_plateau_classique.tscn"
	).instantiate())
	var deselections := [0]
	menu.deselection_pile.connect(func() -> void: deselections[0] += 1)

	var clic_gauche := InputEventMouseButton.new()
	clic_gauche.button_index = MOUSE_BUTTON_LEFT
	clic_gauche.pressed = true
	menu._on_fond_gui_input(clic_gauche)
	assert_eq(deselections[0], 1)

	var clic_droit := InputEventMouseButton.new()
	clic_droit.button_index = MOUSE_BUTTON_RIGHT
	clic_droit.pressed = true
	menu._on_fond_gui_input(clic_droit)
	var relachement := InputEventMouseButton.new()
	relachement.button_index = MOUSE_BUTTON_LEFT
	relachement.pressed = false
	menu._on_fond_gui_input(relachement)
	assert_eq(deselections[0], 1)
