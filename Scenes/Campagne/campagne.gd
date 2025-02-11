extends Node

class_name Campagne

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Menu.set_script(MenuCampagne)
	$Menu.modifier_tempo_message(1.0)
	$Menu.modifier_message_vertical_align(VERTICAL_ALIGNMENT_CENTER)
	$Menu.show()
	$Menu.afficher_accueil()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_menu_commencer_plateau() -> void:
	GestionScore.commencer()
	_lancer_plateau_de_campagne($Menu/EditeurPlateau/SaisieEditionPlateau.text)

func _lancer_plateau_de_campagne(plateau : String) -> void:
	if $PlateauDeJeu.est_valide(plateau):
		$Menu.cacher_accueil()
		$PlateauDeJeu.effacer_le_plateau()
		$PlateauDeJeu.commencer_un_nouveau_plateau(plateau)
		$SonCommencer.play()
		$Musique.play()
	else:
		_on_plateau_de_jeu_plateau_invalide()

func _on_plateau_de_jeu_victoire() -> void:
	GestionScore.gagner()
	$Menu.show()
	if GestionScore.est_victoire_dernier_plateau():
		$Menu.afficher_fin_campagne()
	else:
		$Menu.afficher_victoire()
	$SonFinDePartie.play()
	$Musique.stop()

func _on_plateau_de_jeu_plateau_invalide() -> void:
	# Pas de plateau invalide en campagne
	print("_on_plateau_de_jeu_plateau_invalide pour la campagne IMPOSSIBLE ! WTF !")
	pass

func _on_plateau_de_jeu_abandon() -> void:
	$Menu.show()
	$Menu.afficher_abandon()
	$SonEchec.play()
	$Musique.stop()
