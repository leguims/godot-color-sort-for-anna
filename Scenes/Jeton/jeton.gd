extends Node

class_name Jeton

var jetons = {
	0: ['A', Color('RED')],
	1: ['B', Color('BLUE_VIOLET')],
	3: ['C', Color('FOREST_GREEN')],
	4: ['D', Color('CORAL')],
	5: ['E', Color('SADDLE_BROWN')],
	6: ['F', Color('DEEP_SKY_BLUE')],
	7: ['G', Color('MAGENTA')],
	8: ['H', Color('TOMATO')],
	9: ['I', Color('BLUE')],
	# ['J', Color('WEB_PURPLE')] # 'J' est hors cadre !
	10: ['K', Color('VIOLET')],
	11: ['L', Color('TEAL')],
	12: ['M', Color('SLATE_GRAY')],
	13: ['N', Color('SANDY_BROWN')],
	14: ['O', Color('SALMON')],
	32: [' ', Color('DARK_MAGENTA')] # DARK_VIOLET # DARK_MAGENTA # INDIGO # REBECCA_PURPLE # WEB_PURPLE
}

@export var indice_jeton = 0
var couleur
var nom
var position_initiale_carre : Vector2 #(0,0)
var position_initiale_nom : Vector2 #(0,-16)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Enregistrer les positions initiales
	position_initiale_carre = $Carre.position
	position_initiale_nom = $Nom.position
	while false:
		for i in range(len(jetons)):
			choisir_jeton(i)
			await get_tree().create_timer(1.0).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func choisir_jeton(indice : int) -> void:
	if indice in jetons:
		indice_jeton = indice
		nom = jetons[indice_jeton][0]
		couleur = jetons[indice_jeton][1]
		$Carre.color = couleur
		$Nom.text = nom

func choisir_position(position : Vector2) -> void:
	$Carre.set_position(position_initiale_carre + position)
	# print("choisir_position : $Carre.position = ", position_courante)
	
	$Nom.set_position(position_initiale_nom + position)
	# print("choisir_position : $Nom.position = ", position_courante)

func hauteur() -> int:
	return $Carre.size.y

func largeur() -> int:
	return $Carre.size.x
