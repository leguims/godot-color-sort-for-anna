extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process_input(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file("res://Scenes/MenuPrincipal/menu_principal.tscn")
