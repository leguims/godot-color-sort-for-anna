extends Node

const AES_KEY_B64 := "Yr2lXoh98qpMs9PeG7tqt7hoVGGHw1HE++sBmj3YqMQ="
var AES_KEY: PackedByteArray

const BACKUP_FILENAME := "sauvegarde_range_les_couleurs.bin"

@onready var file_dialog_save: FileDialog = $FileDialogSave
@onready var file_dialog_load: FileDialog = $FileDialogLoad

# TODO : Le bouton d'export est toujours visible.
# TODO : Le bouton d'import est visible en l'absence de sauvegarde.

func _ready() -> void:
	AES_KEY = Marshalls.base64_to_raw(AES_KEY_B64)
	assert(AES_KEY.size() == 32, "La clé AES doit faire 32 bytes (AES-256).")

# ---------- Helpers ----------

func _generate_iv() -> PackedByteArray:
	var crypto := Crypto.new()
	return crypto.generate_random_bytes(16) # 16 bytes IV

func _sha256(data: PackedByteArray) -> PackedByteArray:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(data)
	return ctx.finish() # 32 bytes

# ---------- Export ----------

func export_user_json() -> void:
	# 1. ZIP des .json dans user://
	var zip_path := "user://tmp_export.zip"
	var zip := ZIPPacker.new()
	var err := zip.open(zip_path)
	if err != OK:
		push_error("Impossible d'ouvrir le ZIP : %s" % err)
		return

	var dir := DirAccess.open("user://")
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if not dir.current_is_dir() and name.ends_with(".json"):
			var data := FileAccess.get_file_as_bytes("user://" + name)
			zip.start_file(name)
			zip.write_file(data)
			zip.close_file()
		name = dir.get_next()
	zip.close()

	# 2. Lire ZIP
	var zip_bytes = FileAccess.get_file_as_bytes(zip_path)

	# 3. Générer IV
	var iv = _generate_iv()

	# 4. Chiffrement AES
	var aes = AESContext.new()
	assert( AES_KEY.size() == 32, "AES_KEY ne fait pas 32 octets")
	assert( iv.size() == 16, "IVY ne fait pas 16 octets")
	var err_aes = aes.start(AESContext.MODE_CBC_ENCRYPT, AES_KEY, iv)
	if err_aes != OK:
		push_error("Impossible de chiffrer : %s" % err_aes)
		return
	assert( zip_bytes.size() != 0, "ZIP est vide")
	var encrypted = aes.update(zip_bytes)
	assert( encrypted.size() != 0, "Chiffre est vide")
	aes.finish()

	# 5. SHA-256 sur les données chiffrées
	var digest = _sha256(encrypted)

	# 6. Fichier final : IV (16) + encrypted + digest (32)
	var backup = PackedByteArray()
	backup.append_array(iv)        # 16 bytes
	backup.append_array(digest)    # 32 bytes
	# backup.append_array(encrypted) # N bytes
	backup.append_array(zip_bytes) # N bytes

	# 7. Optionnel : copie temporaire dans user://
	var tmp_backup_path := "user://" + BACKUP_FILENAME
	var f = FileAccess.open(tmp_backup_path, FileAccess.WRITE)
	f.store_buffer(backup)
	f.close()

	# 8. Sortie
	_open_save_dialog(backup)

	print("Export terminé.")

# ---------- Import ----------

func import_user_json() -> void:
	_open_load_dialog()

func import_user_json_from_bytes(backup: PackedByteArray) -> void:
	assert(backup.size() > 48, "Fichier de sauvegarde trop court ou invalide.")

	var iv = backup.slice(0, 16)
	var digest = backup.slice(16, 48)
	var encrypted = backup.slice(48, backup.size())

	var computed = _sha256(encrypted)
	assert(computed == digest, "Intégrité invalide : SHA-256 ne correspond pas.")

	var aes = AESContext.new()
	var err_aes = aes.start(AESContext.MODE_CBC_DECRYPT, AES_KEY, iv)
	if err_aes != OK:
		push_error("Impossible de dechiffrer : %s" % err_aes)
		return
	var zip_bytes = aes.update(encrypted)
	aes.finish()

	var zip_path = "user://tmp_import.zip"
	var f = FileAccess.open(zip_path, FileAccess.WRITE)
	f.store_buffer(zip_bytes)
	f.close()

	var reader = ZIPReader.new()
	var err = reader.open(zip_path)
	if err != OK:
		push_error("Impossible de lire le ZIP : %s" % err)
		return

	for name in reader.get_files():
		var data = reader.read_file(name)
		var out = FileAccess.open("user://" + name, FileAccess.WRITE)
		out.store_buffer(data)
		out.close()

	reader.close()

	print("Import terminé.")

# ---------- FileDialog (Android / Desktop) ----------

func _open_save_dialog(backup: PackedByteArray) -> void:
	file_dialog_save.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog_save.current_file = BACKUP_FILENAME
	file_dialog_save.popup_centered()

	var cb = Callable(self, "_on_save_file_selected")

	if file_dialog_save.is_connected("file_selected", cb):
		file_dialog_save.disconnect("file_selected", cb)

	file_dialog_save.connect("file_selected", cb.bind(backup))


func _on_save_file_selected(path: String, backup: PackedByteArray) -> void:
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_buffer(backup)
	f.close()

func _open_load_dialog() -> void:
	file_dialog_load.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog_load.popup_centered()

	var cb = Callable(self, "_on_load_file_selected")

	if file_dialog_load.is_connected("file_selected", cb):
		file_dialog_load.disconnect("file_selected", cb)

	file_dialog_load.connect("file_selected", cb)

func _on_load_file_selected(path: String) -> void:
	var backup = FileAccess.get_file_as_bytes(path)
	import_user_json_from_bytes(backup)

# ---------- Hooks pour les boutons ----------

func _on_export_button_pressed() -> void:
	export_user_json()

func _on_import_button_pressed() -> void:
	import_user_json()
