extends Node

class_name QuiPerdGagne

signal plateau_invalide
signal abandon
signal victoire

func _ready() -> void:
	# Connecter la callback de gameplay au "Plateau"
	$Plateau.enregistrer_callback_est_termine(Callable(self, "est_termine"))

	# Initialiser le menu
	$MenuPlateau.enregistrer_gameplay("Qui Perd\nGagne")
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
	# Condition de victoire : plateau bloqué + 1 pile non terminée
	# Vérifier si la partie est achevée

	# Impossible de joueur
	var plateau_bloque = false
	plateau_bloque = $Plateau.est_bloque()
	
	# Une pile non terminée
	var une_pile_en_desordre = false
	for pile in liste_piles:
		# Vérifier qu'une piles qui n'est pas vides n'est pas terminée.
		if not pile.est_vide() and not pile.est_termine():
			une_pile_en_desordre = true
			break

	var termine = plateau_bloque and une_pile_en_desordre
	if termine:
		LogService.log_debug("QuiPerdGagne : victoire.emit()")
		$MenuPlateau/Top/BoutonAbandonner.hide()
		$MenuPlateau.arreter_chronometre()
		victoire.emit()
	return termine

# Relais de signaux vers la campagne
func _on_plateau_plateau_invalide() -> void:
	plateau_invalide.emit()

func _on_menu_plateau_abandon() -> void:
	abandon.emit()
