extends Node

class_name QuiPerdGagne

signal victoire
signal abandon
signal plateau_invalide

func _ready() -> void:
	# Connecter la callback de gameplay au "Plateau"
	$Plateau.enregistrer_callback_est_termine(Callable(self, "est_termine"))
	$Plateau.enregistrer_gameplay("Qui Perd\nGagne")
	$Plateau.enregistrer_chrono("03:51")
	$Plateau.enregistrer_coups("0 Coups")

# API pour "Campagne"
func est_valide(plateau_texte : String) -> bool:
	return $Plateau.est_valide(plateau_texte)

func commencer_un_nouveau_plateau(plateau_texte : String) -> void:
	$Plateau.commencer_un_nouveau_plateau(plateau_texte)

func show():
	$Plateau.show()

func hide():
	$Plateau.hide()

func cacher_accueil():
	$Plateau.cacher_accueil()

# Signaux de "Plateau" relayé à "Campagne"
func _on_plateau_plateau_invalide() -> void:
	print("QuiPerdGagne : plateau_invalide.emit()")
	plateau_invalide.emit()

func _on_plateau_abandon() -> void:
	print("QuiPerdGagne : abandon.emit()")
	abandon.emit()

# Callback pour "Plateau"
func est_termine(liste_piles) -> bool:
	# Vérifier si la partie est achevée
	var termine = true
	# TODO : detecter la configuration bloquée !
	for pile in liste_piles:
		# Vérifier que les piles qui ne sont pas vides sont terminées.
		if not pile.est_vide() and not pile.est_termine():
			termine = false
			break
	if termine:
		print("QuiPerdGagne : victoire.emit()")
		victoire.emit()
	return termine
