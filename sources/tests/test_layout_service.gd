extends GutTest

var layout: PlateauLayoutService

func before_each():
	layout = PlateauLayoutService.new()
	layout.taille_bouton_recommencer_originale = 0.
	layout.taille_fenetre_jeu = Vector2(480, 720)
	layout.taille_pile_pixels = Vector2(40, 100)

func test_taille_plateau_zero_pile():
	assert_eq(layout.convertir_nb_piles_en_taille_plateau(0), Vector2i(0, 0))

func test_taille_plateau_une_seule_ligne():
	assert_eq(layout.convertir_nb_piles_en_taille_plateau(1), Vector2i(1, 1))
	assert_eq(layout.convertir_nb_piles_en_taille_plateau(5), Vector2i(5, 1))
	assert_eq(layout.convertir_nb_piles_en_taille_plateau(6), Vector2i(6, 1))

func test_taille_plateau_plusieurs_lignes():
	assert_eq(layout.convertir_nb_piles_en_taille_plateau(7), Vector2i(4, 2))
	assert_eq(layout.convertir_nb_piles_en_taille_plateau(12), Vector2i(6, 2))
	assert_eq(layout.convertir_nb_piles_en_taille_plateau(13), Vector2i(4, 3))
	assert_eq(layout.convertir_nb_piles_en_taille_plateau(18), Vector2i(6, 3))

func test_taille_plateau_contient_toutes_les_piles():
	for nb_piles in range(1, 40):
		var taille = layout.convertir_nb_piles_en_taille_plateau(nb_piles)
		assert_gte(taille.x * taille.y, nb_piles, "capacite insuffisante pour %d piles" % nb_piles)
		assert_lte(taille.x, 6, "trop de piles par ligne pour %d piles" % nb_piles)

func test_coordonnees_zero_pile():
	assert_eq(layout.convertir_indice_pile_coordonnees(0, 0), Vector2i(0, 0))

func test_coordonnees_une_ligne():
	assert_eq(layout.convertir_indice_pile_coordonnees(5, 0), Vector2i(0, 0))
	assert_eq(layout.convertir_indice_pile_coordonnees(5, 4), Vector2i(4, 0))

func test_coordonnees_plusieurs_lignes():
	assert_eq(layout.convertir_indice_pile_coordonnees(7, 3), Vector2i(3, 0))
	assert_eq(layout.convertir_indice_pile_coordonnees(7, 4), Vector2i(0, 1))
	assert_eq(layout.convertir_indice_pile_coordonnees(7, 5), Vector2i(1, 1))
	assert_eq(layout.convertir_indice_pile_coordonnees(13, 12), Vector2i(0, 3))

func test_coordonnees_sont_uniques_pour_chaque_pile():
	for nb_piles in [3, 7, 12, 13, 20]:
		var vues := {}
		for indice in range(nb_piles):
			vues[layout.convertir_indice_pile_coordonnees(nb_piles, indice)] = true
		assert_eq(vues.size(), nb_piles)

func test_position_une_ligne_valeurs_exactes():
	for indice in range(3):
		var position = layout.calculer_la_position_de_la_pile(3, indice)
		assert_almost_eq(position.x, 90. + 130. * indice, 0.001)
		assert_almost_eq(position.y, 410., 0.001)

func test_position_une_ligne_tient_compte_du_bouton_recommencer():
	layout.taille_bouton_recommencer_originale = 100.
	var position = layout.calculer_la_position_de_la_pile(3, 0)
	assert_almost_eq(position.y, 435., 0.001)

func test_position_une_ligne_centree_horizontalement():
	var premiere = layout.calculer_la_position_de_la_pile(4, 0)
	var derniere = layout.calculer_la_position_de_la_pile(4, 3)
	var marge_gauche = premiere.x
	var marge_droite = layout.taille_fenetre_jeu.x - (derniere.x + layout.taille_pile_pixels.x)
	assert_almost_eq(marge_gauche, marge_droite, 0.001)

func test_position_une_pile_est_au_centre():
	var position = layout.calculer_la_position_de_la_pile(1, 0)
	assert_almost_eq(position.x + layout.taille_pile_pixels.x / 2., 240., 0.001)

func test_position_plusieurs_lignes_valeurs_exactes():
	var p0 = layout.calculer_la_position_de_la_pile(7, 0)
	assert_almost_eq(p0.x, 64., 0.001)
	assert_almost_eq(p0.y, 546.667, 0.001)
	var p4 = layout.calculer_la_position_de_la_pile(7, 4)
	assert_almost_eq(p4.x, 64., 0.001)
	assert_almost_eq(p4.y, 273.333, 0.001)
	var p5 = layout.calculer_la_position_de_la_pile(7, 5)
	assert_almost_eq(p5.x, 168., 0.001)

func test_position_plusieurs_lignes_premiere_ligne_en_bas():
	var ligne_0 = layout.calculer_la_position_de_la_pile(8, 0)
	var ligne_1 = layout.calculer_la_position_de_la_pile(8, 4)
	assert_gt(ligne_0.y, ligne_1.y)

func test_positions_toutes_distinctes():
	for nb_piles in [1, 4, 6, 7, 12, 13]:
		var vues := {}
		for indice in range(nb_piles):
			vues[layout.calculer_la_position_de_la_pile(nb_piles, indice)] = true
		assert_eq(vues.size(), nb_piles, "positions dupliquees pour %d piles" % nb_piles)
