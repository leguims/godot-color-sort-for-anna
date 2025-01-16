extends Node

class_name Jeton

var jetons = [
	['A', Color('RED')],
	['B', Color('BLUE_VIOLET')],
	['C', Color('FOREST_GREEN')],
	['D', Color('CORAL')],
	['E', Color('SADDLE_BROWN')],
	['F', Color('DEEP_SKY_BLUE')],
	['G', Color('MAGENTA')],
	['H', Color('TOMATO')],
	['I', Color('BLUE')],
	# ['J', Color('WEB_PURPLE')] # 'J' est hors cadre !
	['K', Color('VIOLET')],
	['L', Color('TEAL')],
	['M', Color('SLATE_GRAY')],
	['N', Color('SANDY_BROWN')],
	['O', Color('SALMON')]
]

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
	if 0 <= indice and indice < len(jetons):
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
