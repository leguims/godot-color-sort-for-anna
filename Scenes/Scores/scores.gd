extends "res://Scenes/References/retour_menu_principal.gd"

var liste_scores = {
	'entete': "[outline_size=10][color=white][center]\n",
	1: "[font_size=60][color=gold]score[/color][/font_size]\n",
	2: "[font_size=50][color=silver]score[/color][/font_size]\n",
	3: "[font_size=40][color=#CD7F32]score[/color][/font_size]\n",
	4: "[font_size=30]score\n",
	5: "score[/font_size]\n",
	'pied_de_page': "[/center][/color][/outline_size]\n",
	}

func _ready() -> void:
	# Remplir chaque score dans la liste des scores
	var liste_score_bbcode : String
	
	var score = GestionScore.score()
	liste_score_bbcode += liste_scores.get('entete')
	var texte_bbcode = liste_scores.get(1)
	texte_bbcode = texte_bbcode.replace('score', str(score))
	liste_score_bbcode += texte_bbcode
	liste_score_bbcode += liste_scores.get('pied_de_page')
	$ListeScores.bbcode_text = liste_score_bbcode
	#var top_5 = GestionScore.lire_top_5()
	#liste_score_bbcode += liste_scores.get('entete')
	#for score in GestionScore.lire_top_5():
	#	var classement = score.get('classement')
	#	var niveau = score.get('niveau')
	#	var plateau = score.get('plateau')
	#	var nombre_de_partie = score.get('nombre_de_partie')
	#	var texte_bbcode = liste_scores.get(classement)
	#	texte_bbcode = texte_bbcode.replace('score', "Niv. "+ str(niveau) + "." + str(plateau) + " /"+ str(nombre_de_partie))
	#	liste_score_bbcode += texte_bbcode
	#liste_score_bbcode += liste_scores.get('pied_de_page')
	#$ListeScores.bbcode_text = liste_score_bbcode
