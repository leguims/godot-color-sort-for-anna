extends Control

func _ready():
	campagne()
	ascensions()
	

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
	# KPI
	var KPI_Completion = $Marge/HBoxContainer/VBoxContainer/KPI_Campagne/KPI_Completion
	KPI_Completion.set_title("Complétion")
	KPI_Completion.set_value("33%")
	KPI_Completion.set_color(Color("e6e6ffff"), Color('BLUE'))
	KPI_Completion.set_minimum_size(Vector2(105,50))

	var KPI_Temps = $Marge/HBoxContainer/VBoxContainer/KPI_Campagne/KPI_Temps
	KPI_Temps.set_title("Temps")
	KPI_Temps.set_value("5h 30")
	KPI_Temps.set_color(Color("BLACK"), Color('SPRING_GREEN'))
	KPI_Temps.set_minimum_size(Vector2(105,50))

	var KPI_TauxReussite = $Marge/HBoxContainer/VBoxContainer/KPI_Campagne/KPI_TauxReussite
	KPI_TauxReussite.set_title("Réussite")
	KPI_TauxReussite.set_value("82%")
	KPI_TauxReussite.set_color(Color("fff4e6ff"), Color('DARK_ORANGE'))
	KPI_TauxReussite.set_minimum_size(Vector2(105,50))

	var KPI_SerieMaximumSucces = $Marge/HBoxContainer/VBoxContainer/KPI_Campagne/KPI_SerieMaximumSucces
	KPI_SerieMaximumSucces.set_title("Série Max.")
	KPI_SerieMaximumSucces.set_value(12)
	KPI_SerieMaximumSucces.set_color(Color("ffe6f3ff"), Color('DEEP_PINK'))
	KPI_SerieMaximumSucces.set_minimum_size(Vector2(105,50))

func ascensions():
	# KPI
	# Ligne 1
	var KPI_Completion = $Marge/HBoxContainer/VBoxContainer/KPI_Ascension/KPI_Completion
	KPI_Completion.set_title("Complétion")
	KPI_Completion.set_value("66%")
	KPI_Completion.set_color(Color("e6e6ffff"), Color('BLUE'))
	KPI_Completion.set_minimum_size(Vector2(120,50))

	var KPI_Parfait = $Marge/HBoxContainer/VBoxContainer/KPI_Ascension/KPI_Parfait
	KPI_Parfait.set_title("Parfait")
	KPI_Parfait.set_value("1")
	KPI_Parfait.set_color(Color("GOLD"), Color('BLACK'))
	KPI_Parfait.set_minimum_size(Vector2(120,50))

	var KPI_Longueur = $Marge/HBoxContainer/VBoxContainer/KPI_Ascension/KPI_Longueur
	KPI_Longueur.set_title("Longueur Max.")
	KPI_Longueur.set_value("50")
	KPI_Longueur.set_color(Color("fff0e3ff"), Color('CRIMSON'))
	KPI_Longueur.set_minimum_size(Vector2(120,50))

	# Ligne 2
	var KPI_DureeMoyenne = $Marge/HBoxContainer/VBoxContainer/KPI_Ascension2/KPI_DureeMoyenne
	KPI_DureeMoyenne.set_title("Durée Moy.")
	KPI_DureeMoyenne.set_value("3min 07s")
	KPI_DureeMoyenne.set_color(Color("fff0ffff"), Color('MAROON'))
	KPI_DureeMoyenne.set_minimum_size(Vector2(120,50))

	var KPI_Terminees = $Marge/HBoxContainer/VBoxContainer/KPI_Ascension2/KPI_Terminees
	KPI_Terminees.set_title("Terminées")
	KPI_Terminees.set_value(3)
	KPI_Terminees.set_color(Color("ffe6f3ff"), Color('DEEP_PINK'))
	KPI_Terminees.set_minimum_size(Vector2(120,50))
