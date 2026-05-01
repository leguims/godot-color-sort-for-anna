extends RefCounted
class_name PlateauDecodeurService

var string2int = {}

func est_valide(plateau_texte : String) -> bool:
	# Vérifier si chaque pile est valide
	for pile in decoder_plateau(plateau_texte):
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

func decoder_plateau(plateau_texte : String) -> Array:
	plateau_texte = plateau_texte.to_upper()
	#LogService.log_debug("decoder_plateau : ", plateau_texte)
	var plateau_liste = []
	#plateau_texte = plateau_texte.replace(' ','')
	for pile in plateau_texte.split('.'):
		plateau_liste.append(decoder_pile(pile))
	#LogService.log_debug("  decoder_plateau : ", plateau_texte, " => ", plateau_liste)
	#LogService.log_debug("decoder_plateau : fin")
	return plateau_liste

func decoder_pile(pile_texte : String) -> Array:
	var pile_liste = []
	if not string2int:
		for i in range(26):
			string2int[String.chr(65+i)] = i
		string2int[String.chr(Plateau.ESPACE)] = Plateau.ESPACE # chr(ESPACE)=' '
	for c in pile_texte:
		pile_liste.append(string2int[c])
	#LogService.log_debug("  decoder_pile : ", pile_texte, " => ", pile_liste)
	return pile_liste
