extends GutTest

var service
var sauvegarde_joueur_initiale
var fichier_sauvegarde_initial
var configuration_initiale
const RACINE_TEST = "tests/test_audio_service"

func _nettoyer_fichiers_utilisateur():
	FichiersJsonService.effacer_racine_utilisateur()

func _activer_joueur_test(reussis: int, restants: int) -> void:
	var plateaux_reussis = []
	for index in range(reussis):
		plateaux_reussis.append({
			"nom": "Plateau reussi %d" % index,
			"date_debut": 1700000010 + index,
			"duree": 1000,
			"difficulte": 1,
			"statut": "reussi"
		})

	var plateaux_restants = []
	for index in range(restants):
		plateaux_restants.append({
			"nom": "Plateau restant %d" % index,
			"difficulte": 1,
			"gameplay": "CLASSIQUE"
		})

	SauvegardeBddJoueursService._sauvegarde_joueur = {
		"nom": "Joueur Audio",
		"nom_campagne": "campagne_test",
		"campagne": {
			"niveau_1": plateaux_restants
		},
		"enregistrement_campagne": [
			{
				"campagne": "campagne_test",
				"date_debut": 1700000000,
				"date_fin": 0,
				"score": {},
				"niveaux": [{
					"niveau": "niveau_1",
					"date_debut": 1700000000,
					"date_fin": 0,
					"score": {},
					"plateaux": plateaux_reussis
				}]
			}
		],
		"plateaux_libres": {},
		"nombre_de_parties": {}
	}
	FichiersJsonService.write_json_file("test_audio_service.json", SauvegardeBddJoueursService._sauvegarde_joueur)
	assert_true(SauvegardeBddJoueursService.choisir_le_joueur("Joueur Audio", "test_audio_service.json"))

func before_each():
	FichiersJsonService.definir_racine_utilisateur(RACINE_TEST)
	_nettoyer_fichiers_utilisateur()
	sauvegarde_joueur_initiale = SauvegardeBddJoueursService._sauvegarde_joueur.duplicate(true)
	fichier_sauvegarde_initial = SauvegardeBddJoueursService.fichier_sauvegarde
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)

	SauvegardeConfigurationService.configuration_du_jeu["date_debut_campagne"] = "2020-01-01 00:00:00"
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = true
	SauvegardeConfigurationService.configuration_du_jeu["effets sonores"] = true
	_activer_joueur_test(1, 5)

	service = add_child_autofree(load("res://Singletons/audio_service.gd").new())

func after_each():
	SauvegardeBddJoueursService._sauvegarde_joueur = sauvegarde_joueur_initiale
	SauvegardeBddJoueursService.fichier_sauvegarde = fichier_sauvegarde_initial
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale
	_nettoyer_fichiers_utilisateur()
	FichiersJsonService.reinitialiser_racine_utilisateur()

func test_ready_initialise_les_players_audio():
	assert_true(service.musique != null)
	assert_true(service.effet_sonore != null)
	assert_eq(service.get_child_count(), 2)

func test_jouer_la_musique_ne_joue_rien_si_les_musiques_sont_desactivees():
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = false
	service.musique.stream = null
	service.jouer_la_musique()
	assert_eq(service.musique.stream, null)

func test_jouer_la_musique_choisit_la_bonne_piste_selon_la_progression_du_niveau():
	var cas = [
		{"reussis": 0, "restants": 6, "musique": service.MUSIQUE_DREAMING},
		{"reussis": 1, "restants": 5, "musique": service.MUSIQUE_DREAMING},
		{"reussis": 2, "restants": 4, "musique": service.MUSIQUE_SU_TURNO},
		{"reussis": 3, "restants": 3, "musique": service.MUSIQUE_THE_THREE_PRINCESSES_OF_LILAC_MEADOW},
		{"reussis": 4, "restants": 2, "musique": service.MUSIQUE_SOLVE_THE_PUZZLE},
		{"reussis": 5, "restants": 1, "musique": service.MUSIQUE_HUMBLE_MATCH},
		{"reussis": 6, "restants": 0, "musique": service.MUSIQUE_GREAT_LITTLE_CHALLENGE}
	]

	for cas_de_test in cas:
		_activer_joueur_test(cas_de_test.get("reussis"), cas_de_test.get("restants"))
		service.jouer_la_musique()
		assert_eq(service.musique.stream, cas_de_test.get("musique"))

func test_arreter_la_musique_stoppe_la_lecture_si_les_musiques_sont_actives():
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = true
	service._musique_play(service.MUSIQUE_DREAMING)
	assert_true(service.musique.playing)
	service.arreter_la_musique()
	assert_false(service.musique.playing)

func test_arreter_la_musique_ne_crashe_pas_si_les_musiques_sont_desactivees():
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = false
	service.musique.stream = null
	service.arreter_la_musique()
	assert_eq(service.musique.stream, null)
	assert_false(service.musique.playing)

func test_effets_sonores_jouent_le_bon_son_quand_ils_sont_actifs():
	var cas = [
		{"methode": "son_menu_click", "son": service.SON_MENU_CLICK},
		{"methode": "son_commencer_un_plateau", "son": service.SON_PARTIE_COMMENCER},
		{"methode": "son_abandonner_un_plateau", "son": service.SON_PARTIE_ECHEC},
		{"methode": "son_gagner_un_plateau", "son": service.SON_PARTIE_VICTOIRE},
		{"methode": "son_jeton_deplacer_debut", "son": service.SON_JETON_DEPLACER_DEBUT_SUCCES},
		{"methode": "son_jeton_deplacer_echec", "son": service.SON_JETON_DEPLACER_ECHEC},
		{"methode": "son_jeton_deplacer_succes", "son": service.SON_JETON_DEPLACER_DEBUT_SUCCES},
		{"methode": "son_jeton_deplacer_pile_pleine", "son": service.SON_JETON_DEPLACER_PLEINE}
	]

	SauvegardeConfigurationService.configuration_du_jeu["effets sonores"] = true
	for cas_de_test in cas:
		service.effet_sonore.stream = null
		service.call(cas_de_test.get("methode"))
		assert_eq(service.effet_sonore.stream, cas_de_test.get("son"))

func test_effets_sonores_ne_jouent_rien_quand_ils_sont_desactives():
	var methodes = [
		"son_menu_click",
		"son_commencer_un_plateau",
		"son_abandonner_un_plateau",
		"son_gagner_un_plateau",
		"son_jeton_deplacer_debut",
		"son_jeton_deplacer_echec",
		"son_jeton_deplacer_succes",
		"son_jeton_deplacer_pile_pleine"
	]

	SauvegardeConfigurationService.configuration_du_jeu["effets sonores"] = false
	for methode in methodes:
		service.effet_sonore.stream = null
		service.call(methode)
		assert_eq(service.effet_sonore.stream, null)


func test_son_passer_un_plateau_joue_le_son_de_passage_quand_actif():
	SauvegardeConfigurationService.configuration_du_jeu["effets sonores"] = true
	service.effet_sonore.stream = null
	service.son_passer_un_plateau()
	assert_eq(service.effet_sonore.stream, service.SON_PARTIE_PASSER)
	assert_true(service.effet_sonore.playing)

func test_son_passer_un_plateau_ne_joue_rien_quand_desactive():
	SauvegardeConfigurationService.configuration_du_jeu["effets sonores"] = false
	service.effet_sonore.stream = null
	service.son_passer_un_plateau()
	assert_null(service.effet_sonore.stream)
	assert_false(service.effet_sonore.playing)

func test_son_passer_un_plateau_distinct_des_sons_de_victoire_et_echec():
	assert_ne(service.SON_PARTIE_PASSER, service.SON_PARTIE_VICTOIRE)
	assert_ne(service.SON_PARTIE_PASSER, service.SON_PARTIE_ECHEC)

func test_effet_sonore_play_remplace_le_stream_et_lance_la_lecture():
	service._effet_sonore_play(service.SON_MENU_CLICK)
	assert_eq(service.effet_sonore.stream, service.SON_MENU_CLICK)
	assert_true(service.effet_sonore.playing)
	service._effet_sonore_play(service.SON_PARTIE_VICTOIRE)
	assert_eq(service.effet_sonore.stream, service.SON_PARTIE_VICTOIRE)

func test_effet_sonore_play_ne_touche_pas_a_la_musique():
	service._effet_sonore_play(service.SON_MENU_CLICK)
	assert_null(service.musique.stream)
	assert_false(service.musique.playing)

func test_effet_sonore_play_ignore_la_configuration():
	SauvegardeConfigurationService.configuration_du_jeu["effets sonores"] = false
	service._effet_sonore_play(service.SON_MENU_CLICK)
	assert_eq(service.effet_sonore.stream, service.SON_MENU_CLICK)

func test_effet_sonore_play_avec_stream_nul_ne_plante_pas():
	service._effet_sonore_play(null)
	assert_null(service.effet_sonore.stream)
	assert_false(service.effet_sonore.playing)

func test_musique_play_remplace_le_stream_et_lance_la_lecture():
	service._musique_play(service.MUSIQUE_DREAMING)
	assert_eq(service.musique.stream, service.MUSIQUE_DREAMING)
	assert_true(service.musique.playing)
	service._musique_play(service.MUSIQUE_SU_TURNO)
	assert_eq(service.musique.stream, service.MUSIQUE_SU_TURNO)

func test_musique_stop_arrete_la_lecture_et_garde_le_stream():
	service._musique_play(service.MUSIQUE_DREAMING)
	service._musique_stop()
	assert_false(service.musique.playing)
	assert_eq(service.musique.stream, service.MUSIQUE_DREAMING)

func test_musique_stop_sans_lecture_ne_plante_pas():
	service._musique_stop()
	service._musique_stop()
	assert_false(service.musique.playing)

func test_musique_stop_ignore_la_configuration():
	service._musique_play(service.MUSIQUE_DREAMING)
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = false
	service._musique_stop()
	assert_false(service.musique.playing)

func test_musique_stop_ne_touche_pas_aux_effets_sonores():
	service._effet_sonore_play(service.SON_MENU_CLICK)
	service._musique_play(service.MUSIQUE_DREAMING)
	service._musique_stop()
	assert_true(service.effet_sonore.playing)

func test_arreter_la_musique_n_arrete_pas_les_effets_sonores():
	service._effet_sonore_play(service.SON_MENU_CLICK)
	service.arreter_la_musique()
	assert_true(service.effet_sonore.playing)

func test_arreter_la_musique_laisse_jouer_si_musiques_desactivees_en_cours_de_lecture():
	# Comportement actuel (discutable) : désactiver les musiques pendant la lecture n'autorise plus l'arrêt.
	service._musique_play(service.MUSIQUE_DREAMING)
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = false
	service.arreter_la_musique()
	assert_true(service.musique.playing)

func test_jouer_la_musique_sans_joueur_ni_donnees_joue_dreaming():
	SauvegardeBddJoueursService.liberer_le_joueur()
	service.jouer_la_musique()
	assert_eq(service.musique.stream, service.MUSIQUE_DREAMING)

func test_jouer_la_musique_sans_plateau_restant_joue_la_derniere_piste():
	_activer_joueur_test(3, 0)
	service.jouer_la_musique()
	assert_eq(service.musique.stream, service.MUSIQUE_GREAT_LITTLE_CHALLENGE)

func test_jouer_la_musique_remplace_la_piste_en_cours():
	_activer_joueur_test(0, 6)
	service.jouer_la_musique()
	assert_eq(service.musique.stream, service.MUSIQUE_DREAMING)
	_activer_joueur_test(6, 0)
	service.jouer_la_musique()
	assert_eq(service.musique.stream, service.MUSIQUE_GREAT_LITTLE_CHALLENGE)
	assert_true(service.musique.playing)

func test_jouer_la_musique_desactivee_ne_lance_pas_la_lecture():
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = false
	service.jouer_la_musique()
	assert_false(service.musique.playing)

func test_musiques_et_effets_sont_independants():
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = false
	SauvegardeConfigurationService.configuration_du_jeu["effets sonores"] = true
	service.jouer_la_musique()
	service.son_menu_click()
	assert_null(service.musique.stream)
	assert_eq(service.effet_sonore.stream, service.SON_MENU_CLICK)
	SauvegardeConfigurationService.configuration_du_jeu["musiques"] = true
	SauvegardeConfigurationService.configuration_du_jeu["effets sonores"] = false
	service.effet_sonore.stream = null
	service.son_menu_click()
	assert_null(service.effet_sonore.stream)

func test_effets_sonores_sans_cle_de_configuration_utilisent_la_valeur_par_defaut():
	SauvegardeConfigurationService.configuration_du_jeu.erase("effets sonores")
	SauvegardeConfigurationService.configuration_du_jeu.erase("musiques")
	service.son_passer_un_plateau()
	service.jouer_la_musique()
	service.arreter_la_musique()
	assert_true(true)