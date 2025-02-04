extends Node

class_name Pile

signal clique_gauche(reference_parent)

@export var jeton_scene: PackedScene
var liste_jetons = []
var reference_parent

var position = Vector2(0, 720)
var marge = 4

var couleur_de_deselection = Color("580058")
var couleur_de_selection = Color("d800d8")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func choisir_reference(reference : int) -> void:
	reference_parent = reference

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

		# Fournir l'indice du jeton comme reference
		# Permet d'identifier de quel jeton provient un signal.
		var indice_jeton = len(liste_jetons)-1
		jeton.choisir_reference(indice_jeton)
		
		# Connexion au signal 'Jeton.clique_gauche'
		jeton.connect("clique_gauche", Callable(self, "on_jeton_clique_gauche"))
		
		# Definir la position du jeton dans la pile
		var position_jeton = _calculer_la_position_du_jeton(indice_jeton)
		jeton.choisir_position( position_jeton )

		# Definir le type du jeton
		jeton.choisir_jeton(jeton_courant)
	
	# Definir la taille du fond de pile
	var size = Vector2(largeur(), hauteur() )
	$Fond.set_size(size)
	
	# Definir la position du fond de pile
	_choisir_position_fond(Vector2(0, 720))
	return true # pile valide

func ajouter_le_jeton_dans_le_vide(jeton_a_ajouter : int) -> bool:
	var ajoute = false
	if accepte_jeton(jeton_a_ajouter, 1):
		for jeton_courant in liste_jetons:
			if jeton_courant.est_vide():
				jeton_courant.choisir_jeton(jeton_a_ajouter)
				# TODO : Attention, le jeton 'J' posera un probleme !
				# TODO : 'J' avant = jeton petit
				# TODO : 'J' apres = ok
				ajoute = true
				break
	return ajoute

func retirer_le_dernier_jeton() -> bool:
	var retire = false
	var liste_inversee = liste_jetons.duplicate(true)
	liste_inversee.reverse()
	for jeton_courant in liste_inversee:
		if not jeton_courant.est_vide():
			jeton_courant.choisir_jeton(Plateau.ESPACE)
			# TODO : Attention, le jeton 'J' posera un probleme !
			# TODO : 'J' avant = jeton petit
			# TODO : 'J' apres = ok
			retire = true
			break
	return retire

func choisir_position(nouvelle_position : Vector2) -> void:
	position = nouvelle_position
	var indice_jeton = 0
	# Changer la position de tous les jetons
	for jeton_courant in liste_jetons:
		var position_jeton = _calculer_la_position_du_jeton(indice_jeton)
		# print("Pile.choisir_position : position_jeton = ", position_jeton)
		jeton_courant.choisir_position( position_jeton )
		indice_jeton += 1
	_choisir_position_fond(nouvelle_position)

func _choisir_position_fond(nouvelle_position : Vector2) -> void:
	if liste_jetons:
		# Position du dernier jeton + Centrage de la pile
		$Fond.set_position(liste_jetons[-1].position() - Vector2(marge, marge))
		# print("Pile.choisir_position $Fond.get_position()", $Fond.get_position())

func selectionner() -> void:
	$Fond.color = couleur_de_selection

func deselectionner() -> void:
	$Fond.color = couleur_de_deselection

func largeur() -> int:
	if liste_jetons:
		return liste_jetons[0].largeur() + 2 * marge
	return 0

func hauteur() -> int:
	if liste_jetons:
		return (liste_jetons[0].hauteur() + 2) * len(liste_jetons) + 2 * marge
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


# Methodes pour cadrer les mouvements de jetons
func est_vide() -> bool:
	return liste_jetons.is_empty() \
		or liste_jetons.front().indice_jeton == Plateau.ESPACE

func est_pleine() -> bool:
	return liste_jetons.is_empty() \
		or liste_jetons.back().indice_jeton != Plateau.ESPACE

func est_termine() -> bool:
	# Terminée = pleine monocouleur
	# Tous les jetons sont identiques
	var jeton_precedent = null
	for jeton in liste_jetons:
		if jeton_precedent != null and jeton.indice_jeton != jeton_precedent:
			return false
		jeton_precedent = jeton.indice_jeton
	return true

func quelle_est_la_couleur_au_sommet() -> int:
	if not est_vide():
		var liste_inversee = liste_jetons.duplicate(true)
		liste_inversee.reverse()
		for jeton in liste_inversee:
			if jeton.indice_jeton != Plateau.ESPACE:
				return jeton.indice_jeton
	return Plateau.ESPACE
	
func combien_de_jetons_identiques_au_sommet() -> int:
	var nb_identique_sommet = 0
	var jeton_sommet = null
	if not est_vide() and not est_termine():
		var liste_inversee = liste_jetons.duplicate(true)
		liste_inversee.reverse()
		for jeton in liste_inversee:
			if jeton_sommet == null and jeton.indice_jeton == Plateau.ESPACE :
				continue # Ignorer les cases vides au sommet
			elif jeton_sommet == null and jeton.indice_jeton != Plateau.ESPACE :
				# Enregistrer le premier jeton rencontré
				jeton_sommet = jeton.indice_jeton
				nb_identique_sommet += 1
			elif jeton_sommet != null and jeton.indice_jeton == jeton_sommet:
				# Comptabiliser les jetons identiques
				nb_identique_sommet += 1
			else:
				break # Arret du comptage pour un jeton différent
	return nb_identique_sommet

func combien_de_cases_vides_au_sommet() -> int:
	var vide_sommet = 0
	if not est_pleine():
		var liste_inversee = liste_jetons.duplicate(true)
		liste_inversee.reverse()
		for jeton in liste_inversee:
			if jeton.indice_jeton == Plateau.ESPACE:
				vide_sommet += 1
			else:
				break
	return vide_sommet

func accepte_jeton(indice : int, nombre : int) -> bool:
	return (est_vide() or indice == quelle_est_la_couleur_au_sommet()) \
		and nombre <= combien_de_cases_vides_au_sommet()

func _calculer_la_position_du_jeton(indice_jeton : int) -> Vector2:
	var position_jeton = position
	# Inversion sur Y pour commencer à la base de la pile
	position_jeton.y = position.y - indice_jeton * (liste_jetons[indice_jeton].hauteur() + 2)
	return position_jeton

func on_jeton_clique_gauche(indice_jeton : int) -> void:
	# print("clique sur le jeton : ", indice_jeton)
	clique_gauche.emit(reference_parent)
