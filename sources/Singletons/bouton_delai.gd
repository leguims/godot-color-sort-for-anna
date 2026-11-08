extends Node

var delay_ms: int = 100
var last_click_time : Dictionary= {
	}

func clic_est_valable(nom_bouton: String) -> bool:
	"Retourne true si le clic est valable"
	"Filtre les clics rapides et parasites d'ANDROID."
	var heure_courante = Time.get_ticks_msec()
	var dernier_clic = lire_heure_dernier_clic(nom_bouton)
	var clic_valable = heure_courante - dernier_clic > delay_ms
	if clic_valable:
		enregistrer_heure_clic(nom_bouton)
	# print("[", clic_valable, "]", "Clic sur le bouton ", nom_bouton,
	# 	 " à ", heure_courante, ", dernier clic à ", dernier_clic)
	return clic_valable

func clic_est_pas_valable(nom_bouton: String) -> bool:
	"Retourne true si le clic n'est pas valable"
	"Il faut filtrer ce clic parasite sur ANDROID"
	return not clic_est_valable(nom_bouton)

func lire_heure_dernier_clic(nom_bouton: String) -> int:
	return last_click_time.get(nom_bouton, 0)

func enregistrer_heure_clic(nom_bouton: String):
	last_click_time[nom_bouton] = Time.get_ticks_msec()
