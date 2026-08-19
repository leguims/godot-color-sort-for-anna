extends Node

signal progression_DIFFICULTE
signal detail_score_plateau(detail_score : Dictionary)
signal fin_DIFFICULTE
# TODO : signal fin_campagne

####################################
# Gestion de données transverses Campagne
####################################
func la_campagne_est_terminee_pour_joueur(nom_joueur : String) -> bool:
	var succes: bool = _choisir_et_corriger_le_joueur(nom_joueur)
	if succes:
		return SauvegardeBddJoueursService.la_campagne_est_terminee()
	return false

func choisir_le_joueur_pour_la_campagne(nom_joueur : String) -> bool:
	# Choisir le joueur pour la campagne
	return _choisir_et_corriger_le_joueur(nom_joueur)

func _choisir_et_corriger_le_joueur(nom_joueur : String) -> bool:
	# Charge le joueur et l'efface de la liste en cas de probleme.
	if SauvegardeListeJoueursService.le_joueur_existe(nom_joueur):
		# Choisir le joueur pour la campagne
		var nom_fichier = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(nom_joueur)
		var succes: bool =  SauvegardeBddJoueursService.choisir_le_joueur(nom_joueur, nom_fichier)
		if not succes:
			LogService.log_erreur("Erreur : Impossible de charger le joueur *" + nom_joueur + "*. L'effacer de la liste des joueurs.")
			SauvegardeListeJoueursService.supprimer_un_joueur_orphelin_de_sauvegarde(nom_joueur, nom_fichier)
		return succes
	return false

func liberer_le_joueur_pour_la_campagne():
	SauvegardeBddJoueursService.liberer_le_joueur()

func ajouter_un_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur : String) -> bool:
	return not SauvegardeListeJoueursService.le_joueur_existe(nom_nouveau_joueur)

func initialiser_le_nouveau_joueur_pour_la_campagne(nom_nouveau_joueur : String) -> bool:
	if not SauvegardeListeJoueursService.le_joueur_existe(nom_nouveau_joueur):
		# Ajouter le joueur dans la liste des joueurs
		if SauvegardeListeJoueursService.ajouter_un_nouveau_joueur(nom_nouveau_joueur):
			var nom_fichier = SauvegardeListeJoueursService.retourner_le_fichier_de_sauvegarde(nom_nouveau_joueur)
			# Ajouter la sauvegarde personnelle du joueur
			if SauvegardeBddJoueursService.ajouter_un_nouveau_joueur(nom_nouveau_joueur, nom_fichier):
				# Ajouter le joueur dans le tableau des scores
				return SauvegardeTableauDesScoresService.ajouter_un_nouveau_joueur(nom_nouveau_joueur)
	return false

####################################
# Gestion des mécaniques de jeu
####################################

# Evenements de jeu du plateau
##############################

func DIFFICULTE_en_cours() -> bool:
	return SauvegardeBddJoueursService.DIFFICULTE_en_cours()

func la_campagne_est_terminee() -> bool:
	return SauvegardeBddJoueursService.la_campagne_est_terminee()

func commencer_un_plateau(pourcentage_longueur : float) -> void:
	if not SauvegardeBddJoueursService.DIFFICULTE_en_cours():
		initialiser_un_nouveau_DIFFICULTE(pourcentage_longueur)
	if SauvegardeBddJoueursService.plateau_en_cours():
		# Si un plateau était en cours, mais pas terminé, le considérer abandonné
		abandonner_un_plateau()

	# Ajouter le nouveau plateau et incrémenter le compteur de parties du DIFFICULTE courant
	SauvegardeBddJoueursService.commencer_un_plateau()
	LogService.log_debug("Nombre de parties = ", SauvegardeBddJoueursService.lire_nombre_de_parties_joueur_pour_DIFFICULTE_courant())

func gagner_un_plateau(duree_en_ms : int) -> void:
	# Valider le plateau courant (effacer de la liste des plateaux jouables)
	SauvegardeBddJoueursService.gagner_un_plateau(duree_en_ms)

	# Calculer le score du plateau et l'enregistrer dans l'historique de Le DIFFICULTE
	var detail_score = ScoreService.mettre_a_jour_score_pour_victoire(duree_en_ms)
	detail_score_plateau.emit(detail_score)

	# Emmettre un signal de mise à jour du DIFFICULTE
	progression_DIFFICULTE.emit() # Pour mise à jour des bandeaux d'infos
	afficher_DIFFICULTE_plateau_parties()

func abandonner_un_plateau() -> void:
	# En cas d'abandon, pas d'enrgistrement du temps.
	SauvegardeBddJoueursService.abandonner_un_plateau()
	# On reste sur le même plateau
	# La campagne et le DIFFICULTES sont inchangés

func initialiser_un_nouveau_DIFFICULTE(pourcentage_longueur : float):
		# TODO : supprimer les notions de pourcentage pour le demarrage du DIFFICULTE
		# TODO : gerer le choix du DIFFICULTE de campagne
		SauvegardeBddJoueursService.initialiser_un_nouveau_DIFFICULTE(2)

func afficher_DIFFICULTE_plateau_parties():
	LogService.log_debug("[Campagne] DIFFICULTE = ", str(SauvegardeBddJoueursService.lire_DIFFICULTE_joueur()),
	 " - Plateau = '", str(SauvegardeBddJoueursService.lire_nom_plateau()).replace(' ', '-'), "'",
	 " - Pourcentage DIFFICULTE = ", str(SauvegardeBddJoueursService.lire_pourcentage_DIFFICULTE_realise()),"%")

# Traitement de DIFFICULTE
######################

func retourner_le_DIFFICULTE_le_plus_bas() -> int:
	# Retourner le plus bas DIFFICULTE réalisable
	for DIFFICULTE_le_plus_bas in range(0, 300):
		# Vérifier qu'il reste des plateaux à réaliser par le joueur
		if not SauvegardeBddJoueursService.le_DIFFICULTE_est_termine(DIFFICULTE_le_plus_bas):
			return DIFFICULTE_le_plus_bas
	return -1

# TODO : Cette methode est inutilisée
func retourner_le_DIFFICULTE_le_plus_haut() -> int:
	# Retourner le plus haut DIFFICULTE réalisable
	for DIFFICULTE_le_plus_haut in range(300, -1, -1):
		# Vérifier qu'il reste des plateaux à réaliser par le joueur
		if not SauvegardeBddJoueursService.le_DIFFICULTE_est_termine(DIFFICULTE_le_plus_haut):
			return DIFFICULTE_le_plus_haut
	return -1

func retourner_le_DIFFICULTE_nieme(nb_DIFFICULTES : int) -> int:
	var DIFFICULTE = -1
	for DIFFICULTE_le_plus_bas in range(0, 300):
		# Vérifier qu'il reste des plateaux à réaliser par le joueur
		if not SauvegardeBddJoueursService.le_DIFFICULTE_est_termine(DIFFICULTE_le_plus_bas):
			nb_DIFFICULTES -= 1
			DIFFICULTE = DIFFICULTE_le_plus_bas
			if not nb_DIFFICULTES:
				break
	return DIFFICULTE

func retourner_le_DIFFICULTE_suivant() -> int:
	# Parcourir le DIFFICULTE supérieur
	return retourner_le_DIFFICULTE_le_plus_bas()

