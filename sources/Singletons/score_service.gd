extends Node

func mettre_a_jour_score_pour_victoire(duree_en_ms : int) -> Dictionary:
	"Calculer le score suite à une victoire (duree, ratio réussites, ascension, campagne)"
	var score_duree = mettre_a_jour_score_duree(duree_en_ms)
	var score_ratio_reussite = mettre_a_jour_score_ratio_reussite()
	var score_ascension = mettre_a_jour_score_ascension()
	var score_ascension_sans_detour = mettre_a_jour_score_ascension_sans_detour()
	var score_campagne = mettre_a_jour_score_campagne()

	var score_global = {
					'duree': score_duree,
					'ratio_reussite': score_ratio_reussite,
					'ascension': score_ascension,
					'ascension_sans_detour': score_ascension_sans_detour,
					'campagne': score_campagne
					}

	bonus_score_anna_damour(score_global)
	return score_global

func mettre_a_jour_score_duree(duree_en_ms : int) -> Dictionary:
	"Calculer le score relatif au temps"
	var temps_reference_par_niveau = {
		25 : 10.,
		50 : 15.,
		60 : 20.,
		100 : 25.,
		125 : 40.
		}

	var niveau = SauvegardeBddJoueursService.lire_niveau_joueur()
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
		LogService.log_erreur("Erreur : Niveau inattendu pour le score !")

	var bonus_duree = 0
	var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var duree_en_s = duree_en_ms / 1000.
	# Score sur le ratio du temps référence/joué
	var ratio_temps = temps_reference_en_s / duree_en_s
	bonus_duree = roundi(100 * niveau * ratio_temps)
	SauvegardeBddJoueursService.modifier_score_duree_plateau(bonus_duree)
	SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_duree)
	return {'type':'duree', 'reference': temps_reference_en_s, 'realise': duree_en_s, 'points': bonus_duree}

func mettre_a_jour_score_ratio_reussite() -> Dictionary:
	"Calculer le score relatif au temps"
	var bonus_ratio_reussite = 0
	var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var niveau = SauvegardeBddJoueursService.lire_niveau_joueur()
	var int_ratio_reussite = SauvegardeBddJoueursService.lire_ratio_reussite_ascension()
	var ratio_reussite = SauvegardeBddJoueursService.lire_ratio_reussite_ascension() / 100.
	bonus_ratio_reussite = roundi(100 * niveau * ratio_reussite)
	SauvegardeBddJoueursService.modifier_score_ratio_reussite_plateau(bonus_ratio_reussite)
	SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_ratio_reussite)
	return {'type':'ratio_reussite', 'ratio': int_ratio_reussite, 'points': bonus_ratio_reussite}

func mettre_a_jour_score_ascension() -> Dictionary:
	"Calculer le score suite à une ascension achevée"
	var bonus_ascension = 0
	var niveau_ascension_longueur_totale = 0
	if not SauvegardeBddJoueursService.ascension_en_cours():
		var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
		niveau_ascension_longueur_totale = SauvegardeBddJoueursService.lire_niveau_ascension_longueur_totale()
		# bonus = 100 x Dénivelé ^2 (bonus non linéaire)
		bonus_ascension = roundi(50 * pow(niveau_ascension_longueur_totale, 2))
		SauvegardeBddJoueursService.modifier_score_ascension(bonus_ascension)
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_ascension)
		return {'type':'ascension', 'longueur': niveau_ascension_longueur_totale, 'points': bonus_ascension}
	return{}

func mettre_a_jour_score_ascension_sans_detour() -> Dictionary:
	"Calculer le score suite à une ascension parfaite achevée"
	var bonus_ascension_sans_detour = 0
	if not SauvegardeBddJoueursService.ascension_en_cours() \
		and SauvegardeBddJoueursService.lire_longueur_detour_ascension() == 0:
		var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
		bonus_ascension_sans_detour = SauvegardeBddJoueursService.lire_score_ascension()
		SauvegardeBddJoueursService.modifier_score_ascension_sans_detour(bonus_ascension_sans_detour)
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_ascension_sans_detour)
		return {'type':'ascension_sans_detour', 'bonus': 'x2', 'points': bonus_ascension_sans_detour}
	return{}

func mettre_a_jour_score_campagne() -> Dictionary:
	"Calculer le score suite à la campagne achevée"
	var bonus_campagne = 0
	if SauvegardeBddJoueursService.la_campagne_est_terminee():
		var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
		bonus_campagne = 2_000_000
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_campagne)
		return {'type':'campagne', 'points': bonus_campagne}
	return {}

func bonus_score_anna_damour(score_global : Dictionary) -> void:
	"Bonus spécifique pour Anna d'Amour, la déesse de ce jeu."
	var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	if nom_joueur.to_lower() == 'Anna'.to_lower():
		var score_total = 0
		for score in score_global.values():
			score_total += score.get('points', 0)
		var bonus_anna = score_total * 3
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_anna)
