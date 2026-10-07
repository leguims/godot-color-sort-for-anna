extends Control

func meta_clicked_connect(on_meta_clicked : Variant) -> void:
	$Fond/Colonne2/Lien.meta_clicked.connect(on_meta_clicked)
