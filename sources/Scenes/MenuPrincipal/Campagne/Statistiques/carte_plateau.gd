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
	$Nombre.get("theme_override_styles/panel").bg_color = couleur
	$Essais.get("theme_override_styles/panel").bg_color = couleur
	$TempsMoyen.get("theme_override_styles/panel").bg_color = couleur
	$Reussite.get("theme_override_styles/panel").bg_color = couleur

func _couleur_lisere(couleur : Color) -> void:
	$Fond.get("theme_override_styles/panel").border_color = couleur
	$Nombre.get("theme_override_styles/panel").border_color = couleur
	$Essais.get("theme_override_styles/panel").border_color = couleur
	$TempsMoyen.get("theme_override_styles/panel").border_color = couleur
	$Reussite.get("theme_override_styles/panel").border_color = couleur
	$Tableau/Interligne1.color = couleur
	$Tableau/Interligne2.color = couleur
	$Tableau/Interligne3.color = couleur

func _couleur_texte_sombre(couleur : Color) -> void:
	$Nombre/Titre.add_theme_color_override("font_color", couleur)
	$Essais/Titre.add_theme_color_override("font_color", couleur)
	$TempsMoyen/Titre.add_theme_color_override("font_color", couleur)
	$Reussite/Titre.add_theme_color_override("font_color", couleur)
	$Tableau/Entete/col1.add_theme_color_override("font_color", couleur)
	$Tableau/Entete/col2.add_theme_color_override("font_color", couleur)
	$Tableau/Entete/col3.add_theme_color_override("font_color", couleur)
	$Tableau/PlusRapide/Titre.add_theme_color_override("font_color", couleur)
	$Tableau/PlusLent/Titre.add_theme_color_override("font_color", couleur)
	$Tableau/PlusGalere/Titre.add_theme_color_override("font_color", couleur)

func nb_plateaux(valeur : String) -> void:
	$Nombre/Valeur.text = valeur

func nb_essais(valeur : String) -> void:
	$Essais/Valeur.text = valeur

func temps_moyen(valeur : String) -> void:
	$TempsMoyen/Valeur.text = valeur

func taux_reussite(valeur : String) -> void:
	$Reussite/Valeur.text = valeur

func plus_rapide_temps(valeur : String) -> void:
	$Tableau/PlusRapide/Temps.text = valeur

func plus_rapide_niveau(valeur : String) -> void:
	$Tableau/PlusRapide/Niveau.text = valeur

func plus_lent_temps(valeur : String) -> void:
	$Tableau/PlusLent/Temps.text = valeur

func plus_lent_niveau(valeur : String) -> void:
	$Tableau/PlusLent/Niveau.text = valeur

func plus_galere_essais(valeur : String) -> void:
	$Tableau/PlusGalere/Essais.text = valeur

func plus_galere_niveau(valeur : String) -> void:
	$Tableau/PlusGalere/Niveau.text = valeur
