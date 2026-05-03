extends Node

func _ready() -> void:
	# TODO : Supprimer
	#ProgressionCampagneService.choisir_le_joueur_pour_la_campagne("Alain Konu")
	ProgressionCampagneService.choisir_le_joueur_pour_la_campagne("toto")
	#ProgressionCampagneService.choisir_le_joueur_pour_la_campagne("Anna")

# ########
# Campagne
func campagne_taux_completion() -> float:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	LogService.log_debug("joueur:",joueur, ' campagne_taux_completion=', taux_completion_campagne())
	return taux_completion_campagne()

func campagne_temps_total_en_s() -> int:
	return duree_totale_plateaux_toutes_les_ascensions_en_s()

func campagne_taux_reussite() -> float:
	return taux_de_reussite_des_plateaux()

func campagne_serie_max_reussite() -> int:
	return serie_de_victoire_maximum()

# #########
# Ascension
func ascension_taux_completion() -> int:
	return SauvegardeBddJoueursService.lire_pourcentage_ascension_realise()

func ascension_terminees() -> int:
	return SauvegardeBddJoueursService.lire_nombre_ascensions()

func ascension_duree_moyenne_en_s() -> int:
	return duree_moyenne_ascensions_terminees_en_s()

func ascension_longueur_max() -> int:
	return longueur_max_ascension_terminee()

func ascension_parfaite_nb() -> int:
	"Ascension sans erreur"
	return nombre_ascension_parfaite()

func ascension_parfaite_longeur() -> int:
	"Ascension sans erreur (nb plateaux)"
	return longueur_max_ascension_parfaite()

# #######
# Plateau
func plateau_plus_rapide_en_s() -> float:
	return plateau_le_plus_rapide_temps_en_s()

func plateau_plus_rapide_difficulte() -> float:
	return plateau_le_plus_rapide_difficulte()

func plateau_plus_lent_en_s() -> float:
	return plateau_le_plus_lent_temps_en_s()

func plateau_plus_lent_difficulte() -> float:
	return plateau_le_plus_lent_difficulte()


# ####################
# Calculs Statistiques
func nombre_de_plateau_inacheves() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Nombre de plateau inachevés
	var nb_plateaux_inacheves: int = 0
	# Parcourir la liste des plateaux de chaque niveaux
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("plateaux", null):
		for liste_plateaux in SauvegardeBddJoueursService.sauvegarde_joueur.get("plateaux").values():
			nb_plateaux_inacheves += liste_plateaux.size()
	LogService.log_debug("joueur:",joueur, ' nb_plateaux_inacheves=', nb_plateaux_inacheves)
	return nb_plateaux_inacheves

func nombre_de_plateau_acheves() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Nombre de plateau achevés
	var nb_plateaux_acheves: int = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null):
				for plateau_joue in ascension.get("plateaux"):
					if plateau_joue.get("statut") == "reussi":
						nb_plateaux_acheves += 1
	LogService.log_debug("joueur:",joueur, ' nb_plateaux_acheves=', nb_plateaux_acheves)
	return nb_plateaux_acheves

func nombre_de_plateaux_totaux() -> int:
	return nombre_de_plateau_inacheves() + nombre_de_plateau_acheves()

func taux_completion_campagne() -> float:
	return 1. * nombre_de_plateau_acheves() / nombre_de_plateaux_totaux()

func duree_totale_plateaux_toutes_les_ascensions_en_s(terminee: bool = false) -> float:
	"Durée totale de jeu effectif de plateaux dans les ascensions"
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Nombre de plateau achevés
	var duree_totale_plateaux_toutes_les_ascensions: float = 0.
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les ascensions terminees ou toutes (dont en cours)
			if not terminee or ascension.get("date_fin"):
				# Comptabiliser les plateaux reussis
				if ascension.get("plateaux", null):
					for plateau_joue in ascension.get("plateaux"):
						if plateau_joue.get("date_debut") and plateau_joue.get("date_fin"):
							duree_totale_plateaux_toutes_les_ascensions += plateau_joue.get("date_fin") - plateau_joue.get("date_debut")
	LogService.log_debug("joueur:",joueur, ' duree_totale_plateaux_toutes_les_ascensions=', duree_totale_plateaux_toutes_les_ascensions)
	return duree_totale_plateaux_toutes_les_ascensions

func duree_totale_plateaux_ascensions_terminees_en_s() -> float:
	"Durée totale de jeu effectif de plateaux dans l'ascension en cours"
	return duree_totale_plateaux_toutes_les_ascensions_en_s(true)

func nombre_ascensions_terminees() -> int:
	var nb_ascensions = SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions").size()
	if duree_totale_plateaux_ascensions_terminees_en_s() == duree_totale_plateaux_toutes_les_ascensions_en_s():
		return nb_ascensions
	return nb_ascensions - 1

func duree_moyenne_ascensions_terminees_en_s() -> float:
	return duree_totale_plateaux_ascensions_terminees_en_s() / nombre_ascensions_terminees()

func nombre_de_plateau_reussis() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Nombre de plateau reussis
	var nb_plateaux_reussis: int = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null):
				for plateau_joue in ascension.get("plateaux"):
					if plateau_joue.get("statut") == "reussi":
						nb_plateaux_reussis += 1
	LogService.log_debug("joueur:",joueur, ' nb_plateaux_reussis=', nb_plateaux_reussis)
	return nb_plateaux_reussis

func nombre_de_plateau_abandonnes() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Nombre de plateau reussis
	var nb_plateaux_abandonnes: int = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null):
				for plateau_joue in ascension.get("plateaux"):
					if plateau_joue.get("statut") == "abandonné":
						nb_plateaux_abandonnes += 1
	LogService.log_debug("joueur:",joueur, ' nb_plateaux_abandonnes=', nb_plateaux_abandonnes)
	return nb_plateaux_abandonnes

func taux_de_reussite_des_plateaux() -> float:
	return 1. * nombre_de_plateau_reussis() / (nombre_de_plateau_reussis() + nombre_de_plateau_abandonnes())

func longueur_max_ascension_terminee() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Nombre de plateau reussis
	var longueur_max_ascension_terminee: int = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux sur les ascensions terminées
			if ascension.get("plateaux", null) and ascension.get("date_fin", null):
				longueur_max_ascension_terminee += ascension.get("plateaux", null).size()
	LogService.log_debug("joueur:",joueur, ' longueur_max_ascension_terminee=', longueur_max_ascension_terminee)
	return longueur_max_ascension_terminee

func plateau_le_plus_rapide_temps_en_s() -> float:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Plateau termine le plus vite
	var plus_rapide_temps: float = 0.
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null):
				for plateau_joue in ascension.get("plateaux"):
					if plateau_joue.get("date_fin") and plateau_joue.get("date_debut"):
						var duree = plateau_joue.get("date_fin") - plateau_joue.get("date_debut")
						if duree < plus_rapide_temps or plus_rapide_temps == 0.:
							plus_rapide_temps = plateau_joue.get("date_fin") - plateau_joue.get("date_debut")
	LogService.log_debug("joueur:",joueur, ' plus_rapide_temps=', plus_rapide_temps)
	return plus_rapide_temps

func plateau_le_plus_rapide_difficulte() -> float:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Plateau termine le plus vite et sa difficulté
	var plus_rapide_temps: float = 0.
	var plus_rapide_difficulte: float = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null):
				for plateau_joue in ascension.get("plateaux"):
					if plateau_joue.get("date_fin") and plateau_joue.get("date_debut"):
						var duree = plateau_joue.get("date_fin") - plateau_joue.get("date_debut")
						var difficulte = plateau_joue.get("niveau")
						if duree <= plus_rapide_temps or plus_rapide_temps == 0.:
							if duree == plus_rapide_temps and difficulte > plus_rapide_difficulte:
								plus_rapide_difficulte = difficulte
							else:
								plus_rapide_temps = plateau_joue.get("date_fin") - plateau_joue.get("date_debut")
								plus_rapide_difficulte = difficulte
	LogService.log_debug("joueur:",joueur, ' plus_rapide_difficulte=', plus_rapide_difficulte)
	return plus_rapide_difficulte

func plateau_le_plus_lent_temps_en_s() -> float:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Plateau le plus lent à résoudre
	var plus_lent_temps: float = 0.
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null):
				for plateau_joue in ascension.get("plateaux"):
					if plateau_joue.get("date_fin") and plateau_joue.get("date_debut"):
						var duree = plateau_joue.get("date_fin") - plateau_joue.get("date_debut")
						if duree > plus_lent_temps or plus_lent_temps == 0.:
							plus_lent_temps = plateau_joue.get("date_fin") - plateau_joue.get("date_debut")
	LogService.log_debug("joueur:",joueur, ' plus_lent_temps=', plus_lent_temps)
	return plus_lent_temps

func plateau_le_plus_lent_difficulte() -> float:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Plateau le plus lent à résoudre et sa difficulté
	var plus_lent_temps: float = 0.
	var plus_lent_difficulte: float = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null):
				for plateau_joue in ascension.get("plateaux"):
					if plateau_joue.get("date_fin") and plateau_joue.get("date_debut"):
						var duree = plateau_joue.get("date_fin") - plateau_joue.get("date_debut")
						var difficulte = plateau_joue.get("niveau")
						if duree >= plus_lent_temps or plus_lent_temps == 0.:
							if duree == plus_lent_temps and difficulte > plus_lent_difficulte:
								plus_lent_difficulte = difficulte
							else:
								plus_lent_temps = plateau_joue.get("date_fin") - plateau_joue.get("date_debut")
								plus_lent_difficulte = difficulte
	LogService.log_debug("joueur:",joueur, ' plus_lent_difficulte=', plus_lent_difficulte)
	return plus_lent_difficulte

func nombre_ascension_parfaite() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Nombre d'ascension sans erreur
	var nb_ascension_parfaite: int = 0.
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			if ascension.get("longueur_detour", null) == 0.:
				nb_ascension_parfaite += 1
	LogService.log_debug("joueur:",joueur, ' nb_ascension_parfaite=', nb_ascension_parfaite)
	return nb_ascension_parfaite

func longueur_max_ascension_parfaite() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Longueur max. d'ascension sans erreur
	var longueur_max_ascension_parfaite: int = 0.
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			var detour = ascension.get("longueur_detour", null)
			var longueur = ascension.get("plateaux", null).size()
			if detour == 0.:
				if longueur > longueur_max_ascension_parfaite:
					longueur_max_ascension_parfaite = longueur
	LogService.log_debug("joueur:",joueur, ' longueur_max_ascension_parfaite=', longueur_max_ascension_parfaite)
	return longueur_max_ascension_parfaite

func serie_de_victoire_maximum() -> int:
	var joueur = SauvegardeBddJoueursService.lire_nom_joueur()
	# Serie de victoire la plus grande.
	var serie_de_victoire_maximum: int = 0
	var serie_de_victoire_courante: int = 0
	# Parcourir la liste des ascensions
	if SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions", null):
		for ascension in SauvegardeBddJoueursService.sauvegarde_joueur.get("ascensions"):
			# Comptabiliser les plateaux reussis
			if ascension.get("plateaux", null):
				for plateau_joue in ascension.get("plateaux"):
					if plateau_joue.get("statut") == "reussi":
						serie_de_victoire_courante += 1
					if plateau_joue.get("statut") == "abandonné":
						# Defaite : Enregistrer le max et repartir à zéro.
						if serie_de_victoire_courante > serie_de_victoire_maximum:
							serie_de_victoire_maximum = serie_de_victoire_courante
						serie_de_victoire_courante = 0
		# Pour la derniere serie
		if serie_de_victoire_courante > serie_de_victoire_maximum:
			serie_de_victoire_maximum = serie_de_victoire_courante
	LogService.log_debug("joueur:",joueur, ' serie_de_victoire_maximum=', serie_de_victoire_maximum)
	return serie_de_victoire_maximum
