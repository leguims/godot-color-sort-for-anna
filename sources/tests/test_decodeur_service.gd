extends GutTest

var decodeur: PlateauDecodeurService

func before_each():
	decodeur = PlateauDecodeurService.new()

func test_table_de_conversion_initialisee_a_la_construction():
	assert_eq(decodeur.string2int.size(), 27)
	assert_eq(decodeur.string2int["A"], 0)
	assert_eq(decodeur.string2int["Z"], 25)
	assert_eq(decodeur.string2int[" "], Plateau.ESPACE)

func test_decoder_pile_lettres_en_indices():
	assert_eq(decodeur.decoder_pile("ABZ"), [0, 1, 25])

func test_decoder_pile_espace_devient_espace_plateau():
	assert_eq(decodeur.decoder_pile("A  "), [0, Plateau.ESPACE, Plateau.ESPACE])

func test_decoder_pile_vide():
	assert_eq(decodeur.decoder_pile(""), [])

func test_decoder_pile_tout_l_alphabet():
	var attendu := []
	for i in range(26):
		attendu.append(i)
	assert_eq(decodeur.decoder_pile("ABCDEFGHIJKLMNOPQRSTUVWXYZ"), attendu)

func test_decoder_plateau_plusieurs_piles():
	assert_eq(decodeur.decoder_plateau("AB.BA. "), [[0, 1], [1, 0], [Plateau.ESPACE]])

func test_decoder_plateau_met_en_majuscules():
	assert_eq(decodeur.decoder_plateau("ab.ba"), decodeur.decoder_plateau("AB.BA"))

func test_decoder_plateau_texte_vide_donne_une_pile_vide():
	assert_eq(decodeur.decoder_plateau(""), [[]])

func test_decoder_plateau_separateurs_consecutifs():
	assert_eq(decodeur.decoder_plateau("A..B"), [[0], [], [1]])

func test_est_valide_plateau_correct():
	assert_true(decodeur.est_valide("AAB.BBA.   "))

func test_est_valide_plateau_deux_couleurs_une_pile_vide():
	assert_true(decodeur.est_valide("AB.BA.  "))

func test_est_valide_minuscules():
	assert_true(decodeur.est_valide("aab.bba.   "))

func test_est_valide_refuse_plateau_vide():
	assert_false(decodeur.est_valide(""))

func test_est_valide_refuse_que_des_vides_et_separateurs():
	assert_false(decodeur.est_valide("..."))
	assert_false(decodeur.est_valide("   .   "))
	assert_false(decodeur.est_valide(" . . "))

func test_est_valide_refuse_vide_au_milieu_d_une_pile():
	assert_false(decodeur.est_valide("A B.BAA"))

func test_est_valide_refuse_vide_en_bas_d_une_pile():
	assert_false(decodeur.est_valide(" AB.BAA"))

func test_est_valide_refuse_nombre_de_jetons_inegaux():
	assert_false(decodeur.est_valide("AAB.BB .   "))

func test_est_valide_refuse_nombre_de_jetons_different_de_la_taille_de_pile():
	assert_false(decodeur.est_valide("AA.BB.AAB"))

func test_est_valide_refuse_une_seule_pile_invalide_parmi_valides():
	assert_false(decodeur.est_valide("AB.BA. A"))

func test_est_valide_refuse_actuellement_deux_piles_vides():
	# Les espaces sont comptes comme une lettre : 6 espaces != 3 jetons
	assert_false(decodeur.est_valide("AAB.BBA.   .   "))
