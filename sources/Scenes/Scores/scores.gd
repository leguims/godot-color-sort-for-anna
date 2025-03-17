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
	# Remplir chaque score dans la liste des scores
	var liste_score_bbcode : String = ''
	
	# TODO : Rallier 'GestionScore.lire_classement_des_joueurs'
	# Realiser le classement des joueurs
	var liste_score_croissant = []
	var dico_score_nom_joueur = {}
	for nom_joueur in GestionScore.lire_la_liste_des_joueurs():
		var score = GestionScore.lire_le_score_du_joueur(nom_joueur)
		liste_score_croissant.append(score)
		if score not in dico_score_nom_joueur:
			dico_score_nom_joueur[score] = [nom_joueur]
		else:
			# Score égalité
			dico_score_nom_joueur[score].append(nom_joueur)
	liste_score_croissant.sort() # Classement croissant des scores
	
	liste_score_bbcode += liste_format_scores.get('entete')
	for rang in range(1, 6):
		var score = liste_score_croissant.pop_back()
		if score:
			var nom_joueur = dico_score_nom_joueur.get(score).pop_front()
			var score_texte = nom_joueur + " " + str(score)
			var texte_bbcode = liste_format_scores.get(rang)
			texte_bbcode = texte_bbcode.replace('score', score_texte)
			liste_score_bbcode += texte_bbcode
	liste_score_bbcode += liste_format_scores.get('pied_de_page')
	$ListeScores.bbcode_text = liste_score_bbcode
