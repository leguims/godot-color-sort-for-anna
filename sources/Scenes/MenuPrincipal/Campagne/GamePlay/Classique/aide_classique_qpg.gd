extends CanvasLayer

signal fermee

func ouvrir() -> void:
	show()

func _on_compris_pressed() -> void:
	fermee.emit()
