# Implemente toutes les spécificité de la campagnes:
# Lectures des "Sauvegarde*" + synthese en croisant les données
# Il gere tous les mecanismes de regles, de donnees et de comportements de la campagne.

extends Node

class_name Campagne

enum Gameplay {
	CLASSIQUE,
	MEMOIRE,
	DEFI_DU_GOSSE,
	DEFI_DU_BOSS,
	QUI_PERD_GAGNE,
	FLEMMARD,
	DOUBLE_FACE,
	DICO
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecter les signaux attendus
	var pcs = get_node("/root/ProgressionCampagneService")
	pcs.progression_niveau.connect(_on_progression_campagne_service_progression_niveau)
	pcs.fin_niveau.connect(_on_progression_campagne_service_fin_niveau)

	# $MenuCampagne.modifier_message_vertical_align(VERTICAL_ALIGNMENT_CENTER)
	cacher_les_gameplays()
	$MenuCampagne.cacher_accueil()
	$MenuCampagne.show()
	if ProgressionCampagneService.niveau_en_cours():
		enregistrer_infos_joueur_pour_menu()
		$MenuCampagne.afficher_accueil_niveau_en_cours()
	else:
		enregistrer_longueur_max_plateaux_pour_menu()
		$MenuCampagne.afficher_accueil_nouveau_niveau()

func _on_menu_commencer_plateau() -> void:
	# TODO : supprimer "pourcentage" (-1) pour commencer campagne
	ProgressionCampagneService.commencer_un_plateau(-1)
	_lancer_plateau_de_campagne(SauvegardeBddJoueursService.enregistrement_lire_nom_plateau())

func _lancer_plateau_de_campagne(plateau : String) -> void:
	# TODO : Définir le type de plateau à lancer => Ajouter un parametre 'gameplay'
	var gameplay : Gameplay = Gameplay.CLASSIQUE
	# var gameplay : Gameplay = Gameplay.QUI_PERD_GAGNE

	var i_gameplay : Node = instance_gameplay(gameplay)
	if i_gameplay.est_valide(plateau):
		$MenuCampagne.cacher_accueil()
		montrer_le_gameplay(gameplay)
		i_gameplay.commencer_un_nouveau_plateau(plateau)
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

func _on_progression_campagne_service_progression_niveau():
	enregistrer_infos_joueur_pour_menu()

func _on_progression_campagne_service_fin_niveau():
	enregistrer_longueur_max_plateaux_pour_menu()

func cacher_les_gameplays() -> void:
	$Classique.cacher_accueil()
	$QuiPerdGagne.cacher_accueil()

func montrer_le_gameplay(gameplay : Gameplay) -> void:
	if gameplay == Gameplay.CLASSIQUE:
		$QuiPerdGagne.hide()
	if gameplay == Gameplay.QUI_PERD_GAGNE:
		$Classique.hide()

func instance_gameplay(gameplay : Gameplay) -> Node:
	if gameplay == Gameplay.CLASSIQUE:
		return $Classique
	if gameplay == Gameplay.QUI_PERD_GAGNE:
		return $QuiPerdGagne
	LogService.log_erreur("Gameplay inconnu : ", gameplay)
	return null

# TODO : Déplacer le code. Le menu doit demande au SERVICE les infos necessiares.
func enregistrer_infos_joueur_pour_menu():
	# Transmet les infos pour mettre à jour la banniere 'infos joueur' du menu
	var nom = SauvegardeBddJoueursService.lire_nom_joueur()
	var trophee = SauvegardeTableauDesScoresService.lire_le_trophee_du_joueur(nom)
	var pourcentage_niveau_realise = StatsService.niveau_taux_completion() * 100.
	var pourcentage_campagne_realise = StatsService.campagne_taux_completion() * 100.
	var score_texte = SauvegardeTableauDesScoresService.lire_score_txt_joueur(nom)
	$MenuCampagne.enregistrer_infos_joueur(	nom, trophee, pourcentage_niveau_realise, pourcentage_campagne_realise, score_texte)

# TODO : Déplacer le code. Le menu doit demande au SERVICE les infos necessiares.
func enregistrer_longueur_max_plateaux_pour_menu():
	# Transmet la longueur max de plateau d'Un niveau
	var longueur_max_niveau = SauvegardeBddJoueursService.campagne_lire_nombre_de_niveaux_realisables()
	$MenuCampagne.enregistrer_longueur_max_niveau(longueur_max_niveau)
