extends Control

@export var title := "Titre"
@export var value := "0"
@export var _size := Vector2(140, 50)

func _ready():
	clip_contents = true
	$VBox/Label_Title.text = title
	$VBox/Label_Value.text = str(value)

func set_value(v):
	$VBox/Label_Value.text = str(v)

func set_color(texte : Color , fond : Color):
	$VBox/Label_Title.add_theme_color_override("font_color", texte)
	$VBox/Label_Value.add_theme_color_override("font_color", texte)
	$Fond.color = fond

func set_minimum_size(new_size: Vector2):
	_size = new_size
	set_custom_minimum_size(_size) 
	$Fond.set_custom_minimum_size(_size) 
	$VBox.set_custom_minimum_size(_size) 
