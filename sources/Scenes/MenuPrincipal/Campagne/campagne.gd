# Implemente toutes les spécificité de la campagnes:
# Lectures des "Sauvegarde*" + synthese en croisant les données
# Il gere tous les mecanismes de regles, de donnees et de comportements de la campagne.

extends Node

class_name Campagne

var gameplay_courant : Node

func gameplay_to_ui(gameplay : GameplayTypes.Gameplay) -> Node:
	match gameplay:
		GameplayTypes.Gameplay.CLASSIQUE:
			return $Classique
		GameplayTypes.Gameplay.AU_PLUS_PRES:
			return $AuPlusPres
		GameplayTypes.Gameplay.PILE_POIL:
			return $PilePoil
		GameplayTypes.Gameplay.TOUT_EN_TETE:
			return $ToutEnTete
		GameplayTypes.Gameplay.PROGRAMMATION:
			return $Programmation
		GameplayTypes.Gameplay.PROGRAMMATION_GENIUS:
			return $ProgrammationGenius
		GameplayTypes.Gameplay.QUI_PERD_GAGNE:
			return $QuiPerdGagne
		GameplayTypes.Gameplay.POIDS_PLUME:
			return $PoidsPlume
		GameplayTypes.Gameplay.PILE_OU_FACE:
			return $PileOuFace
		GameplayTypes.Gameplay.MOT_CACHE:
			return $MotCache
		_:
			LogService.log_erreur("Gameplay inconnu : ", str(gameplay))
			return $Classique

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecter les signaux attendus

	var gameplay_str : String = SauvegardeBddJoueursService.campagne_lire_prochain_gameplay()
	var gameplay : GameplayTypes.Gameplay = GameplayTypes.gameplay_to_enum(gameplay_str)
	gameplay_courant = gameplay_to_ui(gameplay)
	commencer_un_nouveau_gameplay(gameplay)

	$MessagesCampagne.hide()

func _on_menu_commencer_plateau() -> void:
	ProgressionCampagneService.commencer_un_plateau()
	_lancer_plateau_de_campagne()

func _lancer_plateau_de_campagne() -> void:
	var plateau : String = SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_plateau()
	var gameplay_str : String = SauvegardeBddJoueursService.enregistrement_campagne_lire_gameplay_plateau()
	var gameplay : GameplayTypes.Gameplay = GameplayTypes.gameplay_to_enum(gameplay_str)
	gameplay_courant = gameplay_to_ui(gameplay)

	if gameplay_courant.est_valide(plateau):
		$MessagesCampagne.hide()
		gameplay_courant.commencer_un_nouveau_plateau(plateau)
		AudioService.son_commencer_un_plateau()
		AudioService.jouer_la_musique()
	else:
		_on_classique_plateau_invalide()

func _on_classique_plateau_invalide() -> void:
	# Pas de plateau invalide en campagne
	LogService.log_erreur("_on_classique_plateau_invalide pour la campagne IMPOSSIBLE ! WTF !")

func _on_classique_victoire() -> void:
	ProgressionCampagneService.gagner_un_plateau()
	$MessagesCampagne.show()
	if ProgressionCampagneService.la_campagne_est_terminee():
		$MessagesCampagne.afficher_fin_campagne()
	elif not ProgressionCampagneService.niveau_en_cours():
		$MessagesCampagne.afficher_fin_niveau()
	else:
		$MessagesCampagne.afficher_gagner_un_plateau()
	AudioService.son_gagner_un_plateau()
	AudioService.arreter_la_musique()

func _on_classique_abandon() -> void:
	# Mettre à jour les plateaux à jouer
	ProgressionCampagneService.abandonner_un_plateau()
	gameplay_courant.show_fond()
	$MessagesCampagne.show()
	$MessagesCampagne.afficher_abandonner_un_plateau()
	AudioService.son_abandonner_un_plateau()
	AudioService.arreter_la_musique()

func _on_classique_passe() -> void:
	# Mettre à jour les plateaux à jouer
	ProgressionCampagneService.passer_un_plateau()
	gameplay_courant.show_fond()
	$MessagesCampagne.show()
	$MessagesCampagne.afficher_passer_un_plateau()
	AudioService.son_passer_un_plateau()
	AudioService.arreter_la_musique()

func _on_messages_campagne_score_continuer() -> void:
	# Fin d'affichage du score, réactiver le menu
	pass
	if not ProgressionCampagneService.la_campagne_est_terminee():
		$MessagesCampagne.hide()

		# Afficher le prochain gameplay
		var gameplay_str : String = SauvegardeBddJoueursService.campagne_lire_prochain_gameplay()
		var gameplay : GameplayTypes.Gameplay = GameplayTypes.gameplay_to_enum(gameplay_str)
		gameplay_courant.hide()
		gameplay_courant = gameplay_to_ui(gameplay)
		gameplay_courant.commencer_un_nouveau_gameplay()


func _on_qui_perd_gagne_plateau_invalide() -> void:
	LogService.log_erreur("_on_qui_perd_gagne_plateau_invalide pour la campagne IMPOSSIBLE ! WTF !")

func _on_qui_perd_gagne_victoire() -> void:
	_on_classique_victoire()

func _on_qui_perd_gagne_abandon() -> void:
	_on_classique_abandon()

func _on_qui_perd_gagne_passe() -> void:
	_on_classique_passe()

func cacher_les_gameplays() -> void:
	$Classique.hide()
	$QuiPerdGagne.hide()

func commencer_un_nouveau_gameplay(gameplay : GameplayTypes.Gameplay) -> void:
	if gameplay == GameplayTypes.Gameplay.CLASSIQUE:
		$QuiPerdGagne.hide()
		$Classique.commencer_un_nouveau_gameplay()
	if gameplay == GameplayTypes.Gameplay.QUI_PERD_GAGNE:
		$Classique.hide()
		$QuiPerdGagne.commencer_un_nouveau_gameplay()

func instance_gameplay(gameplay : GameplayTypes.Gameplay) -> Node:
	if gameplay == GameplayTypes.Gameplay.CLASSIQUE:
		return $Classique
	if gameplay == GameplayTypes.Gameplay.QUI_PERD_GAGNE:
		return $QuiPerdGagne
	LogService.log_erreur("Gameplay inconnu : ", gameplay)
	return null
