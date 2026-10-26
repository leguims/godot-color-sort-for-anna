extends GutTest

const SCENE_MESSAGES_CAMPAGNE = preload("res://Scenes/MenuPrincipal/Campagne/MessagesCampagne/messages_campagne.tscn")

func test_fin_de_campagne_est_traitee_par_la_fin_de_niveau_et_n_affiche_rien() -> void:
	var menu: MessagesCampagne = add_child_autofree(SCENE_MESSAGES_CAMPAGNE.instantiate())
	var panneau_partage: Control = menu.get_node("Centrer/PanneauPartagePerformances")
	var continuations: Array[bool] = []
	menu.score_continuer.connect(func() -> void: continuations.append(true))

	await menu._on_progression_campagne_service_fin_campagne()

	# Le partage de fin de campagne est affiché par la fin du dernier niveau.
	assert_false(panneau_partage.visible)
	assert_eq(continuations, [])

func test_passer_un_plateau_redonne_la_main_a_la_campagne_sans_panneau() -> void:
	var menu: MessagesCampagne = add_child_autofree(SCENE_MESSAGES_CAMPAGNE.instantiate())
	var continuations: Array[bool] = []
	menu.score_continuer.connect(func() -> void: continuations.append(true))

	menu.afficher_passer_un_plateau()

	assert_eq(continuations, [])
	assert_false(menu.get_node("Centrer").visible)

func test_messages_de_victoire_ne_redonnent_pas_la_main_avant_le_panneau_de_score() -> void:
	var menu: MessagesCampagne = add_child_autofree(SCENE_MESSAGES_CAMPAGNE.instantiate())
	var continuations: Array[bool] = []
	menu.score_continuer.connect(func() -> void: continuations.append(true))

	menu.afficher_gagner_un_plateau()
	menu.afficher_fin_niveau()
	menu.afficher_fin_campagne()

	assert_eq(continuations, [])
