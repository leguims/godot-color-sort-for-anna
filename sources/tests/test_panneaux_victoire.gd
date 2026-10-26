extends GutTest

const DOSSIER := "res://Scenes/MenuPrincipal/Campagne/GamePlay/Commun/"
const SCENE_DEFAITE = preload(DOSSIER + "panneau_defaite.tscn")
const SCENE_PLATEAU = preload(DOSSIER + "panneau_victoire_plateau.tscn")
const SCENE_NIVEAU = preload(DOSSIER + "panneau_victoire_niveau.tscn")
const SCENE_CAMPAGNE = preload(DOSSIER + "panneau_victoire_campagne.tscn")

func _panneaux() -> Array:
	return [SCENE_DEFAITE, SCENE_PLATEAU, SCENE_NIVEAU, SCENE_CAMPAGNE]

func _texte(panneau: Node, carte: String, numero: int) -> String:
	return panneau.get_node("%s/ListeItems/Item%d/Texte" % [carte, numero]).text

func test_le_bouton_continuer_est_ignore_juste_apres_l_affichage() -> void:
	for scene in _panneaux():
		var panneau: Control = add_child_autofree(scene.instantiate())
		var signaux: Array[bool] = []
		panneau.continuer.connect(func() -> void: signaux.append(true))
		panneau._create_time_ms = Time.get_ticks_msec()

		panneau.get_node("Control/Bouton").emit_signal("pressed")

		assert_eq(signaux, [])

func test_le_bouton_continuer_emet_le_signal_apres_le_seuil_anti_clic() -> void:
	for scene in _panneaux():
		var panneau: Control = add_child_autofree(scene.instantiate())
		var signaux: Array[bool] = []
		panneau.continuer.connect(func() -> void: signaux.append(true))
		panneau._create_time_ms = Time.get_ticks_msec() - panneau.SEUIL_CLICK_BOUTON_EN_MS - 1

		panneau.get_node("Control/Bouton").emit_signal("pressed")

		assert_eq(signaux, [true])

func test_le_seuil_anti_clic_est_de_500_ms() -> void:
	for scene in _panneaux():
		var panneau: Control = add_child_autofree(scene.instantiate())
		assert_eq(panneau.SEUIL_CLICK_BOUTON_EN_MS, 500)

func test_on_draw_memorise_l_instant_d_affichage() -> void:
	for scene in _panneaux():
		var panneau: Control = add_child_autofree(scene.instantiate())
		panneau._create_time_ms = 0

		var avant := Time.get_ticks_msec()
		panneau._on_draw()

		assert_between(panneau._create_time_ms, avant, Time.get_ticks_msec())

func test_chaque_clic_valide_emet_un_signal() -> void:
	var panneau: Control = add_child_autofree(SCENE_DEFAITE.instantiate())
	var signaux: Array[bool] = []
	panneau.continuer.connect(func() -> void: signaux.append(true))
	panneau._create_time_ms = Time.get_ticks_msec() - 1000

	panneau._on_bouton_pressed()
	panneau._on_bouton_pressed()

	assert_eq(signaux.size(), 2)

func test_le_bouton_et_le_libelle_continuer_existent_sur_chaque_panneau() -> void:
	for scene in _panneaux():
		var panneau: Control = add_child_autofree(scene.instantiate())
		assert_true(panneau.get_node("Control/Bouton") is Button)
		assert_eq(panneau.get_node("Control/Continuer").text, "Continuer")

func test_panneau_defaite_affiche_titre_et_logo() -> void:
	var panneau: Control = add_child_autofree(SCENE_DEFAITE.instantiate())

	assert_not_null(panneau.get_node("Titre").texture)
	assert_not_null(panneau.get_node("Logo").texture)

func test_panneau_plateau_affiche_score_temps_et_ratio() -> void:
	var panneau: Control = add_child_autofree(SCENE_PLATEAU.instantiate())

	panneau.score_points("1.234")
	panneau.temps("12", "8.5", "9.1", "250")
	panneau.ratio("80", "400")

	assert_eq(panneau.get_node("ScorePoints/Points").text, "1.234")
	assert_eq(_texte(panneau, "Temps", 1), "Référence : 12s")
	assert_eq(_texte(panneau, "Temps", 2), "Recommencé : 8.5s")
	assert_eq(_texte(panneau, "Temps", 3), "Réalisé : 9.1s")
	assert_eq(_texte(panneau, "Temps", 4), "250 points")
	assert_eq(_texte(panneau, "Ratio", 1), "Réalisé : 80%")
	assert_eq(_texte(panneau, "Ratio", 2), "400 points")
	assert_almost_eq(panneau.get_node("Ratio/MarginContainer/ArcProgressBar").percentage, 80.0, 0.001)

func test_panneau_plateau_gere_les_valeurs_inconnues() -> void:
	var panneau: Control = add_child_autofree(SCENE_PLATEAU.instantiate())

	panneau.temps("-", "-", "-", "0")
	panneau.ratio("-", "0")

	assert_eq(_texte(panneau, "Temps", 1), "Référence : -s")
	assert_eq(_texte(panneau, "Ratio", 1), "Réalisé : -%")
	assert_almost_eq(panneau.get_node("Ratio/MarginContainer/ArcProgressBar").percentage, 0.0, 0.001)

func test_panneau_niveau_affiche_score_temps_ratio_niveau_et_niveau_parfait() -> void:
	var panneau: Control = add_child_autofree(SCENE_NIVEAU.instantiate())

	panneau.score_points("5.000")
	panneau.temps("20", "15", "18.2", "300")
	panneau.ratio("65", "650")
	panneau.niveau("3", "1.000")
	panneau.niveau_parfait("oui", "1.000")

	assert_eq(panneau.get_node("ScorePoints/Points").text, "5.000")
	assert_eq(_texte(panneau, "Temps", 1), "Référence : 20s")
	assert_eq(_texte(panneau, "Temps", 2), "Recommencé : 15s")
	assert_eq(_texte(panneau, "Temps", 3), "Réalisé : 18.2s")
	assert_eq(_texte(panneau, "Temps", 4), "300 points")
	assert_eq(_texte(panneau, "Ratio", 1), "Réalisé : 65%")
	assert_eq(_texte(panneau, "Ratio", 2), "650 points")
	assert_eq(_texte(panneau, "Niveau", 1), "Longueur: 3")
	assert_eq(_texte(panneau, "Niveau", 2), "1.000 points")
	assert_eq(_texte(panneau, "NiveauParfait", 1), "Bonus:  oui")
	assert_eq(_texte(panneau, "NiveauParfait", 2), "1.000 points")

func test_panneau_campagne_affiche_toutes_les_cartes_dont_le_bonus_de_campagne() -> void:
	var panneau: Control = add_child_autofree(SCENE_CAMPAGNE.instantiate())

	panneau.score_points("9.999")
	panneau.temps("30", "20", "25", "100")
	panneau.ratio("90", "900")
	panneau.niveau("5", "2.000")
	panneau.niveau_parfait("non", "0")
	panneau.campagne("5.000")

	assert_eq(panneau.get_node("ScorePoints/Points").text, "9.999")
	assert_eq(_texte(panneau, "Temps", 3), "Réalisé : 25s")
	assert_eq(_texte(panneau, "Ratio", 1), "Réalisé : 90%")
	assert_eq(_texte(panneau, "Niveau", 1), "Longueur: 5")
	assert_eq(_texte(panneau, "NiveauParfait", 1), "Bonus:  non")
	assert_eq(_texte(panneau, "NiveauParfait", 2), "0 points")
	assert_eq(_texte(panneau, "Campagne", 1), "5.000 points")

func test_les_cartes_du_panneau_niveau_et_niveau_parfait_sont_independantes() -> void:
	var panneau: Control = add_child_autofree(SCENE_CAMPAGNE.instantiate())

	panneau.niveau("4", "10")
	panneau.niveau_parfait("oui", "20")

	assert_eq(_texte(panneau, "Niveau", 2), "10 points")
	assert_eq(_texte(panneau, "NiveauParfait", 2), "20 points")
