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
	# en haut à gauche (0,0)
	# en bas à droite (infini, infini)
	var taille_bouton_abandonner = $BoutonAbandon.size.y * 0.5
	# TODO : Facteur 0,5 ajouté par bricolage, car la hauteur de la pile ne semble pas être
	#        ... exactement celle retournée par liste_piles[0].hauteur()
	#        ... ou sinon, son affichage est décallé
	var taille_fenetre_jeu = get_viewport().get_visible_rect().size
	var taille_pile_pixels = Vector2(liste_piles[0].largeur(), liste_piles[0].hauteur())
	var taille_plateau = convertir_nb_piles_en_taille_plateau(nb_piles)
	var coordonnees_pile = convertir_indice_pile_coordonnees(nb_piles, indice_pile)
	var position_pile = Vector2()
	if taille_plateau.y == 1:
		# 1 ligne de piles : 'y' constant
		position_pile.y = taille_bouton_abandonner + (taille_fenetre_jeu.y - taille_bouton_abandonner) / 2 + taille_pile_pixels.y / 2
		var nb_ecarts_x = nb_piles + 1
		var vide_x = (taille_fenetre_jeu.x - (nb_piles * taille_pile_pixels.x)) / nb_ecarts_x
		var ecart_x = vide_x + taille_pile_pixels.x
		var taille_plateau_totale_x = nb_piles * taille_pile_pixels.x + (nb_piles - 1) * vide_x
		position_pile.x = taille_fenetre_jeu.x / 2 - taille_plateau_totale_x / 2 + ecart_x * (indice_pile)
	else:
		# N lignes de piles
		var nb_ecarts = Vector2i(taille_plateau.x + 1, taille_plateau.y + 1)
		var vide = Vector2( (taille_fenetre_jeu.x - (taille_plateau.x * taille_pile_pixels.x)) / nb_ecarts.x,
							 (taille_fenetre_jeu.y - taille_bouton_abandonner - (taille_plateau.y * taille_pile_pixels.y)) / nb_ecarts.y)
		var ecart = Vector2( vide.x + taille_pile_pixels.x,
							 vide.y + taille_pile_pixels.y)
		var taille_plateau_totale = Vector2( taille_plateau.x * taille_pile_pixels.x + (taille_plateau.x - 1) * vide.x,
												taille_plateau.y * taille_pile_pixels.y + (taille_plateau.y - 1) * vide.y)
		position_pile = Vector2( taille_fenetre_jeu.x / 2 - taille_plateau_totale.x / 2 + ecart.x * (coordonnees_pile.x),
									taille_bouton_abandonner + (taille_fenetre_jeu.y - taille_bouton_abandonner) / 2 + taille_plateau_totale.y / 2 - ecart.y * (coordonnees_pile.y) )
	return position_pile

func convertir_indice_pile_coordonnees(nb_piles : int, indice_pile : int) -> Vector2i:
	var coordonnees = Vector2i(0,0)
	var nb_pile_par_ligne = convertir_nb_piles_en_taille_plateau(nb_piles).x
	if nb_pile_par_ligne != 0:
		coordonnees.y = floori(1. * indice_pile / nb_pile_par_ligne) # Division entiere
		coordonnees.x = indice_pile - coordonnees.y * nb_pile_par_ligne # Reste de la division entiere
	return coordonnees

func convertir_nb_piles_en_taille_plateau(nb_piles : int) -> Vector2i:
	var taille_plateau = Vector2i(0,0)
	if nb_piles:
		# 13 piles max par ligne, mais rendu surchargé
		# 6 piles par ligne = rendu agréable. Correspond à un écart d'une pile vide entre chaque pile.
		taille_plateau.y = ceili(nb_piles / 6.) # Nombre de ligne necessaires
		taille_plateau.x = roundi(1. * nb_piles / taille_plateau.y) # Nombre de pile par ligne
	return taille_plateau

func on_pile_clique_gauche(indice_pile : int) -> void:
	# print("clique sur la pile : ", indice_pile)
	var pile_cible = liste_piles[indice_pile]
	if sauvegarde_indice_pile_depart == -1 \
		and pile_de_depart_de_tansfert_valide(indice_pile):
		$SelectionPile.start()
		sauvegarde_indice_pile_depart = indice_pile
		# Selecitonner la pile de depart
		pile_cible.selectionner()
		
		# Parcourir chaque pile pour voir si elle peut etre destination
		for pile_arrivee in range(len(liste_piles)):
			if pile_arrivee != indice_pile \
				and _est_valide_le_tansfert_de_pile(indice_pile, pile_arrivee):
				liste_piles[pile_arrivee].selectionner_deplacement_valide()
	else:
		$SelectionPile.stop()
		if realiser_le_tansfert_de_pile(sauvegarde_indice_pile_depart, indice_pile):
			if pile_cible.est_termine():
				pile_cible.bloquer()
				# Vérifier si la partie est achevée
				if _est_termine():
					$BoutonAbandon.hide()
					victoire.emit()
					if SauvegardeConfiguration.vibrations_sont_actives():
						# Grosse vibration
						Input.vibrate_handheld(800, 1.0)
				else:
					if SauvegardeConfiguration.vibrations_sont_actives():
						# Petite vibration
						Input.vibrate_handheld(200, 0.5)
			else:
				if SauvegardeConfiguration.vibrations_sont_actives():
					# Toute petite vibration
					Input.vibrate_handheld(50, 0.2)
		_on_selection_pile_timeout()

func _est_termine() -> bool:
	# Vérifier si la partie est achevée
	var termine = true
	for pile in liste_piles:
		# Vérifier que les piles qui ne sont pas vides sont terminées.
		if not pile.est_vide() and not pile.est_termine():
			termine = false
			break
	return termine

func _on_selection_pile_timeout() -> void:
	# Deselecitonner toutes les piles
	for pile in liste_piles:
			pile.deselectionner()
	# Annulation du coup en cours
	sauvegarde_indice_pile_depart = -1
	# print("Annulation du coup en cours")

func pile_de_depart_de_tansfert_valide(indice_pile_depart : int) -> bool:
	var pile_depart = liste_piles[indice_pile_depart]
	if pile_depart.est_vide():
		print("Pile de départ vide")
		return false
	if pile_depart.est_termine():
		print("Pile de départ terminée")
		return false
	return true

func _est_valide_le_tansfert_de_pile(indice_pile_depart : int, indice_pile_arrivee : int) -> bool:
	if indice_pile_depart == indice_pile_arrivee:
		#print("Pile de départ et d'arrivée sont les mêmes")
		return false

	var pile_arrivee = liste_piles[indice_pile_arrivee]
	if pile_arrivee.est_pleine():
		#print("Pile d'arrivée pleine")
		return false

	var pile_depart = liste_piles[indice_pile_depart]
	var indice_jeton_depart = pile_depart.quelle_est_la_couleur_au_sommet()
	var nb_jeton_depart = pile_depart.combien_de_jetons_identiques_au_sommet()

	if pile_arrivee.accepte_jeton(indice_jeton_depart, nb_jeton_depart):
		return true
	else:
		#print("La pile d'arrivée refuse le(s) ", nb_jeton_depart, " jeton(s)")
		return false

func realiser_le_tansfert_de_pile(indice_pile_depart : int, indice_pile_arrivee : int) -> bool:
	if _est_valide_le_tansfert_de_pile(indice_pile_depart, indice_pile_arrivee):
		var pile_arrivee = liste_piles[indice_pile_arrivee]
		var pile_depart = liste_piles[indice_pile_depart]
		var indice_jeton_depart = pile_depart.quelle_est_la_couleur_au_sommet()
		var nb_jeton_depart = pile_depart.combien_de_jetons_identiques_au_sommet()

		for i in range(nb_jeton_depart):
			pile_depart.retirer_le_dernier_jeton()
			pile_arrivee.ajouter_le_jeton_dans_le_vide(indice_jeton_depart)
		return true
	return false

func _on_bouton_abandon_pressed() -> void:
	$BoutonAbandon.hide()
	abandon.emit()

func _on_fond_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# print("Clique souris sur le fond du plateau")
			# Parcourir les piles et déselectionner la pile (comme "timeout" sur la selection)
			_on_selection_pile_timeout()
			
