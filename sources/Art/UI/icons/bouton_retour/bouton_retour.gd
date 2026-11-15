extends Control

signal pressed

func medaille(nom : String) -> void:
	_fond(Color('ffffff'))
	_image_fleche('res://Art/UI/icons/bouton_retour/retour.png')
	if nom.to_lower() == 'bronze':
		_fond(Color('f5dfbd'))
		_image_fleche('res://Art/UI/icons/bouton_retour/retour_bronze.png')
	if nom.to_lower() == 'argent':
		_fond(Color('eaf2f7'))
		_image_fleche('res://Art/UI/icons/bouton_retour/retour_argent.png')
	if nom.to_lower() == 'or':
		_fond(Color('e0b865'))
		_image_fleche('res://Art/UI/icons/bouton_retour/retour_or.png')
	if nom.to_lower() == 'diamant':
		_fond(Color('eff4fe'))
		_image_fleche('res://Art/UI/icons/bouton_retour/retour_diamant.png')

func _fond(couleur : Color) -> void:
	$Fond.get("theme_override_styles/panel").bg_color = couleur

func _image_fleche(chemin : String) -> void:
	$Bouton.icon = load(chemin)

func _on_bouton_pressed() -> void:
	pressed.emit()
