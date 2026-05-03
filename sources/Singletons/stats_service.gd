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

func campagne_temps_total_en_ms() -> int:
	return 0

func campagne_taux_reussite() -> float:
	return 0.0

func campagne_serie_max_reussite() -> int:
	return 0

# #########
# Ascension
func ascension_taux_completion() -> int:
	return SauvegardeBddJoueursService.lire_pourcentage_ascension_realise()

func ascension_terminees() -> int:
	return SauvegardeBddJoueursService.lire_nombre_ascensions()

func ascension_duree_moyenne_en_ms() -> int:
	return 0

func ascension_longueur_max() -> int:
	return 0

func ascension_parfaite_nb() -> int:
	"Ascension sans erreur"
	return 0

func ascension_parfaite_longeur() -> int:
	"Ascension sans erreur (nb plateaux)"
	return 0

# #######
# Plateau
func plateau_plus_rapide_en_ms() -> int:
	return 0

func plateau_plus_rapide_difficulte() -> int:
	return 0

func plateau_plus_lent_en_ms() -> int:
	return 0

func plateau_plus_lent_difficulte() -> int:
	return 0


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
