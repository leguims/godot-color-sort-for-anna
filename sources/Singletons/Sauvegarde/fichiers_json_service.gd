extends Node

var clonage: bool = true
var clonage_app_dir: String = "/sdcard/Download/"
var clonage_prefixe: String = "RLC_"

func json_file_exists(chemin : String) -> Variant:
	return FileAccess.file_exists(chemin)

func remove_json_file(chemin : String) -> void:
	if FileAccess.file_exists(chemin):
		var erreur = DirAccess.remove_absolute(chemin)
		if erreur != OK:
			LogService.log_erreur("Erreur : Effacement du fichier : ", chemin,
					 " avec l'erreur : ", erreur)
		if OS.get_name() == "Android" and clonage:
			var nom_fichier = clonage_prefixe + chemin.remove_chars("user://")
			if FileAccess.file_exists(clonage_app_dir + nom_fichier):
				DirAccess.remove_absolute(clonage_app_dir + nom_fichier)

func read_json_file(chemin : String) -> Variant:
	var fichier = null
	var contenu_texte = null
	
	# Lecture du fichier
	if FileAccess.file_exists(chemin):
		fichier = FileAccess.open(chemin, FileAccess.READ)
		if not fichier:
			LogService.log_erreur("read_json_file : ERREUR sur le chemin : ", chemin)
			return null
		contenu_texte = fichier.get_as_text()
		if not contenu_texte :
			LogService.log_erreur("read_json_file : ERREUR sur le contenu : ", chemin, " erreur = ", fichier.get_as_text())
			return null
		fichier.close()
		# LogService.log_debug("contenu_texte = ", contenu_texte)
		
		# Decodage JSON
		var json = JSON.new()
		var error = json.parse(contenu_texte)
		# LogService.log_debug("error = ", error)
		if error == OK:
			if OS.get_name() == "Android" and clonage:
				var nom_fichier = clonage_prefixe + chemin.remove_chars("user://")
				# Copier le fichier s'il n'existe pas !
				if not FileAccess.file_exists(clonage_app_dir + nom_fichier):
					fichier = FileAccess.open(clonage_app_dir + nom_fichier, FileAccess.WRITE)
					if not fichier:
						LogService.log_erreur("write_json_file : ERREUR sur le chemin : ", clonage_app_dir + nom_fichier)
					fichier.store_string(contenu_texte)
					fichier.close()
			return json.get_data()
		LogService.log_erreur("read_json_file : ERREUR sur le décodage JSON: ", json.get_error_message(), " in ", chemin, " at line ", json.get_error_line())
	else:
		LogService.log_erreur("read_json_file : ERREUR, le fichier *", chemin, "* n'existe pas ")
	return null

func write_json_file(chemin : String, contenu) -> void:
	var fichier = null
	
	# Ouverture du fichier
	fichier = FileAccess.open(chemin, FileAccess.WRITE)
	if not fichier:
		LogService.log_erreur("write_json_file : ERREUR sur le chemin : ", chemin)
		return
	# Encodage JSON
	var json_string = JSON.stringify(contenu)
	# LogService.log_debug("json_string = ", json_string)
	# Ecriture du fichier
	fichier.store_string(json_string)
	fichier.close()

	if OS.get_name() == "Android" and clonage:
		var nom_fichier = clonage_prefixe + chemin.remove_chars("user://")
		fichier = FileAccess.open(clonage_app_dir + nom_fichier, FileAccess.WRITE)
		if not fichier:
			LogService.log_erreur("write_json_file : ERREUR sur le chemin : ", clonage_app_dir + nom_fichier)
		fichier.store_string(json_string)
		fichier.close()
