extends GutTest

const SCENE_PILE = preload("res://Scenes/MenuPrincipal/Campagne/GamePlay/Plateau/Pile/pile.tscn")

var decodeur := PlateauDecodeurService.new()

func _pile(texte: String) -> Pile:
	var pile: Pile = add_child_autofree(SCENE_PILE.instantiate())
	assert_true(pile.ajouter_les_jetons(decodeur.decoder_pile(texte)))
	return pile

func _contenu(pile: Pile) -> Array:
	var contenu := []
	for jeton in pile.liste_jetons:
		contenu.append(jeton.indice_jeton)
	return contenu

func _selectionnes(pile: Pile) -> Array:
	var selection := []
	for jeton in pile.liste_jetons:
		selection.append(jeton.get_node("Selection").visible)
	return selection

func _evenement_souris(bouton: int, appuye: bool) -> InputEventMouseButton:
	var evenement = InputEventMouseButton.new()
	evenement.button_index = bouton
	evenement.pressed = appuye
	return evenement

# --- Validite ---

func test_est_valide_vides_uniquement_en_haut():
	assert_true(Pile.est_valide([0, 1, Plateau.ESPACE, Plateau.ESPACE]))
	assert_true(Pile.est_valide([0, 1, 2]))
	assert_true(Pile.est_valide([Plateau.ESPACE, Plateau.ESPACE]))
	assert_true(Pile.est_valide([]))

func test_est_valide_refuse_jeton_au_dessus_d_un_vide():
	assert_false(Pile.est_valide([0, Plateau.ESPACE, 1]))
	assert_false(Pile.est_valide([Plateau.ESPACE, 0]))

func test_ajouter_les_jetons_pile_invalide_est_refusee():
	var pile: Pile = add_child_autofree(SCENE_PILE.instantiate())
	assert_false(pile.ajouter_les_jetons([Plateau.ESPACE, 0]))
	assert_eq(pile.liste_jetons.size(), 0)

func test_ajouter_les_jetons_cree_les_jetons_dans_l_ordre():
	var pile = _pile("AB ")
	assert_eq(_contenu(pile), [0, 1, Plateau.ESPACE])

func test_ajouter_les_jetons_attribue_les_references():
	var pile = _pile("ABC")
	for i in range(3):
		assert_eq(pile.liste_jetons[i].reference_parent, i)

func test_choisir_et_obtenir_reference():
	var pile = _pile("A")
	pile.choisir_reference(4)
	assert_eq(pile.obtenir_reference(), 4)

# --- Etats vide / pleine / terminee ---

func test_pile_sans_jeton():
	var pile: Pile = add_child_autofree(SCENE_PILE.instantiate())
	assert_true(pile.est_vide())
	assert_true(pile.est_pleine())
	assert_eq(pile.largeur(), 0)
	assert_eq(pile.hauteur(), 0)

func test_pile_vide():
	var pile = _pile("   ")
	assert_true(pile.est_vide())
	assert_false(pile.est_pleine())
	assert_false(pile.est_termine())

func test_pile_partiellement_remplie():
	var pile = _pile("AB ")
	assert_false(pile.est_vide())
	assert_false(pile.est_pleine())
	assert_false(pile.est_termine())

func test_pile_pleine_heterogene():
	var pile = _pile("ABA")
	assert_false(pile.est_vide())
	assert_true(pile.est_pleine())
	assert_false(pile.est_termine())

func test_pile_pleine_homogene_est_terminee():
	var pile = _pile("AAA")
	assert_true(pile.est_pleine())
	assert_true(pile.est_termine())

func test_pile_homogene_non_pleine_n_est_pas_terminee():
	assert_false(_pile("AA ").est_termine())

# --- Sommet ---

func test_couleur_au_sommet():
	assert_eq(_pile("AB ").quelle_est_la_couleur_au_sommet(), 1)
	assert_eq(_pile("ABC").quelle_est_la_couleur_au_sommet(), 2)
	assert_eq(_pile("A  ").quelle_est_la_couleur_au_sommet(), 0)

func test_couleur_au_sommet_pile_vide():
	assert_eq(_pile("   ").quelle_est_la_couleur_au_sommet(), Plateau.ESPACE)

func test_nombre_de_jetons_identiques_au_sommet():
	assert_eq(_pile("ABB ").combien_de_jetons_identiques_au_sommet(), 2)
	assert_eq(_pile("ABBB").combien_de_jetons_identiques_au_sommet(), 3)
	assert_eq(_pile("BAB ").combien_de_jetons_identiques_au_sommet(), 1)
	assert_eq(_pile("A   ").combien_de_jetons_identiques_au_sommet(), 1)

func test_nombre_de_jetons_identiques_au_sommet_pile_vide_ou_terminee():
	assert_eq(_pile("   ").combien_de_jetons_identiques_au_sommet(), 0)
	assert_eq(_pile("AAA").combien_de_jetons_identiques_au_sommet(), 0)

func test_nombre_de_cases_vides_au_sommet():
	assert_eq(_pile("AB  ").combien_de_cases_vides_au_sommet(), 2)
	assert_eq(_pile("    ").combien_de_cases_vides_au_sommet(), 4)
	assert_eq(_pile("ABAB").combien_de_cases_vides_au_sommet(), 0)

# --- Acceptation ---

func test_accepte_jeton_meme_couleur_avec_place():
	assert_true(_pile("AB  ").accepte_jeton(1, 1))
	assert_true(_pile("AB  ").accepte_jeton(1, 2))

func test_refuse_jeton_de_couleur_differente():
	assert_false(_pile("AB  ").accepte_jeton(0, 1))

func test_refuse_trop_de_jetons():
	assert_false(_pile("AB  ").accepte_jeton(1, 3))

func test_pile_vide_accepte_toutes_les_couleurs_dans_la_limite_de_la_place():
	var pile = _pile("   ")
	assert_true(pile.accepte_jeton(5, 3))
	assert_false(pile.accepte_jeton(5, 4))

func test_pile_pleine_refuse_tout():
	assert_false(_pile("ABA").accepte_jeton(0, 1))

# --- Empilement / depilement ---

func test_ajouter_le_jeton_dans_le_vide():
	var pile = _pile("A  ")
	assert_true(pile.ajouter_le_jeton_dans_le_vide(0))
	assert_eq(_contenu(pile), [0, 0, Plateau.ESPACE])

func test_ajouter_le_jeton_dans_une_pile_vide():
	var pile = _pile("   ")
	assert_true(pile.ajouter_le_jeton_dans_le_vide(3))
	assert_eq(_contenu(pile), [3, Plateau.ESPACE, Plateau.ESPACE])

func test_ajouter_jusqu_a_remplir_la_pile_la_termine():
	var pile = _pile("A  ")
	pile.ajouter_le_jeton_dans_le_vide(0)
	pile.ajouter_le_jeton_dans_le_vide(0)
	assert_true(pile.est_pleine())
	assert_true(pile.est_termine())

func test_ajouter_un_jeton_de_mauvaise_couleur_est_refuse():
	var pile = _pile("A  ")
	assert_false(pile.ajouter_le_jeton_dans_le_vide(1))
	assert_eq(_contenu(pile), [0, Plateau.ESPACE, Plateau.ESPACE])

func test_ajouter_dans_une_pile_pleine_est_refuse():
	var pile = _pile("AB")
	assert_false(pile.ajouter_le_jeton_dans_le_vide(1))
	assert_eq(_contenu(pile), [0, 1])

func test_retirer_le_dernier_jeton():
	var pile = _pile("AB ")
	assert_true(pile.retirer_le_dernier_jeton())
	assert_eq(_contenu(pile), [0, Plateau.ESPACE, Plateau.ESPACE])

func test_retirer_dans_une_pile_pleine():
	var pile = _pile("ABC")
	assert_true(pile.retirer_le_dernier_jeton())
	assert_eq(_contenu(pile), [0, 1, Plateau.ESPACE])

func test_retirer_dans_une_pile_vide_retourne_faux():
	var pile = _pile("   ")
	assert_false(pile.retirer_le_dernier_jeton())
	assert_true(pile.est_vide())

func test_retirer_tous_les_jetons_vide_la_pile():
	var pile = _pile("AB")
	pile.retirer_le_dernier_jeton()
	pile.retirer_le_dernier_jeton()
	assert_true(pile.est_vide())

func test_retirer_puis_ajouter_conserve_l_ordre_des_jetons_restants():
	var pile = _pile("ABC")
	pile.retirer_le_dernier_jeton()
	pile.ajouter_le_jeton_dans_le_vide(1)
	assert_eq(_contenu(pile), [0, 1, 1])

# --- Soudures ---

func _soudures(pile: Pile) -> Array:
	var soudures := []
	for jeton in pile.liste_jetons:
		soudures.append([jeton.get_node("SoudureHaute").visible, jeton.get_node("SoudureBasse").visible])
	return soudures

func test_soudures_entre_jetons_identiques_adjacents():
	var pile = _pile("AAB")
	assert_eq(_soudures(pile), [[true, false], [false, true], [false, false]])

func test_pas_de_soudure_pour_jetons_differents():
	assert_eq(_soudures(_pile("ABA")), [[false, false], [false, false], [false, false]])

func test_soudures_mises_a_jour_apres_retrait():
	var pile = _pile("AAA")
	pile.retirer_le_dernier_jeton()
	assert_eq(_soudures(pile), [[true, false], [false, true], [false, false]])

func test_soudures_mises_a_jour_apres_ajout():
	var pile = _pile("AA ")
	pile.ajouter_le_jeton_dans_le_vide(0)
	assert_eq(_soudures(pile), [[true, false], [true, true], [false, true]])

# --- Selection ---

func test_selectionner_marque_les_jetons_identiques_au_sommet():
	var pile = _pile("ABB ")
	pile.selectionner()
	assert_eq(_selectionnes(pile), [false, true, true, false])

func test_selectionner_un_seul_jeton_au_sommet():
	var pile = _pile("BAB")
	pile.selectionner()
	assert_eq(_selectionnes(pile), [false, false, true])

func test_selectionner_ne_fait_rien_sur_pile_vide_ou_terminee():
	var vide = _pile("   ")
	var terminee = _pile("AAA")
	vide.selectionner()
	terminee.selectionner()
	assert_eq(_selectionnes(vide), [false, false, false])
	assert_eq(_selectionnes(terminee), [false, false, false])

func test_deselectionner_efface_la_selection_et_remet_la_couleur_de_fond():
	var pile = _pile("ABB")
	pile.selectionner()
	pile.selectionner_deplacement_valide()
	pile.deselectionner()
	assert_eq(_selectionnes(pile), [false, false, false])
	assert_eq(pile.get_node("Fond").color, pile.couleur_de_deselection)

func test_selectionner_deplacement_valide_change_la_couleur_de_fond():
	var pile = _pile("A  ")
	pile.selectionner_deplacement_valide()
	assert_eq(pile.get_node("Fond").color, pile.couleur_de_deplacement_valide)

func test_deselectionner_ne_modifie_pas_une_pile_terminee():
	var pile = _pile("AAA")
	pile.bloquer()
	var couleur = pile.get_node("Fond").color
	pile.deselectionner()
	assert_eq(pile.get_node("Fond").color, couleur)

func test_bloquer_prend_la_couleur_de_selection_du_premier_jeton():
	var pile = _pile("AAA")
	pile.bloquer()
	assert_eq(pile.get_node("Fond").color, pile.liste_jetons[0].couleur_selection())

# --- Dimensions et position ---

func test_largeur_et_hauteur():
	var pile = _pile("AB ")
	assert_eq(pile.largeur(), 32 + 2 * pile.marge)
	assert_eq(pile.hauteur(), (32 + 2) * 3 + 2 * pile.marge)

func test_le_fond_prend_la_taille_de_la_pile():
	var pile = _pile("AB ")
	assert_eq(pile.get_node("Fond").size, Vector2(pile.largeur(), pile.hauteur()))

func test_choisir_position_place_les_jetons_de_bas_en_haut():
	var pile = _pile("ABC")
	pile.choisir_position(Vector2(100, 300))
	assert_eq(pile.position, Vector2(100, 300))
	assert_eq(pile.liste_jetons[0].position(), Vector2(100, 300))
	assert_eq(pile.liste_jetons[1].position(), Vector2(100, 266))
	assert_eq(pile.liste_jetons[2].position(), Vector2(100, 232))

func test_effacer_la_pile():
	var pile = _pile("AB ")
	pile.choisir_position(Vector2(10, 10))
	pile.effacer_la_pile()
	assert_eq(pile.liste_jetons.size(), 0)
	assert_eq(pile.position, Vector2(0, 720))
	assert_true(pile.est_vide())

# --- Signaux ---

func test_clic_sur_un_jeton_emet_clique_gauche_avec_la_reference_de_pile():
	var pile = _pile("AB ")
	pile.choisir_reference(3)
	watch_signals(pile)
	pile.liste_jetons[0].clique_gauche.emit(0)
	assert_signal_emitted_with_parameters(pile, "clique_gauche", [3])

func test_clic_sur_une_pile_terminee_n_emet_rien():
	var pile = _pile("AAA")
	watch_signals(pile)
	pile.liste_jetons[0].clique_gauche.emit(0)
	assert_signal_not_emitted(pile, "clique_gauche")

func test_clic_gauche_sur_le_fond_emet_clique_gauche():
	var pile = _pile("AB ")
	pile.choisir_reference(2)
	watch_signals(pile)
	pile._on_fond_gui_input(_evenement_souris(MOUSE_BUTTON_LEFT, true))
	assert_signal_emitted_with_parameters(pile, "clique_gauche", [2])

func test_autres_evenements_sur_le_fond_n_emettent_rien():
	var pile = _pile("AB ")
	watch_signals(pile)
	pile._on_fond_gui_input(_evenement_souris(MOUSE_BUTTON_RIGHT, true))
	pile._on_fond_gui_input(_evenement_souris(MOUSE_BUTTON_LEFT, false))
	pile._on_fond_gui_input(InputEventKey.new())
	assert_signal_not_emitted(pile, "clique_gauche")
