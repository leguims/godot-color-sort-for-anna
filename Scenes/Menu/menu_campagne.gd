extends Menu

class_name MenuCampagne

func afficher_accueil():
	# Initialisation du menu de campagne
	# En campagne, le plateau n'est ni visible, ni éditable
	$EditeurPlateau.hide()
	$EditeurPlateau/SaisieEditionPlateau.editable = false
	$EditeurPlateau/SaisieEditionPlateau.text = GestionScore.lire_plateau_courant()
	$Message.size.y = $Message.size.y + 100
	
	$BoutonMenuPrincipal.show()
	super.mettre_a_jour_infos_joueur()
	$InfosDuJoueur.show()
	
	_afficher_message("Mode Campagne!", false)
	# Attendre l'échéance d'une temporisation libre
	await get_tree().create_timer(1.0).timeout
	$BoutonCommencer.show()

func afficher_plateau_suivant():
	$EditeurPlateau/SaisieEditionPlateau.text = GestionScore.lire_plateau_courant()
	_afficher_message("Plateau suivant!", false)
	super.mettre_a_jour_infos_joueur()
	$BoutonMenuPrincipal.show()
	$InfosDuJoueur.show()
	$BoutonCommencer.show()

func afficher_plateau_invalide():
	# Pas de plateau invalide en campagne
	pass

func afficher_abandon():
	_afficher_message("Perdu!")
	await $TempoMessage.timeout
	_afficher_message("Fin de Partie")
	await $TempoMessage.timeout
	afficher_plateau_suivant()

func afficher_victoire(duree : int) -> void:
	_afficher_message("Bravo!")
	await $TempoMessage.timeout
	_afficher_message("Gagné en " + str(duree) + "s")
	await $TempoMessage.timeout
	afficher_plateau_suivant()

func afficher_fin_campagne():
	_afficher_message("Bravo!")
	# Attendre l'échéance de la temporisation
	await $TempoMessage.timeout
	_afficher_message("C'était le dernier plateau!")
	await $TempoMessage.timeout
	_afficher_message("Vous êtes au sommet...")
	await $TempoMessage.timeout
	_afficher_message("...de l'Everest!")
	await $TempoMessage.timeout
	$BoutonMenuPrincipal.show()
	super.mettre_a_jour_infos_joueur()
	$InfosDuJoueur.show()
	$BoutonCommencer.show()
