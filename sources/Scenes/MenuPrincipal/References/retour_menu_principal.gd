extends Control

func _ready() -> void:
	set_process_input(true)
	_capturer_si_demande()

func _input(event: InputEvent) -> void:
	# Comportement historique conservé : un clic hors contrôle retourne aussi au menu.
	if event is InputEventMouseButton and event.pressed:
		_retour()

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
