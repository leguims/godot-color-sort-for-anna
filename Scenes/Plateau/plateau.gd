extends Node

@export var pile_scene: PackedScene
var liste_piles = []
var string2int = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if true:
		#creer_un_plateau( [ range(4), range(2,6), range(2,4) ] )
		decoder_pile('AABC')
		decoder_pile('ABCG')
		var plateau = decoder_plateau("ABC.AAB.CC .   ")
		#creer_un_plateau(plateau)
		plateau = decoder_plateau("ABC.AAB.CC .   .EFG.MNO.MNONONONONO")
		creer_un_plateau(plateau)
		var scr_size = DisplayServer.screen_get_size()
		var win_size = DisplayServer.window_get_size()
		pass
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func decoder_plateau(plateau_texte : String) -> Array:
	print("decoder_plateau : ", plateau_texte)
	var plateau_liste = []
	plateau_texte = plateau_texte.replace(' ','')
	for pile in plateau_texte.split('.'):
		plateau_liste.append(decoder_pile(pile))
	print("  decoder_plateau : ", plateau_texte, " => ", plateau_liste)
	print("decoder_plateau : fin")
	return plateau_liste

func decoder_pile(pile_texte : String) -> Array:
	var pile_liste = []
	if not string2int:
		for i in range(26):
			string2int[String.chr(65+i)] = i
		# string2int[String.chr(32)] = 32 # chr(32)=' '
	for c in pile_texte:
		pile_liste.append(string2int[c])
	print("  decoder_pile : ", pile_texte, " => ", pile_liste)
	return pile_liste

func creer_un_plateau(piles : Array) -> void:
	for pile_courante in piles:
		# Créer une nouvelle instance de la scene 'Jeton'.
		var pile = pile_scene.instantiate()

		# Ajouter la nouvelle scene au plus tot pour que
		# le constructeur '_ready' ait fait ses actions préalables.
		add_child(pile)
		liste_piles.append(pile)
		
		# Créer la pile
		pile.ajouter_les_jetons(pile_courante)

		# Definir la position de la pile sur le plateau
		var position_pile = calculer_la_position_de_la_pile(len(piles), len(liste_piles)-1)
		#print("creer_un_plateau : position_pile = ", position_pile)
		pile.choisir_position( position_pile )

func calculer_la_position_de_la_pile(nb_piles : int, indice_pile : int) -> Vector2:
	var marge_x = 50
	var marge_y = 50
	var taille_fenetre_jeu = DisplayServer.window_get_size()
	var ecart_entre_piles_x = int( (taille_fenetre_jeu.x - 2 * marge_x) / nb_piles )
	var position_pile : Vector2
	position_pile.x = marge_x + ecart_entre_piles_x * indice_pile
	position_pile.y = taille_fenetre_jeu.y - marge_y
	return position_pile
