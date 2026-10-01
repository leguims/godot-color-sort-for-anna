extends Node

class_name PartagePerformancesAPI

const LOGIQUE := preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_logic.gd")
var _logique: PartagePerformancesLogic = LOGIQUE.new()

## Retourne le nom du joueur et les enregistrements de son dernier niveau.
func lire_donnees_dernier_niveau() -> Dictionary:
	return {
		"nom": SauvegardeBddJoueursService.lire_nom_joueur(),
		"niveau": SauvegardeBddJoueursService.enregistrement_lire_dernier_niveau()
	}

## Prépare les données JSON du niveau, leur signature HMAC et le contenu du QR.
func preparer_partage(enregistrements: Dictionary) -> Dictionary:
	var cle_hmac: String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	return _logique.preparer_enveloppe(enregistrements, cle_hmac)

## Génère l'image du QR avec le plugin natif sur Android ou iOS.
func generer_image_qr(contenu: String) -> Dictionary:
	return _logique.generer_image_qr(contenu, self)

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
