extends GutTest

var service

func before_each():
	service = add_child_autofree(load("res://Singletons/log_service.gd").new())

func test_explode_args_sans_argument_retourne_chaine_vide():
	assert_eq(service.explode_args([]), "")

func test_explode_args_concatene_sans_separateur():
	assert_eq(service.explode_args(["joueur:", "Alice", " score=", 12]), "joueur:Alice score=12")

func test_explode_args_convertit_les_types():
	assert_eq(service.explode_args([1, 2.5, true, null]), "12.5true<null>")
	assert_eq(service.explode_args([[1, 2]]), "[1, 2]")
	assert_eq(service.explode_args([{"a": 1}]), str({"a": 1}))
	assert_eq(service.explode_args([Vector2(1, 2)]), "(1.0, 2.0)")
	assert_eq(service.explode_args([&"nom"]), "nom")

func test_explode_args_chaines_vides():
	assert_eq(service.explode_args(["", ""]), "")
	assert_eq(service.explode_args(["a", "", "b"]), "ab")

func test_explode_args_ne_modifie_pas_les_arguments():
	var args = ["a", 1]
	service.explode_args(args)
	assert_eq(args, ["a", 1])

func test_explode_args_accents_et_unicode():
	assert_eq(service.explode_args(["abandonné", " ", "🖤"]), "abandonné 🖤")

func test_log_debug_ne_plante_pas():
	service.log_debug()
	service.log_debug("texte")
	service.log_debug("a", 1, null, [1], {"k": "v"}, Vector2.ZERO)
	assert_true(true)

func test_log_erreur_ne_plante_pas():
	service.log_erreur()
	service.log_erreur("texte")
	service.log_erreur("a", 1, null, [1], {"k": "v"}, Vector2.ZERO)
	assert_true(true)

func test_log_debug_ne_retourne_rien():
	assert_null(service.log_debug("x"))
	assert_null(service.log_erreur("x"))
