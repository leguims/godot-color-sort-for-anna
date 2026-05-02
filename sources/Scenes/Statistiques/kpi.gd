extends Control

func _ready():
	clip_contents = true
	$VBox/Label_Title.text = "Titre"
	$VBox/Label_Value.text = str("Valeur")

func set_title(title: String):
	$VBox/Label_Title.text = title

func set_value(v):
	$VBox/Label_Value.text = str(v)

func set_color(texte : Color , fond : Color):
	$VBox/Label_Title.add_theme_color_override("font_color", texte)
	$VBox/Label_Value.add_theme_color_override("font_color", texte)
	$Fond.color = fond

func set_minimum_size(new_size: Vector2):
	set_custom_minimum_size(new_size) 
	$Fond.set_custom_minimum_size(new_size) 
	$VBox.set_custom_minimum_size(new_size) 
