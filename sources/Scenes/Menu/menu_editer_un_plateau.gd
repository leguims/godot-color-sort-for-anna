extends Menu

class_name MenuEditerUnPlateau

func afficher_accueil():
	# Initialisation du menu de l'éditeur
	$EditeurPlateau.hide()
	$EditeurPlateau/SaisieEditionPlateau.editable = true
	$EditeurPlateau/SaisieEditionPlateau.placeholder_text = 'AC .A  .BAC.BDB.CDD'

	_afficher_message("Editer un plateau!", false)
	# Attendre l'échéance d'une temporisation libre
	await get_tree().create_timer(1.0).timeout
	# En édition de plateau, le plateau vierge, visible et éditable
	$EditeurPlateau/SaisieEditionPlateau.clear()
	$EditeurPlateau.show()
	await get_tree().create_timer(1.0).timeout
	$BoutonMenuPrincipal.show()
	$InfosDuJoueur.hide()
	$BoutonCommencer.show()

func afficher_plateau_suivant():
	_afficher_message("Editer un nouveau plateau!", false)
	# En édition de plateau, le plateau vierge, visible et éditable
	$EditeurPlateau/SaisieEditionPlateau.clear()
	$EditeurPlateau.show()
	await get_tree().create_timer(1.0).timeout
	$BoutonMenuPrincipal.show()
	$BoutonCommencer.show()

func afficher_plateau_invalide():
	_afficher_message("Plateau Invalide!")
	# Attendre l'échéance de la temporisation
	await $TempoMessage.timeout
	$Message.autowrap_mode=TextServer.AUTOWRAP_OFF
	_afficher_message("'.' = Fin de pile")
	await $TempoMessage.timeout
	_afficher_message("'.' = Fin de pile\nex: 'AB .BA .BA '")
	await $TempoMessage.timeout
	_afficher_message("'.' = Fin de pile\nex: 'AB .BA .BA '\nex: 'ABA.BAB.   '")
	await $TempoMessage.timeout
	_afficher_message("'.' = Fin de pile\nex: 'AB .BA .BA '\nex: 'ABA.BAB.   '\nex: 'AB.BC.C .A '")
	await $TempoMessage.timeout
	_afficher_message("'.' = Fin de pile\nex: 'AB .BA .BA '\nex: 'ABA.BAB.   '\nex: 'AB.BC.C .A '", false)
	await $TempoMessage.timeout
	$Message.autowrap_mode=TextServer.AUTOWRAP_WORD

	$BoutonMenuPrincipal.show()
	$EditeurPlateau/SaisieEditionPlateau.clear()
	$EditeurPlateau.show()
	$BoutonCommencer.show()

func afficher_abandon():
	_afficher_message("Perdu!")
	await $TempoMessage.timeout
	afficher_plateau_suivant()

func afficher_victoire():
	_afficher_message("Bravo!")
	# Attendre l'échéance de la temporisation
	await $TempoMessage.timeout
	afficher_plateau_suivant()
