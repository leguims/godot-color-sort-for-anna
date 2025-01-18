extends Node

class_name Pile

@export var jeton_scene: PackedScene
var liste_jetons = []
var position = Vector2(0, 720)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if false:
		var valide
		valide = est_valide([0,3,32])
		print("est_valide([0,3,32]) = ",valide)
		valide = est_valide([32,0,3])
		print("est_valide([32,0,3]) = ",valide)
		valide = est_valide([0,32,3])
		print("est_valide([0,32,3]) = ",valide)
	if false:
		ajouter_les_jetons(range(14))
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func ajouter_les_jetons(jetons : Array) -> bool:
	# Vérifier la validité de la pile
	if not est_valide(jetons):
		return false # pile invalide
	
	for jeton_courant in jetons:
		# Créer une nouvelle instance de la scene 'Jeton'.
		var jeton = jeton_scene.instantiate()

		# Ajouter la nouvelle scene au plus tot pour que
		# le constructeur '_ready' ait fait ses actions préalables.
		add_child(jeton)
		liste_jetons.append(jeton) 

		# Definir la position du jeton dans la pile
		var indice_jeton = len(liste_jetons)-1
		var position_jeton = _calculer_la_position_du_jeton(indice_jeton)
		jeton.choisir_position( position_jeton )

		# Definir le type du jeton
		jeton.choisir_jeton(jeton_courant)
	return true # pile valide

func choisir_position(nouvelle_position : Vector2) -> void:
	position = nouvelle_position
	var indice_jeton = 0
	# Changer la position de tous les jetons
	for jeton_courant in liste_jetons:
		var position_jeton = _calculer_la_position_du_jeton(indice_jeton)
		jeton_courant.choisir_position( position_jeton )
		indice_jeton += 1

func largeur() -> int:
	if liste_jetons:
		return liste_jetons[0].largeur()
	return 0

func hauteur() -> int:
	if liste_jetons:
		return (liste_jetons[0].hauteur() + 2) * len(liste_jetons)
	return 0

func effacer_la_pile() -> void:
	for jeton in liste_jetons:
		jeton.queue_free()
	position = Vector2(0, 720)
	liste_jetons.clear()

static func est_valide(jetons : Array) -> bool:
	var vide = false
	# Les cases vides sont en haut de la pile
	for jeton_courant in jetons:
		if not vide and jeton_courant == Plateau.ESPACE:
			vide = true
		elif vide and jeton_courant != Plateau.ESPACE:
			return false
	return true

func _calculer_la_position_du_jeton(indice_jeton : int) -> Vector2:
	var position_jeton = position
	# Inversion sur Y pour commencer à la base de la pile
	position_jeton.y = position.y - indice_jeton * (liste_jetons[indice_jeton].hauteur() + 2)
	return position_jeton
