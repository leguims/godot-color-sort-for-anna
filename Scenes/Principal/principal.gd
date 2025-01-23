extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Menu.show()
	$Menu.afficher_accueil()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_menu_commencer_plateau() -> void:
	if $PlateauDeJeu.est_valide($Menu/EditeurPlateau/SaisieEditionPlateau.text):
		$Menu.cacher_accueil()
		$PlateauDeJeu.effacer_le_plateau()
		$PlateauDeJeu.commencer_un_nouveau_plateau($Menu/EditeurPlateau/SaisieEditionPlateau.text)
		$SonCommencer.play()
		$Musique.play()
	else:
		_on_plateau_de_jeu_plateau_invalide()

func _on_plateau_de_jeu_victoire() -> void:
	$Menu.show()
	$Menu.afficher_victoire()
	$SonFinDePartie.play()
	$Musique.stop()

func _on_plateau_de_jeu_plateau_invalide() -> void:
	$Menu.show()
	$Menu.afficher_plateau_invalide()
	$SonEchec.play()

func _on_plateau_de_jeu_abandon() -> void:
	$Menu.show()
	$Menu.afficher_abandon()
	$SonEchec.play()
	$Musique.stop()
