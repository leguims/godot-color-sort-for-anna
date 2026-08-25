extends Control

enum Ecran { JOUER, SCORES, REFERENCES, GAMEPLAY }

@export var ecran: Ecran = Ecran.JOUER

var _indicateurs_joueurs: Array[Control] = []

const BLEU := Color("172943")
const BLEU_2 := Color("223a59")
const CREME := Color("fff4df")
const CREME_2 := Color("f8dfbd")
const ABRICOT := Color("ef9b60")
const CORAIL := Color("ef6f5d")
const TEXTE := Color("24364c")
const TEXTE_JOUER := Color("183653")
const TEXTE_SCORES := Color("102f55")
const TAUPE := Color("d8c39f")

const FONDS := [
	preload("res://Art/UI/Validated/jouer_background.png"),
	preload("res://Art/UI/Validated/scores_background.png"),
	preload("res://Art/UI/Validated/references_background.png"),
	preload("res://Art/UI/Validated/originel_gameplay_background.png"),
]
const HERO_SCORES := preload("res://Art/UI/Validated/scores_hero.png")
const REFERENCE_JOUER := preload("res://Art/UI/ReferencesValidated/reference_jouer_validee.png")
const REFERENCE_SCORES := preload("res://Art/UI/ReferencesValidated/reference_scores_validee.png")
const REFERENCE_REFERENCES := preload("res://Art/UI/ReferencesValidated/reference_references_validee.png")
const SCORES_TOP_LOCKED := preload("res://Art/UI/Validated/Scores/scores_top_locked.png")
const ICON_SCORES := preload("res://Art/Images/MenuPrincipal/icon_records.png")
const ICON_REFERENCES := preload("res://Art/Images/MenuPrincipal/icon_about.png")
const ICON_MUSIC := preload("res://Art/Images/MenuPrincipal/icon_music.png")
const ICON_SOUND := preload("res://Art/Images/MenuPrincipal/icon_sound.png")


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	get_viewport().size_changed.connect(_adapter)
	_adapter()
	_capture_si_demandee()


func _adapter() -> void:
	var viewport := get_viewport_rect().size
	var facteur := minf(viewport.x / 480.0, viewport.y / 720.0)
	$Interface.scale = Vector2.ONE * facteur
	$Interface.position = (viewport - Vector2(480, 720) * facteur) * 0.5


func _build() -> void:
	var base := ColorRect.new()
	base.name = "FondCremeTechnique"
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base.color = Color("f9dfbd")
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(base)

	var fond := TextureRect.new()
	fond.name = "DecorStatiqueReference" if ecran == Ecran.JOUER else "FondValide"
	if ecran == Ecran.JOUER:
		fond.position = Vector2(54, 0)
		fond.size = Vector2(372, 720)
		fond.texture = REFERENCE_JOUER
	elif ecran == Ecran.SCORES:
		fond.position = Vector2(52, 0)
		fond.size = Vector2(376, 720)
		fond.texture = REFERENCE_SCORES
	elif ecran == Ecran.REFERENCES:
		fond.position = Vector2(52, 0)
		fond.size = Vector2(376, 720)
		fond.texture = REFERENCE_REFERENCES
	else:
		fond.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		fond.texture = FONDS[ecran]
	fond.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fond.stretch_mode = TextureRect.STRETCH_SCALE if ecran in [Ecran.JOUER, Ecran.SCORES, Ecran.REFERENCES] else TextureRect.STRETCH_KEEP_ASPECT_COVERED
	fond.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fond)

	var interface := Control.new()
	interface.name = "Interface"
	interface.custom_minimum_size = Vector2(480, 720)
	interface.size = Vector2(480, 720)
	add_child(interface)

	match ecran:
		Ecran.JOUER:
			_jouer(interface)
		Ecran.SCORES: _scores(interface)
		Ecran.REFERENCES: _references(interface)
		Ecran.GAMEPLAY: _gameplay(interface)


func _jouer(root: Control) -> void:
	# Le décor, le titre et le retour sont les pixels statiques exacts de la
	# référence. Cette carte opaque masque l'ancienne UI rasterisée sans tenter
	# de reconstruire les zones qu'elle recouvre.
	var carte := _panel(root, Rect2(93, 159, 294, 527), Color("fff1d9"), 20, Color(1, 1, 1, 0.72), 1)
	carte.name = "CartePrincipale"
	_draw_players_icon(carte, Vector2(16, 27), BLEU)
	_label(carte, Rect2(42, 24, 236, 20), "JOUEURS", 11, BLEU, HORIZONTAL_ALIGNMENT_LEFT, 0.45)
	var alain := _panel(carte, Rect2(14, 51, 266, 52), Color("fff8e9"), 13, Color(TAUPE, 0.56), 1)
	alain.name = "Joueur0"
	_avatar(alain, Vector2(12, 10), BLEU, false)
	var nom_alain := _label(alain, Rect2(53, 10, 175, 30), "Alain Konu", 14, TEXTE_JOUER, HORIZONTAL_ALIGNMENT_LEFT, 0.30)
	nom_alain.name = "NomJoueur"
	var indicateur_alain := _indicateur_selection(alain, Vector2(230, 14), false)
	_indicateurs_joueurs.append(indicateur_alain)
	_zone_clic_joueur(alain, 0)

	var anna := _panel(carte, Rect2(14, 110, 266, 52), CORAIL, 13, Color(1, 0.82, 0.73, 0.80), 1)
	anna.name = "Joueur1"
	_avatar(anna, Vector2(12, 10), Color.WHITE, true)
	var nom_anna := _label(anna, Rect2(53, 10, 175, 30), "Anna", 14, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT, 0.30)
	nom_anna.name = "NomJoueur"
	var indicateur_anna := _indicateur_selection(anna, Vector2(230, 14), true)
	_indicateurs_joueurs.append(indicateur_anna)
	_zone_clic_joueur(anna, 1)

	var ajouter := _panel(carte, Rect2(14, 169, 266, 52), Color("fff4df"), 13)
	ajouter.name = "AjouterJoueur"
	_dashed_border(ajouter, Rect2(0, 0, 266, 52), Color(TEXTE_JOUER, 0.40), 7, 5)
	var plus := _panel(ajouter, Rect2(14, 11, 30, 30), BLEU, 15)
	_label(plus, Rect2(0, 1, 30, 27), "+", 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER)
	_label(ajouter, Rect2(54, 11, 190, 30), "Ajouter un joueur", 14, TEXTE_JOUER, HORIZONTAL_ALIGNMENT_LEFT, 0.24)

	var continuer := _button(carte, Rect2(14, 255, 266, 59), "Continuer", false)
	continuer.name = "BoutonContinuer"
	continuer.add_theme_font_size_override("font_size", 17)
	continuer.add_theme_font_override("font", _font_avec_poids(0.52))
	continuer.add_theme_color_override("font_color", CREME)
	continuer.add_theme_color_override("font_hover_color", Color.WHITE)
	continuer.add_theme_stylebox_override("normal", _style(BLEU, 20))
	continuer.add_theme_stylebox_override("hover", _style(BLEU_2, 20, Color(1, 1, 1, 0.35), 1))
	continuer.add_theme_stylebox_override("pressed", _style(BLEU.darkened(0.08), 20))
	_draw_play_icon(continuer, Vector2(44, 19), CREME)

	var scores := _button(carte, Rect2(14, 335, 266, 46), "", false)
	var references := _button(carte, Rect2(14, 400, 266, 46), "", false)
	scores.name = "BoutonScores"
	references.name = "BoutonReferences"
	_texture_icon(scores, Vector2(18, 10), Vector2(25, 25), ICON_SCORES)
	_texture_icon(references, Vector2(18, 10), Vector2(25, 25), ICON_REFERENCES)
	_label(scores, Rect2(56, 7, 168, 30), "Scores", 13, TEXTE_JOUER, HORIZONTAL_ALIGNMENT_LEFT, 0.26)
	_label(references, Rect2(56, 7, 168, 30), "Références", 13, TEXTE_JOUER, HORIZONTAL_ALIGNMENT_LEFT, 0.26)
	_draw_chevron(scores, Vector2(238, 16), BLEU)
	_draw_chevron(references, Vector2(238, 16), BLEU)

	# Le header et son raccord au panneau constituent une seule composition
	# graphique. Cette bande remet les pixels exacts de la référence au-dessus
	# du raccord opaque, sans recouvrir les contrôles dynamiques qui commencent
	# sous la ligne JOUEURS.
	var masque_header := Control.new()
	masque_header.name = "HeaderReferenceVerrouille"
	masque_header.position = Vector2.ZERO
	masque_header.size = Vector2(480, 190)
	masque_header.clip_contents = true
	masque_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(masque_header)

	var header := TextureRect.new()
	header.position = Vector2(54, 0)
	header.size = Vector2(372, 720)
	header.texture = REFERENCE_JOUER
	header.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	header.stretch_mode = TextureRect.STRETCH_SCALE
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	masque_header.add_child(header)

	# La flèche appartenait aux pixels de la maquette, sans Control ni
	# navigation associés. La décision produit la retire en réemployant un
	# fragment voisin du même décor statique, sans altérer l'asset source.
	var decor_sans_retour := TextureRect.new()
	decor_sans_retour.name = "MasqueFlecheRetourSupprimee"
	decor_sans_retour.position = Vector2(58, 4)
	decor_sans_retour.size = Vector2(60, 65)
	var fragment_decor := AtlasTexture.new()
	fragment_decor.atlas = REFERENCE_JOUER
	fragment_decor.region = Rect2(3, 48, 48, 53)
	decor_sans_retour.texture = fragment_decor
	decor_sans_retour.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	decor_sans_retour.stretch_mode = TextureRect.STRETCH_SCALE
	var fondu_bords := Shader.new()
	fondu_bords.code = "shader_type canvas_item;\nvoid fragment() {\n\tvec4 pixel = texture(TEXTURE, UV);\n\tvec2 uv_local = (UV - REGION_RECT.xy) / REGION_RECT.zw;\n\tfloat bord = min(min(uv_local.x, 1.0 - uv_local.x), min(uv_local.y, 1.0 - uv_local.y));\n\tpixel.a *= smoothstep(0.0, 0.16, bord);\n\tCOLOR = pixel;\n}"
	var materiau_fondu := ShaderMaterial.new()
	materiau_fondu.shader = fondu_bords
	decor_sans_retour.material = materiau_fondu
	decor_sans_retour.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(decor_sans_retour)


func _draw_players_icon(parent: Control, position_: Vector2, couleur: Color) -> void:
	_panel(parent, Rect2(position_ + Vector2(2, 1), Vector2(7, 7)), couleur, 4)
	_panel(parent, Rect2(position_ + Vector2(0, 9), Vector2(11, 6)), couleur, 4)
	_panel(parent, Rect2(position_ + Vector2(12, 4), Vector2(6, 6)), Color(couleur, 0.72), 3)
	_panel(parent, Rect2(position_ + Vector2(11, 11), Vector2(10, 5)), Color(couleur, 0.72), 3)


func _texture_icon(parent: Control, position_: Vector2, taille: Vector2, texture_: Texture2D) -> void:
	var icone := TextureRect.new()
	icone.position = position_
	icone.size = taille
	icone.texture = texture_
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone.modulate = BLEU
	icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(icone)


func _reglage_jouer(parent: Control, y: float, texte: String, texture_: Texture2D) -> void:
	var ligne := _panel(parent, Rect2(6, y, 254, 33), Color("fff8e9"), 10)
	ligne.add_theme_stylebox_override("panel", _style_sans_ombre(Color("fff8e9"), 10))
	_texture_icon(ligne, Vector2(11, 7), Vector2(18, 18), texture_)
	_label(ligne, Rect2(40, 3, 155, 27), texte, 12, TEXTE_JOUER, HORIZONTAL_ALIGNMENT_LEFT, 0.18)
	var rail := _panel(ligne, Rect2(207, 6, 39, 21), CORAIL, 11)
	_panel(rail, Rect2(20, 3, 15, 15), CREME, 8)


func _avatar(parent: Control, position_: Vector2, couleur: Color, actif: bool) -> void:
	var cercle := _panel(parent, Rect2(position_, Vector2(32, 32)), Color(couleur, 0.12 if not actif else 0.22), 16, couleur, 2)
	_panel(cercle, Rect2(12, 7, 8, 8), couleur, 4)
	_panel(cercle, Rect2(8, 17, 16, 8), couleur, 6)


func _indicateur_selection(parent: Control, position_: Vector2, selectionne: bool) -> Control:
	var indicateur := Panel.new()
	indicateur.position = position_
	indicateur.size = Vector2(24, 24)
	indicateur.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE if selectionne else Color("fff8e9")
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color("dfbd82")
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	indicateur.add_theme_stylebox_override("panel", style)
	parent.add_child(indicateur)

	var coche := Line2D.new()
	coche.name = "Coche"
	coche.points = PackedVector2Array([Vector2(6.5, 12.5), Vector2(10.5, 16.5), Vector2(18, 7.5)])
	coche.width = 2.5
	coche.default_color = CORAIL
	coche.begin_cap_mode = Line2D.LINE_CAP_ROUND
	coche.end_cap_mode = Line2D.LINE_CAP_ROUND
	coche.joint_mode = Line2D.LINE_JOINT_ROUND
	coche.antialiased = true
	coche.visible = selectionne
	indicateur.add_child(coche)
	indicateur.set_meta("selectionne", selectionne)
	return indicateur


func _zone_clic_joueur(parent: Control, indice: int) -> void:
	var zone := Button.new()
	zone.name = "ZoneClic"
	zone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	zone.flat = true
	zone.focus_mode = Control.FOCUS_NONE
	zone.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	zone.pressed.connect(_selectionner_joueur_poc.bind(indice))
	parent.add_child(zone)


func _selectionner_joueur_poc(indice_selectionne: int) -> void:
	for indice in _indicateurs_joueurs.size():
		var indicateur := _indicateurs_joueurs[indice]
		var selectionne := indice == indice_selectionne
		var style := indicateur.get_theme_stylebox("panel") as StyleBoxFlat
		style.bg_color = Color.WHITE if selectionne else Color("fff8e9")
		indicateur.get_node("Coche").visible = selectionne
		indicateur.set_meta("selectionne", selectionne)


func _draw_back_icon(parent: Control, position_: Vector2, couleur: Color) -> void:
	_color_rect(parent, Rect2(position_ + Vector2(2, 8), Vector2(18, 2)), couleur)
	var haut := _color_rect(parent, Rect2(position_ + Vector2(1, 8), Vector2(10, 2)), couleur)
	haut.rotation = deg_to_rad(-42)
	var bas := _color_rect(parent, Rect2(position_ + Vector2(1, 8), Vector2(10, 2)), couleur)
	bas.rotation = deg_to_rad(42)


func _draw_play_icon(parent: Control, position_: Vector2, couleur: Color) -> void:
	var triangle := Polygon2D.new()
	triangle.position = position_
	triangle.polygon = PackedVector2Array([Vector2(0, 0), Vector2(0, 20), Vector2(16, 10)])
	triangle.color = couleur
	parent.add_child(triangle)


func _draw_chevron(parent: Control, position_: Vector2, couleur: Color) -> void:
	var haut := _color_rect(parent, Rect2(position_, Vector2(9, 2)), couleur)
	haut.rotation = deg_to_rad(45)
	var bas := _color_rect(parent, Rect2(position_ + Vector2(6, 6), Vector2(9, 2)), couleur)
	bas.rotation = deg_to_rad(135)


func _icon_placeholder(parent: Control, position_: Vector2) -> void:
	var icone := _panel(parent, Rect2(position_, Vector2(20, 20)), Color(BLEU, 0.06), 6, Color(BLEU, 0.62), 1)
	_panel(icone, Rect2(6, 6, 8, 8), BLEU, 4)


func _dashed_border(parent: Control, rect: Rect2, couleur: Color, tiret: int, espace: int) -> void:
	var pas := tiret + espace
	for x in range(8, int(rect.size.x) - 8, pas):
		_color_rect(parent, Rect2(x, 0, min(tiret, int(rect.size.x) - x), 1), couleur)
		_color_rect(parent, Rect2(x, rect.size.y - 1, min(tiret, int(rect.size.x) - x), 1), couleur)
	for y in range(8, int(rect.size.y) - 8, pas):
		_color_rect(parent, Rect2(0, y, 1, min(tiret, int(rect.size.y) - y)), couleur)
		_color_rect(parent, Rect2(rect.size.x - 1, y, 1, min(tiret, int(rect.size.y) - y)), couleur)


func _color_rect(parent: Control, rect: Rect2, couleur: Color) -> ColorRect:
	var ligne := ColorRect.new()
	ligne.position = rect.position
	ligne.size = rect.size
	ligne.color = couleur
	ligne.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(ligne)
	return ligne


func _scores(root: Control) -> void:
	# La référence complète reste visible sur toute la hauteur. Seule l'ancienne
	# zone audio reçoit un raccord local progressif provenant du fond SCORES
	# existant ; aucun panneau opaque n'est ajouté.
	_masque_audio_scores(root)
	_bouton_retour_scores(root)

	_ajouter_score_dynamique(root, 1, Rect2(179, 282, 105, 31), Rect2(184, 277, 122, 38), Rect2(288, 282, 99, 31), Rect2(287, 276, 98, 40), "Anna", "245 836", Color("feefd5"), Color("fff9f1"), 18, 20)
	_ajouter_score_dynamique(root, 2, Rect2(179, 351, 127, 31), Rect2(184, 347, 132, 38), Rect2(344, 351, 45, 31), Rect2(339, 347, 48, 38), "Alain Konu", "0", Color("f3e7da"), Color("ede1d5"), 17, 17)
	_ajouter_score_dynamique(root, 3, Rect2(179, 405, 127, 29), Rect2(184, 401, 132, 36), Rect2(344, 405, 45, 29), Rect2(339, 401, 48, 36), "-", "-", Color("f3e7da"), Color("ede1d5"), 16, 16)
	_ajouter_score_dynamique(root, 4, Rect2(179, 457, 127, 29), Rect2(184, 453, 132, 36), Rect2(344, 457, 45, 29), Rect2(339, 453, 48, 36), "-", "-", Color("f3e7da"), Color("ede1d5"), 16, 16)
	_ajouter_score_dynamique(root, 5, Rect2(179, 509, 127, 29), Rect2(184, 505, 132, 36), Rect2(344, 509, 45, 29), Rect2(339, 505, 48, 36), "-", "-", Color("f3e7da"), Color("ede1d5"), 16, 16)

	var continuer := Button.new()
	continuer.name = "BoutonContinuer"
	continuer.position = Vector2(108, 555)
	continuer.size = Vector2(295, 52)
	continuer.flat = true
	continuer.focus_mode = Control.FOCUS_NONE
	root.add_child(continuer)


func _masque_audio_scores(parent: Control) -> void:
	var raccord := TextureRect.new()
	raccord.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	raccord.texture = FONDS[Ecran.SCORES]
	raccord.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	raccord.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	raccord.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
void fragment() {
	vec4 fond = texture(TEXTURE, UV);
	float vertical = smoothstep(0.835, 0.865, UV.y);
	float gauche = smoothstep(0.14, 0.18, UV.x);
	float droite = 1.0 - smoothstep(0.88, 0.92, UV.x);
	float masque = vertical * gauche * droite;
	COLOR = vec4(fond.rgb, fond.a * masque);
}
"""
	var materiau := ShaderMaterial.new()
	materiau.shader = shader
	raccord.material = materiau
	parent.add_child(raccord)


func _texte_score_dynamique(parent: Control, masque: Rect2, rect_label: Rect2,
		texte: String, fond: Color, taille: int, alignement: HorizontalAlignment,
		couleur: Color, poids: float, nom_masque: String = "") -> Label:
	var fond_masque := _color_rect(parent, masque, fond)
	if not nom_masque.is_empty():
		fond_masque.name = nom_masque
	return _label(parent, rect_label, texte, taille, couleur, alignement, poids)

func _ajouter_score_dynamique(parent: Control, rang: int, masque_nom: Rect2,
		rect_nom: Rect2, masque_score: Rect2, rect_score: Rect2, nom: String,
		score: String, fond_nom: Color, fond_score: Color, taille_nom: int,
		taille_score: int) -> void:
	var label_nom := _texte_score_dynamique(parent, masque_nom, rect_nom, nom,
			fond_nom, taille_nom, HORIZONTAL_ALIGNMENT_LEFT, TEXTE_SCORES, 0.28,
			"MasqueNomRang%d" % rang)
	label_nom.name = "NomRang%d" % rang
	var label_score := _texte_score_dynamique(parent, masque_score, rect_score, score,
			fond_score, taille_score, HORIZONTAL_ALIGNMENT_RIGHT,
			CORAIL if rang == 1 else TEXTE_SCORES, 0.30,
			"MasqueScoreRang%d" % rang)
	label_score.name = "ScoreRang%d" % rang

func _bouton_retour_scores(parent: Control) -> void:
	var bouton := Button.new()
	bouton.name = "BoutonRetour"
	bouton.position = Vector2(67, 20)
	bouton.size = Vector2(49, 49)
	bouton.flat = true
	bouton.focus_mode = Control.FOCUS_NONE
	parent.add_child(bouton)


func _medaille_score(parent: Control, position_: Vector2, rang: String, bord: Color, fond: Color, premiere: bool) -> void:
	var diametre := 52.0 if premiere else 44.0
	var halo_alpha := 0.18 if premiere else 0.10
	var anneau_alpha := 0.68 if premiere else 0.52
	var halo := _panel(parent, Rect2(position_, Vector2(diametre, diametre)), Color(bord, halo_alpha), int(diametre * 0.5), Color(bord, anneau_alpha), 1)
	halo.add_theme_stylebox_override("panel", _style_sans_ombre(Color(bord, halo_alpha), int(diametre * 0.5), Color(bord, anneau_alpha), 1))
	var marge := 4.0 if premiere else 3.0
	var interieur := diametre - marge * 2.0
	var medaille := _panel(halo, Rect2(marge, marge, interieur, interieur), fond, int(interieur * 0.5), bord, 1)
	medaille.add_theme_stylebox_override("panel", _style_sans_ombre(fond, int(interieur * 0.5), bord, 1))
	_label(medaille, Rect2(0, 0, interieur, interieur), rang, 20 if premiere else 16, bord.darkened(0.28), HORIZONTAL_ALIGNMENT_CENTER, 0.28)


func _lauriers_premier(parent: Control) -> void:
	for i in range(4):
		var feuille_g := _panel(parent, Rect2(-1 + i * 2, 17 + i * 8, 4, 10), Color("e6a21f"), 3)
		feuille_g.rotation = -0.55
		feuille_g.z_index = 1
		feuille_g.add_theme_stylebox_override("panel", _style_sans_ombre(Color("e6a21f"), 3))
		var feuille_d := _panel(parent, Rect2(315 - i * 2, 17 + i * 8, 4, 10), Color("e6a21f"), 3)
		feuille_d.rotation = 0.55
		feuille_d.z_index = 1
		feuille_d.add_theme_stylebox_override("panel", _style_sans_ombre(Color("e6a21f"), 3))


func _ligne_score_claire(parent: Control, y: float, rang: String, nom: String, score: String, bord_medaille: Color, fond_medaille: Color) -> void:
	_color_rect(parent, Rect2(13, y + 46, 314, 1), Color("d8cab7"))
	_medaille_score(parent, Vector2(20, y + 2), rang, bord_medaille, fond_medaille, false)
	_label(parent, Rect2(78, y + 5, 157, 38), nom, 16, TEXTE_SCORES, HORIZONTAL_ALIGNMENT_LEFT, 0.26)
	_label(parent, Rect2(238, y + 5, 64, 38), score, 16, TEXTE_SCORES, HORIZONTAL_ALIGNMENT_RIGHT, 0.22)


func _reglage_scores(parent: Control, y: float, texte: String, texture_: Texture2D) -> void:
	_texture_icon(parent, Vector2(12, y + 5), Vector2(20, 20), texture_)
	_label(parent, Rect2(44, y + 1, 170, 29), texte, 13, TEXTE_SCORES, HORIZONTAL_ALIGNMENT_LEFT, 0.18)
	var rail := _panel(parent, Rect2(239, y + 4, 42, 23), CORAIL, 12)
	_panel(rail, Rect2(21, 3, 17, 17), Color("fff8e9"), 9)


func _references(root: Control) -> void:
	# Le décor et le header sont les pixels verrouillés du pack validé. Les
	# quatre cartes sont natives ; seuls leurs pictogrammes statiques sont lus
	# directement dans la référence afin de ne pas les réinventer.
	_bouton_retour_references(root)

	_carte_reference(root, Rect2(112, 187, 289, 77), Rect2(96, 226, 72, 72), "Moteur", "Godot Engine", "godotengine.org", 205, 198)
	_carte_reference(root, Rect2(112, 273, 289, 143), Rect2(96, 337, 68, 68), "Musiques", "• Dreaming – Su Turno\n• The Three Princesses of Lilac Meadow\n• Solve The Puzzle\n• Humble Match\n• Great Little Challenge", "patrickdearteaga.com", 205, 285)
	_carte_reference(root, Rect2(112, 425, 289, 137), Rect2(98, 511, 68, 62), "Effets sonores", "• freesound.community\n• floraphonic\n• virtual_vibes\n• SoundReality\n• Dragon-Studio", "pixabay.com", 205, 437)
	_carte_reference(root, Rect2(112, 571, 289, 68), Rect2(96, 673, 70, 54), "Didacticiel", "Baba Des Bois – @BabaDesBois", "youtube.com", 205, 580)

	# L'évolution produit retire les réglages audio globaux. La courte bande de
	# transition située entre Didacticiel et l'ancien panneau est prolongée :
	# ce sont exclusivement des pixels de la référence, sans décor inventé.
	var fond_fin_atlas := AtlasTexture.new()
	fond_fin_atlas.atlas = REFERENCE_REFERENCES
	fond_fin_atlas.region = Rect2(70, 742, 336, 8)
	var fond_fin := TextureRect.new()
	fond_fin.position = Vector2(112, 647)
	fond_fin.size = Vector2(289, 73)
	fond_fin.texture = fond_fin_atlas
	fond_fin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fond_fin.stretch_mode = TextureRect.STRETCH_SCALE
	fond_fin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(fond_fin)


func _bouton_retour_references(parent: Control) -> void:
	var bouton := Button.new()
	bouton.name = "BoutonRetour"
	bouton.position = Vector2(94, 19)
	bouton.size = Vector2(45, 45)
	bouton.flat = true
	bouton.focus_mode = Control.FOCUS_NONE
	bouton.tooltip_text = "Retour"
	parent.add_child(bouton)


func _carte_reference(parent: Control, rect: Rect2, region_icone: Rect2, titre: String, corps: String, url: String, texte_x: float, texte_y: float) -> void:
	var carte := _panel(parent, rect, Color("fff5e7"), 14, Color("dcc8aa"), 1)
	# L'ombre exacte reste visible dans l'underlay : ne pas la doubler avec une
	# seconde ombre native.
	carte.add_theme_stylebox_override("panel", _style_sans_ombre(Color("fff5e7"), 14, Color("dcc8aa"), 1))

	var atlas := AtlasTexture.new()
	atlas.atlas = REFERENCE_REFERENCES
	atlas.region = region_icone
	var icone := TextureRect.new()
	icone.position = Vector2(14, 12)
	icone.size = Vector2(56, minf(56.0, rect.size.y - 24.0))
	icone.texture = atlas
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	carte.add_child(icone)

	var x_local := texte_x - rect.position.x
	var y_local := texte_y - rect.position.y
	_label(carte, Rect2(x_local, y_local, rect.size.x - x_local - 12, 21), titre, 14, Color("163657"), HORIZONTAL_ALIGNMENT_LEFT, 0.38)

	var corps_y := y_local + 21
	var url_h := 18.0
	var url_y := rect.size.y - url_h - 8.0
	var taille_corps := 9 if titre == "Musiques" else 10
	var corps_label := _label(carte, Rect2(x_local, corps_y, rect.size.x - x_local - 10, maxf(18.0, url_y - corps_y)), corps, taille_corps, Color("183a5d"), HORIZONTAL_ALIGNMENT_LEFT, 0.10)
	corps_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	corps_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	corps_label.add_theme_constant_override("line_spacing", -2)
	var lien := _label(carte, Rect2(x_local, url_y, rect.size.x - x_local - 10, url_h), url, 10, Color("e74838"), HORIZONTAL_ALIGNMENT_LEFT, 0.14)
	lien.mouse_filter = Control.MOUSE_FILTER_STOP
	lien.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _gameplay(root: Control) -> void:
	_button(root, Rect2(22, 20, 105, 42), "‹  MENU", false)
	_button(root, Rect2(353, 20, 105, 42), "★  SCORES", false)
	var joueur := _panel(root, Rect2(187, 20, 106, 42), CREME, 18)
	_label(joueur, Rect2(8, 8, 90, 25), "Anna", 15, TEXTE, HORIZONTAL_ALIGNMENT_CENTER)
	var badge := _panel(root, Rect2(145, 76, 190, 48), BLEU, 20)
	_label(badge, Rect2(14, 8, 38, 30), "◆", 19, CREME, HORIZONTAL_ALIGNMENT_CENTER)
	_label(badge, Rect2(54, 9, 120, 28), "ORIGINEL", 17, CREME, HORIZONTAL_ALIGNMENT_CENTER)
	var plateau := _panel(root, Rect2(24, 140, 432, 404), Color(0.98, 0.96, 0.90, 0.90), 28, Color("d4c09e"), 2)
	_label(plateau, Rect2(24, 18, 384, 22), "ZONE DE PLATEAU RESPONSIVE", 11, Color(TEXTE, 0.44), HORIZONTAL_ALIGNMENT_CENTER)
	for rang in 2:
		for col in 5:
			var pile := _panel(plateau, Rect2(23 + col * 77, 68 + rang * 145, 62, 119), Color("d5c4a4"), 15)
			for jeton in 3:
				_panel(pile, Rect2(15, 66 - jeton * 25, 32, 32), [Color("f28a1c"), Color("7058b2"), Color("5aabd7")][(col + jeton) % 3], 7)
	_button(root, Rect2(64, 566, 352, 56), "JOUER", true)
	_button(root, Rect2(112, 632, 256, 42), "RELANCER LA PARTIE", false)
	_label(root, Rect2(45, 678, 390, 24), "Recommence le plateau en cours.", 11, Color(TEXTE, 0.66), HORIZONTAL_ALIGNMENT_CENTER)


func _score(parent: Control, y: float, rang: String, nom: String, valeur: String) -> void:
	var ligne := _panel(parent, Rect2(22, y, 360, 50), CREME, 15)
	_label(ligne, Rect2(12, 9, 34, 30), rang, 15, TEXTE, HORIZONTAL_ALIGNMENT_CENTER)
	_label(ligne, Rect2(56, 10, 190, 28), nom, 15, TEXTE)
	_label(ligne, Rect2(252, 10, 92, 28), valeur, 15, TEXTE, HORIZONTAL_ALIGNMENT_RIGHT)


func _ref_card(parent: Control, rect: Rect2, icone: String, titre: String, corps: String) -> void:
	var carte := _panel(parent, rect, CREME, 19)
	_label(carte, Rect2(13, 12, 38, 32), icone, 20, CORAIL, HORIZONTAL_ALIGNMENT_CENTER)
	_label(carte, Rect2(13, 51, 150, 22), titre, 13, TEXTE)
	_label(carte, Rect2(13, 76, 150, 40), corps, 11, Color(TEXTE, 0.72))


func _reglage(parent: Control, y: float, icone: String, texte: String) -> void:
	var ligne := _panel(parent, Rect2(22, y, 366, 47), Color(1, 0.94, 0.83, 0.75), 15)
	_label(ligne, Rect2(12, 9, 32, 28), icone, 18, BLEU, HORIZONTAL_ALIGNMENT_CENTER)
	_label(ligne, Rect2(50, 10, 210, 26), texte, 15, TEXTE)
	_switch(ligne, Vector2(299, 10))


func _reglage_compact(parent: Control, y: float, texte: String) -> void:
	_label(parent, Rect2(25, y, 220, 28), texte, 13, CREME)
	_switch(parent, Vector2(330, y + 1))


func _switch(parent: Control, position_: Vector2) -> void:
	var rail := _panel(parent, Rect2(position_, Vector2(50, 27)), CORAIL, 14)
	_panel(rail, Rect2(26, 3, 21, 21), CREME, 11)


func _button(parent: Control, rect: Rect2, texte: String, principal: bool) -> Button:
	var bouton := Button.new()
	bouton.position = rect.position
	bouton.size = rect.size
	bouton.text = texte
	bouton.add_theme_font_size_override("font_size", 16 if principal else 13)
	bouton.add_theme_color_override("font_color", Color.WHITE if principal else TEXTE)
	bouton.add_theme_stylebox_override("normal", _style(CORAIL if principal else CREME, 18))
	bouton.add_theme_stylebox_override("hover", _style(CORAIL.lightened(0.08) if principal else Color.WHITE, 18))
	bouton.add_theme_stylebox_override("pressed", _style(CORAIL.darkened(0.10) if principal else CREME_2, 18))
	parent.add_child(bouton)
	return bouton


func _label(parent: Control, rect: Rect2, texte: String, taille: int, couleur: Color, alignement := HORIZONTAL_ALIGNMENT_LEFT, poids := 0.0) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = texte
	label.add_theme_font_size_override("font_size", taille)
	if poids > 0.0:
		label.add_theme_font_override("font", _font_avec_poids(poids))
	label.add_theme_color_override("font_color", couleur)
	label.horizontal_alignment = alignement
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	parent.add_child(label)
	return label


func _font_avec_poids(poids: float) -> FontVariation:
	var font := FontVariation.new()
	font.base_font = ThemeDB.fallback_font
	font.variation_embolden = poids
	return font


func _style_sans_ombre(couleur: Color, rayon: int, bordure := Color.TRANSPARENT, largeur := 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = couleur
	style.corner_radius_top_left = rayon
	style.corner_radius_top_right = rayon
	style.corner_radius_bottom_left = rayon
	style.corner_radius_bottom_right = rayon
	style.border_width_left = largeur
	style.border_width_top = largeur
	style.border_width_right = largeur
	style.border_width_bottom = largeur
	style.border_color = bordure
	return style


func _panel(parent: Control, rect: Rect2, couleur: Color, rayon: int, bordure := Color.TRANSPARENT, largeur := 0) -> Panel:
	var panel := Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _style(couleur, rayon, bordure, largeur))
	parent.add_child(panel)
	return panel


func _style(couleur: Color, rayon: int, bordure := Color.TRANSPARENT, largeur := 0) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = couleur
	style.corner_radius_top_left = rayon
	style.corner_radius_top_right = rayon
	style.corner_radius_bottom_left = rayon
	style.corner_radius_bottom_right = rayon
	style.border_width_left = largeur
	style.border_width_top = largeur
	style.border_width_right = largeur
	style.border_width_bottom = largeur
	style.border_color = bordure
	style.shadow_color = Color(0, 0, 0, 0.18)
	style.shadow_size = 7 if rayon >= 24 else 3
	style.shadow_offset = Vector2(0, 4 if rayon >= 24 else 2)
	return style


func _capture_si_demandee() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--capture="):
			await get_tree().process_frame
			await get_tree().process_frame
			var image := get_viewport().get_texture().get_image()
			if image != null:
				image.save_png(argument.trim_prefix("--capture="))
			get_tree().quit()
