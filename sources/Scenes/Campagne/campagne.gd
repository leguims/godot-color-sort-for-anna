# Implemente toutes les spécificité de la campagnes:
# Lectures des "Sauvegarde*" + synthese en croisant les données
# Il gere tous les mecanismes de regles, de donnees et de comportements de la campagne.

extends Node

class_name Campagne

var heure_debut_en_ms : int
var duree_en_ms : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connecter les signaux attendus
	var pcs = get_node("/root/ProgressionCampagneService")
	pcs.progression_ascension.connect(_on_progression_campagne_service_progression_ascension)
	pcs.fin_ascension.connect(_on_progression_campagne_service_fin_ascension)

	$MenuCampagne.modifier_tempo_message(1.0)
	# $MenuCampagne.modifier_message_vertical_align(VERTICAL_ALIGNMENT_CENTER)
	$MenuCampagne.cacher_accueil()
	$MenuCampagne.show()
	if ProgressionCampagneService.ascension_en_cours():
		enregistrer_infos_joueur_pour_menu()
		$MenuCampagne.afficher_accueil_ascension_en_cours()
	else:
		enregistrer_longueur_max_plateaux_pour_menu()
		$MenuCampagne.afficher_accueil_nouvelle_ascension()

func _on_menu_commencer_plateau() -> void:
	ProgressionCampagneService.commencer_un_plateau($MenuCampagne/LongueurAscension/VBox/Pourcentage.value)
	_lancer_plateau_de_campagne(SauvegardeBddJoueursService.lire_nom_plateau())

func _lancer_plateau_de_campagne(plateau : String) -> void:
	if $PlateauDeJeu.est_valide(plateau):
		$MenuCampagne.cacher_accueil()
		$PlateauDeJeu.effacer_le_plateau()
		$PlateauDeJeu.commencer_un_nouveau_plateau(plateau)
		AudioService.son_commencer_un_plateau()
		AudioService.jouer_la_musique()
		heure_debut_en_ms = Time.get_ticks_msec()
	else:
		_on_plateau_de_jeu_plateau_invalide()

func _on_plateau_de_jeu_victoire() -> void:
	duree_en_ms = Time.get_ticks_msec() - heure_debut_en_ms
	ProgressionCampagneService.gagner_un_plateau(duree_en_ms)
	$MenuCampagne.show()
	if ProgressionCampagneService.la_campagne_est_terminee():
		$MenuCampagne.afficher_fin_campagne()
	elif not ProgressionCampagneService.ascension_en_cours():
		enregistrer_longueur_max_plateaux_pour_menu()
		$MenuCampagne.afficher_fin_ascension()
	else:
		$MenuCampagne.afficher_victoire(roundi(duree_en_ms / 1000.0))
	AudioService.son_gagner_un_plateau()
	AudioService.arreter_la_musique()

func _on_plateau_de_jeu_plateau_invalide() -> void:
	# Pas de plateau invalide en campagne
	print("_on_plateau_de_jeu_plateau_invalide pour la campagne IMPOSSIBLE ! WTF !")
	pass

func _on_plateau_de_jeu_abandon() -> void:
	# Mettre à jour les plateaux à jouer
	ProgressionCampagneService.abandonner_un_plateau()
	$MenuCampagne.show()
	$MenuCampagne.afficher_abandon()
	AudioService.son_abandonner_un_plateau()
	AudioService.arreter_la_musique()

func _on_progression_campagne_service_progression_ascension():
	enregistrer_infos_joueur_pour_menu()

func _on_progression_campagne_service_fin_ascension():
	enregistrer_longueur_max_plateaux_pour_menu()

func enregistrer_infos_joueur_pour_menu():
	# Transmet les infos pour mettre à jour la banniere 'infos joueur' du menu
	var nom = SauvegardeBddJoueursService.lire_nom_joueur()
	var trophee = SauvegardeTableauDesScoresService.lire_le_trophee_du_joueur(nom)
	var pourcentage_ascension_realise = SauvegardeBddJoueursService.lire_pourcentage_ascension_realise()
	var nb_ascensions = SauvegardeBddJoueursService.lire_nombre_ascensions()
	var score_texte = SauvegardeTableauDesScoresService.lire_score_txt_joueur(nom)
	$MenuCampagne.enregistrer_infos_joueur(	nom, trophee, pourcentage_ascension_realise,
									 nb_ascensions, score_texte)

func enregistrer_longueur_max_plateaux_pour_menu():
	# Transmet la longueur max de plateau d'une ascension
	var longueur_max_ascension = SauvegardeBddJoueursService.lire_nombre_de_niveaux_realisables()
	$MenuCampagne.enregistrer_longueur_max_ascension(longueur_max_ascension)
