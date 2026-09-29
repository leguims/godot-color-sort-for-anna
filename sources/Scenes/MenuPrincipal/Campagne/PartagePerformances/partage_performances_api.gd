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

## Ouvre le client de messagerie par défaut avec le destinataire et le message préremplis.
func ouvrir_courriel() -> int:
	return OS.shell_open(_logique.creer_url_courriel())
