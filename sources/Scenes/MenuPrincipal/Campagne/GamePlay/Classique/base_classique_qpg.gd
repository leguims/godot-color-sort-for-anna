extends Node

class_name BaseClassiqueQuiPerdGagne

signal plateau_invalide
signal abandon
signal passe
signal victoire
signal commencer_plateau

func _ready() -> void:
	# Connecter la callback de gameplay au "Plateau"
	$Plateau.enregistrer_callback_est_termine(Callable(self, "est_termine"))

	# Initialiser le menu
	$MenuPlateau.enregistrer_gameplay("Gameplay")
	$MenuPlateau.enregistrer_chrono('00', '00', '0')
	$MenuPlateau.enregistrer_coups("0 Coup")

	# Transmettre les infos de l'UI à Plateau
	$Plateau.enregistrer_bouton_recommencer_size_y($MenuPlateau/BandeauEnJeu.size.y)

	# Initialisation du bandeau de menu
	maj_bandeau_menu()

# API pour "Campagne"
func est_valide(plateau_texte : String) -> bool:
	return $Plateau.est_valide(plateau_texte)

func commencer_un_nouveau_gameplay() -> void:
	maj_bandeau_menu()
	$MenuPlateau.show_menu()

func maj_bandeau_menu() -> void:
	var nom : String = SauvegardeBddJoueursService.lire_nom_joueur()
	$MenuPlateau.enregistrer_joueur(nom)

	var niveau_int : int = 0
	niveau_int = SauvegardeBddJoueursService.campagne_lire_prochain_niveau()
	var niveau_str : String
	if "NIVEAU " in $MenuPlateau.lire_niveau():
		niveau_str = "NIVEAU "+String.num_int64(niveau_int).pad_zeros(2)
	else:
		niveau_str = String.num_int64(niveau_int).pad_zeros(2)
	$MenuPlateau.enregistrer_niveau(niveau_str)

	var pourcentage_niveau_realise
	if SauvegardeBddJoueursService.enregistrement_campagne_lire_valeur_niveau_joueur() == niveau_int:
		pourcentage_niveau_realise = StatsService.niveau_taux_completion() * 100.
	else:
		# Niveau courant achevé, On commence le suivant.
		pourcentage_niveau_realise = 0.
	$MenuPlateau.enregistrer_pourcentage(String.num_int64(pourcentage_niveau_realise)+'%')

func commencer_un_nouveau_plateau(plateau_texte : String) -> void:
	$Plateau.commencer_un_nouveau_plateau(plateau_texte)
	$MenuPlateau.show_jeu()

func hide():
	$MenuPlateau.hide()
	$Plateau.hide()

func show_fond():
	$MenuPlateau.show_fond()

# Callback pour "Plateau"
func est_termine(_liste_piles) -> bool:
	return false

# Relais de signaux vers la campagne
func _on_plateau_plateau_invalide() -> void:
	LogService.log_debug("[base_classique_qpg] emission signal : plateau_invalide")
	plateau_invalide.emit()

func _on_menu_plateau_abandon() -> void:
	LogService.log_debug("[base_classique_qpg] emission signal : abandon")
	abandon.emit()

func _on_menu_plateau_passe() -> void:
	LogService.log_debug("[base_classique_qpg] emission signal : passe")
	passe.emit()

func _on_menu_plateau_commencer_plateau() -> void:
	LogService.log_debug("[base_classique_qpg] emission signal : commencer_plateau")
	commencer_plateau.emit()
