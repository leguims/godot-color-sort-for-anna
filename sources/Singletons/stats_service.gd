extends Node

# ########
# Campagne
func campagne_taux_completion() -> float:
	return 0.0

func campagne_temps_total_en_ms() -> int:
	return 0

func campagne_taux_reussite() -> float:
	return 0.0

func campagne_serie_max_reussite() -> int:
	return 0

# #########
# Ascension
func ascension_taux_completion() -> float:
	return 0.0

func ascension_terminees() -> int:
	return 0

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
