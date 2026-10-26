extends GutTest

const SCENE_JETON = preload("res://Scenes/MenuPrincipal/Campagne/GamePlay/Plateau/Pile/Jeton/jeton.tscn")

var jeton: Jeton

func before_each():
	jeton = add_child_autofree(SCENE_JETON.instantiate())

func _evenement_souris(bouton: int, appuye: bool) -> InputEventMouseButton:
	var evenement = InputEventMouseButton.new()
	evenement.button_index = bouton
	evenement.pressed = appuye
	return evenement

func test_etat_initial_vide():
	assert_eq(jeton.indice_jeton, Plateau.ESPACE)
	assert_true(jeton.est_vide())

func test_choisir_jeton_definit_indice_nom_couleur_et_libelle():
	jeton.choisir_jeton(0)
	assert_eq(jeton.indice_jeton, 0)
	assert_eq(jeton.nom, "A")
	assert_eq(jeton.couleur(), Color("RED"))
	assert_eq(jeton.get_node("Nom").text, "A")
	assert_eq(jeton.get_node("Carre").color, Color("RED"))
	assert_false(jeton.est_vide())

func test_choisir_jeton_correspondance_lettres_indices():
	for indice in range(26):
		jeton.choisir_jeton(indice)
		assert_eq(jeton.nom, String.chr(65 + indice))

func test_choisir_jeton_couleurs_toutes_differentes():
	var couleurs := {}
	for indice in range(26):
		jeton.choisir_jeton(indice)
		couleurs[jeton.couleur()] = true
	assert_eq(couleurs.size(), 26)

func test_choisir_jeton_espace_rend_le_jeton_vide():
	jeton.choisir_jeton(3)
	jeton.choisir_jeton(Plateau.ESPACE)
	assert_true(jeton.est_vide())
	assert_eq(jeton.nom, " ")

func test_choisir_jeton_indice_inconnu_est_ignore():
	jeton.choisir_jeton(5)
	jeton.choisir_jeton(26)
	jeton.choisir_jeton(-1)
	assert_eq(jeton.indice_jeton, 5)
	assert_eq(jeton.nom, "F")

func test_couleur_de_selection_assombrie_pour_couleur_claire():
	jeton.choisir_jeton(3)
	assert_eq(jeton.couleur_selection(), jeton.couleur().darkened(0.3))

func test_couleur_de_selection_eclaircie_pour_couleur_foncee():
	jeton.choisir_jeton(15)
	assert_eq(jeton.couleur_selection(), jeton.couleur().lightened(0.3))

func test_soudures_prennent_la_couleur_assombrie():
	jeton.choisir_jeton(1)
	assert_eq(jeton.get_node("SoudureHaute").color, jeton.couleur().darkened(0.3))
	assert_eq(jeton.get_node("SoudureBasse").color, jeton.couleur().darkened(0.3))

func test_redimensionner_lettre_j_reduit_la_police_et_remonte_le_nom():
	var taille_initiale: int = jeton.get_node("Nom").get_theme_font_size("font_size")
	var position_initiale: float = jeton.position_initiale_nom.y
	jeton.choisir_jeton(9, true)
	assert_eq(jeton.get_node("Nom").get_theme_font_size("font_size"), taille_initiale - 2)
	assert_eq(jeton.position_initiale_nom.y, position_initiale - 3)

func test_pas_de_redimensionnement_sans_demande_ou_autre_lettre():
	var taille_initiale: int = jeton.get_node("Nom").get_theme_font_size("font_size")
	jeton.choisir_jeton(9, false)
	jeton.choisir_jeton(0, true)
	assert_eq(jeton.get_node("Nom").get_theme_font_size("font_size"), taille_initiale)

func test_dimensions_du_jeton():
	assert_eq(jeton.largeur(), 32)
	assert_eq(jeton.hauteur(), 32)

func test_choisir_position_deplace_les_elements():
	jeton.choisir_position(Vector2(100, 200))
	assert_eq(jeton.position(), Vector2(100, 200))
	assert_eq(jeton.get_node("Carre").position, Vector2(100, 200))
	assert_eq(jeton.get_node("Selection").position, Vector2(96, 196))
	assert_eq(jeton.get_node("SoudureHaute").position, Vector2(100, 198))
	assert_eq(jeton.get_node("SoudureBasse").position, Vector2(100, 232))
	assert_eq(jeton.get_node("Nom").position, jeton.position_initiale_nom + Vector2(100, 200))

func test_selectionner_et_deselectionner():
	assert_false(jeton.get_node("Selection").visible)
	jeton.selectionner()
	assert_true(jeton.get_node("Selection").visible)
	jeton.deselectionner()
	assert_false(jeton.get_node("Selection").visible)

func test_souder_et_dessouder():
	jeton.souder_en_haut()
	jeton.souder_en_bas()
	assert_true(jeton.get_node("SoudureHaute").visible)
	assert_true(jeton.get_node("SoudureBasse").visible)
	jeton.dessouder()
	assert_false(jeton.get_node("SoudureHaute").visible)
	assert_false(jeton.get_node("SoudureBasse").visible)

func test_hide_et_show_masquent_carre_et_nom():
	jeton.hide()
	assert_false(jeton.get_node("Carre").visible)
	assert_false(jeton.get_node("Nom").visible)
	jeton.show()
	assert_true(jeton.get_node("Carre").visible)
	assert_true(jeton.get_node("Nom").visible)

func test_set_scale_s_applique_a_tous_les_elements():
	jeton.set_scale(Vector2(2, 2))
	for nom in ["Selection", "SoudureHaute", "Carre", "SoudureBasse", "Nom"]:
		assert_eq(jeton.get_node(nom).scale, Vector2(2, 2), nom)

func test_clic_gauche_emet_clique_gauche_avec_la_reference():
	watch_signals(jeton)
	jeton.choisir_reference(7)
	jeton._on_carre_gui_input(_evenement_souris(MOUSE_BUTTON_LEFT, true))
	assert_signal_emitted_with_parameters(jeton, "clique_gauche", [7])

func test_clic_droit_ou_relachement_n_emet_rien():
	watch_signals(jeton)
	jeton._on_carre_gui_input(_evenement_souris(MOUSE_BUTTON_RIGHT, true))
	jeton._on_carre_gui_input(_evenement_souris(MOUSE_BUTTON_LEFT, false))
	jeton._on_carre_gui_input(InputEventKey.new())
	assert_signal_not_emitted(jeton, "clique_gauche")
