extends Node

class_name Plateau

signal victoire
signal plateau_invalide
signal abandon

@export var pile_scene: PackedScene
var liste_piles = []
var string2int = {}
static var ESPACE = 32

var sauvegarde_indice_pile_depart : int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func  commencer_un_nouveau_plateau(plateau_texte : String) -> void:
	if est_valide(plateau_texte):
		var plateau = _decoder_plateau(plateau_texte)
		_creer_un_plateau(plateau)
	else:
		plateau_invalide.emit()

func effacer_le_plateau() -> void:
	for pile in liste_piles:
		pile.effacer_la_pile()
		pile.queue_free()
	liste_piles.clear()
	$BoutonAbandon.show()


func est_valide(plateau_texte : String) -> bool:
	# Vérifier si chaque pile est valide
	for pile in _decoder_plateau(plateau_texte):
		if not Pile.est_valide(pile):
			return false
	# TODO : Vérifier la validité du plateau dans son ensemble (nombre de jetons, possibilité de réussir)
	# Invalide : Plateau vide
	if plateau_texte.is_empty():
		return false
	if plateau_texte.replacen(' ','').replacen('.','').is_empty():
		return false
	# TODO : Invalide : Nombre de jetons inégaux
	# TODO : Invalide : Nombre de jetons != taille pile
	return true

func _decoder_plateau(plateau_texte : String) -> Array:
	plateau_texte = plateau_texte.to_upper()
	#print("decoder_plateau : ", plateau_texte)
	var plateau_liste = []
	#plateau_texte = plateau_texte.replace(' ','')
	for pile in plateau_texte.split('.'):
		plateau_liste.append(_decoder_pile(pile))
	#print("  decoder_plateau : ", plateau_texte, " => ", plateau_liste)
	#print("decoder_plateau : fin")
	return plateau_liste

func _decoder_pile(pile_texte : String) -> Array:
	var pile_liste = []
	if not string2int:
		for i in range(26):
			string2int[String.chr(65+i)] = i
		string2int[String.chr(ESPACE)] = ESPACE # chr(ESPACE)=' '
	for c in pile_texte:
		pile_liste.append(string2int[c])
	#print("  decoder_pile : ", pile_texte, " => ", pile_liste)
	return pile_liste

func _creer_un_plateau(piles : Array) -> void:
	for pile_courante in piles:
		# Créer une nouvelle instance de la scene 'Jeton'.
		var pile = pile_scene.instantiate()

		# Ajouter la nouvelle scene au plus tot pour que
		# le constructeur '_ready' ait fait ses actions préalables.
		add_child(pile)
		liste_piles.append(pile)
		
		# Fournir l'indice de la pile comme reference
		# Permet d'identifier de quelle pile provient un signal.
		var indice_pile = len(liste_piles)-1
		pile.choisir_reference(indice_pile)
		
		# Connexion au signal 'Jeton.clique_gauche'
		pile.connect("clique_gauche", Callable(self, "on_pile_clique_gauche"))
		
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
			#print("calculer_la_position_de_la_pile : nb_piles = ", nb_piles)
			pass
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
				#print("calculer_la_position_de_la_pile : nb_piles = ", nb_piles)
				pass
		else:
			if indice_pile == 0:
				# TODO : Gérer N lignes en fonction de la hauteur de pile !
				# TODO : Gérer les piles de tailes différentes
				#print("calculer_la_position_de_la_pile : Trop de piles ! nb_piles = ", nb_piles)
				pass
		pass
	return position_pile

func on_pile_clique_gauche(indice_pile : int) -> void:
	# print("clique sur la pile : ", indice_pile)
	if sauvegarde_indice_pile_depart == -1:
		$SelectionPile.start()
		sauvegarde_indice_pile_depart = indice_pile
		# Selecitonner la pile de depart
		liste_piles[sauvegarde_indice_pile_depart].selectionner()
	else:
		$SelectionPile.stop()
		if realiser_le_tansfert_de_pile(sauvegarde_indice_pile_depart, indice_pile):
			if liste_piles[indice_pile].est_termine():
				# Vérifier si la partie est achevée
				if _est_termine():
					$BoutonAbandon.hide()
					victoire.emit()
		_on_selection_pile_timeout()

func _est_termine() -> bool:
	# Vérifier si la partie est achevée
	var termine = true
	for pile in liste_piles:
		if not pile.est_termine():
			termine = false
			break
	return termine

func _on_selection_pile_timeout() -> void:
	# Deselecitonner la pile de depart
	liste_piles[sauvegarde_indice_pile_depart].deselectionner()
	# Annulation du coup en cours
	sauvegarde_indice_pile_depart = -1
	# print("Annulation du coup en cours")

func realiser_le_tansfert_de_pile(indice_pile_depart : int, indice_pile_arrivee : int) -> bool:
	if indice_pile_depart == indice_pile_arrivee:
		print("Pile de départ et d'arrivée sont les mêmes")
		return false

	var pile_depart = liste_piles[indice_pile_depart]
	if pile_depart.est_vide() or pile_depart.est_termine():
		print("Pile de départ vide ou terminée")
		return false

	var pile_arrivee = liste_piles[indice_pile_arrivee]
	if pile_arrivee.est_pleine():
		print("Pile d'arrivée pleine")
		return false

	var indice_jeton_depart = pile_depart.quelle_est_la_couleur_au_sommet()
	var nb_jeton_depart = pile_depart.combien_de_jetons_identiques_au_sommet()

	if pile_arrivee.accepte_jeton(indice_jeton_depart, nb_jeton_depart):
		for i in range(nb_jeton_depart):
			pile_depart.retirer_le_dernier_jeton()
			pile_arrivee.ajouter_le_jeton_dans_le_vide(indice_jeton_depart)
		return true
	else:
		print("La pile d'arrivée refuse le(s) ", nb_jeton_depart, " jeton(s)")
		return false


func _on_bouton_abandon_pressed() -> void:
	$BoutonAbandon.hide()
	abandon.emit()
