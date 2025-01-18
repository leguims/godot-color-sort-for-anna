extends Node

class_name Plateau

signal fin_de_partie
signal plateau_invalide

@export var pile_scene: PackedScene
var liste_piles = []
var string2int = {}
static var ESPACE = 32

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if false:
		await get_tree().create_timer(15.0).timeout
		fin_de_partie.emit()
	if false:
		await get_tree().create_timer(5.0).timeout
		plateau_invalide.emit()
	if false:
		#_creer_un_plateau( [ range(4), range(2,6), range(2,4) ] )
		_decoder_pile('AABC')
		_decoder_pile('ABCG')
		
		var plateau = _decoder_plateau("ABC.AAB.CC .   ")
		_creer_un_plateau(plateau)
		# Sleep
		await get_tree().create_timer(5.0).timeout
		effacer_le_plateau()
		
		plateau = _decoder_plateau("ABC.AAB.CC .   .EFG.MNOMNONONONONO")
		_creer_un_plateau(plateau)
		# Sleep
		await get_tree().create_timer(5.0).timeout
		effacer_le_plateau()
		
		plateau = _decoder_plateau("AB.CJ.AAB.CC .   .DEFG.HIJKLMJ.NO.MNO.NON.ONO.NO")
		_creer_un_plateau(plateau)
		# Sleep
		await get_tree().create_timer(5.0).timeout
		effacer_le_plateau()

		commencer_un_nouveau_plateau("ABC.AAB.CC .   ")
		await get_tree().create_timer(5.0).timeout
		effacer_le_plateau()
		
		commencer_un_nouveau_plateau("ABC.AAB.CC .   .EFG.MNOMNONONONONO")
		await get_tree().create_timer(5.0).timeout
		effacer_le_plateau()
		
		commencer_un_nouveau_plateau("AB.CJ.AAB.CC .   .DEFG.HIJKLMJ.NO.MNO.NON.ONO.NO")
		
		var scr_size = DisplayServer.screen_get_size()
		var win_size = DisplayServer.window_get_size()
		pass
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func  commencer_un_nouveau_plateau(plateau_texte : String) -> void:
	if est_valide(plateau_texte):
		var plateau = _decoder_plateau(plateau_texte)
		_creer_un_plateau(plateau)
		# TODO : Code de test
		if true:
			await get_tree().create_timer(5.0).timeout
			#if randi_range(0, 1):
			if true:
				fin_de_partie.emit()
			else:
				plateau_invalide.emit()
	else:
		plateau_invalide.emit()

func effacer_le_plateau() -> void:
	for pile in liste_piles:
		pile.effacer_la_pile()
		pile.queue_free()
	liste_piles.clear()

func est_valide(plateau_texte : String) -> bool:
	# Vérifier si chaque pile est valide
	for pile in _decoder_plateau(plateau_texte):
		if not Pile.est_valide(pile):
			return false
	return true

func _decoder_plateau(plateau_texte : String) -> Array:
	plateau_texte = plateau_texte.to_upper()
	print("decoder_plateau : ", plateau_texte)
	var plateau_liste = []
	#plateau_texte = plateau_texte.replace(' ','')
	for pile in plateau_texte.split('.'):
		plateau_liste.append(_decoder_pile(pile))
	print("  decoder_plateau : ", plateau_texte, " => ", plateau_liste)
	print("decoder_plateau : fin")
	return plateau_liste

func _decoder_pile(pile_texte : String) -> Array:
	var pile_liste = []
	if not string2int:
		for i in range(26):
			string2int[String.chr(65+i)] = i
		string2int[String.chr(ESPACE)] = ESPACE # chr(ESPACE)=' '
	for c in pile_texte:
		pile_liste.append(string2int[c])
	print("  decoder_pile : ", pile_texte, " => ", pile_liste)
	return pile_liste

func _creer_un_plateau(piles : Array) -> void:
	for pile_courante in piles:
		# Créer une nouvelle instance de la scene 'Jeton'.
		var pile = pile_scene.instantiate()

		# Ajouter la nouvelle scene au plus tot pour que
		# le constructeur '_ready' ait fait ses actions préalables.
		add_child(pile)
		liste_piles.append(pile)
		
		# Créer la pile
		var valide = pile.ajouter_les_jetons(pile_courante)
		# Traiter le cas d'une pile invalide.
		if not valide:
			# la pile est invalide, le plateau aussi
			effacer_le_plateau()
			plateau_invalide.emit()
		

		# Definir la position de la pile sur le plateau
		var position_pile = _calculer_la_position_de_la_pile(len(piles), len(liste_piles)-1)
		#print("_creer_un_plateau : position_pile = ", position_pile)
		pile.choisir_position( position_pile )

func _calculer_la_position_de_la_pile(nb_piles : int, indice_pile : int) -> Vector2:
	var marge_y = 50
	var taille_fenetre_jeu = DisplayServer.window_get_size()
	var nb_ecarts = nb_piles + 1 # (nb_piles-1) = ecarts + 2 marges
	var largeur_pile = liste_piles[0].largeur()
	var ecart_entre_piles_x = taille_fenetre_jeu.x / nb_ecarts
	var position_pile : Vector2
	# 13 piles max par ligne, mais rendu surchargé
	# 6 piles par ligne = rendu agréable. Correspond à un écart d'une pile vide entre chaque pile.
	if 2*largeur_pile < ecart_entre_piles_x :
		# Gérer 1 ligne de piles
		position_pile.x = ecart_entre_piles_x * (1 + indice_pile) - 0.5 * largeur_pile
		position_pile.y = taille_fenetre_jeu.y - marge_y
		if indice_pile == 0:
			print("calculer_la_position_de_la_pile : nb_piles = ", nb_piles)
	else :
		# Gérer 2 lignes de piles
		nb_ecarts = int((nb_piles -1) / 2 + 2) # (nb_piles-1)/2 = ecarts + 2 marges
		ecart_entre_piles_x = taille_fenetre_jeu.x / nb_ecarts
		if 2*largeur_pile < ecart_entre_piles_x :
			var indice_pile_2_colonnes = int(indice_pile / 2)
			position_pile.x = ecart_entre_piles_x * (1 + indice_pile_2_colonnes) - 0.5 * largeur_pile
			if indice_pile % 2:
				position_pile.y = taille_fenetre_jeu.y - marge_y
			else:
				position_pile.y = (taille_fenetre_jeu.y / 2) - marge_y
			if indice_pile == 0:
				print("calculer_la_position_de_la_pile : nb_piles = ", nb_piles)
		else:
			if indice_pile == 0:
				# TODO : Gérer N lignes en fonction de la hauteur de pile !
				# TODO : Gérer les piles de tailes différentes
				print("calculer_la_position_de_la_pile : Trop de piles ! nb_piles = ", nb_piles)
		pass
	return position_pile
