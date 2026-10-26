extends GutTest

const DOSSIER := "res://Scenes/MenuPrincipal/Campagne/GamePlay/Commun/"
const SCENE_1_ITEM = preload(DOSSIER + "carte_victoire_score_1_items.tscn")
const SCENE_2_ITEMS = preload(DOSSIER + "carte_victoire_score_2_items.tscn")
const SCENE_3_ITEMS = preload(DOSSIER + "carte_victoire_score_3_items.tscn")
const SCENE_4_ITEMS = preload(DOSSIER + "carte_victoire_score_4_items.tscn")
const SCENE_POINTS = preload(DOSSIER + "carte_victoire_score_points.tscn")
const SCENE_RATIO = preload(DOSSIER + "carte_victoire_score_ratio_2_items.tscn")
const SCENE_ARC = preload(DOSSIER + "ArcProgressBar/ArcProgressBar.tscn")
const LOGO_PAR_DEFAUT := "res://Art/UI/Gameplay/Commun/victoire_temps.png"

func _scenes_a_items() -> Array:
	return [
		{"scene": SCENE_1_ITEM, "items": 1},
		{"scene": SCENE_2_ITEMS, "items": 2},
		{"scene": SCENE_3_ITEMS, "items": 3},
		{"scene": SCENE_4_ITEMS, "items": 4},
	]

func _texte_item(carte: Node, numero: int) -> String:
	return carte.get_node("ListeItems/Item%d/Texte" % numero).text

func test_les_cartes_a_items_posent_titre_et_logo_une_fois_dans_l_arbre() -> void:
	for cas in _scenes_a_items():
		var carte: Control = add_child_autofree(cas["scene"].instantiate())
		assert_eq(carte.get_node("Titre").text, carte._titre)
		assert_not_null(carte.get_node("MarginContainer/Logo").texture)

func test_le_logo_par_defaut_existe_et_est_charge() -> void:
	assert_true(ResourceLoader.exists(LOGO_PAR_DEFAUT))
	for cas in _scenes_a_items():
		var carte: Control = add_child_autofree(cas["scene"].instantiate())
		assert_eq(carte.get_node("MarginContainer/Logo").texture.resource_path, carte._chemin_logo)

func test_titre_avant_l_entree_dans_l_arbre_est_applique_au_ready() -> void:
	for cas in _scenes_a_items():
		var carte: Control = cas["scene"].instantiate()
		carte.titre("Mon titre")
		add_child_autofree(carte)
		assert_eq(carte.get_node("Titre").text, "Mon titre")

func test_titre_apres_l_entree_dans_l_arbre_met_a_jour_le_label() -> void:
	for cas in _scenes_a_items():
		var carte: Control = add_child_autofree(cas["scene"].instantiate())
		carte.titre("Autre titre")
		assert_eq(carte.get_node("Titre").text, "Autre titre")
		assert_eq(carte._titre, "Autre titre")

func test_logo_change_la_texture_et_memorise_le_chemin() -> void:
	var chemin := "res://Art/UI/Gameplay/Commun/victoire_ratio.png"
	if not ResourceLoader.exists(chemin):
		chemin = LOGO_PAR_DEFAUT
	for cas in _scenes_a_items():
		var carte: Control = add_child_autofree(cas["scene"].instantiate())
		carte.logo(chemin)
		assert_eq(carte._chemin_logo, chemin)
		assert_eq(carte.get_node("MarginContainer/Logo").texture.resource_path, chemin)

func test_les_items_ecrivent_dans_le_bon_label_sans_toucher_aux_autres() -> void:
	for cas in _scenes_a_items():
		var carte: Control = add_child_autofree(cas["scene"].instantiate())
		var avant: Array[String] = []
		for numero in range(1, cas["items"] + 1):
			avant.append(_texte_item(carte, numero))

		for numero in range(1, cas["items"] + 1):
			carte.call("item%d" % numero, "valeur %d" % numero)

		for numero in range(1, cas["items"] + 1):
			assert_eq(_texte_item(carte, numero), "valeur %d" % numero)

		carte.item1("seul")
		assert_eq(_texte_item(carte, 1), "seul")
		if cas["items"] > 1:
			assert_eq(_texte_item(carte, 2), "valeur 2")

func test_seules_les_cartes_avec_plus_d_items_exposent_les_items_supplementaires() -> void:
	var carte_1: Control = add_child_autofree(SCENE_1_ITEM.instantiate())
	var carte_2: Control = add_child_autofree(SCENE_2_ITEMS.instantiate())
	var carte_3: Control = add_child_autofree(SCENE_3_ITEMS.instantiate())

	assert_false(carte_1.has_method("item2"))
	assert_true(carte_2.has_method("item2"))
	assert_false(carte_2.has_method("item3"))
	assert_true(carte_3.has_method("item3"))
	assert_false(carte_3.has_method("item4"))

func test_carte_points_ecrit_le_titre_et_les_points() -> void:
	var carte: Control = add_child_autofree(SCENE_POINTS.instantiate())

	carte.titre("Score total")
	carte.points("12 345")

	assert_eq(carte.get_node("Titre").text, "Score total")
	assert_eq(carte.get_node("Points").text, "12 345")

func test_carte_ratio_ecrit_les_items_et_deduit_le_pourcentage_de_l_arc() -> void:
	var carte: Control = add_child_autofree(SCENE_RATIO.instantiate())
	var arc: Node2D = carte.get_node("MarginContainer/ArcProgressBar")

	carte.item1("Réalisé : 45%")
	carte.item2("1.500 points")
	await wait_process_frames(2)

	assert_eq(carte.get_node("ListeItems/Item1/Texte").text, "Réalisé : 45%")
	assert_eq(carte.get_node("ListeItems/Item2/Texte").text, "1.500 points")
	assert_almost_eq(arc.percentage, 45.0, 0.001)
	assert_eq(arc.get_node("PercentText").text, "45%")

func test_carte_ratio_accepte_les_extremes_et_les_decimales() -> void:
	var carte: Control = add_child_autofree(SCENE_RATIO.instantiate())
	var arc: Node2D = carte.get_node("MarginContainer/ArcProgressBar")

	carte.item1("Réalisé : 100%")
	assert_almost_eq(arc.percentage, 100.0, 0.001)
	carte.item1("Réalisé : 0%")
	assert_almost_eq(arc.percentage, 0.0, 0.001)
	carte.item1("Réalisé : 12.5%")
	assert_almost_eq(arc.percentage, 12.5, 0.001)

func test_carte_ratio_borne_un_pourcentage_hors_limites() -> void:
	var carte: Control = add_child_autofree(SCENE_RATIO.instantiate())
	var arc: Node2D = carte.get_node("MarginContainer/ArcProgressBar")

	carte.item1("Réalisé : 250%")

	assert_almost_eq(arc.percentage, 100.0, 0.001)

func test_carte_ratio_sans_ratio_connu_affiche_zero() -> void:
	var carte: Control = add_child_autofree(SCENE_RATIO.instantiate())
	var arc: Node2D = carte.get_node("MarginContainer/ArcProgressBar")

	carte.item1("Réalisé : -%")

	assert_almost_eq(arc.percentage, 0.0, 0.001)

func test_carte_ratio_titre_avant_ready_est_applique() -> void:
	var carte: Control = SCENE_RATIO.instantiate()
	carte.titre("Ratio")
	add_child_autofree(carte)

	assert_eq(carte.get_node("Titre").text, "Ratio")

func test_arc_progress_bar_affiche_le_pourcentage_arrondi_par_defaut() -> void:
	var arc: Node2D = add_child_autofree(SCENE_ARC.instantiate())
	await wait_process_frames(2)

	assert_almost_eq(arc.percentage, 35.0, 0.001)
	assert_eq(arc.get_node("PercentText").text, "35%")

func test_arc_progress_bar_borne_et_arrondit_les_valeurs() -> void:
	var arc: Node2D = add_child_autofree(SCENE_ARC.instantiate())
	await wait_process_frames(2)

	arc.percentage = 150.0
	assert_almost_eq(arc.percentage, 100.0, 0.001)
	assert_eq(arc.get_node("PercentText").text, "100%")

	arc.percentage = -20.0
	assert_almost_eq(arc.percentage, 0.0, 0.001)
	assert_eq(arc.get_node("PercentText").text, "0%")

	arc.percentage = 49.6
	assert_eq(arc.get_node("PercentText").text, "50%")

func test_arc_progress_bar_transmet_la_progression_au_shader() -> void:
	var arc: Node2D = add_child_autofree(SCENE_ARC.instantiate())
	await wait_process_frames(2)

	arc.percentage = 60.0

	var materiau := arc.get_node("ProgressArc").material as ShaderMaterial
	assert_not_null(materiau)
	assert_almost_eq(float(materiau.get_shader_parameter("progress")), 0.6, 0.0001)

func test_arc_progress_bar_reduit_la_police_pour_cent_pour_cent() -> void:
	var arc: Node2D = add_child_autofree(SCENE_ARC.instantiate())
	await wait_process_frames(2)
	var texte: Label = arc.get_node("PercentText")

	arc.percentage = 100.0
	assert_eq(texte.get_theme_font_size("font_size"), 21)

	arc.percentage = 50.0
	assert_eq(texte.get_theme_font_size("font_size"), 25)

func test_arc_progress_bar_regle_avant_ready_est_applique_apres_ready() -> void:
	var arc: Node2D = SCENE_ARC.instantiate()
	arc.percentage = 72.0
	add_child_autofree(arc)
	await wait_process_frames(2)

	assert_eq(arc.get_node("PercentText").text, "72%")
