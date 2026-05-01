extends Node

func log_debug(...args):
	if OS.is_debug_build():
		print("[DEBUG] ", explode_args(args))

func log_erreur(...args):
	if OS.is_debug_build():
		printerr("[ERROR] ", explode_args(args))

func explode_args(args):
	var txt = ""
	for t in args:
		txt += str(t)
	return txt
