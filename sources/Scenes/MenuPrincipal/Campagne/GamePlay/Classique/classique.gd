extends Node

class_name Classique

signal plateau_invalide
signal abandon
signal victoire

func _ready() -> void:
	# Connecter la callback de gameplay au "Plateau"
	$Plateau.enregistrer_callback_est_termine(Callable(self, "est_termine"))

	# Initialiser le menu
	$MenuPlateau.enregistrer_gameplay("Classique")
	$MenuPlateau.enregistrer_chrono("03:51")
	$MenuPlateau.enregistrer_coups("0 Coups")

	# Transmettre les infos de l'UI à Plateau
	$Plateau.enregistrer_bouton_abandonner_size_y($MenuPlateau/Top/BoutonAbandonner.size.y)

# API pour "Campagne"
func est_valide(plateau_texte : String) -> bool:
	return $Plateau.est_valide(plateau_texte)

func commencer_un_nouveau_plateau(plateau_texte : String) -> void:
	$Plateau.commencer_un_nouveau_plateau(plateau_texte)
	$MenuPlateau.demarrer_chronometre()
	show()

func show():
	$MenuPlateau.show()

func hide():
	$MenuPlateau.hide()

func cacher_accueil():
	$MenuPlateau.cacher_accueil()

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
		$MenuPlateau/Top/BoutonAbandonner.hide()
		$MenuPlateau.arreter_chronometre()
		victoire.emit()
	return termine

# Relais de signaux vers la campagne
func _on_plateau_plateau_invalide() -> void:
	plateau_invalide.emit()

func _on_menu_plateau_abandon() -> void:
	abandon.emit()
