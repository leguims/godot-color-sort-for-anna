extends GutTest

const SCENE_CLASSIQUE = preload("res://Scenes/MenuPrincipal/Campagne/GamePlay/Classique/classique.tscn")
const RACINE_TEST = "tests/test_classique"

var sauvegarde_joueur_initiale: Dictionary
var fichier_sauvegarde_initial: String
var configuration_initiale: Dictionary
var gameplay: Classique

func before_each():
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)

	_definir_sauvegarde([])
	SauvegardeBddJoueursService.fichier_sauvegarde = "joueuse_classique.json"
	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	gameplay = add_child_autofree(SCENE_CLASSIQUE.instantiate())

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
			"niveau_1": [{"nom": "AAA.BBB.CCC", "gameplay": "CLASSIQUE", "difficulte": 1}]
		},
		"nombre_de_parties": {},
		"enregistrement_campagne": enregistrement_campagne,
		"plateaux_libres": {}
	}

func _demarrer_une_partie() -> void:
	_definir_sauvegarde([{
		"niveaux": [{
			"plateaux": [{
				"nom": "", "gameplay": "CLASSIQUE", "date_debut": 1.0,
				"date_fin": 0.0, "statut": "en cours", "score": {}, "coups joués": []
			}]
		}]
	}])

func _plateau() -> Plateau:
	return gameplay.get_node("Plateau")

# --- Initialisation ---

func test_le_gameplay_enregistre_sa_callback_aupres_du_plateau():
	assert_true(_plateau().gameplay_est_termine.is_valid())
	assert_eq(_plateau().gameplay_est_termine.get_object(), gameplay)

func test_est_valide_delegue_au_plateau():
	assert_true(gameplay.est_valide("AAB.BBA.   "))
	assert_false(gameplay.est_valide(""))
	assert_false(gameplay.est_valide("A B.BAA"))

func test_commencer_un_nouveau_plateau_cree_les_piles():
	gameplay.commencer_un_nouveau_plateau("AAB.BBA.   ")
	assert_eq(_plateau().liste_piles.size(), 3)
	assert_true(gameplay.get_node("MenuPlateau/BandeauEnJeu").visible)
	assert_false(gameplay.get_node("MenuPlateau/BandeauMenu").visible)

func test_hide_efface_les_piles_du_plateau():
	gameplay.commencer_un_nouveau_plateau("AAB.BBA.   ")
	gameplay.hide()
	assert_eq(_plateau().liste_piles.size(), 0)

func test_commencer_un_nouveau_gameplay_affiche_le_menu():
	gameplay.commencer_un_nouveau_plateau("AAB.BBA.   ")
	gameplay.commencer_un_nouveau_gameplay()
	assert_true(gameplay.get_node("MenuPlateau/BandeauMenu").visible)
	assert_false(gameplay.get_node("MenuPlateau/BandeauEnJeu").visible)

# --- Relais de signaux ---

func test_plateau_invalide_est_relaye():
	watch_signals(gameplay)
	gameplay.commencer_un_nouveau_plateau("A B.BAA")
	assert_signal_emit_count(gameplay, "plateau_invalide", 1)

func test_plateau_valide_n_emet_pas_plateau_invalide():
	watch_signals(gameplay)
	gameplay.commencer_un_nouveau_plateau("AAB.BBA.   ")
	assert_signal_not_emitted(gameplay, "plateau_invalide")

func test_abandon_du_menu_est_relaye():
	watch_signals(gameplay)
	gameplay.get_node("MenuPlateau").abandon.emit()
	assert_signal_emit_count(gameplay, "abandon", 1)

func test_passe_du_menu_est_relaye():
	watch_signals(gameplay)
	gameplay.get_node("MenuPlateau").passe.emit()
	assert_signal_emit_count(gameplay, "passe", 1)

func test_commencer_plateau_du_menu_est_relaye():
	watch_signals(gameplay)
	gameplay.get_node("MenuPlateau").commencer_plateau.emit()
	assert_signal_emit_count(gameplay, "commencer_plateau", 1)

# --- Condition de victoire ---

func test_est_termine_faux_quand_une_pile_est_en_desordre():
	gameplay.commencer_un_nouveau_plateau("AAB.BBA.   ")
	watch_signals(gameplay)
	assert_false(gameplay.est_termine(_plateau().liste_piles))
	assert_signal_not_emitted(gameplay, "victoire")

func test_est_termine_vrai_quand_toutes_les_piles_non_vides_sont_terminees():
	gameplay.commencer_un_nouveau_plateau("AAA.BBB.   ")
	watch_signals(gameplay)
	assert_true(gameplay.est_termine(_plateau().liste_piles))
	assert_signal_emit_count(gameplay, "victoire", 1)

func test_est_termine_faux_si_une_pile_est_homogene_mais_incomplete():
	gameplay.commencer_un_nouveau_plateau("AAA.BBB.   ")
	_plateau().liste_piles[0].retirer_le_dernier_jeton()
	assert_false(gameplay.est_termine(_plateau().liste_piles))

func test_est_termine_ignore_les_piles_vides():
	gameplay.commencer_un_nouveau_plateau("AAA.   .BBB")
	assert_true(gameplay.est_termine(_plateau().liste_piles))

func test_est_termine_sans_pile_est_vrai():
	watch_signals(gameplay)
	assert_true(gameplay.est_termine([]))
	assert_signal_emit_count(gameplay, "victoire", 1)

func test_victoire_en_jouant_une_partie_complete():
	_demarrer_une_partie()
	gameplay.commencer_un_nouveau_plateau("AAB.BBA.   ")
	watch_signals(gameplay)
	_plateau().on_pile_clique_gauche(0)
	_plateau().on_pile_clique_gauche(2)
	_plateau().on_pile_clique_gauche(1)
	_plateau().on_pile_clique_gauche(0)
	assert_signal_not_emitted(gameplay, "victoire")
	_plateau().on_pile_clique_gauche(2)
	_plateau().on_pile_clique_gauche(1)
	assert_signal_emit_count(gameplay, "victoire", 1)
	assert_eq(SauvegardeBddJoueursService.enregistrement_campagne_lire_nombre_coups(), 3)

# --- Classe de base ---

func test_la_classe_de_base_n_est_jamais_terminee():
	var base: BaseClassiqueQuiPerdGagne = autofree(BaseClassiqueQuiPerdGagne.new())
	assert_false(base.est_termine([]))

# --- GameplayTypes ---

func test_gameplay_to_enum_toutes_les_valeurs():
	var attendu := {
		"CLASSIQUE": GameplayTypes.Gameplay.CLASSIQUE,
		"AU_PLUS_PRES": GameplayTypes.Gameplay.AU_PLUS_PRES,
		"PILE_POIL": GameplayTypes.Gameplay.PILE_POIL,
		"TOUT_EN_TETE": GameplayTypes.Gameplay.TOUT_EN_TETE,
		"PROGRAMMATION": GameplayTypes.Gameplay.PROGRAMMATION,
		"PROGRAMMATION_GENIUS": GameplayTypes.Gameplay.PROGRAMMATION_GENIUS,
		"QUI_PERD_GAGNE": GameplayTypes.Gameplay.QUI_PERD_GAGNE,
		"POIDS_PLUME": GameplayTypes.Gameplay.POIDS_PLUME,
		"PILE_OU_FACE": GameplayTypes.Gameplay.PILE_OU_FACE,
		"MOT_CACHE": GameplayTypes.Gameplay.MOT_CACHE
	}
	for nom in attendu:
		assert_eq(GameplayTypes.gameplay_to_enum(nom), attendu[nom], nom)

func test_gameplay_to_enum_valeurs_enum_distinctes():
	var valeurs := {}
	for nom in GameplayTypes.Gameplay.keys():
		valeurs[GameplayTypes.gameplay_to_enum(nom)] = true
	assert_eq(valeurs.size(), GameplayTypes.Gameplay.size())

func test_gameplay_to_enum_inconnu_retourne_classique():
	assert_eq(GameplayTypes.gameplay_to_enum("INCONNU"), GameplayTypes.Gameplay.CLASSIQUE)
	assert_eq(GameplayTypes.gameplay_to_enum(""), GameplayTypes.Gameplay.CLASSIQUE)

func test_gameplay_to_enum_est_sensible_a_la_casse():
	assert_eq(GameplayTypes.gameplay_to_enum("qui_perd_gagne"), GameplayTypes.Gameplay.CLASSIQUE)
