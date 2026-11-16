extends Control

func medaille(nom : String) -> void:
	_couleur_fond(Color('fcebda'))
	_couleur_fond_sombre(Color('faebd7'))
	_couleur_lisere(Color('efc49f'))
	_couleur_texte_sombre(Color('102b50'))
	if nom.to_lower() == 'bronze':
		_couleur_fond(Color('f5dfbd'))
		_couleur_fond_sombre(Color('f7dfb8'))
		_couleur_lisere(Color('b57645'))
		_couleur_texte_sombre(Color('24463a'))
	if nom.to_lower() == 'argent':
		_couleur_fond(Color('eaf2f7'))
		_couleur_fond_sombre(Color('e0f2fc'))
		_couleur_lisere(Color('9fb2c0'))
		_couleur_texte_sombre(Color('243848'))
	if nom.to_lower() == 'or':
		_couleur_fond(Color('e0b865'))
		_couleur_fond_sombre(Color('e6b85a'))
		_couleur_lisere(Color('ad7e47'))
		_couleur_texte_sombre(Color('39212d'))
	if nom.to_lower() == 'diamant':
		_couleur_fond(Color('eff4fe'))
		_couleur_fond_sombre(Color('eaf0fe'))
		_couleur_lisere(Color('4c78a2'))
		_couleur_texte_sombre(Color('2f5478'))

func _couleur_fond(couleur : Color) -> void:
	$Fond.get("theme_override_styles/panel").bg_color = couleur

func _couleur_fond_sombre(couleur : Color) -> void:
	$EnCours.get("theme_override_styles/panel").bg_color = couleur
	$Completion.get("theme_override_styles/panel").bg_color = couleur

func _couleur_lisere(couleur : Color) -> void:
	$Fond.get("theme_override_styles/panel").border_color = couleur
	$EnCours.get("theme_override_styles/panel").border_color = couleur
	$Completion.get("theme_override_styles/panel").border_color = couleur
	$Tableau/Interligne1.color = couleur
	$Tableau/Interligne2.color = couleur

func _couleur_texte_sombre(couleur : Color) -> void:
	$EnCours/Titre.add_theme_color_override("font_color", couleur)
	$Completion/Titre.add_theme_color_override("font_color", couleur)
	$Tableau/Entete/col1.add_theme_color_override("font_color", couleur)
	$Tableau/Entete/col2.add_theme_color_override("font_color", couleur)
	$Tableau/Entete/col3.add_theme_color_override("font_color", couleur)
	$Tableau/ReussiteMinimum/Titre.add_theme_color_override("font_color", couleur)
	$Tableau/ReussiteMaximum/Titre.add_theme_color_override("font_color", couleur)

func en_cours(valeur : String) -> void:
	$EnCours/Valeur.text = valeur

func completion(valeur : String) -> void:
	$Completion/Valeur.text = valeur

func taux_reussite_minimum(valeur : String) -> void:
	$Tableau/ReussiteMinimum/Pourcent.text = valeur

func difficulte_reussite_minimum(valeur : String) -> void:
	$Tableau/ReussiteMinimum/Difficulte.text = valeur

func taux_reussite_maximum(valeur : String) -> void:
	$Tableau/ReussiteMaximum/Pourcent.text = valeur

func difficulte_reussite_maximum(valeur : String) -> void:
	$Tableau/ReussiteMaximum/Difficulte.text = valeur
