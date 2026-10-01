extends Control

class_name PartagePerformancesUI

signal fermer

const SHARE_SCRIPT_PATH := "res://addons/SharePlugin/Share.gd"

func _ready() -> void:
	$AdresseCourriel.text = $PartagePerformancesAPI.lire_adresse_courriel()
	$BoutonPartagerQR.visible = OS.has_feature("android")

	if OS.has_feature("android"):
		var share_script := load(SHARE_SCRIPT_PATH) as Script
		if share_script == null:
			_afficher_erreur("Le plugin de partage Android est introuvable.")
			$BoutonPartagerQR.disabled = true
			return
		var share_node := share_script.new() as Node
		if share_node == null:
			_afficher_erreur("Impossible d'initialiser le partage Android.")
			$BoutonPartagerQR.disabled = true
			return
		if not share_node.has_signal("share_failed"):
			_afficher_erreur("Le plugin de partage Android ne fournit pas son signal d'erreur.")
			$BoutonPartagerQR.disabled = true
			share_node.free()
			return
		share_node.name = "Share"
		share_node.connect("share_failed", _on_partage_qr_echoue)
		add_child(share_node)

## Lit les enregistrements du dernier niveau via l'API et affiche leur QR.
func afficher_dernier_niveau() -> bool:
	var enregistrements: Dictionary = $PartagePerformancesAPI.lire_donnees_dernier_niveau()
	return afficher(enregistrements)

## Affiche le panneau et prépare le QR à partir des enregistrements du niveau.
func afficher(enregistrements: Dictionary) -> bool:
	show()
	$ImageQR.texture = null
	$Message.visible = true
	$Message.text = "Préparation des performances..."
	$BoutonPartagerQR.disabled = true

	var resultat_partage: Dictionary = $PartagePerformancesAPI.preparer_partage(enregistrements)
	if not resultat_partage.get("succes", false):
		_afficher_erreur(resultat_partage.get("erreur", "Impossible de préparer le partage."))
		return false

	var resultat_qr: Dictionary = $PartagePerformancesAPI.generer_image_qr(resultat_partage.get("contenu_qr", ""))
	if not resultat_qr.get("succes", false):
		_afficher_erreur(resultat_qr.get("erreur", "Impossible de générer le QR."))
		return false

	$ImageQR.texture = ImageTexture.create_from_image(resultat_qr.get("image"))
	$Message.visible = false
	$BoutonPartagerQR.disabled = not OS.has_feature("android")
	return true

func _on_bouton_copier_courriel_pressed() -> void:
	DisplayServer.clipboard_set($PartagePerformancesAPI.lire_adresse_courriel())
	$Message.text = "Adresse courriel copiée."
	$Message.visible = true

func _on_bouton_partager_qr_pressed() -> void:
	var share_node := get_node_or_null("Share")
	if share_node == null:
		_afficher_erreur("Le partage natif Android n'est pas disponible.")
		return

	var texture_qr: Texture2D = $ImageQR.texture
	if not $PartagePerformancesAPI.partager_qr_android(share_node, texture_qr):
		_afficher_erreur("Impossible de partager le QR code sur cet appareil.")

func _on_partage_qr_echoue(message: String) -> void:
	_afficher_erreur("Le partage du QR a échoué : %s" % message)

func _on_bouton_fermer_pressed() -> void:
	fermer.emit()

func _afficher_erreur(message: String) -> void:
	$Message.text = message
	$Message.visible = true
