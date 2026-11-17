extends BaseClassiqueQuiPerdGagne

class_name Classique

func _ready() -> void:
	super._ready()

	# Initialiser le menu
	$MenuPlateau.enregistrer_gameplay("CLASSIQUE")
	$MenuPlateau.enregistrer_sous_titre_gameplay("Range tes couleurs")

# Surchargé pour gerer l'affichage de l'aide
func afficher_aide() -> void:
	if SauvegardeBddJoueursService.configuration_montrer_aide_classique():
		SauvegardeBddJoueursService.configuration_desactiver_aide_classique()
		$MenuPlateau.afficher_aide()

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
		show_fond()
		LogService.log_debug("[classique] emission signal : victoire")
		victoire.emit()
	return termine
