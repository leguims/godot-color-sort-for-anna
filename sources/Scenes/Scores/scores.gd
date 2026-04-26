extends "res://Scenes/References/retour_menu_principal.gd"

var liste_format_scores = {
	'entete': "[outline_size=10][color=white][center]\n",
	1: "[font_size=60][color=gold]score[/color][/font_size]\n",
	2: "[font_size=50][color=silver]score[/color][/font_size]\n",
	3: "[font_size=40][color=#CD7F32]score[/color][/font_size]\n",
	4: "[font_size=30]score[/font_size]\n",
	5: "[font_size=30]score[/font_size]\n",
	'pied_de_page': "[/center][/color][/outline_size]\n",
	}

func _ready() -> void:
	# Realiser le classement des joueurs
	var classement = SauvegardeTableauDesScoresService.retourner_classement()

	# Remplir chaque score dans la liste des scores
	var liste_score_bbcode : String = ''
	liste_score_bbcode += liste_format_scores.get('entete')
	for i in range(5): # TOP 5
		var joueur = classement.pop_front()
		if joueur:
			var rang_joueur = joueur.get('rang')
			var score_texte = joueur.get('nom') + " " + joueur.get('score_txt')
			if 1 <= rang_joueur and rang_joueur <= 3:
				score_texte = SauvegardeTableauDesScoresService.lire_le_trophee_du_rang(rang_joueur) + score_texte
			# int(rang_joueur) car 'rang_joueur' est vu comme un float !
			var texte_bbcode = liste_format_scores.get(int(rang_joueur))
			texte_bbcode = texte_bbcode.replace('score', score_texte)
			liste_score_bbcode += texte_bbcode
	liste_score_bbcode += liste_format_scores.get('pied_de_page')
	$ListeScores.bbcode_text = liste_score_bbcode
