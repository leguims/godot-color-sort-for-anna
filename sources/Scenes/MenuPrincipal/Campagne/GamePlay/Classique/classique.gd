extends BaseClassiqueQuiPerdGagne

class_name Classique

func _ready() -> void:
	super._ready()

	# Initialiser le menu
	$MenuPlateau.enregistrer_gameplay("CLASSIQUE")
	$MenuPlateau.enregistrer_sous_titre_gameplay("Range tes couleurs")

	var nom = SauvegardeBddJoueursService.lire_nom_joueur()

	var niveau_courant : int = 0
	if SauvegardeBddJoueursService.enregistrement_niveau_existe():
		niveau_courant = SauvegardeBddJoueursService.enregistrement_lire_valeur_niveau_joueur()
	else:
		niveau_courant = SauvegardeBddJoueursService.lire_prochain_niveau_de_campagne()

	var pourcentage_niveau_realise = StatsService.niveau_taux_completion() * 100.

	$MenuPlateau.enregistrer_joueur(nom)
	$MenuPlateau.enregistrer_niveau("NIVEAU "+String.num_int64(niveau_courant))
	$MenuPlateau.enregistrer_pourcentage(String.num_int64(pourcentage_niveau_realise)+'%')

# Callback pour "Plateau"
func est_termine(liste_piles) -> bool:
	# Vérifier si la partie est achevée
	var termine = true
	for pile in liste_piles:
		# Vérifier que les piles qui ne sont pas vides sont terminées.
		if not pile.est_vide() and not pile.est_termine():
			termine = false
			break
	if termine:
		LogService.log_debug("Classique : victoire.emit()")
		show_fond()
		victoire.emit()
	return termine
