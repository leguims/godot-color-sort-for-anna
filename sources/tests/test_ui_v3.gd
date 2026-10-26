extends GutTest

const SCENE_A_PROPOS = preload("res://Scenes/MenuPrincipal/APropos/a_propos.tscn")
const SCENE_CARTE_MOTEUR = preload("res://Scenes/MenuPrincipal/APropos/carte_moteur.tscn")

func after_each() -> void:
	var scene_courante := get_tree().current_scene
	if scene_courante != null:
		scene_courante.queue_free()

func test_box_applique_couleur_et_rayon() -> void:
	var style := UIV3.box(Color.RED, 7)

	assert_eq(style.bg_color, Color.RED)
	assert_eq(style.corner_radius_top_left, 7)
	assert_eq(style.corner_radius_top_right, 7)
	assert_eq(style.corner_radius_bottom_left, 7)
	assert_eq(style.corner_radius_bottom_right, 7)

func test_box_par_defaut_rayon_16_sans_bordure() -> void:
	var style := UIV3.box(Color.BLUE)

	assert_eq(style.corner_radius_top_left, 16)
	assert_eq(style.border_color, Color.TRANSPARENT)
	assert_eq(style.border_width_left, 0)
	assert_eq(style.border_width_top, 0)
	assert_eq(style.border_width_right, 0)
	assert_eq(style.border_width_bottom, 0)

func test_box_applique_la_bordure_sur_les_quatre_cotes() -> void:
	var style := UIV3.box(Color.WHITE, 4, Color.GREEN, 3)

	assert_eq(style.border_color, Color.GREEN)
	assert_eq(style.border_width_left, 3)
	assert_eq(style.border_width_top, 3)
	assert_eq(style.border_width_right, 3)
	assert_eq(style.border_width_bottom, 3)

func test_box_renvoie_un_nouveau_style_a_chaque_appel() -> void:
	assert_ne(UIV3.box(Color.RED), UIV3.box(Color.RED))

func test_place_positionne_et_dimensionne_le_controle() -> void:
	var controle := Control.new()
	add_child_autofree(controle)

	var resultat := UIV3.place(controle, Rect2(5, 6, 70, 80))

	assert_eq(controle.position, Vector2(5, 6))
	assert_eq(controle.size, Vector2(70, 80))
	assert_same(resultat, controle)

func test_les_constantes_de_couleur_sont_celles_de_la_charte() -> void:
	assert_eq(UIV3.NAVY, Color("0a274d"))
	assert_eq(UIV3.CREAM, Color("fff8ed"))
	assert_eq(UIV3.CORAL, Color("f04d3c"))
	assert_eq(UIV3.CAMPAIGN, Color("e52b1f"))
	assert_eq(UIV3.LEVEL, Color("119d9c"))
	assert_eq(UIV3.PLATEAU, Color("7137a8"))
	assert_eq(UIV3.MODE, Color("d98219"))

func test_a_propos_affiche_titres_et_cinq_cartes() -> void:
	var ecran: Control = add_child_autofree(SCENE_A_PROPOS.instantiate())

	assert_eq(ecran.get_node("PanneauCredits/HBoxContainer/VBox/VBoxEntete/Titre").text, "À propos")
	assert_eq(ecran.get_node("PanneauCredits/HBoxContainer/VBox/VBoxEntete/SousTitre").text, "Crédits et ressources")
	assert_eq(ecran.get_node("PanneauCredits/HBoxContainer/VBox/VBoxCorps").get_child_count(), 5)
	for nom in ["CarteMoteur", "CarteIA", "CarteMusique", "CarteEffetsSonores", "CarteDidacticiel"]:
		assert_not_null(ecran.get_node("PanneauCredits/HBoxContainer/VBox/VBoxCorps/" + nom), nom)

func test_a_propos_retour_charge_le_menu_principal() -> void:
	var ecran: Control = add_child_autofree(SCENE_A_PROPOS.instantiate())

	ecran.get_node("Retour").emit_signal("pressed")
	await wait_process_frames(3)

	assert_eq(get_tree().current_scene.scene_file_path, "res://Scenes/MenuPrincipal/menu_principal.tscn")

func test_carte_moteur_se_charge_comme_controle() -> void:
	var carte: Control = add_child_autofree(SCENE_CARTE_MOTEUR.instantiate())

	assert_true(carte.has_method("_on_lien_meta_clicked"))
