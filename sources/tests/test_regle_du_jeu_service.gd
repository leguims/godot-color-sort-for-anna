extends GutTest

const SCENE_PILE = preload("res://Scenes/MenuPrincipal/Campagne/GamePlay/Plateau/Pile/pile.tscn")
const RACINE_TEST = "tests/test_regle_du_jeu_service"

var regles: PlateauReglesDuJeuService
var decodeur := PlateauDecodeurService.new()
var sauvegarde_joueur_initiale: Dictionary
var fichier_sauvegarde_initial: String

func before_each():
	regles = PlateauReglesDuJeuService.new()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	SauvegardeBddJoueursService.fichier_sauvegarde = "joueur_regles.json"

func after_each():
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _plateau_en_cours() -> void:
	SauvegardeBddJoueursService._sauvegarde_joueur = {
		"nom": "Joueuse test",
		"campagne": {},
		"nombre_de_parties": {},
		"plateaux_libres": {},
		"enregistrement_campagne": [{
			"niveaux": [{
				"plateaux": [{
					"nom": "AAB.BBA.   ", "gameplay": "CLASSIQUE", "date_debut": 1.0,
					"date_fin": 0.0, "statut": "en cours", "score": {}, "coups joués": []
				}]
			}]
		}]
	}

func _piles(texte: String) -> Array:
	var piles := []
	for jetons in decodeur.decoder_plateau(texte):
		var pile: Pile = add_child_autofree(SCENE_PILE.instantiate())
		pile.ajouter_les_jetons(jetons)
		pile.choisir_reference(piles.size())
		piles.append(pile)
	return piles

func _contenus(piles: Array) -> Array:
	var contenus := []
	for pile in piles:
		var contenu := []
		for jeton in pile.liste_jetons:
			contenu.append(jeton.indice_jeton)
		contenus.append(contenu)
	return contenus

# --- pile_de_depart_de_tansfert_valide ---

func test_depart_valide_pile_non_vide_non_terminee():
	assert_true(regles.pile_de_depart_de_tansfert_valide(_piles("AB ")[0]))
	assert_true(regles.pile_de_depart_de_tansfert_valide(_piles("ABA")[0]))

func test_depart_invalide_pile_vide():
	assert_false(regles.pile_de_depart_de_tansfert_valide(_piles("   ")[0]))

func test_depart_invalide_pile_terminee():
	assert_false(regles.pile_de_depart_de_tansfert_valide(_piles("AAA")[0]))

# --- est_valide_le_tansfert_de_pile ---

func test_transfert_vers_la_meme_pile_invalide():
	var piles = _piles("AB .   ")
	assert_false(regles.est_valide_le_tansfert_de_pile(piles, 0, 0))

func test_transfert_vers_pile_pleine_invalide():
	var piles = _piles("AB .BA")
	assert_false(regles.est_valide_le_tansfert_de_pile(piles, 0, 1))

func test_transfert_vers_pile_vide_valide():
	var piles = _piles("AB .   ")
	assert_true(regles.est_valide_le_tansfert_de_pile(piles, 0, 1))

func test_transfert_vers_meme_couleur_valide():
	var piles = _piles("AB .CB ")
	assert_true(regles.est_valide_le_tansfert_de_pile(piles, 0, 1))

func test_transfert_vers_couleur_differente_invalide():
	var piles = _piles("AB .CA ")
	assert_false(regles.est_valide_le_tansfert_de_pile(piles, 0, 1))

func test_transfert_de_plusieurs_jetons_exige_assez_de_place():
	var piles = _piles("ABB.B  .D  ")
	assert_true(regles.est_valide_le_tansfert_de_pile(piles, 0, 1))
	piles = _piles("ABB.CB .D  ")
	assert_false(regles.est_valide_le_tansfert_de_pile(piles, 0, 1))

func test_transfert_de_plusieurs_jetons_exactement_la_place_disponible():
	var piles = _piles("ABB.B  .C  ")
	assert_true(regles.est_valide_le_tansfert_de_pile(piles, 0, 1))

# --- realiser_le_tansfert_de_pile ---

func test_realiser_deplace_un_jeton_vers_une_pile_vide():
	var piles = _piles("AB .   ")
	assert_true(regles.realiser_le_tansfert_de_pile(piles, 0, 1))
	assert_eq(_contenus(piles), [[0, 32, 32], [1, 32, 32]])

func test_realiser_deplace_tous_les_jetons_identiques_du_sommet():
	var piles = _piles("ABB.   ")
	assert_true(regles.realiser_le_tansfert_de_pile(piles, 0, 1))
	assert_eq(_contenus(piles), [[0, 32, 32], [1, 1, 32]])

func test_realiser_empile_sur_la_meme_couleur():
	var piles = _piles("AB .CB ")
	assert_true(regles.realiser_le_tansfert_de_pile(piles, 0, 1))
	assert_eq(_contenus(piles), [[0, 32, 32], [2, 1, 1]])

func test_realiser_termine_la_pile_d_arrivee_quand_elle_se_complete():
	var piles = _piles("AAB.BB ")
	assert_true(regles.realiser_le_tansfert_de_pile(piles, 0, 1))
	assert_true(piles[1].est_termine())
	assert_false(piles[0].est_termine())

func test_realiser_refuse_ne_modifie_rien():
	var piles = _piles("AB .CA ")
	var avant = _contenus(piles)
	assert_false(regles.realiser_le_tansfert_de_pile(piles, 0, 1))
	assert_eq(_contenus(piles), avant)

func test_realiser_vers_la_meme_pile_ne_modifie_rien():
	var piles = _piles("AB .   ")
	var avant = _contenus(piles)
	assert_false(regles.realiser_le_tansfert_de_pile(piles, 0, 0))
	assert_eq(_contenus(piles), avant)

func test_realiser_enregistre_le_coup_quand_un_plateau_est_en_cours():
	_plateau_en_cours()
	var piles = _piles("AB .   ")
	assert_true(regles.realiser_le_tansfert_de_pile(piles, 0, 1))
	assert_eq(SauvegardeBddJoueursService.enregistrement_campagne_lire_nombre_coups(), 1)
	assert_eq(SauvegardeBddJoueursService.enregistrement_campagne_coups_joues()[0], {"depart": 0, "arrivee": 1})

func test_realiser_n_enregistre_pas_un_coup_refuse():
	_plateau_en_cours()
	var piles = _piles("AB .CA ")
	regles.realiser_le_tansfert_de_pile(piles, 0, 1)
	assert_eq(SauvegardeBddJoueursService.enregistrement_campagne_lire_nombre_coups(), 0)

# --- est_bloque ---

func test_non_bloque_avec_une_pile_vide_disponible():
	assert_false(regles.est_bloque(_piles("AAB.BBA.   ")))

func test_bloque_quand_toutes_les_piles_sont_pleines_et_en_desordre():
	assert_true(regles.est_bloque(_piles("AB.BA")))

func test_bloque_quand_toutes_les_piles_sont_terminees():
	assert_true(regles.est_bloque(_piles("AA.BB")))

func test_bloque_malgre_de_la_place_si_les_couleurs_ne_correspondent_pas():
	assert_true(regles.est_bloque(_piles("A .B ")))

func test_non_bloque_si_une_couleur_peut_etre_empilee():
	assert_false(regles.est_bloque(_piles("AB.B ")))

func test_bloque_sans_pile():
	assert_true(regles.est_bloque([]))
