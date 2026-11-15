extends Control

func medaille(nom : String) -> void:
	_couleur_fond(Color('fcebda'))
	_couleur_lisere(Color('efc49f'))
	_couleur_texte_sombre(Color('102b50'))
	_couleur_texte_clair(Color('df8000'))
	_image_laurier('res://Art/UI/Statistiques/laurier_score_gauche.png')
	if nom.to_lower() == 'bronze':
		_image_grade('res://Art/UI/icons/grades/medaille_bronze_60.png')
		_nom_grade(nom)
		_couleur_fond(Color('f5dfbd'))
		_couleur_lisere(Color('b57645'))
		_couleur_texte_sombre(Color('24463a'))
		_couleur_texte_clair(Color('76513b'))
		_image_laurier('res://Art/UI/Statistiques/laurier_score_gauche_bronze.png')
	if nom.to_lower() == 'argent':
		_image_grade('res://Art/UI/icons/grades/medaille_argent_60.png')
		_nom_grade(nom)
		_couleur_fond(Color('eaf2f7'))
		_couleur_lisere(Color('9fb2c0'))
		_couleur_texte_sombre(Color('243848'))
		_couleur_texte_clair(Color('596e7e'))
		_image_laurier('res://Art/UI/Statistiques/laurier_score_gauche_argent.png')
	if nom.to_lower() == 'or':
		_image_grade('res://Art/UI/icons/grades/medaille_or_60.png')
		_nom_grade(nom)
		_couleur_fond(Color('e0b865'))
		_couleur_lisere(Color('ad7e47'))
		_couleur_texte_sombre(Color('39212d'))
		_couleur_texte_clair(Color('532118'))
		_image_laurier('res://Art/UI/Statistiques/laurier_score_gauche_or.png')
	if nom.to_lower() == 'diamant':
		_image_grade('res://Art/UI/icons/grades/medaille_diamant_60.png')
		_nom_grade(nom)
		_couleur_fond(Color('eff4fe'))
		_couleur_lisere(Color('4c78a2'))
		_couleur_texte_sombre(Color('2f5478'))
		_couleur_texte_clair(Color('437db6'))
		_image_laurier('res://Art/UI/Statistiques/laurier_score_gauche_diamant.png')

func _couleur_fond(couleur : Color) -> void:
	$Fond.get("theme_override_styles/panel").bg_color = couleur
	$Rapidite/Fond.get("theme_override_styles/panel").bg_color = couleur
	$Reussite/Fond.get("theme_override_styles/panel").bg_color = couleur
	$Niveau/Fond.get("theme_override_styles/panel").bg_color = couleur
	$Parfait/Fond.get("theme_override_styles/panel").bg_color = couleur
	$Campagne/Fond.get("theme_override_styles/panel").bg_color = couleur

func _couleur_lisere(couleur : Color) -> void:
	$Fond.get("theme_override_styles/panel").border_color = couleur
	$GradeIdentite/Separateur/Line.color = couleur
	$Separateur.color = couleur
	$Rapidite/Fond.get("theme_override_styles/panel").border_color = couleur
	$Reussite/Fond.get("theme_override_styles/panel").border_color = couleur
	$Niveau/Fond.get("theme_override_styles/panel").border_color = couleur
	$Parfait/Fond.get("theme_override_styles/panel").border_color = couleur
	$Campagne/Fond.get("theme_override_styles/panel").border_color = couleur

func _couleur_texte_sombre(couleur : Color) -> void:
	$GradeIdentite/NomGrade.add_theme_color_override("font_color", couleur)
	$GradeIdentite/PlayerName.add_theme_color_override("font_color", couleur)
	$Rapidite/Titre.add_theme_color_override("font_color", couleur)
	$Reussite/Titre.add_theme_color_override("font_color", couleur)
	$Niveau/Titre.add_theme_color_override("font_color", couleur)
	$Parfait/Titre.add_theme_color_override("font_color", couleur)
	$Campagne/Titre.add_theme_color_override("font_color", couleur)

func _couleur_texte_clair(couleur : Color) -> void:
	$Score/Valeur.add_theme_color_override("font_color", couleur)
	$RepartitionDesPoints.add_theme_color_override("font_color", couleur)
	$Rapidite/Valeur.add_theme_color_override("font_color", couleur)
	$Reussite/Valeur.add_theme_color_override("font_color", couleur)
	$Niveau/Valeur.add_theme_color_override("font_color", couleur)
	$Parfait/Valeur.add_theme_color_override("font_color", couleur)
	$Campagne/Valeur.add_theme_color_override("font_color", couleur)

func _image_laurier(nom : String) -> void:
	$Score/LaurierGauche.texture = load(nom)
	$Score/LaurierDroit.texture = load(nom)

func _image_grade(nom : String) -> void:
	$GradeIdentite/Medaille.texture = load(nom)

func _nom_grade(nom : String) -> void:
	$GradeIdentite/NomGrade.text = nom.to_lower().capitalize()

func nom_joueur(nom : String) -> void:
	$GradeIdentite/PlayerName.text = nom

func score(valeur : String) -> void:
	$Score/Valeur.text = valeur

func rapidite(valeur : String) -> void:
	$Rapidite/Valeur.text = valeur

func reussite(valeur : String) -> void:
	$Reussite/Valeur.text = valeur

func niveau(valeur : String) -> void:
	$Niveau/Valeur.text = valeur

func parfait(valeur : String) -> void:
	$Parfait/Valeur.text = valeur

func campagne(valeur : String) -> void:
	$Campagne/Valeur.text = valeur
