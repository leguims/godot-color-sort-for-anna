extends Node

class_name Pile

signal clique_gauche(reference_parent)

@export var jeton_scene: PackedScene
var liste_jetons = []
var position = Vector2(0, 720)
var reference_parent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if false:
			print("est vide : ", est_vide())
			print("est pleine : ", est_pleine())
			print("est terminé : ", est_termine())
			
			effacer_la_pile()
			ajouter_les_jetons([0,0,0,0])
			print("[0,0,0,0]")
			print("est vide : ", est_vide())
			print("est pleine : ", est_pleine())
			print("est terminé : ", est_termine())
			print("quelle_est_la_couleur_au_sommet : ",quelle_est_la_couleur_au_sommet())
			print("combien_de_cases_vides_au_sommet : ",combien_de_cases_vides_au_sommet())
			print("accepte_jeton(0,1) : ",accepte_jeton(0,1))
			print("accepte_jeton(0,0) : ",accepte_jeton(0,0))
			print("ajouter 0 : ", ajouter_le_jeton_dans_le_vide(0))
			print("retirer : ", retirer_le_dernier_jeton())
			for j in liste_jetons:
				print(j.indice_jeton)

			effacer_la_pile()
			ajouter_les_jetons([0,1,0,32])
			print("[0,1,0,32]")
			print("est vide : ", est_vide())
			print("est pleine : ", est_pleine())
			print("est terminé : ", est_termine())
			print("quelle_est_la_couleur_au_sommet : ",quelle_est_la_couleur_au_sommet())
			print("combien_de_cases_vides_au_sommet : ",combien_de_cases_vides_au_sommet())
			print("accepte_jeton(0,1) : ",accepte_jeton(0,1))
			print("accepte_jeton(1,1) : ",accepte_jeton(1,1))
			print("accepte_jeton(0,2) : ",accepte_jeton(0,2))
			print("ajouter 1 : ", ajouter_le_jeton_dans_le_vide(1))
			print("ajouter 0 : ", ajouter_le_jeton_dans_le_vide(0))
			for j in liste_jetons:
				print(j.indice_jeton)
			
			effacer_la_pile()
			ajouter_les_jetons([32])
			print("[32]")
			print("est vide : ", est_vide())
			print("est pleine : ", est_pleine())
			print("est terminé : ", est_termine())
			print("accepte_jeton(0,1) : ",accepte_jeton(0,1))
			print("accepte_jeton(0,2) : ",accepte_jeton(0,2))
			print("ajouter 1 : ", ajouter_le_jeton_dans_le_vide(1))
			for j in liste_jetons:
				print(j.indice_jeton)
			print("retirer : ", retirer_le_dernier_jeton())
			for j in liste_jetons:
				print(j.indice_jeton)

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
	#print("clique sur le jeton : ", indice_jeton)
	clique_gauche.emit(reference_parent)
