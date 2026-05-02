extends Control

func _ready():
	# KPI
	var KPI_AverageDuration = $Marge/HBoxContainer/VBoxContainer/KPIRow/KPI_AverageDuration
	KPI_AverageDuration.set_title("Durée Moyenne")
	KPI_AverageDuration.set_value("3 min 42")
	KPI_AverageDuration.set_color(Color("e6e6ffff"), Color('BLUE'))
	KPI_AverageDuration.set_minimum_size(Vector2(150,50))
	var KPI_MaxLevel = $Marge/HBoxContainer/VBoxContainer/KPIRow/KPI_MaxLevel
	KPI_MaxLevel.set_title("Niveau Max")
	KPI_MaxLevel.set_value(12)
	KPI_MaxLevel.set_color(Color("fff4e6ff"), Color('DARK_ORANGE'))
	KPI_MaxLevel.set_minimum_size(Vector2(135,50))

	var KPI_TotalPlaytime = $Marge/HBoxContainer/VBoxContainer/KPIRow/KPI_TotalPlaytime
	KPI_TotalPlaytime.set_title("Temps Total")
	KPI_TotalPlaytime.set_value("5h 30")
	KPI_TotalPlaytime.set_color(Color("ffe6f3ff"), Color('DEEP_PINK'))
	KPI_TotalPlaytime.set_minimum_size(Vector2(135,50))

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
