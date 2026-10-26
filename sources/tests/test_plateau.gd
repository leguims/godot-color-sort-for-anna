extends GutTest

const SCENE_PLATEAU = preload("res://Scenes/MenuPrincipal/Campagne/GamePlay/Plateau/plateau.tscn")
const RACINE_TEST = "tests/test_plateau"

var plateau: Plateau
var nombre_appels_gameplay: Array
var gameplay_termine: bool
var sauvegarde_joueur_initiale: Dictionary
var fichier_sauvegarde_initial: String

func before_each():
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	SauvegardeBddJoueursService.fichier_sauvegarde = "joueur_plateau.json"
	_definir_sauvegarde([])

	nombre_appels_gameplay = [0]
	gameplay_termine = false
	plateau = add_child_autofree(SCENE_PLATEAU.instantiate())
	plateau.enregistrer_callback_est_termine(func(_piles) -> bool:
		nombre_appels_gameplay[0] += 1
		return gameplay_termine)

func after_each():
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	FichiersJsonService.effacer_racine_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func _definir_sauvegarde(enregistrement_campagne: Array) -> void:
	SauvegardeBddJoueursService._sauvegarde_joueur = {
		"nom": "Joueuse test",
		"campagne": {},
		"nombre_de_parties": {},
		"plateaux_libres": {},
		"enregistrement_campagne": enregistrement_campagne
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

func _contenus() -> Array:
	var contenus := []
	for pile in plateau.liste_piles:
		var contenu := []
		for jeton in pile.liste_jetons:
			contenu.append(jeton.indice_jeton)
		contenus.append(contenu)
	return contenus

func _evenement_souris(bouton: int, appuye: bool) -> InputEventMouseButton:
	var evenement = InputEventMouseButton.new()
	evenement.button_index = bouton
	evenement.pressed = appuye
	return evenement

# --- Validation ---

func test_est_valide_delegue_au_decodeur():
	assert_true(plateau.est_valide("AAB.BBA.   "))
	assert_false(plateau.est_valide(""))
	assert_false(plateau.est_valide("A B.BAA"))

# --- Creation du plateau ---

func test_commencer_un_nouveau_plateau_cree_les_piles():
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	assert_eq(plateau.liste_piles.size(), 3)
	assert_eq(_contenus(), [[0, 0, 1], [1, 1, 0], [32, 32, 32]])

func test_les_piles_ont_leur_indice_comme_reference():
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	for i in range(3):
		assert_eq(plateau.liste_piles[i].obtenir_reference(), i)

func test_les_piles_sont_enfants_du_plateau():
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	for pile in plateau.liste_piles:
		assert_eq(pile.get_parent(), plateau)

func test_les_piles_sont_alignees_sur_une_ligne_et_ordonnees():
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	var piles = plateau.liste_piles
	assert_eq(piles[0].position.y, piles[1].position.y)
	assert_eq(piles[1].position.y, piles[2].position.y)
	assert_lt(piles[0].position.x, piles[1].position.x)
	assert_lt(piles[1].position.x, piles[2].position.x)

func test_plateau_invalide_emet_le_signal_et_ne_cree_rien():
	watch_signals(plateau)
	plateau.commencer_un_nouveau_plateau("A B.BAA")
	assert_signal_emitted(plateau, "plateau_invalide")
	assert_eq(plateau.liste_piles.size(), 0)

func test_plateau_vide_emet_plateau_invalide():
	watch_signals(plateau)
	plateau.commencer_un_nouveau_plateau("")
	assert_signal_emit_count(plateau, "plateau_invalide", 1)

func test_plateau_valide_n_emet_pas_plateau_invalide():
	watch_signals(plateau)
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	assert_signal_not_emitted(plateau, "plateau_invalide")

func test_nouveau_plateau_remplace_l_ancien():
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	var anciennes_piles = plateau.liste_piles.duplicate()
	plateau.commencer_un_nouveau_plateau("AA.BB.  ")
	await get_tree().process_frame
	assert_eq(plateau.liste_piles.size(), 3)
	for pile in anciennes_piles:
		assert_false(is_instance_valid(pile))

func test_plateau_invalide_apres_un_plateau_valide_efface_les_piles():
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.commencer_un_nouveau_plateau("")
	assert_eq(plateau.liste_piles.size(), 0)

func test_hide_efface_le_plateau():
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.hide()
	assert_eq(plateau.liste_piles.size(), 0)

# --- Blocage ---

func test_est_bloque_plateau_initial_non_bloque():
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	assert_false(plateau.est_bloque())

func test_est_bloque_plateau_sans_mouvement():
	plateau.commencer_un_nouveau_plateau("AB.BA")
	assert_true(plateau.est_bloque())

# --- Clics ---

func test_clic_ignore_sans_partie_en_cours():
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.on_pile_clique_gauche(0)
	assert_eq(plateau.sauvegarde_indice_pile_depart, -1)
	assert_eq(nombre_appels_gameplay[0], 0)

func test_premier_clic_selectionne_la_pile_de_depart():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.on_pile_clique_gauche(0)
	assert_eq(plateau.sauvegarde_indice_pile_depart, 0)
	assert_true(plateau.liste_piles[0].liste_jetons[2].get_node("Selection").visible)
	assert_false(plateau.liste_piles[0].liste_jetons[1].get_node("Selection").visible)

func test_premier_clic_marque_les_destinations_valides():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.on_pile_clique_gauche(0)
	assert_eq(plateau.liste_piles[2].get_node("Fond").color, plateau.liste_piles[2].couleur_de_deplacement_valide)
	assert_ne(plateau.liste_piles[1].get_node("Fond").color, plateau.liste_piles[1].couleur_de_deplacement_valide)

func test_premier_clic_demarre_le_minuteur_de_selection():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.on_pile_clique_gauche(0)
	assert_false(plateau.get_node("SelectionPile").is_stopped())

func test_deuxieme_clic_realise_le_deplacement_et_deselectionne():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.on_pile_clique_gauche(0)
	plateau.on_pile_clique_gauche(2)
	assert_eq(_contenus(), [[0, 0, 32], [1, 1, 0], [1, 32, 32]])
	assert_eq(plateau.sauvegarde_indice_pile_depart, -1)
	assert_true(plateau.get_node("SelectionPile").is_stopped())
	assert_eq(plateau.liste_piles[0].get_node("Fond").color, plateau.liste_piles[0].couleur_de_deselection)
	assert_false(plateau.liste_piles[0].liste_jetons[1].get_node("Selection").visible)

func test_deplacement_enregistre_le_coup():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.on_pile_clique_gauche(0)
	plateau.on_pile_clique_gauche(2)
	assert_eq(SauvegardeBddJoueursService.enregistrement_campagne_coups_joues(), [{"depart": 0, "arrivee": 2}])

func test_deplacement_refuse_deselectionne_sans_modifier_les_piles():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	var avant = _contenus()
	plateau.on_pile_clique_gauche(0)
	plateau.on_pile_clique_gauche(1)
	assert_eq(_contenus(), avant)
	assert_eq(plateau.sauvegarde_indice_pile_depart, -1)
	assert_eq(SauvegardeBddJoueursService.enregistrement_campagne_lire_nombre_coups(), 0)

func test_clic_sur_la_meme_pile_annule_la_selection():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	var avant = _contenus()
	plateau.on_pile_clique_gauche(0)
	plateau.on_pile_clique_gauche(0)
	assert_eq(_contenus(), avant)
	assert_eq(plateau.sauvegarde_indice_pile_depart, -1)

func test_pile_completee_par_un_deplacement_est_bloquee_en_couleur():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.on_pile_clique_gauche(0)
	plateau.on_pile_clique_gauche(2)
	plateau.on_pile_clique_gauche(1)
	plateau.on_pile_clique_gauche(0)
	var pile = plateau.liste_piles[0]
	assert_true(pile.est_termine())
	assert_eq(pile.get_node("Fond").color, pile.liste_jetons[0].couleur_selection())

func test_le_gameplay_est_interroge_apres_chaque_clic():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.on_pile_clique_gauche(0)
	assert_eq(nombre_appels_gameplay[0], 1)
	plateau.on_pile_clique_gauche(2)
	assert_eq(nombre_appels_gameplay[0], 2)

func test_le_gameplay_recoit_la_liste_des_piles():
	_demarrer_une_partie()
	var recu := []
	plateau.enregistrer_callback_est_termine(func(piles) -> bool:
		recu.append(piles)
		return false)
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.on_pile_clique_gauche(0)
	assert_eq(recu.size(), 1)
	assert_eq(recu[0], plateau.liste_piles)

func test_clic_sur_pile_vide_sans_selection_ne_deplace_rien():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("   .AAB.BBA")
	var avant = _contenus()
	plateau.on_pile_clique_gauche(0)
	assert_eq(_contenus(), avant, "un clic sur une pile vide ne doit rien deplacer")
	assert_eq(SauvegardeBddJoueursService.enregistrement_campagne_lire_nombre_coups(), 0)

func test_clic_via_un_jeton_de_la_pile_declenche_la_selection():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.liste_piles[1].liste_jetons[0].clique_gauche.emit(0)
	assert_eq(plateau.sauvegarde_indice_pile_depart, 1)

func test_clic_sur_une_pile_terminee_est_ignore():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAA.BBB.   ")
	plateau.liste_piles[0].liste_jetons[0].clique_gauche.emit(0)
	assert_eq(plateau.sauvegarde_indice_pile_depart, -1)

# --- Annulation de la selection ---

func test_timeout_de_selection_annule_la_selection():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.on_pile_clique_gauche(0)
	plateau.get_node("SelectionPile").timeout.emit()
	assert_eq(plateau.sauvegarde_indice_pile_depart, -1)
	assert_false(plateau.liste_piles[0].liste_jetons[2].get_node("Selection").visible)
	assert_eq(plateau.liste_piles[2].get_node("Fond").color, plateau.liste_piles[2].couleur_de_deselection)

func test_timeout_sans_pile_ne_fait_rien():
	plateau._on_selection_pile_timeout()
	assert_eq(plateau.sauvegarde_indice_pile_depart, -1)

func test_deselection_demandee_par_le_menu_annule_la_selection_si_partie_en_cours():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.on_pile_clique_gauche(0)
	plateau._on_menu_plateau_deselection_pile()
	assert_eq(plateau.sauvegarde_indice_pile_depart, -1)

func test_deselection_demandee_par_le_menu_ignoree_sans_partie_en_cours():
	_demarrer_une_partie()
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	plateau.on_pile_clique_gauche(0)
	_definir_sauvegarde([])
	plateau._on_menu_plateau_deselection_pile()
	assert_eq(plateau.sauvegarde_indice_pile_depart, 0)

# --- Positionnement ---

func test_enregistrer_bouton_recommencer_size_y_decale_les_piles():
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	var y_sans_bouton = plateau.liste_piles[0].position.y
	plateau.enregistrer_bouton_recommencer_size_y(100.)
	plateau.commencer_un_nouveau_plateau("AAB.BBA.   ")
	assert_gt(plateau.liste_piles[0].position.y, y_sans_bouton)
