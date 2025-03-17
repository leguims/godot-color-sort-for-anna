extends Node

class_name EditerUnPlateau

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Menu.set_script(MenuEditerUnPlateau)
	$Menu.modifier_tempo_message(2.0)
	$Menu.modifier_message_vertical_align(VERTICAL_ALIGNMENT_BOTTOM)
	$Menu.show()
	$Menu.afficher_accueil()

func _on_menu_commencer_plateau() -> void:
	_editer_plateau_texte($Menu/EditeurPlateau/SaisieEditionPlateau.text)

func _on_menu_saisie_plateau(new_text: String) -> void:
	_editer_plateau_texte(new_text)

func _editer_plateau_texte(plateau : String) -> void:
	if $PlateauDeJeu.est_valide(plateau):
		$Menu.cacher_accueil()
		$PlateauDeJeu.effacer_le_plateau()
		$PlateauDeJeu.commencer_un_nouveau_plateau(plateau)
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
