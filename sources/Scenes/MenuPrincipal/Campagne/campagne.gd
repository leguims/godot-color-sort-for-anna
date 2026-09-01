# Implemente toutes les spécificité de la campagnes:
# Lectures des "Sauvegarde*" + synthese en croisant les données
# Il gere tous les mecanismes de regles, de donnees et de comportements de la campagne.

extends Node

class_name Campagne

# var liste_gameplay : Dictionary[Gameplay, Node] = {}

# TODO : à depalcer dans "Scenes\MenuPrincipal\Campagne\GamePlay"
enum Gameplay {
	CLASSIQUE,
	AU_PLUS_PRES,
	PILE_POIL,
	TOUT_EN_TETE,
	PROGRAMMATION,
	PROGRAMMATION_GENIUS,
	QUI_PERD_GAGNE,
	POIDS_PLUME,
	PILE_OU_FACE,
	MOT_CACHE
}

func gameplay_to_enum(gameplay : String) -> Gameplay:
	match gameplay:
		"CLASSIQUE":
			return Gameplay.CLASSIQUE
		"AU_PLUS_PRES":
			return Gameplay.AU_PLUS_PRES
		"PILE_POIL":
			return Gameplay.PILE_POIL
		"TOUT_EN_TETE":
			return Gameplay.TOUT_EN_TETE
		"PROGRAMMATION":
			return Gameplay.PROGRAMMATION
		"PROGRAMMATION_GENIUS":
			return Gameplay.PROGRAMMATION_GENIUS
		"QUI_PERD_GAGNE":
			return Gameplay.QUI_PERD_GAGNE
		"POIDS_PLUME":
			return Gameplay.POIDS_PLUME
		"PILE_OU_FACE":
			return Gameplay.PILE_OU_FACE
		"MOT_CACHE":
			return Gameplay.MOT_CACHE
		_:
			LogService.log_erreur("Gameplay inconnu : ", gameplay)
			return Gameplay.CLASSIQUE

func gameplay_to_ui(gameplay : Gameplay) -> Node:
	match gameplay:
		Gameplay.CLASSIQUE:
			return $Classique
		Gameplay.AU_PLUS_PRES:
			return $AuPlusPres
		Gameplay.PILE_POIL:
			return $PilePoil
		Gameplay.TOUT_EN_TETE:
			return $ToutEnTete
		Gameplay.PROGRAMMATION:
			return $Programmation
		Gameplay.QUI_PERD_GAGNE:
			return $QuiPerdGagne
		Gameplay.POIDS_PLUME:
			return $PoidsPlume
		Gameplay.PILE_OU_FACE:
			return $PileOuFace
		Gameplay.MOT_CACHE:
			return $MotCache
		_:
			LogService.log_erreur("Gameplay inconnu : ", str(gameplay))
			return $Classique

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecter les signaux attendus
	ProgressionCampagneService.fin_niveau.connect(_on_progression_campagne_service_fin_niveau)

	# $MenuCampagne.modifier_message_vertical_align(VERTICAL_ALIGNMENT_CENTER)
	cacher_les_gameplays()
	$MenuCampagne.cacher_accueil()
	$MenuCampagne.show()
	 # TODO : plus de IF ? 1 seul traitement ?
	if ProgressionCampagneService.niveau_en_cours():
		$MenuCampagne.afficher_accueil_niveau_en_cours()
	else:
		enregistrer_longueur_max_plateaux_pour_menu() # TODO : à effacer ?
		$MenuCampagne.afficher_accueil_nouveau_niveau()

func _on_menu_commencer_plateau() -> void:
	# TODO : Drole de comportement pour commencer un niveau.
	# TODO : Corriger ce comportement.
	ProgressionCampagneService.commencer_un_plateau()
	_lancer_plateau_de_campagne()

func _lancer_plateau_de_campagne() -> void:
	var plateau : String = SauvegardeBddJoueursService.enregistrement_lire_nom_plateau()
	var gameplay_str : String = SauvegardeBddJoueursService.enregistrement_lire_gameplay_plateau()
	var gameplay : Gameplay = gameplay_to_enum(gameplay_str)
	var ui_gameplay : Node = gameplay_to_ui(gameplay)

	if ui_gameplay.est_valide(plateau):
		$MenuCampagne.cacher_accueil()
		montrer_le_gameplay(gameplay)
		ui_gameplay.commencer_un_nouveau_plateau(plateau)
		AudioService.son_commencer_un_plateau()
		AudioService.jouer_la_musique()
	else:
		_on_classique_plateau_invalide()

func _on_classique_plateau_invalide() -> void:
	# Pas de plateau invalide en campagne
	LogService.log_erreur("_on_classique_plateau_invalide pour la campagne IMPOSSIBLE ! WTF !")

func _on_classique_victoire() -> void:
	ProgressionCampagneService.gagner_un_plateau()
	$MenuCampagne.show()
	if ProgressionCampagneService.la_campagne_est_terminee():
		$MenuCampagne.afficher_fin_campagne()
	elif not ProgressionCampagneService.niveau_en_cours():
		enregistrer_longueur_max_plateaux_pour_menu()
		$MenuCampagne.afficher_fin_niveau()
	else:
		$MenuCampagne.afficher_gagner_un_plateau()
	AudioService.son_gagner_un_plateau()
	AudioService.arreter_la_musique()

func _on_classique_abandon() -> void:
	# Mettre à jour les plateaux à jouer
	ProgressionCampagneService.abandonner_un_plateau()
	cacher_les_gameplays()
	$MenuCampagne.show()
	$MenuCampagne.afficher_abandonner_un_plateau()
	AudioService.son_abandonner_un_plateau()
	AudioService.arreter_la_musique()


func _on_qui_perd_gagne_plateau_invalide() -> void:
	LogService.log_erreur("_on_qui_perd_gagne_plateau_invalide pour la campagne IMPOSSIBLE ! WTF !")

func _on_qui_perd_gagne_victoire() -> void:
	_on_classique_victoire()

func _on_qui_perd_gagne_abandon() -> void:
	# TODO : ce cas peut etre détécté automatiquement. à reflechir
	_on_classique_abandon()

func _on_progression_campagne_service_fin_niveau():
	enregistrer_longueur_max_plateaux_pour_menu()

func cacher_les_gameplays() -> void:
	$Classique.cacher_accueil()
	$QuiPerdGagne.cacher_accueil()

func montrer_le_gameplay(gameplay : Gameplay) -> void:
	if gameplay == Gameplay.CLASSIQUE:
		$QuiPerdGagne.hide()
		$Classique.show()
	if gameplay == Gameplay.QUI_PERD_GAGNE:
		$Classique.hide()
		$QuiPerdGagne.show()

func instance_gameplay(gameplay : Gameplay) -> Node:
	if gameplay == Gameplay.CLASSIQUE:
		return $Classique
	if gameplay == Gameplay.QUI_PERD_GAGNE:
		return $QuiPerdGagne
	LogService.log_erreur("Gameplay inconnu : ", gameplay)
	return null

# TODO : Déplacer le code. Le menu doit demande au SERVICE les infos necessaires.
# TODO : Est-ce encore utile sans le choix de la longueur de l'ascension ?
func enregistrer_longueur_max_plateaux_pour_menu():
	# Transmet la longueur max de plateau d'Un niveau
	var longueur_max_niveau = SauvegardeBddJoueursService.campagne_lire_nombre_de_niveaux_realisables()
	$MenuCampagne.enregistrer_longueur_max_niveau(longueur_max_niveau)
