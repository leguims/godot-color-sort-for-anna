extends Control

@export var title := "Titre"
@export var value := "0"

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
