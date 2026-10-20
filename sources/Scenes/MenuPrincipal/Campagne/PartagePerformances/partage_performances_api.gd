extends Node

class_name PartagePerformancesAPI

signal partage_qr_code(donnees_json: Dictionary)
signal erreur_decodage_qr(message: String)

const LOGIQUE := preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_logic.gd")
const QR_SCRIPT_PATH := "res://addons/QRPlugin/QR.gd"
const POLICE_SOUS_TITRE := "res://Art/UI/Fonts/TeXGyreAdventor/texgyreadventor-bold.otf"
var _logique: PartagePerformancesLogic = LOGIQUE.new()
var _qr_scanner: Node

## Retourne le nom du joueur et les enregistrements de son dernier niveau.
func lire_donnees_dernier_niveau() -> Dictionary:
	return {
		"joueur": SauvegardeBddJoueursService.lire_nom_joueur(),
		"campagne": SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_derniere_campagne(),
		"niveau": SauvegardeBddJoueursService.enregistrement_campagne_lire_dernier_niveau()
	}

## Prépare les données JSON du niveau, leur signature HMAC et le contenu du QR.
func preparer_partage(enregistrements: Dictionary) -> Dictionary:
	var cle_hmac: String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	return _logique.preparer_enveloppe(enregistrements, cle_hmac)

## Génère l'image du QR avec le plugin natif sur Android ou iOS.
func generer_image_qr(contenu: String) -> Dictionary:
	return _logique.generer_image_qr(contenu, self)

## Compose l'image QR avec les libellés destinés aux joueurs.
func ajouter_sous_titre_qr(image_qr: Image) -> Dictionary:
	if image_qr == null or image_qr.is_empty():
		return {"succes": false, "erreur": "L'image du QR est vide."}
	var texte_sous_titre := lire_sous_titre_qr()
	if texte_sous_titre.is_empty():
		return {"succes": false, "erreur": "Le nom du joueur ou sa campagne ou son niveau est indisponible."}
	var police := load(POLICE_SOUS_TITRE) as Font
	if police == null:
		return {"succes": false, "erreur": "La police du sous-titre QR est introuvable."}

	var taille_police := 22
	while taille_police > 12 and police.get_string_size(
		texte_sous_titre,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		taille_police
	).x > image_qr.get_width() - 48:
		taille_police -= 1
	while police.get_string_size(
		texte_sous_titre,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		taille_police
	).x > image_qr.get_width() - 48:
		var candidat := texte_sous_titre.left(texte_sous_titre.length() - 1).strip_edges() + "..."
		if police.get_string_size(
			candidat,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			taille_police
		).x <= image_qr.get_width() - 48:
			texte_sous_titre = candidat
			break
		texte_sous_titre = texte_sous_titre.left(texte_sous_titre.length() - 1).strip_edges()
	if texte_sous_titre.is_empty():
		return {"succes": false, "erreur": "Le sous-titre QR est trop long."}

	var hauteur_sous_titre := 78
	var viewport := SubViewport.new()
	viewport.size = Vector2i(image_qr.get_width(), hauteur_sous_titre)
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

	var fond := ColorRect.new()
	fond.color = Color.WHITE
	fond.size = Vector2(viewport.size)
	viewport.add_child(fond)

	var separateur := ColorRect.new()
	separateur.position = Vector2(40, 12)
	separateur.size = Vector2(maxi(0, image_qr.get_width() - 80), 2)
	separateur.color = Color("edc9a5")
	viewport.add_child(separateur)

	var etiquette := Label.new()
	etiquette.position = Vector2(0, 24)
	etiquette.size = Vector2(image_qr.get_width(), 40)
	etiquette.text = texte_sous_titre
	etiquette.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etiquette.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	etiquette.add_theme_font_override("font", police)
	etiquette.add_theme_font_size_override("font_size", taille_police)
	etiquette.add_theme_color_override("font_color", Color("0a274d"))
	viewport.add_child(etiquette)
	add_child(viewport)

	if DisplayServer.get_name() == "headless":
		await get_tree().process_frame
	else:
		await RenderingServer.frame_post_draw
	var image_sous_titre := viewport.get_texture().get_image()
	viewport.queue_free()
	if image_sous_titre == null or image_sous_titre.is_empty():
		return {"succes": false, "erreur": "Impossible de dessiner le sous-titre du QR."}

	var image_finale := Image.create(
		image_qr.get_width(),
		image_qr.get_height() + hauteur_sous_titre,
		false,
		Image.FORMAT_RGBA8
	)
	image_finale.fill(Color.WHITE)
	image_finale.blit_rect(image_qr, Rect2i(Vector2i.ZERO, image_qr.get_size()), Vector2i.ZERO)
	image_finale.blit_rect(
		image_sous_titre,
		Rect2i(Vector2i.ZERO, image_sous_titre.get_size()),
		Vector2i(0, image_qr.get_height())
	)
	return {"succes": true, "image": image_finale}

## Retourne le libellé affiché sous le QR au format « Nom - Niveau X ».
func lire_sous_titre_qr() -> String:
	var nom_joueur : String = SauvegardeBddJoueursService.lire_nom_joueur()
	var nom_campagne : String = SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_derniere_campagne().capitalize()
	var nom_niveau : String = SauvegardeBddJoueursService.enregistrement_campagne_lire_nom_dernier_niveau().capitalize()
	if nom_joueur.is_empty() or nom_campagne.is_empty() or nom_niveau.is_empty():
		return ""
	return "%s - %s - %s" % [nom_joueur, nom_campagne, nom_niveau]

## Reçoit une image QR et lance son décodage asynchrone avec le plugin.
func recevoir_image_qr(image: Image) -> bool:
	if image == null or image.is_empty():
		erreur_decodage_qr.emit("L'image QR est vide ou invalide.")
		return false
	if not Engine.has_singleton("QRPlugin"):
		erreur_decodage_qr.emit("Le décodage QR n'est pas disponible sur cette plateforme.")
		return false
	if is_instance_valid(_qr_scanner):
		erreur_decodage_qr.emit("Un décodage QR est déjà en cours.")
		return false

	var qr_script := load(QR_SCRIPT_PATH) as Script
	if qr_script == null:
		erreur_decodage_qr.emit("Le script du plugin QR est introuvable.")
		return false

	_qr_scanner = qr_script.new() as Node
	if _qr_scanner == null:
		erreur_decodage_qr.emit("Impossible d'initialiser le décodeur QR.")
		return false
	if not _qr_scanner.has_signal("qr_detected") or not _qr_scanner.has_signal("qr_scan_failed"):
		_qr_scanner.free()
		_qr_scanner = null
		erreur_decodage_qr.emit("Le plugin QR n'expose pas les signaux de décodage attendus.")
		return false

	_qr_scanner.connect("qr_detected", _on_qr_detected)
	_qr_scanner.connect("qr_scan_failed", _on_qr_scan_failed)
	add_child(_qr_scanner)
	_qr_scanner.call("scan_qr_image", image)
	return true

## Retourne l'adresse courriel à afficher ou à copier.
func lire_adresse_courriel() -> String:
	return _logique.DESTINATAIRE_COURRIEL

## Partage l'image du QR avec le dialogue natif Android.
func partager_qr_android(share: Node, texture_qr: Texture2D) -> bool:
	if not OS.has_feature("android"):
		return false
	if not Engine.has_singleton("SharePlugin"):
		return false
	if texture_qr == null:
		return false

	var qr_data = lire_donnees_dernier_niveau()
	var nom_joueur = qr_data.get("nom", "")
	var nom_niveau = qr_data.get("niveau", "").get("niveau", "").replace("_", " ")
	share.call(
		"share_texture",
		texture_qr,
		nom_joueur + " partage ses performances", # titre
		"Performances du " + nom_niveau,          # sujet
		nom_joueur + " partage ses performances sur le " + nom_niveau + "." # texte du partage
	)
	return true

func _on_qr_detected(contenu_qr: String) -> void:
	_liberer_qr_scanner()
	var cle_hmac: String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	var resultat: Dictionary = _logique.decoder_et_verifier_qr(contenu_qr, cle_hmac)
	if not resultat.get("succes", false):
		erreur_decodage_qr.emit(resultat.get("erreur", "Le QR ne peut pas être validé."))
		return
	partage_qr_code.emit(resultat.get("donnees"))

func _on_qr_scan_failed(erreur: Object) -> void:
	_liberer_qr_scanner()
	var description := "Le plugin QR n'a pas pu décoder l'image."
	if erreur.has_method("get_description"):
		description = erreur.call("get_description")
	erreur_decodage_qr.emit(description)

func _liberer_qr_scanner() -> void:
	if is_instance_valid(_qr_scanner):
		_qr_scanner.queue_free()
	_qr_scanner = null
