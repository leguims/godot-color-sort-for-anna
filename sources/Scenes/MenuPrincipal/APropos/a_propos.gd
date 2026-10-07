extends Control

func _ready() -> void:
	_connect_links()

func _connect_links() -> void:
	$PanneauCredits/HBoxContainer/VBox/VBoxCorps/CarteMoteur.meta_clicked_connect(_on_link_clicked)
	$PanneauCredits/HBoxContainer/VBox/VBoxCorps/CarteMusique.meta_clicked_connect(_on_link_clicked)
	$PanneauCredits/HBoxContainer/VBox/VBoxCorps/CarteEffetsSonores.meta_clicked_connect(_on_link_clicked)
	$PanneauCredits/HBoxContainer/VBox/VBoxCorps/CarteDidacticiel.meta_clicked_connect(_on_link_clicked)

func _on_link_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_retour_pressed() -> void:
	AudioService.son_menu_click()
	VibrationService.vibration_click()
	get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")
