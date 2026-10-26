extends GutTest

var service
var configuration_initiale: Dictionary

func before_each():
	configuration_initiale = SauvegardeConfigurationService.configuration_du_jeu.duplicate(true)
	service = partial_double(load("res://Singletons/vibration_service.gd")).new()
	add_child_autofree(service)

func after_each():
	SauvegardeConfigurationService.configuration_du_jeu = configuration_initiale

func test_constantes_de_vibration():
	assert_eq(service.VIBRATION_PLATEAU, {"duration": 800, "amplitude": 1.0})
	assert_eq(service.VIBRATION_PILE, {"duration": 200, "amplitude": 0.5})
	assert_eq(service.VIBRATION_JETON, {"duration": 50, "amplitude": 0.20})
	assert_eq(service.VIBRATION_ECHEC, {"duration": 50, "amplitude": 0.20})
	assert_eq(service.VIBRATION_CLICK, {"duration": 50, "amplitude": 0.20})

func test_vibration_active_ne_plante_pas_sans_peripherique():
	SauvegardeConfigurationService.configuration_du_jeu["vibrations"] = true
	service._vibration(service.VIBRATION_PLATEAU)
	service._vibration(service.VIBRATION_PILE)
	service._vibration(service.VIBRATION_JETON)
	assert_true(true)

func test_vibration_desactivee_ne_plante_pas():
	SauvegardeConfigurationService.configuration_du_jeu["vibrations"] = false
	service._vibration(service.VIBRATION_PLATEAU)
	assert_true(true)

func test_vibration_sans_cle_de_configuration_est_active_par_defaut():
	SauvegardeConfigurationService.configuration_du_jeu.erase("vibrations")
	assert_true(SauvegardeConfigurationService.vibrations_sont_actives())
	service._vibration(service.VIBRATION_JETON)
	assert_true(true)

func test_vibration_valeurs_limites_ne_plantent_pas():
	SauvegardeConfigurationService.configuration_du_jeu["vibrations"] = true
	service._vibration({"duration": 0, "amplitude": 0.0})
	service._vibration({"duration": 1, "amplitude": 1.0})
	assert_true(true)

func test_vibration_fin_de_plateau_utilise_la_constante_plateau():
	service.vibration_fin_de_plateau()
	assert_called(service, "_vibration", [service.VIBRATION_PLATEAU])

func test_vibration_fin_de_pile_utilise_la_constante_pile():
	service.vibration_fin_de_pile()
	assert_called(service, "_vibration", [service.VIBRATION_PILE])

func test_vibration_de_jeton_utilise_la_constante_jeton():
	service.vibration_de_jeton()
	assert_called(service, "_vibration", [service.VIBRATION_JETON])

func test_vibration_echec_utilise_la_constante_echec():
	service.vibration_echec()
	assert_called(service, "_vibration", [service.VIBRATION_ECHEC])

func test_vibration_click_utilise_la_constante_click():
	service.vibration_click()
	assert_called(service, "_vibration", [service.VIBRATION_CLICK])

func test_chaque_vibration_n_appelle_qu_une_fois_vibration():
	service.vibration_fin_de_pile()
	assert_call_count(service, "_vibration", 1)

func test_vibrations_desactivees_toutes_les_fonctions_publiques_sans_crash():
	SauvegardeConfigurationService.configuration_du_jeu["vibrations"] = false
	service.vibration_fin_de_plateau()
	service.vibration_fin_de_pile()
	service.vibration_de_jeton()
	service.vibration_echec()
	service.vibration_click()
	assert_call_count(service, "_vibration", 5)