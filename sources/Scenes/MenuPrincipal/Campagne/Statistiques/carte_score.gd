extends Control

func medaille(nom : String) -> void:
	if nom.to_lower() == 'bronze':
		$GradeIdentite/Medaille.texture = load('res://Art/UI/icons/grades/medaille_bronze_60.png')
	if nom.to_lower() == 'argent':
		$GradeIdentite/Medaille.texture = load('res://Art/UI/icons/grades/medaille_argent_60.png')
	if nom.to_lower() == 'or':
		$GradeIdentite/Medaille.texture = load('res://Art/UI/icons/grades/medaille_or_60.png')
	if nom.to_lower() == 'diamant':
		$GradeIdentite/Medaille.texture = load('res://Art/UI/icons/grades/medaille_diamant_60.png')

func nom_grade(nom : String) -> void:
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
