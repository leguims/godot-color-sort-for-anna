extends Node

class_name PartagePerformancesAPI

signal partage_echoue(message: String, manuel: bool)

const LOGIQUE := preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_logic.gd")
const TYPE_MIME_JSON := "application/json"

var _logique: PartagePerformancesLogic = LOGIQUE.new()
var _empreinte_partage_en_attente := ""
var _partage_en_attente := false
var _partage_manuel_en_attente := false

func _ready() -> void:
	if not ShareService.share_completed.is_connected(_on_share_completed):
		ShareService.share_completed.connect(_on_share_completed)
	if not ShareService.share_canceled.is_connected(_on_share_canceled):
		ShareService.share_canceled.connect(_on_share_canceled)
	if not ShareService.share_failed.is_connected(_on_share_failed):
		ShareService.share_failed.connect(_on_share_failed)

## Retourne le joueur et l'intégralité des données de sa dernière campagne.
func lire_donnees_derniere_campagne() -> Dictionary:
	return {
		"joueur": SauvegardeBddJoueursService.lire_nom_joueur(),
		"campagne": SauvegardeBddJoueursService.enregistrement_campagne_lire_derniere_campagne().duplicate(true)
	}

## Prépare les données JSON de la campagne et leur signature HMAC.
func preparer_partage(donnees: Dictionary) -> Dictionary:
	var cle_hmac: String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	return _logique.preparer_enveloppe(donnees, cle_hmac)

## Vérifie une enveloppe JSON signée reçue depuis SHARE.
func decoder_fichier_signe(contenu_fichier: String) -> Dictionary:
	var cle_hmac: String = ProjectSettings.get_setting("partage_performances/cle_hmac", "")
	return _logique.decoder_fichier_signe(contenu_fichier, cle_hmac)

## Signe et transmet la campagne via SHARE ; le partage manuel ne modifie pas le suivi de test.
func partager_campagne(share: Node, donnees: Dictionary, manuel: bool = false) -> Dictionary:
	if _partage_en_attente:
		return {"succes": false, "erreur": "Un partage est déjà en cours."}
	if not is_instance_valid(share) or not share.has_method("is_available") \
		or not share.call("is_available") or not share.has_method("share_file"):
		return {"succes": false, "erreur": "Le partage natif Android n'est pas disponible."}
	var campagne: Variant = donnees.get("campagne")
	if not campagne is Dictionary or campagne.is_empty():
		return {"succes": false, "erreur": "Aucune campagne à partager."}

	var enveloppe: Dictionary = preparer_partage(donnees)
	if not enveloppe.get("succes", false):
		return enveloppe

	var nom_joueur := str(donnees.get("joueur", "inconnue"))
	var nom_campagne := str(campagne.get("campagne", "inconnue"))
	var chemin_fichier := OS.get_user_data_dir().path_join(
		_construire_nom_fichier_partage(nom_campagne, nom_joueur)
	)
	var fichier := FileAccess.open(chemin_fichier, FileAccess.WRITE)
	if fichier == null:
		return {"succes": false, "erreur": "Impossible de créer le fichier de partage JSON."}
	fichier.store_string(enveloppe.get("contenu_fichier", ""))
	fichier.flush()
	var erreur_ecriture := fichier.get_error()
	fichier.close()
	if erreur_ecriture != OK:
		return {"succes": false, "erreur": "Impossible d'écrire le fichier de partage JSON."}

	var nom_campagne_affiche := nom_campagne.capitalize()
	_partage_en_attente = true
	_partage_manuel_en_attente = manuel
	_empreinte_partage_en_attente = "" if manuel else _calculer_empreinte_campagne(campagne)
	if not share.call(
		"share_file",
		chemin_fichier,
		TYPE_MIME_JSON,
		nom_joueur + " partage ses performances",
		nom_campagne_affiche,
		nom_campagne_affiche + " de " + nom_joueur
	):
		_reinitialiser_partage_en_attente()
		return {"succes": false, "erreur": "SHARE n'a pas pu transmettre le fichier JSON."}

	return {"succes": true, "chemin": chemin_fichier}

func _construire_nom_fichier_partage(nom_campagne: String, nom_joueur: String) -> String:
	var campagne_validee := nom_campagne.validate_filename().strip_edges()
	var joueur_valide := nom_joueur.validate_filename().strip_edges()
	if campagne_validee.is_empty():
		campagne_validee = "inconnue"
	if joueur_valide.is_empty():
		joueur_valide = "inconnue"
	return "rtc_%s_%s.json" % [campagne_validee, joueur_valide]

## Indique si les données de campagne ont déjà été partagées depuis ce profil.
func campagne_a_deja_ete_partagee(donnees: Dictionary) -> bool:
	var campagne: Variant = donnees.get("campagne", {})
	if not campagne is Dictionary:
		return false
	var empreinte := _calculer_empreinte_campagne(campagne)
	return SauvegardeBddJoueursService.enregistrement_campagne_fichier_est_partage(empreinte)

## Marque localement une campagne comme déjà partagée, notamment après un import.
func marquer_campagne_comme_partagee(donnees: Dictionary) -> bool:
	var campagne: Variant = donnees.get("campagne", {})
	if not campagne is Dictionary:
		return false
	var empreinte := _calculer_empreinte_campagne(campagne)
	if empreinte.is_empty():
		return false
	return SauvegardeBddJoueursService.enregistrement_campagne_marquer_fichier_partage(empreinte)

func _calculer_empreinte_campagne(campagne: Dictionary) -> String:
	var contexte := HashingContext.new()
	if contexte.start(HashingContext.HASH_SHA256) != OK:
		return ""
	var json_normalise := JSON.stringify(_normaliser_valeur_pour_empreinte(campagne))
	contexte.update(json_normalise.to_utf8_buffer())
	return contexte.finish().hex_encode()

func _normaliser_valeur_pour_empreinte(valeur: Variant) -> Variant:
	if typeof(valeur) == TYPE_INT:
		return float(valeur)
	if valeur is Array:
		var tableau_normalise: Array = []
		for element in valeur:
			tableau_normalise.append(_normaliser_valeur_pour_empreinte(element))
		return tableau_normalise
	if valeur is Dictionary:
		var dictionnaire_normalise := {}
		var cles: Array = valeur.keys()
		cles.sort()
		for cle in cles:
			dictionnaire_normalise[cle] = _normaliser_valeur_pour_empreinte(valeur[cle])
		return dictionnaire_normalise
	return valeur

func _on_share_completed(_activity_type: String) -> void:
	if not _partage_en_attente:
		return
	if not _partage_manuel_en_attente and not _empreinte_partage_en_attente.is_empty() \
		and not SauvegardeBddJoueursService.enregistrement_campagne_marquer_fichier_partage(_empreinte_partage_en_attente):
		LogService.log_erreur("Impossible d'enregistrer le partage de la campagne.")
	_reinitialiser_partage_en_attente()

func _on_share_canceled() -> void:
	_reinitialiser_partage_en_attente()

func _on_share_failed(message: String) -> void:
	if not _partage_en_attente:
		return
	var manuel := _partage_manuel_en_attente
	_reinitialiser_partage_en_attente()
	partage_echoue.emit(message, manuel)

func _reinitialiser_partage_en_attente() -> void:
	_empreinte_partage_en_attente = ""
	_partage_en_attente = false
	_partage_manuel_en_attente = false
