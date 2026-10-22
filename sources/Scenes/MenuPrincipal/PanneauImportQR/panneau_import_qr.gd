extends Control

signal accepter
signal refuser

func afficher_import(nom_joueur: String, nom_niveau: String) -> void:
	$Fond/Panel/Contenu/NomJoueur.text = "Joueur : " + nom_joueur
	$Fond/Panel/Contenu/NomNiveau.text = "Niveau : " + nom_niveau
	show()

func fermer() -> void:
	hide()

func _on_bouton_accepter_pressed() -> void:
	LogService.log_debug("[panneau_import_qr] emission signal : accepter")
	accepter.emit()

func _on_bouton_refuser_pressed() -> void:
	LogService.log_debug("[panneau_import_qr] emission signal : refuser")
	refuser.emit()
