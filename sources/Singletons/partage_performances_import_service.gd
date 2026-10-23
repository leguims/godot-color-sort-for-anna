extends Node

signal partage_qr_code(qr_data: Dictionary)

const API_SCRIPT := preload("res://Scenes/MenuPrincipal/Campagne/PartagePerformances/partage_performances_api.gd")
const MENU_PRINCIPAL_PATH := "res://Scenes/MenuPrincipal/menu_principal.tscn"
const STATISTIQUES_PATH := "res://Scenes/MenuPrincipal/Campagne/Statistiques/statistiques.tscn"
const MESSAGE_ERREUR_IMPORT := "Erreur sur import QR, aucune action."

var _api: Node
var _image_qr: Image
var _chemins_images_recues := PackedStringArray()
var _decodage_en_cours := false
var _import_en_attente: Dictionary = {}
var _import_en_cours := false

func _ready() -> void:
	_api = API_SCRIPT.new()
	add_child(_api)
	_api.connect("partage_qr_code", _on_api_partage_qr_code)
	_api.connect("erreur_decodage_qr", _on_api_erreur_decodage_qr)

	if not ShareService.share_received.is_connected(_on_share_received):
		ShareService.share_received.connect(_on_share_received)
	LogService.log_debug("Import QR : écoute du signal SHARE activée.")

## Traite une image reçue par le share target Android.
func _on_share_received(received_data: Variant) -> void:
	LogService.log_debug("Import QR : événement SHARE reçu.")
	if not received_data is Object:
		LogService.log_debug("Import QR : données SHARE absentes ou de type inattendu.")
		_erreur_import()
		return
	if not received_data.has_method("get_file_paths") or not received_data.has_method("get_mime_type"):
		LogService.log_debug("Import QR : le résultat SHARE n'expose pas les méthodes attendues.")
		_erreur_import()
		return

	var mime_type := str(received_data.call("get_mime_type"))
	var chemins: PackedStringArray = received_data.call("get_file_paths")
	LogService.log_debug("Import QR : MIME reçu = ", mime_type, " ; nombre de fichiers = ", chemins.size(), ".")
	if _decodage_en_cours or not _import_en_attente.is_empty() or _import_en_cours:
		LogService.log_debug("Import QR : réception ignorée, un autre import est déjà actif.")
		_supprimer_fichiers_partages(chemins)
		LogService.log_erreur(MESSAGE_ERREUR_IMPORT)
		return
	_chemins_images_recues = chemins
	if chemins.is_empty():
		LogService.log_debug("Import QR : SHARE n'a transmis aucun chemin de fichier.")
		_erreur_import()
		return
	if not mime_type.is_empty() and not mime_type.begins_with("image/"):
		LogService.log_debug("Import QR : type MIME non image.")
		_erreur_import()
		return

	_image_qr = Image.new()
	var erreur_chargement := _image_qr.load(chemins[0])
	if erreur_chargement != OK:
		LogService.log_debug("Import QR : impossible de charger l'image reçue (", error_string(erreur_chargement), ").")
		_erreur_import()
		return
	if _image_qr.is_empty():
		LogService.log_debug("Import QR : le fichier reçu ne contient pas d'image exploitable.")
		_erreur_import()
		return

	LogService.log_debug("Import QR : image chargée (", _image_qr.get_width(), "x", _image_qr.get_height(), "). Lancement du décodage.")
	_decodage_en_cours = true
	if not _api.call("recevoir_image_qr", _image_qr):
		LogService.log_debug("Import QR : l'API n'a pas démarré le décodage.")
		return
	_image_qr = null

## Valide la demande affichée dans le menu et importe les statistiques.
func accepter_import() -> void:
	if _import_en_attente.is_empty() or _import_en_cours:
		return
	_import_en_cours = true

	var nom_joueur := str(_import_en_attente.get("joueur", ""))
	var donnees_campagne: Dictionary = _import_en_attente.get("campagne", {})
	var  donnees_niveau: Dictionary = _import_en_attente.get("niveau", {})
	var nom_joueur_import := nom_joueur

	if not ProgressionCampagneService.importer_statistiques_nouveau_joueur_externe(nom_joueur_import, donnees_campagne, donnees_niveau) \
		and not ProgressionCampagneService.importer_statistiques_joueur_externe(nom_joueur_import, donnees_campagne, donnees_niveau):
		nom_joueur_import = nom_joueur + " (import)"
		if not ProgressionCampagneService.importer_statistiques_nouveau_joueur_externe(nom_joueur_import, donnees_campagne, donnees_niveau) \
			and not ProgressionCampagneService.importer_statistiques_joueur_externe(nom_joueur_import, donnees_campagne, donnees_niveau):
			_erreur_import()
			return

	_liberer_donnees_import()
	var erreur_changement := get_tree().change_scene_to_file(STATISTIQUES_PATH)
	if erreur_changement != OK:
		LogService.log_erreur("Erreur sur import QR, impossible d'afficher les statistiques.")

## Annule la demande sans modifier les sauvegardes.
func refuser_import() -> void:
	_liberer_donnees_import()

func _on_api_partage_qr_code(qr_data: Dictionary) -> void:
	_decodage_en_cours = false
	_liberer_image_recue()
	LogService.log_debug("Import QR : image décodée et signature validée. Vérification de la structure des données.")
	if not _qr_est_exploitable(qr_data):
		_erreur_import()
		return

	LogService.log_debug("Import QR : structure valide. Ouverture du menu de confirmation.")
	_import_en_attente = qr_data.duplicate(true)
	partage_qr_code.emit(_import_en_attente.duplicate(true))
	var erreur_changement := get_tree().change_scene_to_file(MENU_PRINCIPAL_PATH)
	if erreur_changement != OK:
		LogService.log_debug("Import QR : échec du changement vers le menu (", error_string(erreur_changement), ").")
		_erreur_import()
		return

	await get_tree().scene_changed
	var menu_principal := get_tree().current_scene
	if not is_instance_valid(menu_principal) or not menu_principal.has_method("afficher_import_qr"):
		LogService.log_debug("Import QR : le menu principal ne peut pas afficher le panneau de confirmation.")
		_erreur_import()
		return
	menu_principal.call("afficher_import_qr", _import_en_attente.duplicate(true))

func _on_api_erreur_decodage_qr(message: String) -> void:
	LogService.log_debug("Import QR : échec du décodage ou de la validation : ", message)
	_erreur_import()

func _qr_est_exploitable(qr_data: Dictionary) -> bool:
	var joueur: Variant = qr_data.get("joueur", "")
	if not joueur is String or joueur.strip_edges().is_empty():
		LogService.log_debug("Import QR : champ joueur absent, vide ou de type incorrect.")
		return false

	var campagne: Variant = qr_data.get("campagne", {})
	if not campagne is Dictionary:
		LogService.log_debug("Import QR : champ campagne attendu comme dictionnaire, type reçu : ", type_string(typeof(campagne)), ".")
		return false
	var nom_campagne: Variant = campagne.get("campagne", "")
	if not nom_campagne is String or nom_campagne.strip_edges().is_empty():
		LogService.log_debug("Import QR : nom de campagne absent, vide ou de type incorrect dans le dictionnaire campagne.")
		return false

	var niveau: Variant = qr_data.get("niveau", "")
	if not niveau is Dictionary:
		LogService.log_debug("Import QR : champ niveau attendu comme dictionnaire, type reçu : ", type_string(typeof(niveau)), ".")
		return false

	var nom_niveau: Variant = niveau.get("niveau", "")
	var plateaux: Variant = niveau.get("plateaux", null)
	if not nom_niveau is String or nom_niveau.strip_edges().is_empty() \
		or not plateaux is Array:
		LogService.log_debug("Import QR : nom de niveau ou liste de plateaux absent(e), vide ou de type incorrect.")
		return false
	for index in range(plateaux.size()):
		var plateau: Variant = plateaux[index]
		if not plateau is Dictionary:
			LogService.log_debug("Import QR : plateau ", index, " de type incorrect.")
			return false
	return true

func _erreur_import() -> void:
	_decodage_en_cours = false
	_liberer_donnees_import()
	LogService.log_erreur(MESSAGE_ERREUR_IMPORT)
	var scene_courante := get_tree().current_scene
	if is_instance_valid(scene_courante) and scene_courante.has_method("fermer_import_qr"):
		scene_courante.call("fermer_import_qr")

func _liberer_donnees_import() -> void:
	_import_en_attente.clear()
	_import_en_cours = false
	_liberer_image_recue()

func _liberer_image_recue() -> void:
	_image_qr = null
	_supprimer_fichiers_partages(_chemins_images_recues)
	_chemins_images_recues = PackedStringArray()

func _supprimer_fichiers_partages(chemins: PackedStringArray) -> void:
	for chemin in chemins:
		if FileAccess.file_exists(chemin):
			var erreur_suppression := DirAccess.remove_absolute(chemin)
			if erreur_suppression != OK:
				LogService.log_erreur("Impossible de supprimer une image QR importée.")
