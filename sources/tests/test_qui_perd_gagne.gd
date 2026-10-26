extends GutTest

const SCENE_QUI_PERD_GAGNE = preload("res://Scenes/MenuPrincipal/Campagne/GamePlay/QuiPerdGagne/qui_perd_gagne.tscn")
const RACINE_TEST = "tests/test_qui_perd_gagne"

var sauvegarde_joueur_initiale: Dictionary
var fichier_sauvegarde_initial: String
var configuration_initiale: Dictionary
var gameplay: QuiPerdGagne

func before_each():
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)

	_definir_sauvegarde([])
	SauvegardeBddJoueursService.fichier_sauvegarde = "joueuse_qpg.json"
	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	gameplay = add_child_autofree(SCENE_QUI_PERD_GAGNE.instantiate())

func after_each():
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _definir_sauvegarde(enregistrement_campagne: Array) -> void:
	SauvegardeBddJoueursService._sauvegarde_joueur = {
		"nom": "Joueuse test",
		"campagne": {
			"niveau_1": [{"nom": "AAA.BBB.CCC", "gameplay": "QUI_PERD_GAGNE", "difficulte": 1}]
		},
		"nombre_de_parties": {},
		"enregistrement_campagne": enregistrement_campagne,
		"plateaux_libres": {}
	}

func _demarrer_une_partie() -> void:
	_definir_sauvegarde([{
		"niveaux": [{
			"plateaux": [{
				"nom": "", "gameplay": "QUI_PERD_GAGNE", "date_debut": 1.0,
				"date_fin": 0.0, "statut": "en cours", "score": {}, "coups joués": []
			}]
		}]
	}])

func _plateau() -> Plateau:
	return gameplay.get_node("Plateau")

func _diablotin() -> Control:
	return gameplay.get_node("Diablotin")

# --- Initialisation ---

func test_etat_initial_du_diablotin():
	assert_false(gameplay.diablotin_actif)
	assert_false(_diablotin().visible)

func test_le_gameplay_enregistre_sa_callback_aupres_du_plateau():
	assert_eq(_plateau().gameplay_est_termine.get_object(), gameplay)

func test_est_valide_delegue_au_plateau():
	assert_true(gameplay.est_valide("AAB.BBA.   "))
	assert_false(gameplay.est_valide(""))

# --- Diablotin ---

func test_commencer_un_plateau_active_le_diablotin():
	gameplay.commencer_un_nouveau_plateau("AAB.BBA.   ")
	assert_true(gameplay.diablotin_actif)
	assert_true(_diablotin().visible)
	assert_eq(_plateau().liste_piles.size(), 3)

func test_reset_diablotin_remet_les_valeurs_initiales():
	gameplay.vitesse_diablotin = 5.
	gameplay.rotation_diablotin = 30.
	gameplay.approche_diablotin = Vector2(3, 3)
	gameplay.position_diablotin = Vector2(500, 500)
	gameplay.reset_diablotin()
	assert_eq(gameplay.position_diablotin, Vector2(194, 19))
	assert_eq(gameplay.direction_diablotin, Vector2(0, 1))
	assert_eq(gameplay.vitesse_diablotin, 0.)
	assert_eq(gameplay.rotation_diablotin, 0.)
	assert_eq(gameplay.vitesse_rotation_diablotin, 0.)
	assert_eq(gameplay.approche_diablotin, Vector2.ONE)
	assert_eq(gameplay.vitesse_approche_diablotin, 0.)
	assert_eq(_diablotin().position, Vector2(194, 19))
	assert_eq(_diablotin().scale, Vector2.ONE)

func test_desactiver_diablotin():
	gameplay.activer_diablotin()
	gameplay.desactiver_diablotin()
	assert_false(gameplay.diablotin_actif)
	assert_false(_diablotin().visible)

func test_bouger_diablotin_met_a_jour_la_position_du_noeud():
	gameplay.activer_diablotin()
	gameplay.bouger_diablotin(0.016)
	assert_eq(_diablotin().position, gameplay.position_diablotin)
	assert_eq(_diablotin().scale, gameplay.approche_diablotin)

func test_show_fond_masque_le_diablotin():
	gameplay.activer_diablotin()
	gameplay.show_fond()
	assert_false(_diablotin().visible)

func test_signaux_de_fin_desactivent_le_diablotin():
	for nom_signal in ["abandon", "passe", "plateau_invalide", "victoire"]:
		gameplay.activer_diablotin()
		gameplay.emit_signal(nom_signal)
		assert_false(gameplay.diablotin_actif, nom_signal)
		assert_false(_diablotin().visible, nom_signal)

func test_plateau_invalide_est_relaye_et_desactive_le_diablotin():
	watch_signals(gameplay)
	gameplay.commencer_un_nouveau_plateau("A B.BAA")
	assert_signal_emit_count(gameplay, "plateau_invalide", 1)

func test_abandon_du_menu_est_relaye():
	watch_signals(gameplay)
	gameplay.get_node("MenuPlateau").abandon.emit()
	assert_signal_emit_count(gameplay, "abandon", 1)
	assert_false(gameplay.diablotin_actif)

func test_passe_du_menu_est_relaye():
	watch_signals(gameplay)
	gameplay.get_node("MenuPlateau").passe.emit()
	assert_signal_emit_count(gameplay, "passe", 1)

# --- Condition de victoire : plateau bloque ET une pile en desordre ---

func test_non_termine_si_un_mouvement_reste_possible():
	gameplay.commencer_un_nouveau_plateau("AAB.BBA.   ")
	watch_signals(gameplay)
	assert_false(gameplay.est_termine(_plateau().liste_piles))
	assert_signal_not_emitted(gameplay, "victoire")

func test_termine_quand_bloque_avec_une_pile_en_desordre():
	gameplay.commencer_un_nouveau_plateau("AB.BA")
	watch_signals(gameplay)
	assert_true(gameplay.est_termine(_plateau().liste_piles))
	assert_signal_emit_count(gameplay, "victoire", 1)

func test_termine_quand_bloque_malgre_de_la_place_libre():
	var piles := []
	var decodeur := PlateauDecodeurService.new()
	for jetons in decodeur.decoder_plateau("A .B "):
		var pile: Pile = add_child_autofree(load("res://Scenes/MenuPrincipal/Campagne/GamePlay/Plateau/Pile/pile.tscn").instantiate())
		pile.ajouter_les_jetons(jetons)
		pile.choisir_reference(piles.size())
		piles.append(pile)
	_plateau().liste_piles = piles
	assert_true(gameplay.est_termine(piles))

func test_non_termine_quand_toutes_les_piles_sont_terminees_sans_etre_en_desordre():
	gameplay.commencer_un_nouveau_plateau("AA.BB")
	watch_signals(gameplay)
	assert_false(gameplay.est_termine(_plateau().liste_piles))
	assert_signal_not_emitted(gameplay, "victoire")

func test_victoire_en_bloquant_le_plateau_par_les_clics():
	_demarrer_une_partie()
	gameplay.commencer_un_nouveau_plateau("AB.BA")
	watch_signals(gameplay)
	_plateau().on_pile_clique_gauche(0)
	assert_signal_emit_count(gameplay, "victoire", 1)
	assert_false(gameplay.diablotin_actif)
