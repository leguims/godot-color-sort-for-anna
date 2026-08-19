extends Node

func mettre_a_jour_score_pour_victoire(duree_en_ms : int) -> Dictionary:
	"Calculer le score suite à une victoire (duree, ratio réussites, DIFFICULTE, campagne)"
	var score_duree = mettre_a_jour_score_duree(duree_en_ms)
	var score_ratio_reussite = mettre_a_jour_score_ratio_reussite()
	var score_DIFFICULTE = mettre_a_jour_score_DIFFICULTE()
	var score_DIFFICULTE_sans_detour = mettre_a_jour_score_DIFFICULTE_sans_detour()
	var score_campagne = mettre_a_jour_score_campagne()

	var score_global = {
					'duree': score_duree,
					'ratio_reussite': score_ratio_reussite,
					'DIFFICULTE': score_DIFFICULTE,
					'DIFFICULTE_sans_detour': score_DIFFICULTE_sans_detour,
					'campagne': score_campagne
					}

	bonus_score_anna_damour(score_global)
	return score_global

func mettre_a_jour_score_duree(duree_en_ms : int) -> Dictionary:
	"Calculer le score relatif au temps"
	var temps_reference_par_DIFFICULTE = {
		9 : 9.,
		10 : 12.,
		20 : 14.,
		30 : 16.,
		40 : 18.,
		50 : 20.,
		60 : 25.,
		71 : 30.,
		81 : 60.,
		100 : 120.
		}

	var DIFFICULTE = SauvegardeBddJoueursService.lire_DIFFICULTE_joueur()
	var temps_reference_en_s = temps_reference_par_DIFFICULTE[9]
	if DIFFICULTE <= 9:
		temps_reference_en_s = temps_reference_par_DIFFICULTE[9]
	elif DIFFICULTE <= 10:
		temps_reference_en_s = temps_reference_par_DIFFICULTE[10]
	elif DIFFICULTE <= 20:
		temps_reference_en_s = temps_reference_par_DIFFICULTE[20]
	elif DIFFICULTE <= 30:
		temps_reference_en_s = temps_reference_par_DIFFICULTE[30]
	elif DIFFICULTE <= 40:
		temps_reference_en_s = temps_reference_par_DIFFICULTE[40]
	elif DIFFICULTE <= 50:
		temps_reference_en_s = temps_reference_par_DIFFICULTE[50]
	elif DIFFICULTE <= 60:
		temps_reference_en_s = temps_reference_par_DIFFICULTE[60]
	elif DIFFICULTE <= 71:
		temps_reference_en_s = temps_reference_par_DIFFICULTE[71]
	elif DIFFICULTE <= 81:
		temps_reference_en_s = temps_reference_par_DIFFICULTE[81]
	elif DIFFICULTE <= 100:
		temps_reference_en_s = temps_reference_par_DIFFICULTE[100]
	else :
		LogService.log_erreur("Erreur : DIFFICULTE inattendu pour le score !")

	var bonus_duree = 0
	var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var duree_en_s = duree_en_ms / 1000.
	# Score sur le ratio du temps référence/joué
	var ratio_temps = temps_reference_en_s / duree_en_s
	bonus_duree = roundi(100 * DIFFICULTE * ratio_temps)
	SauvegardeBddJoueursService.modifier_score_duree_plateau(bonus_duree)
	SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_duree)
	return {'type':'duree', 'reference': temps_reference_en_s, 'realise': duree_en_s, 'points': bonus_duree}

func mettre_a_jour_score_ratio_reussite() -> Dictionary:
	"Calculer le score relatif au temps"
	var bonus_ratio_reussite = 0
	var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	var DIFFICULTE = SauvegardeBddJoueursService.lire_DIFFICULTE_joueur()
	var int_ratio_reussite = SauvegardeBddJoueursService.lire_ratio_reussite_DIFFICULTE()
	var ratio_reussite = SauvegardeBddJoueursService.lire_ratio_reussite_DIFFICULTE() / 100.
	bonus_ratio_reussite = roundi(100 * DIFFICULTE * ratio_reussite)
	SauvegardeBddJoueursService.modifier_score_ratio_reussite_plateau(bonus_ratio_reussite)
	SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_ratio_reussite)
	return {'type':'ratio_reussite', 'ratio': int_ratio_reussite, 'points': bonus_ratio_reussite}

func mettre_a_jour_score_DIFFICULTE() -> Dictionary:
	"Calculer le score suite à un DIFFICULTE achevé"
	var bonus_DIFFICULTE = 0
	var DIFFICULTE_longueur_totale = 0
	if not SauvegardeBddJoueursService.DIFFICULTE_en_cours():
		var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
		DIFFICULTE_longueur_totale = SauvegardeBddJoueursService.lire_DIFFICULTE_longueur_initiale()
		# bonus = 100 x Dénivelé ^2 (bonus non linéaire)
		bonus_DIFFICULTE = roundi(50 * pow(DIFFICULTE_longueur_totale, 2))
		SauvegardeBddJoueursService.modifier_score_DIFFICULTE(bonus_DIFFICULTE)
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_DIFFICULTE)
		return {'type':'DIFFICULTE', 'longueur': DIFFICULTE_longueur_totale, 'points': bonus_DIFFICULTE}
	return{}

func mettre_a_jour_score_DIFFICULTE_sans_detour() -> Dictionary:
	"Calculer le score suite à un DIFFICULTE parfaitement achevé (sans détour)"
	var bonus_DIFFICULTE_sans_detour = 0
	if not SauvegardeBddJoueursService.DIFFICULTE_en_cours() \
		and SauvegardeBddJoueursService.lire_longueur_detour_DIFFICULTE() == 0:
		var nom_joueur = SauvegardeBddJoueursService.lire_nom_joueur()
		bonus_DIFFICULTE_sans_detour = SauvegardeBddJoueursService.lire_score_DIFFICULTE()
		SauvegardeBddJoueursService.modifier_score_DIFFICULTE_sans_detour(bonus_DIFFICULTE_sans_detour)
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_DIFFICULTE_sans_detour)
		return {'type':'DIFFICULTE_sans_detour', 'bonus': 'x2', 'points': bonus_DIFFICULTE_sans_detour}
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
	var nom_anna_triche = lire_nom_anna_triche()
	if nom_joueur.to_lower() == nom_anna_triche.to_lower():
		var score_total = 0
		for score in score_global.values():
			score_total += score.get('points', 0)
		var bonus_anna = score_total * 3
		LogService.log_debug("Bonus ", nom_anna_triche, " d'Amour !")
		SauvegardeTableauDesScoresService.incrementer_score_joueur(nom_joueur, bonus_anna)

func nouveau_joueur_est_nom_anna_triche(nom : String) -> bool:
	return nom.to_lower() == 'Anna'.to_lower()

func lire_nom_anna_triche() -> String:
	var nom_anna_triche = String.chr(0x1F5A4) + 'Anna' + String.chr(0x1F9E1)
	if OS.has_feature("web"):
		nom_anna_triche = '*Anna*'
	return nom_anna_triche


