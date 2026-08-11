extends RefCounted
class_name FormatterMenuCampagne

# Infos joueur
###############
var nom : String = ""
var trophee : String = ""
var pourcentage_ascension_realise : int = 0
var pourcentage_campagne_realise : int = 0
var score_texte : String = "0"

func enregistrer_infos_joueur(	_nom : String = "",
								_trophee : String = "",
								_pourcentage_ascension_realise : int = 0,
								_pourcentage_campagne_realise : int = 0,
								_score_texte : String = "0") -> void:
	nom = _nom
	trophee = _trophee
	pourcentage_ascension_realise = _pourcentage_ascension_realise
	pourcentage_campagne_realise = _pourcentage_campagne_realise
	score_texte = _score_texte

func formater_infos_joueur() -> String:
	var texte = "[center][font_size=30]"
	texte += nom + " " + trophee + " " + score_texte + "\n"
	texte += "[font_size=20]Ascension : " + String.num_int64(pourcentage_ascension_realise) + "%"
	texte += " - "
	texte += "Campagne : " + String.num_int64(pourcentage_campagne_realise) + "%[/font_size]"
	texte += "[/font_size][/center]"
	return texte


# MessageRiche
##############

func formater_detail_score(detail_score : Dictionary) -> Dictionary:
	# Afficher le détail du score.
	var bbcode_complet = ''
	var score_total = 0
	var size_y = 300

	# Entete
	bbcode_complet += """[color=#efefef][font_size=30][center][b]Score[/b][/center][/font_size]"""

	# 'duree'
	var bbcode_duree = """[left][font_size=20][b]Temps[/b] :
[ul] Référence: #duree_ref#s[/ul]
[ul] Réalisé: #duree_real#s[/ul]
[ul] #duree_pts# points[/ul]"""
	bbcode_duree = bbcode_duree.replace('#duree_ref#', str(detail_score.get('duree').get('reference')))
	bbcode_duree = bbcode_duree.replace('#duree_real#', str( snapped(detail_score.get('duree').get('realise'), 0.1) ))
	var points_txt = SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score.get('duree').get('points'), '.')
	bbcode_duree = bbcode_duree.replace('#duree_pts#', points_txt)
	bbcode_complet += bbcode_duree
	score_total += detail_score.get('duree').get('points')

	# ratio_reussite
	var bbcode_ratio_reussite = """[b]Ratio Réussite[/b]
[ul] Réalisé: #ratio_real#%[/ul]
[ul] #ratio_pts# points[/ul]"""
	bbcode_ratio_reussite = bbcode_ratio_reussite.replace('#ratio_real#', str(detail_score.get('ratio_reussite').get('ratio')))
	points_txt = SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score.get('ratio_reussite').get('points'), '.')
	bbcode_ratio_reussite = bbcode_ratio_reussite.replace('#ratio_pts#', points_txt)
	bbcode_complet += bbcode_ratio_reussite
	score_total += detail_score.get('ratio_reussite').get('points')

	# ascension
	if detail_score.get('ascension'):
		var bbcode_ascension = """[b]Ascension[/b]
[ul] Longueur: #asc_long# plateaux[/ul]
[ul] #asc_pts# points[/ul]"""
		bbcode_ascension = bbcode_ascension.replace('#asc_long#', str(detail_score.get('ascension').get('longueur')))
		points_txt = SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score.get('ascension').get('points'), '.')
		bbcode_ascension = bbcode_ascension.replace('#asc_pts#', points_txt)
		bbcode_complet += bbcode_ascension
		score_total += detail_score.get('ascension').get('points')
		size_y += 80

	# ascension_sans_detour
	if detail_score.get('ascension_sans_detour'):
		var bbcode_ascension_sans_detour = """[b]Ascension sans détour[/b]
[ul] Bonus: #asc_detour_bonus#[/ul]
[ul] #asc_detour_pts# points[/ul]"""
		bbcode_ascension_sans_detour = bbcode_ascension_sans_detour.replace('#asc_detour_bonus#', str(detail_score.get('ascension_sans_detour').get('bonus')))
		points_txt = SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score.get('ascension_sans_detour').get('points'), '.')
		bbcode_ascension_sans_detour = bbcode_ascension_sans_detour.replace('#asc_detour_pts#', points_txt)
		bbcode_complet += bbcode_ascension_sans_detour
		score_total += detail_score.get('ascension_sans_detour').get('points')
		size_y += 80

	# campagne
	if  detail_score.get('campagne'):
		var bbcode_campagne = """[b]Campagne[/b]
[ul] #campag_pts# points[/ul]"""
		points_txt = SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(detail_score.get('campagne').get('points'), '.')
		bbcode_campagne = bbcode_campagne.replace('#campag_pts#', points_txt)
		bbcode_complet += bbcode_campagne
		score_total += detail_score.get('campagne').get('points')
		size_y += 60

	# total
	var bbcode_total = """[/font_size][/left][font_size=30][center][b]Total : #total_pts#[/b][/center][/font_size][/color]"""
	points_txt = SauvegardeTableauDesScoresService.nombre_avec_separateur_de_milliers(score_total, '.')
	bbcode_total = bbcode_total.replace('#total_pts#', points_txt)
	bbcode_complet += bbcode_total

	# Afficher le score
	return {'bbcode':bbcode_complet, 'size_y':size_y}
