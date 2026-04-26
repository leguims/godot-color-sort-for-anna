extends Node

signal progression_ascension
signal detail_score_plateau(detail_score : Dictionary)
signal fin_ascension
# TODO : signal fin_campagne

####################################
# Gestion des mécaniques de jeu
####################################

# Evenements de jeu du plateau
##############################

func commencer_un_plateau(pourcentage_longueur : float) -> void:
	if not SauvegardeBddJoueursService.ascension_en_cours():
		initialiser_une_nouvelle_ascension(pourcentage_longueur)
	if SauvegardeBddJoueursService.plateau_en_cours():
		# Si un plateau était en cours, mais pas terminé, le considérer abandonné
		abandonner_un_plateau()

	# Ajouter le nouveau plateau et incrémenter le compteur de parties du niveau courant
	SauvegardeBddJoueursService.commencer_un_plateau()
	print("Nombre de parties = ", SauvegardeBddJoueursService.lire_nombre_de_parties_joueur_pour_niveau_courant())

func gagner_un_plateau(duree_en_ms : int) -> void:
	# Valider le plateau courant (effacer de la liste des plateaux jouables)
	SauvegardeBddJoueursService.gagner_un_plateau(duree_en_ms)

	# Calculer le niveau supérieur
	var niveau_superieur = retourner_le_niveau_superieur()
	# Déterminer si l'ascension est achevée (pas de niveau suivant)
	if niveau_superieur == SauvegardeBddJoueursService.lire_niveau_joueur():
		# BDD joueur + Préparer la jauge pour la prochaine ascension
		fin_ascension.emit()

	# Calculer le score du plateau et l'enregistrer dans l'historique de l'ascension
	var detail_score = ScoreService.mettre_a_jour_score_pour_victoire(duree_en_ms)
	detail_score_plateau.emit(detail_score)

	# Passer au niveau suivant
	if niveau_superieur > SauvegardeBddJoueursService.lire_niveau_joueur():
		SauvegardeBddJoueursService.modifier_niveau_joueur(niveau_superieur)
	
	# Emmettre un signal de mise à jour de l'ascension
	progression_ascension.emit() # Pour mise à jour des bandeaux d'infos
	afficher_niveau_plateau_parties()

func abandonner_un_plateau() -> void:
	# En cas d'abandon, pas d'enrgistrement du temps.
	SauvegardeBddJoueursService.abandonner_un_plateau()
	
	# Diminuer le niveau courant (si c'est possible)
	var niveau_inferieur = retourner_le_niveau_inferieur()
	if niveau_inferieur < SauvegardeBddJoueursService.lire_niveau_joueur():
		SauvegardeBddJoueursService.modifier_niveau_joueur(niveau_inferieur)
	progression_ascension.emit() # Pour mise à jour des bandeaux d'infos
	afficher_niveau_plateau_parties()

func initialiser_une_nouvelle_ascension(pourcentage_longueur : float):
		var nb_niveaux = roundi(pourcentage_longueur / 100. * SauvegardeBddJoueursService.lire_nombre_de_niveaux_realisables())
		var niveau_min = retourner_le_niveau_le_plus_bas()
		var niveau_max = retourner_le_niveau_nieme(nb_niveaux)
		SauvegardeBddJoueursService.initialiser_une_nouvelle_ascension(niveau_min, niveau_max)

func afficher_niveau_plateau_parties():
	print("[Campagne] Niveau = ", str(SauvegardeBddJoueursService.lire_niveau_joueur()),
	 " - Plateau = '", str(SauvegardeBddJoueursService.lire_nom_plateau()).replace(' ', '-'), "'",
	 " - Pourcentage ascension = ", str(SauvegardeBddJoueursService.lire_pourcentage_ascension_realise()),"%")

# Traitement de niveau
######################

func retourner_le_niveau_le_plus_bas() -> int:
	# Retourner le plus bas niveau réalisable
	for niveau_le_plus_bas in range(0, 300):
		# Vérifier qu'il reste des plateaux à réaliser par le joueur
		if not SauvegardeBddJoueursService.le_niveau_est_termine(niveau_le_plus_bas):
			return niveau_le_plus_bas
	return -1

# TODO : Cette methode est inutilisée
func retourner_le_niveau_le_plus_haut() -> int:
	# Retourner le plus haut niveau réalisable
	for niveau_le_plus_haut in range(300, -1, -1):
		# Vérifier qu'il reste des plateaux à réaliser par le joueur
		if not SauvegardeBddJoueursService.le_niveau_est_termine(niveau_le_plus_haut):
			return niveau_le_plus_haut
	return -1

func retourner_le_niveau_nieme(nb_niveaux : int) -> int:
	var niveau = -1
	for niveau_le_plus_bas in range(0, 300):
		# Vérifier qu'il reste des plateaux à réaliser par le joueur
		if not SauvegardeBddJoueursService.le_niveau_est_termine(niveau_le_plus_bas):
			nb_niveaux -= 1
			niveau = niveau_le_plus_bas
			if not nb_niveaux:
				break
	return niveau

func retourner_le_niveau_superieur() -> int:
	# Parcourir les niveaux supérieurs
	var niveau_max = SauvegardeBddJoueursService.lire_niveau_fin_ascension()
	for niveau_superieur in range(SauvegardeBddJoueursService.lire_niveau_joueur()+1, niveau_max+1):
		# Vérifier qu'il reste des plateaux à réaliser par le joueur
		if not SauvegardeBddJoueursService.le_niveau_est_termine(niveau_superieur):
			return niveau_superieur
	return SauvegardeBddJoueursService.lire_niveau_joueur()

func retourner_le_niveau_inferieur() -> int:
	# Parcourir les niveaux supérieurs
	var niveau_min = SauvegardeBddJoueursService.lire_niveau_debut_ascension()
	for niveau_inferieur in range(SauvegardeBddJoueursService.lire_niveau_joueur()-1, niveau_min-1, -1):
		# Vérifier qu'il reste des plateaux à réaliser par le joueur
		if not SauvegardeBddJoueursService.le_niveau_est_termine(niveau_inferieur):
			return niveau_inferieur
	return SauvegardeBddJoueursService.lire_niveau_joueur()
