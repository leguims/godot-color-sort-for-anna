extends BaseClassiqueQuiPerdGagne

class_name QuiPerdGagne

var diablotin_actif :bool = false
var position_diablotin :Vector2 = Vector2(194,19)
var direction_diablotin :Vector2 = Vector2(0,1)
var vitesse_diablotin :float = 0.
var rotation_diablotin :float = 0.
var vitesse_rotation_diablotin :float = 0.
var approche_diablotin : Vector2 = Vector2.ONE
var vitesse_approche_diablotin :float = 0.

func _ready() -> void:
	super._ready()

	# Initialiser le menu
	# TODO : On garde les textes de l'image du BandeauEnJeu
	# $MenuPlateau.enregistrer_gameplay("Qui Perd Gagne")
	# $MenuPlateau.enregistrer_sous_titre_gameplay("Bloque le jeu")
	$MenuPlateau.enregistrer_gameplay("")
	$MenuPlateau.enregistrer_sous_titre_gameplay("")

func _physics_process(delta: float) -> void:
	if diablotin_actif:
		# Faire bouger le diablotin
		bouger_diablotin(delta)

func commencer_un_nouveau_plateau(plateau_texte : String) -> void:
	super.commencer_un_nouveau_plateau(plateau_texte)
	activer_diablotin()

func show_fond() -> void:
	super.show_fond()
	$Diablotin.hide()


func activer_diablotin() -> void:
	# Reset du diablotin
	reset_diablotin()
	$Diablotin.show()
	diablotin_actif = true

func desactiver_diablotin() -> void:
	$Diablotin.hide()
	diablotin_actif = false

func reset_diablotin() -> void:
	position_diablotin = Vector2(194,19)
	direction_diablotin = Vector2(0,1)
	vitesse_diablotin = 0.

	rotation_diablotin = 0.
	vitesse_rotation_diablotin = 0.

	approche_diablotin = Vector2.ONE
	vitesse_approche_diablotin = 0.

	# $Diablotin.set_size(Vector2(68,68))
	$Diablotin.set_position(position_diablotin)
	$Diablotin.set_rotation_degrees(rotation_diablotin)
	$Diablotin.set_scale(approche_diablotin)

func bouger_diablotin(delta: float) -> void:
	print("*** bouger_diablotin() ***")
	# Faire bouger le diablotin avec un Min/Max
	var rand_v : float
	if vitesse_diablotin < -10:
		print("trop rapide neg.")
		rand_v = randf_range(0,2) * delta
	elif vitesse_diablotin > 10:
		print("trop rapide pos.")
		rand_v = randf_range(-2,0) * delta
	else:
		rand_v = randf_range(-1,1) * delta
	vitesse_diablotin += rand_v
	print("vitesse", " rand=",rand_v, " v=",vitesse_diablotin)

	# La direction est ajustée pour rester visible
	var rand_x : float
	var rand_y : float

	if position_diablotin.x < -100:
		print("trop à gauche")
		rand_x = randf_range(0,2) * delta
	elif position_diablotin.x > 580:
		print("trop à droite")
		rand_x = randf_range(-2,0) * delta
	else:
		rand_x = randf_range(-1,1) * delta

	if position_diablotin.y < -100:
		print("trop haut")
		rand_y = randf_range(0,2) * delta
	elif position_diablotin.y > 820:
		print("trop bas")
		rand_y = randf_range(-2,0) * delta
	else:
		rand_y = randf_range(-1,1) * delta
	direction_diablotin += Vector2(rand_x,rand_y)
	position_diablotin += direction_diablotin * vitesse_diablotin
	print("position ", " x=",rand_x, " y=",rand_y, " dir=",direction_diablotin, " pos=",position_diablotin)

	# Faire tourner le diablotin avec un Min/Max
	var rand_vr : float
	if vitesse_rotation_diablotin < -10:
		print("trop rapide neg.")
		rand_vr = randf_range(0,2) * delta
	elif vitesse_rotation_diablotin > 10:
		print("trop rapide pos.")
		rand_vr = randf_range(-2,0) * delta
	else:
		rand_vr = randf_range(-1,1) * delta
	vitesse_rotation_diablotin += rand_vr
	rotation_diablotin += vitesse_rotation_diablotin
	print("rotation ", " rand=",rand_vr, " v=",vitesse_rotation_diablotin, " rot=",rotation_diablotin)

	# Faire s'approcher le diablotin avec un Min/Max
	var rand_a : float
	if approche_diablotin < Vector2.ONE:
		print("trop loin")
		rand_a = randf_range(0,2) * delta
	elif approche_diablotin > 7*Vector2.ONE:
		print("trop proche")
		rand_a = randf_range(-2,0) * delta
	else:
		rand_a = randf_range(-1,1) * delta
	vitesse_approche_diablotin += rand_a
	approche_diablotin += Vector2.ONE * vitesse_approche_diablotin
	print("approche", " rand=",rand_a, " v=",vitesse_approche_diablotin, " a=",approche_diablotin)

	$Diablotin.set_position(position_diablotin)
	$Diablotin.set_rotation_degrees(rotation_diablotin)
	$Diablotin.set_scale(approche_diablotin)

# Callback pour "Plateau"
func est_termine(liste_piles) -> bool:
	# Condition de victoire : plateau bloqué + 1 pile non terminée
	# Vérifier si la partie est achevée

	# Impossible de joueur
	var plateau_bloque = false
	plateau_bloque = $Plateau.est_bloque()
	
	# Une pile non terminée
	var une_pile_en_desordre = false
	for pile in liste_piles:
		# Vérifier qu'une piles qui n'est pas vides n'est pas terminée.
		if not pile.est_vide() and not pile.est_termine():
			une_pile_en_desordre = true
			break

	var termine = plateau_bloque and une_pile_en_desordre
	if termine:
		show_fond()
		LogService.log_debug("[qui_perd_gagne] emission signal : victoire")
		victoire.emit()
	return termine


func _on_abandon() -> void:
	desactiver_diablotin()

func _on_passe() -> void:
	desactiver_diablotin()

func _on_plateau_invalide() -> void:
	desactiver_diablotin()

func _on_victoire() -> void:
	desactiver_diablotin()
