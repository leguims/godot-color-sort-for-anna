extends "res://Scenes/References/retour_menu_principal.gd"

# Unicode : https://www.unicode.org/emoji/charts/emoji-list.html
var emoji_1er = String.chr(0x1F3C6)
var emoji_2ond = String.chr(0x1F948)
var emoji_3eme = String.chr(0x1F949)

var liste_format_scores = {
	'entete': "[outline_size=10][color=white][center]\n",
	1: "[font_size=60][color=gold]" + emoji_1er + "score[/color][/font_size]\n",
	2: "[font_size=50][color=silver]" + emoji_2ond + "score[/color][/font_size]\n",
	3: "[font_size=40][color=#CD7F32]" + emoji_3eme + "score[/color][/font_size]\n",
	4: "[font_size=30]score[/font_size]\n",
	5: "[font_size=30]score[/font_size]\n",
	'pied_de_page': "[/center][/color][/outline_size]\n",
	}

func _ready() -> void:
	# Realiser le classement des joueurs
	var dico_rang_nom_joueur = GestionScore.lire_rang_des_joueurs()

	# Remplir chaque score dans la liste des scores
	var liste_score_bbcode : String = ''
	liste_score_bbcode += liste_format_scores.get('entete')
	for rang in range(1, 6):
		if rang in dico_rang_nom_joueur:
			var score = dico_rang_nom_joueur.get(rang).get('score')
			var score_texte = GestionScore.nombre_avec_separateur_de_milliers(score, '.')
			for nom_joueur in  dico_rang_nom_joueur.get(rang).get('liste_joueurs'):
				score_texte = nom_joueur + " " + score_texte
				var texte_bbcode = liste_format_scores.get(rang)
				texte_bbcode = texte_bbcode.replace('score', score_texte)
				liste_score_bbcode += texte_bbcode
	liste_score_bbcode += liste_format_scores.get('pied_de_page')
	$ListeScores.bbcode_text = liste_score_bbcode
