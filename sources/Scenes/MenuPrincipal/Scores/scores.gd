extends Control

const TOP_N := 5

func _ready() -> void:
	var classement: Array = SauvegardeTableauDesScoresService.retourner_classement()
	for rang in range(1, TOP_N + 1):
		var nom := "-"
		var score := "-"
		if rang <= classement.size():
			var joueur: Dictionary = classement[rang - 1]
			nom = str(joueur.get("nom", "-"))
			score = str(joueur.get("score_txt", "-"))
		($Habillage.find_child("NomRang%d" % rang, true, false) as Label).text = nom
		($Habillage.find_child("ScoreRang%d" % rang, true, false) as Label).text = score
		if rang >= 3 and nom == "-" and score == "-":
			$Habillage.find_child("MasqueNomRang%d" % rang, true, false).hide()
			$Habillage.find_child("MasqueScoreRang%d" % rang, true, false).hide()
			$Habillage.find_child("NomRang%d" % rang, true, false).hide()
			$Habillage.find_child("ScoreRang%d" % rang, true, false).hide()
	($Habillage.find_child("BoutonRetour", true, false) as Button).pressed.connect(_retour)
	($Habillage.find_child("BoutonContinuer", true, false) as Button).pressed.connect(_retour)
	_capturer_si_demande()

func _retour() -> void:
	AudioService.son_menu_click()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")

func _capturer_si_demande() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			await get_tree().process_frame
			await get_tree().process_frame
			get_viewport().get_texture().get_image().save_png(argument.trim_prefix("--capture="))
			get_tree().quit()
