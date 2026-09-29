extends RefCounted

class_name PartagePerformancesLogic

const DESTINATAIRE_COURRIEL := "rangelescouleurspouranna@gmail.com"

## Sérialise et signe les enregistrements, puis prépare l'enveloppe à encoder.
func preparer_enveloppe(enregistrements: Dictionary, cle_hmac: String) -> Dictionary:
	if enregistrements.is_empty():
		return _erreur("Aucun enregistrement de niveau à partager.")
	if cle_hmac.is_empty():
		return _erreur("La clé HMAC n'est pas configurée.")

	var donnees_json := JSON.stringify(enregistrements)
	if donnees_json.is_empty():
		return _erreur("Les enregistrements ne peuvent pas être sérialisés en JSON.")

	var signature := calculer_hmac(donnees_json, cle_hmac)
	if signature.is_empty():
		return _erreur("Le calcul de la signature HMAC a échoué.")

	var contenu_qr := JSON.stringify({
		"version": 1,
		"algorithme": "HMAC-SHA256",
		"donnees_json": donnees_json,
		"signature": signature
	})
	return {
		"succes": true,
		"donnees_json": donnees_json,
		"signature": signature,
		"contenu_qr": contenu_qr
	}

## Calcule une empreinte HMAC-SHA256 hexadécimale des données UTF-8.
func calculer_hmac(donnees: String, cle_hmac: String) -> String:
	if cle_hmac.is_empty():
		return ""

	var crypto := Crypto.new()
	var empreinte := crypto.hmac_digest(
		HashingContext.HASH_SHA256,
		cle_hmac.to_utf8_buffer(),
		donnees.to_utf8_buffer()
	)
	if empreinte.is_empty():
		return ""
	return empreinte.hex_encode()

## Vérifie la signature HMAC-SHA256 des données fournies.
func verifier_hmac(donnees: String, signature: String, cle_hmac: String) -> bool:
	if signature.length() != 64 or cle_hmac.is_empty():
		return false
	return calculer_hmac(donnees, cle_hmac) == signature.to_lower()

## Construit le lien mailto prérempli pour l'envoi de la capture.
func creer_url_courriel() -> String:
	var sujet := "Partage des performances - Range les couleurs pour Anna"
	var corps := "Bonjour,\n\nVeuillez trouver en pièce jointe la capture d'écran de mes performances.\n\nMerci !"
	return "mailto:%s?subject=%s&body=%s" % [
		DESTINATAIRE_COURRIEL,
		sujet.uri_encode(),
		corps.uri_encode()
	]

## Génère une image QR avec l'extension native chargée dans le projet.
func generer_image_qr(contenu: String, parent: Node) -> Dictionary:
	if not Engine.has_singleton("QRPlugin"):
		return _erreur("La génération de QR n'est disponible que dans les exports Android.")

	var qr_script := load("res://addons/QRPlugin/QR.gd") as Script
	if qr_script == null:
		return _erreur("Le script du plugin QR est introuvable.")

	var qr_node := qr_script.new() as Node
	if qr_node == null:
		return _erreur("Impossible d'initialiser le plugin QR.")

	parent.add_child(qr_node)
	var image: Variant = qr_node.call("generate_qr_image", contenu, 512, Color.BLACK, Color.WHITE)
	qr_node.queue_free()
	if not image is Image or image.is_empty():
		return _erreur("Le plugin QR n'a pas pu générer l'image.")

	return {"succes": true, "image": image}

func _erreur(message: String) -> Dictionary:
	return {"succes": false, "erreur": message}
