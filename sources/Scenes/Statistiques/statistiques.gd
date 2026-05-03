extends Control

func _ready():
	campagne()
	ascensions()
	niveaux()
	plateaux()
	

	# Graphiques
	var WinLossBarChart = $Marge/HBoxContainer/VBoxContainer/Charts/WinLossBarChart
	WinLossBarChart.wins = 15
	WinLossBarChart.losses = 7
	WinLossBarChart.queue_redraw()

	var PlaytimeLineChart = $Marge/HBoxContainer/VBoxContainer/Charts/PlaytimeLineChart
	PlaytimeLineChart.monthly_minutes = [120, 90, 150, 200, 180, 220]
	PlaytimeLineChart.queue_redraw()

	# Jauge
	$Marge/HBoxContainer/VBoxContainer/MonthlyPlaytimeGauge.set_progress(120, 300)

func campagne():
	# Identifier le joueur
	# Consulter la BDD pour obtenir les indicateurs à afficher
	var valeur
	# TODO

	# KPI
	var KPI_Completion = $Marge/HBoxContainer/VBoxContainer/KPI_Campagne/KPI_Completion
	KPI_Completion.set_title("Complétion")
	valeur = StatsService.campagne_taux_completion()
	valeur = str(arrondir_pourcentage(valeur)) + '%'
	KPI_Completion.set_value(valeur)
	KPI_Completion.set_color(Color("e6e6ffff"), Color('BLUE'))
	KPI_Completion.set_minimum_size(Vector2(105,50))

	var KPI_Temps = $Marge/HBoxContainer/VBoxContainer/KPI_Campagne/KPI_Temps
	KPI_Temps.set_title("Temps")
	valeur = str(StatsService.campagne_temps_total_en_s()) + 's'
	KPI_Temps.set_value(valeur)
	KPI_Temps.set_color(Color("BLACK"), Color('SPRING_GREEN'))
	KPI_Temps.set_minimum_size(Vector2(105,50))

	var KPI_TauxReussite = $Marge/HBoxContainer/VBoxContainer/KPI_Campagne/KPI_TauxReussite
	KPI_TauxReussite.set_title("Réussite")
	valeur = str(StatsService.campagne_taux_reussite()) + '%'
	KPI_TauxReussite.set_value(valeur)
	KPI_TauxReussite.set_color(Color("fff4e6ff"), Color('DARK_ORANGE'))
	KPI_TauxReussite.set_minimum_size(Vector2(105,50))

	var KPI_SerieMaximumSucces = $Marge/HBoxContainer/VBoxContainer/KPI_Campagne/KPI_SerieMaximumSucces
	KPI_SerieMaximumSucces.set_title("Série Max.")
	valeur = StatsService.campagne_serie_max_reussite()
	KPI_SerieMaximumSucces.set_value(valeur)
	KPI_SerieMaximumSucces.set_color(Color("ffe6f3ff"), Color('DEEP_PINK'))
	KPI_SerieMaximumSucces.set_minimum_size(Vector2(105,50))

func ascensions():
	# Identifier le joueur
	# Consulter la BDD pour obtenir les indicateurs à afficher
	var valeur
	# TODO

	# KPI
	# Ligne 1
	var KPI_Completion = $Marge/HBoxContainer/VBoxContainer/KPI_Ascension/KPI_Completion
	KPI_Completion.set_title("Complétion")
	valeur = str(StatsService.ascension_taux_completion()) + '%'
	KPI_Completion.set_value(valeur)
	KPI_Completion.set_color(Color("e6e6ffff"), Color('BLUE'))
	KPI_Completion.set_minimum_size(Vector2(120,50))

	var KPI_Terminees = $Marge/HBoxContainer/VBoxContainer/KPI_Ascension/KPI_Terminees
	KPI_Terminees.set_title("Terminées")
	valeur = StatsService.ascension_terminees()
	KPI_Terminees.set_value(valeur)
	KPI_Terminees.set_color(Color("ffe6f3ff"), Color('DEEP_PINK'))
	KPI_Terminees.set_minimum_size(Vector2(120,50))

	var KPI_DureeMoyenne = $Marge/HBoxContainer/VBoxContainer/KPI_Ascension/KPI_DureeMoyenne
	KPI_DureeMoyenne.set_title("Durée Moy.")
	valeur = str(StatsService.ascension_duree_moyenne_en_ms()) + "ms"
	KPI_DureeMoyenne.set_value(valeur)
	KPI_DureeMoyenne.set_color(Color("fff0ffff"), Color('MAROON'))
	KPI_DureeMoyenne.set_minimum_size(Vector2(120,50))

	# Ligne 2
	var KPI_Longueur = $Marge/HBoxContainer/VBoxContainer/KPI_Ascension2/KPI_Longueur
	KPI_Longueur.set_title("Longueur Max.")
	valeur = StatsService.ascension_longueur_max()
	KPI_Longueur.set_value(valeur)
	KPI_Longueur.set_color(Color("fff0e3ff"), Color('CRIMSON'))
	KPI_Longueur.set_minimum_size(Vector2(120,50))

	var KPI_Parfait_Nb = $Marge/HBoxContainer/VBoxContainer/KPI_Ascension2/KPI_Parfait_Nb
	KPI_Parfait_Nb.set_title("Parfaite")
	valeur = StatsService.ascension_parfaite_nb()
	KPI_Parfait_Nb.set_value(valeur)
	KPI_Parfait_Nb.set_color(Color("GOLD"), Color('BLACK'))
	KPI_Parfait_Nb.set_minimum_size(Vector2(90,50))

	var KPI_Parfait_Lg = $Marge/HBoxContainer/VBoxContainer/KPI_Ascension2/KPI_Parfait_Lg
	KPI_Parfait_Lg.set_title("Longueur (Parfaite)")
	valeur = StatsService.ascension_parfaite_longeur()
	KPI_Parfait_Lg.set_value(valeur)
	KPI_Parfait_Lg.set_color(Color("GOLD"), Color('BLACK'))
	KPI_Parfait_Lg.set_minimum_size(Vector2(150,50))

func niveaux():
	# Identifier le joueur
	# Consulter la BDD pour obtenir les indicateurs à afficher
	# TODO

	# KPI
	pass

func plateaux():
	# Identifier le joueur
	# Consulter la BDD pour obtenir les indicateurs à afficher
	var valeur
	# TODO

	# KPI
	# Ligne 1
	var KPI_RapideTitre = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau/KPI_RapideTitre
	KPI_RapideTitre.set_title("Le Plus")
	KPI_RapideTitre.set_value("Rapide")
	KPI_RapideTitre.set_color(Color("e6e6ffff"), Color('BLUE'))
	KPI_RapideTitre.set_minimum_size(Vector2(120,50))

	var KPI_RapideTemps = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau/KPI_RapideTemps
	KPI_RapideTemps.set_title("Temps")
	valeur = str(StatsService.plateau_plus_rapide_en_ms()) + 'ms'
	KPI_RapideTemps.set_value(valeur)
	KPI_RapideTemps.set_color(Color("ffe6f3ff"), Color('DEEP_PINK'))
	KPI_RapideTemps.set_minimum_size(Vector2(120,50))

	var KPI_RapideDifficulte = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau/KPI_RapideDifficulte
	KPI_RapideDifficulte.set_title("Difficulté")
	valeur = StatsService.plateau_plus_rapide_difficulte()
	KPI_RapideDifficulte.set_value(valeur)
	KPI_RapideDifficulte.set_color(Color("fff0e3ff"), Color('CRIMSON'))
	KPI_RapideDifficulte.set_minimum_size(Vector2(120,50))
	
	# TODO : representer le plateau en miniature

	# Ligne 2
	var KPI_LentTitre = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau2/KPI_LentTitre
	KPI_LentTitre.set_title("Le Plus")
	KPI_LentTitre.set_value("Lent")
	KPI_LentTitre.set_color(Color("e6e6ffff"), Color('BLUE'))
	KPI_LentTitre.set_minimum_size(Vector2(120,50))

	var KPI_LentTemps = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau2/KPI_LentTemps
	KPI_LentTemps.set_title("Temps")
	valeur = str(StatsService.plateau_plus_lent_en_ms()) + 'ms'
	KPI_LentTemps.set_value(valeur)
	KPI_LentTemps.set_color(Color("ffe6f3ff"), Color('DEEP_PINK'))
	KPI_LentTemps.set_minimum_size(Vector2(120,50))

	var KPI_LentDifficulte = $Marge/HBoxContainer/VBoxContainer/KPI_Plateau2/KPI_LentDifficulte
	KPI_LentDifficulte.set_title("Difficulté")
	valeur = StatsService.plateau_plus_lent_difficulte()
	KPI_LentDifficulte.set_value(valeur)
	KPI_LentDifficulte.set_color(Color("fff0e3ff"), Color('CRIMSON'))
	KPI_LentDifficulte.set_minimum_size(Vector2(120,50))
	
	# TODO : representer le plateau en miniature

func arrondir_pourcentage(pourcentage: float) -> float:
	if pourcentage < 1.0:
		# 2 decimales
		return round(pourcentage * 100) / 100.0
	elif pourcentage < 10.0:
		# 1 decimale
		return round(pourcentage * 10) / 10.0
	else:
		# entier
		return round(pourcentage)
