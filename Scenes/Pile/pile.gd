extends Node

@export var jeton_scene: PackedScene
var liste_jetons = []
var position = Vector2(0, 720)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if false:
		ajouter_les_jetons(range(14))
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func ajouter_les_jetons(jetons : Array) -> void:
	for jeton_courant in jetons:
		# Créer une nouvelle instance de la scene 'Jeton'.
		var jeton = jeton_scene.instantiate()

		# Ajouter la nouvelle scene au plus tot pour que
		# le constructeur '_ready' ait fait ses actions préalables.
		add_child(jeton)
		liste_jetons.append(jeton) 

		# Definir la position du jeton dans la pile
		var indice_jeton = len(liste_jetons)-1
		var position_jeton = calculer_la_position_du_jeton(indice_jeton)
		jeton.choisir_position( position_jeton )

		# Definir le type du jeton
		jeton.choisir_jeton(jeton_courant)

func choisir_position(nouvelle_position : Vector2) -> void:
	position = nouvelle_position
	var indice_jeton = 0
	# Changer la position de tous les jetons
	for jeton_courant in liste_jetons:
		var position_jeton = calculer_la_position_du_jeton(indice_jeton)
		jeton_courant.choisir_position( position_jeton )
		indice_jeton += 1

func calculer_la_position_du_jeton(indice_jeton : int) -> Vector2:
	var position_jeton = position
	# Inversion sur Y pour commencer à la base de la pile
	position_jeton.y = position.y - indice_jeton * (liste_jetons[indice_jeton].hauteur() + 2)
	return position_jeton

func largeur() -> int:
	if liste_jetons:
		return liste_jetons[0].largeur()
	return 0

func hauteur() -> int:
	if liste_jetons:
		return (liste_jetons[0].hauteur() + 2) * len(liste_jetons)
	return 0
