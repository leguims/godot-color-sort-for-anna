# Implemente toutes les spécificité de la campagnes:
# Lectures des "Sauvegarde*" + synthese en croisant les données
# Il gere tous les mecanismes de regles, de donnees et de comportements de la campagne.

extends Node

class_name Campagne

var heure_debut_en_ms : int
var duree_en_ms : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MenuCampagne.modifier_tempo_message(1.0)
	# $MenuCampagne.modifier_message_vertical_align(VERTICAL_ALIGNMENT_CENTER)
	$MenuCampagne.cacher_accueil()
	$MenuCampagne.show()
	if SauvegardeBddJoueurs.ascension_en_cours():
		enregistrer_infos_joueur_pour_menu()
		$MenuCampagne.afficher_accueil_ascension_en_cours()
	else:
		enregistrer_longueur_max_plateaux_pour_menu()
		$MenuCampagne.afficher_accueil_nouvelle_ascension()

func _on_menu_commencer_plateau() -> void:
	commencer_un_plateau()
	_lancer_plateau_de_campagne(SauvegardeBddJoueurs.lire_nom_plateau())

func _lancer_plateau_de_campagne(plateau : String) -> void:
	if $PlateauDeJeu.est_valide(plateau):
		$MenuCampagne.cacher_accueil()
		$PlateauDeJeu.effacer_le_plateau()
		$PlateauDeJeu.commencer_un_nouveau_plateau(plateau)
		if SauvegardeConfiguration.effets_sonores_sont_actifs():
			$SonCommencer.play()
		if SauvegardeConfiguration.musiques_sont_actives():
			$Musique.play()
		heure_debut_en_ms = Time.get_ticks_msec()
	else:
		_on_plateau_de_jeu_plateau_invalide()

func _on_plateau_de_jeu_victoire() -> void:
	duree_en_ms = Time.get_ticks_msec() - heure_debut_en_ms
	gagner_un_plateau(duree_en_ms)
	$MenuCampagne.show()
	if SauvegardeBddJoueurs.la_campagne_est_terminee():
		$MenuCampagne.afficher_fin_campagne()
	elif not SauvegardeBddJoueurs.ascension_en_cours():
		enregistrer_longueur_max_plateaux_pour_menu()
		$MenuCampagne.afficher_fin_ascension()
	else:
		$MenuCampagne.afficher_victoire(roundi(duree_en_ms / 1000.0))
	if SauvegardeConfiguration.effets_sonores_sont_actifs():
		$SonFinDePartie.play()
	if SauvegardeConfiguration.musiques_sont_actives():
		$Musique.stop()

func _on_plateau_de_jeu_plateau_invalide() -> void:
	# Pas de plateau invalide en campagne
	print("_on_plateau_de_jeu_plateau_invalide pour la campagne IMPOSSIBLE ! WTF !")
	pass

func _on_plateau_de_jeu_abandon() -> void:
	# Mettre à jour les plateaux à jouer
	abandonner_un_plateau()
	$MenuCampagne.show()
	$MenuCampagne.afficher_abandon()
	if SauvegardeConfiguration.effets_sonores_sont_actifs():
		$SonEchec.play()
	if SauvegardeConfiguration.musiques_sont_actives():
		$Musique.stop()

func enregistrer_infos_joueur_pour_menu():
	# Transmet les infos pour mettre à jour la banniere 'infos joueur' du menu
	var nom = SauvegardeBddJoueurs.lire_nom_joueur()
	var trophee = SauvegardeScores.lire_le_trophee_du_joueur(nom)
	var pourcentage_ascension_realise = SauvegardeBddJoueurs.lire_pourcentage_ascension_realise()
	var nb_ascensions = SauvegardeBddJoueurs.lire_nombre_ascensions()
	var score_texte = SauvegardeScores.lire_score_txt_joueur(nom)
	$MenuCampagne.enregistrer_infos_joueur(	nom, trophee, pourcentage_ascension_realise,
									 nb_ascensions, score_texte)

func enregistrer_longueur_max_plateaux_pour_menu():
	# Transmet la longueur max de plateau d'une ascension
	var longueur_max_ascension = SauvegardeBddJoueurs.lire_nombre_de_niveaux_realisables()
	$MenuCampagne.enregistrer_longueur_max_ascension(longueur_max_ascension)

####################################
# Gestion des mécaniques de jeu
####################################

# Evenements de jeu du plateau
##############################

func commencer_un_plateau() -> void:
	if not SauvegardeBddJoueurs.ascension_en_cours():
		initialiser_une_nouvelle_ascension()
	# Ajouter le nouveau plateau
	SauvegardeBddJoueurs.initialiser_un_nouveau_plateau(
					SauvegardeBddJoueurs.lire_plateau_aleatoire_pour_niveau_courant(),
					SauvegardeBddJoueurs.lire_niveau_joueur()
					)
	
	# Incrémenter le compteur de parties du niveau courant
	SauvegardeBddJoueurs.incrementer_nombre_de_parties_joueur_pour_niveau_courant()
	print("Nombre de parties = ", SauvegardeBddJoueurs.lire_nombre_de_parties_joueur_pour_niveau_courant())

func gagner_un_plateau(duree_en_ms : int) -> void:
	# Valider le plateau courant (effacer de la liste des plateaux jouables)
	SauvegardeBddJoueurs.supprimer_plateau_courant()

	# Ajouter le temps de jeu dans le niveau courant
	SauvegardeBddJoueurs.ajouter_duree_plateau(duree_en_ms)
	SauvegardeBddJoueurs.modifier_statut_plateau('reussi')
	SauvegardeBddJoueurs.terminer_plateau()
	
	# Calculer le niveau supérieur
	var niveau_superieur = retourner_le_niveau_superieur()
	# Déterminer si l'ascension est achevée (pas de niveau suivant)
	if niveau_superieur == SauvegardeBddJoueurs.lire_niveau_joueur():
		SauvegardeBddJoueurs.terminer_ascension()
		# Préparer la jauge pour la prochaine ascension
		enregistrer_longueur_max_plateaux_pour_menu()
	
	# Calculer le score du plateau et l'enregistrer dans l'historique de l'ascension
	var score = mettre_a_jour_score_pour_victoire(duree_en_ms)
	
	# Passer au niveau suivant
	if niveau_superieur > SauvegardeBddJoueurs.lire_niveau_joueur():
		SauvegardeBddJoueurs.modifier_niveau_joueur(niveau_superieur)
	enregistrer_infos_joueur_pour_menu()
	afficher_niveau_plateau_parties()

func abandonner_un_plateau() -> void:
	# En cas d'abandon, pas d'enrgistrement du temps.
	SauvegardeBddJoueurs.incrementer_longueur_detour_ascension()
	SauvegardeBddJoueurs.modifier_statut_plateau('abandonné')
	SauvegardeBddJoueurs.terminer_plateau()
	
	# Diminuer le niveau courant (si c'est possible)
	var niveau_inferieur = retourner_le_niveau_inferieur()
	if niveau_inferieur < SauvegardeBddJoueurs.lire_niveau_joueur():
		SauvegardeBddJoueurs.modifier_niveau_joueur(niveau_inferieur)
	enregistrer_infos_joueur_pour_menu()
	afficher_niveau_plateau_parties()

func initialiser_une_nouvelle_ascension():
		var pourcentage_longueur = $MenuCampagne/LongueurAscension/VBox/Pourcentage.value
		var nb_niveaux = roundi(pourcentage_longueur / 100. * SauvegardeBddJoueurs.lire_nombre_de_niveaux_realisables())
		var niveau_min = retourner_le_niveau_le_plus_bas()
		var niveau_max = retourner_le_niveau_nieme(nb_niveaux)
		SauvegardeBddJoueurs.initialiser_une_nouvelle_ascension(niveau_min, niveau_max)

func afficher_niveau_plateau_parties():
	print("[Campagne] Niveau = ", str(SauvegardeBddJoueurs.lire_niveau_joueur()),
	 " - Plateau = '", str(SauvegardeBddJoueurs.lire_nom_plateau()).replace(' ', '-'), "'",
	 " - Pourcentage ascension = ", str(SauvegardeBddJoueurs.lire_pourcentage_ascension_realise()),"%")

# Traitement d'un plateau
#########################

func mettre_a_jour_score_pour_victoire(duree_en_ms : int):
	"Calculer le score suite à une victoire (duree, ratio réussites, ascension, campagne)"
	var score_duree = mettre_a_jour_score_duree(duree_en_ms)
	var score_ratio_reussite = mettre_a_jour_score_ratio_reussite()
	var score_ascension = mettre_a_jour_score_ascension()
	var score_ascension_sans_detour = mettre_a_jour_score_ascension_sans_detour()
	var score_campagne = mettre_a_jour_score_campagne()
	var score = score_duree \
		+ score_ratio_reussite \
		+ score_ascension \
		+ score_ascension_sans_detour \
		+ score_campagne

	# Bonus spécifique pour Anna d'Amour, la déesse de ce jeu.
	if SauvegardeBddJoueurs.lire_nom_joueur().to_lower() == 'Anna'.to_lower():
		var nom_joueur = SauvegardeBddJoueurs.lire_nom_joueur()
		var bonus_anna = score * 3
		SauvegardeScores.incrementer_score_joueur(nom_joueur, bonus_anna)
	return {
		'duree': score_duree,
		'ratio_reussite': score_ratio_reussite,
		'ascension': score_ascension,
		'ascension_sans_detour': score_ascension_sans_detour,
		'campagne': score_campagne
		}

func mettre_a_jour_score_duree(duree_en_ms : int) -> int:
	"Calculer le score relatif au temps"
	var temps_reference_par_niveau = {
		25 : 10.,
		50 : 15.,
		60 : 20.,
		100 : 25.,
		125 : 40.
		}

	var niveau = SauvegardeBddJoueurs.lire_niveau_joueur()
	var temps_reference_en_s = temps_reference_par_niveau[25]
	if niveau <= 25:
		temps_reference_en_s = temps_reference_par_niveau[25]
	elif niveau <= 50:
		temps_reference_en_s = temps_reference_par_niveau[50]
	elif niveau <= 60:
		temps_reference_en_s = temps_reference_par_niveau[60]
	elif niveau <= 100:
		temps_reference_en_s = temps_reference_par_niveau[100]
	elif niveau <= 125:
		temps_reference_en_s = temps_reference_par_niveau[125]
	else :
		printerr("Erreur : Niveau inattendu pour le score !")

	var bonus_duree = 0
	var nom_joueur = SauvegardeBddJoueurs.lire_nom_joueur()
	var duree_en_s = duree_en_ms / 1000.
	# Score sur le ratio du temps référence/joué
	var ratio_temps = temps_reference_en_s / duree_en_s
	bonus_duree = roundi(100 * niveau * ratio_temps)
	SauvegardeBddJoueurs.modifier_score_duree_plateau(bonus_duree)
	SauvegardeScores.incrementer_score_joueur(nom_joueur, bonus_duree)
	return bonus_duree

func mettre_a_jour_score_ratio_reussite() -> int:
	"Calculer le score relatif au temps"
	var bonus_ratio_reussite = 0
	var nom_joueur = SauvegardeBddJoueurs.lire_nom_joueur()
	var niveau = SauvegardeBddJoueurs.lire_niveau_joueur()
	var ratio_reussite = SauvegardeBddJoueurs.lire_pourcentage_ascension_realise() / 100.
	bonus_ratio_reussite = roundi(100 * niveau * ratio_reussite)
	SauvegardeBddJoueurs.modifier_score_ratio_reussite_plateau(bonus_ratio_reussite)
	SauvegardeScores.incrementer_score_joueur(nom_joueur, bonus_ratio_reussite)
	return bonus_ratio_reussite

func mettre_a_jour_score_ascension() -> int:
	"Calculer le score suite à une ascension achevée"
	var bonus_ascension = 0
	if not SauvegardeBddJoueurs.ascension_en_cours():
		var nom_joueur = SauvegardeBddJoueurs.lire_nom_joueur()
		var niveau_ascension_longueur_totale = SauvegardeBddJoueurs.lire_niveau_ascension_longueur_totale()
		# bonus = 100 x Dénivelé ^2 (bonus non linéaire)
		bonus_ascension = roundi(50 * pow(niveau_ascension_longueur_totale, 2))
		SauvegardeBddJoueurs.modifier_score_ascension(bonus_ascension)
		SauvegardeScores.incrementer_score_joueur(nom_joueur, bonus_ascension)
	return bonus_ascension

func mettre_a_jour_score_ascension_sans_detour() -> int:
	"Calculer le score suite à une ascension parfaite achevée"
	var bonus_ascension_sans_detour = 0
	if SauvegardeBddJoueurs.lire_longueur_detour_ascension() == 0:
		bonus_ascension_sans_detour = SauvegardeBddJoueurs.lire_score_ascension()
		SauvegardeBddJoueurs.modifier_score_ascension_sans_detour(bonus_ascension_sans_detour)
	return bonus_ascension_sans_detour

func mettre_a_jour_score_campagne() -> int:
	"Calculer le score suite à la campagne achevée"
	var bonus_campagne = 0
	if SauvegardeBddJoueurs.la_campagne_est_terminee():
		var nom_joueur = SauvegardeBddJoueurs.lire_nom_joueur()
		bonus_campagne = 2_000_000
		SauvegardeScores.incrementer_score_joueur(nom_joueur, bonus_campagne)
	return bonus_campagne

# Traitement de niveau
######################

func retourner_le_niveau_le_plus_bas() -> int:
	# Retourner le plus bas niveau réalisable
	for niveau_le_plus_bas in range(0, 300):
		# Vérifier qu'il reste des plateaux à réaliser par le joueur
		if not SauvegardeBddJoueurs.le_niveau_est_termine(niveau_le_plus_bas):
			return niveau_le_plus_bas
	return -1

func retourner_le_niveau_le_plus_haut() -> int:
	# Retourner le plus haut niveau réalisable
	for niveau_le_plus_haut in range(300, -1, -1):
		# Vérifier qu'il reste des plateaux à réaliser par le joueur
		if not SauvegardeBddJoueurs.le_niveau_est_termine(niveau_le_plus_haut):
			return niveau_le_plus_haut
	return -1

func retourner_le_niveau_nieme(nb_niveaux : int) -> int:
	var niveau = -1
	for niveau_le_plus_bas in range(0, 300):
		# Vérifier qu'il reste des plateaux à réaliser par le joueur
		if not SauvegardeBddJoueurs.le_niveau_est_termine(niveau_le_plus_bas):
			nb_niveaux -= 1
			niveau = niveau_le_plus_bas
			if not nb_niveaux:
				break
	return niveau

func retourner_le_niveau_superieur() -> int:
	# Parcourir les niveaux supérieurs
	var niveau_max = SauvegardeBddJoueurs.lire_niveau_fin_ascension()
	for niveau_superieur in range(SauvegardeBddJoueurs.lire_niveau_joueur()+1, niveau_max+1):
		# Vérifier qu'il reste des plateaux à réaliser par le joueur
		if not SauvegardeBddJoueurs.le_niveau_est_termine(niveau_superieur):
			return niveau_superieur
	return SauvegardeBddJoueurs.lire_niveau_joueur()

func retourner_le_niveau_inferieur() -> int:
	# Parcourir les niveaux supérieurs
	var niveau_min = SauvegardeBddJoueurs.lire_niveau_debut_ascension()
	for niveau_inferieur in range(SauvegardeBddJoueurs.lire_niveau_joueur()-1, niveau_min-1, -1):
		# Vérifier qu'il reste des plateaux à réaliser par le joueur
		if not SauvegardeBddJoueurs.le_niveau_est_termine(niveau_inferieur):
			return niveau_inferieur
	return SauvegardeBddJoueurs.lire_niveau_joueur()
