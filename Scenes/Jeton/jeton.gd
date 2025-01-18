extends Node

class_name Jeton

var _jetons = {
	0: ['A', Color('RED')],
	1: ['B', Color('BLUE_VIOLET')],
	2: ['C', Color('FOREST_GREEN')],
	3: ['D', Color('CORAL')],
	4: ['E', Color('SADDLE_BROWN')],
	5: ['F', Color('DEEP_SKY_BLUE')],
	6: ['G', Color('MAGENTA')],
	7: ['H', Color('TOMATO')],
	8: ['I', Color('BLUE')],
	9: ['J', Color('CORNFLOWER_BLUE')], # 'J' est hors cadre !
	10: ['K', Color('VIOLET')],
	11: ['L', Color('TEAL')],
	12: ['M', Color('SLATE_GRAY')],
	13: ['N', Color('SANDY_BROWN')],
	14: ['O', Color('SALMON')],
	Plateau.ESPACE: [' ', Color('DARK_MAGENTA')] # DARK_VIOLET # DARK_MAGENTA # INDIGO # REBECCA_PURPLE # WEB_PURPLE
}

@export var indice_jeton = Plateau.ESPACE
var couleur
var nom
var position_initiale_carre : Vector2 #(0,0)
var position_initiale_nom : Vector2 #(0,-16)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Enregistrer les positions initiales
	position_initiale_carre = $Carre.position
	position_initiale_nom = $Nom.position
	if false:
		choisir_jeton(9)
	while false:
		for i in range(len(_jetons)):
			choisir_jeton(i)
			await get_tree().create_timer(1.0).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func choisir_jeton(indice : int) -> void:
	if indice in _jetons:
		indice_jeton = indice
		nom = _jetons[indice_jeton][0]
		couleur = _jetons[indice_jeton][1]
		$Carre.color = couleur
		$Nom.text = nom
		if nom == 'J':
			# La lettre 'J' sort de son carré
			var font_size = $Nom.get_theme_font_size("font_size")
			$Nom.add_theme_font_size_override("font_size", font_size - 2)
			position_initiale_nom.y -= 3

func choisir_position(position : Vector2) -> void:
	$Carre.set_position(position_initiale_carre + position)
	# print("choisir_position : $Carre.position = ", position_courante)
	
	$Nom.set_position(position_initiale_nom + position)
	# print("choisir_position : $Nom.position = ", position_courante)

func hauteur() -> int:
	return $Carre.size.y

func largeur() -> int:
	return $Carre.size.x

func est_vide() -> bool:
	return indice_jeton == Plateau.ESPACE
