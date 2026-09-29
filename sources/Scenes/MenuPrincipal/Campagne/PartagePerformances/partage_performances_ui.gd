extends Control

class_name PartagePerformancesUI

signal fermer

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
	return true

func _on_bouton_courriel_pressed() -> void:
	var erreur: int = $PartagePerformancesAPI.ouvrir_courriel()
	if erreur != OK:
		_afficher_erreur("Impossible d'ouvrir votre application de messagerie (erreur %d)." % erreur)

func _on_bouton_fermer_pressed() -> void:
	fermer.emit()

func _afficher_erreur(message: String) -> void:
	$Message.text = message
	$Message.visible = true
