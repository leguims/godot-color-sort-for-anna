extends Node

var clonage: bool = true
var clonage_base_path: String = "/sdcard/Documents/"
var clonage_app_dir: String = "RangeLesCouleurs"
var clonage_fullpath: String = clonage_base_path + clonage_app_dir + "/"

func json_file_exists(chemin) -> Variant:
	return FileAccess.file_exists(chemin)

func remove_json_file(chemin) -> void:
	if FileAccess.file_exists(chemin):
		var erreur = DirAccess.remove_absolute(chemin)
		if erreur != OK:
			LogService.log_erreur("Erreur : Effacement du fichier : ", chemin,
					 " avec l'erreur : ", erreur)
		if OS.get_name() == "Android" and clonage:
			if FileAccess.file_exists(clonage_fullpath + chemin):
				DirAccess.remove_absolute(clonage_fullpath + chemin)

func read_json_file(chemin) -> Variant:
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
				# Verifier si le repertoire existe
				if not DirAccess.dir_exists_absolute(clonage_fullpath):
					var dir := DirAccess.open(clonage_base_path)
					if dir:
						var err = dir.make_dir(clonage_app_dir)
						if err == OK:
							LogService.log("Dossier créé :", clonage_base_path + clonage_app_dir)
						else:
							LogService.log_erreur("Impossible de créer le dossier :", err)
					else:
						LogService.log_erreur("Impossible d'ouvrir :", clonage_base_path)
				# Copier le fichier s'il n'existe pas !
				if not FileAccess.file_exists(clonage_fullpath + chemin):
					fichier = FileAccess.open(clonage_fullpath + chemin, FileAccess.WRITE)
					if not fichier:
						LogService.log_erreur("write_json_file : ERREUR sur le chemin : ", clonage_fullpath + chemin)
					fichier.store_string(contenu_texte)
					fichier.close()
			return json.get_data()
		LogService.log_erreur("read_json_file : ERREUR sur le décodage JSON: ", json.get_error_message(), " in ", chemin, " at line ", json.get_error_line())
	else:
		LogService.log_erreur("read_json_file : ERREUR, le fichier *", chemin, "* n'existe pas ")
	return null

func write_json_file(chemin, contenu) -> void:
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
		fichier = FileAccess.open(clonage_fullpath + chemin, FileAccess.WRITE)
		if not fichier:
			LogService.log_erreur("write_json_file : ERREUR sur le chemin : ", clonage_fullpath + chemin)
		fichier.store_string(json_string)
		fichier.close()
