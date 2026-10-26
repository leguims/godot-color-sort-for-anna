extends GutTest

const SCENE_PANNEAU = preload("res://Scenes/MenuPrincipal/PanneauImportQR/panneau_import_qr.tscn")
const CONTENU := "Fond/Panel/Contenu/"

func _panneau() -> Control:
	return add_child_autofree(SCENE_PANNEAU.instantiate())

func test_le_panneau_est_cache_au_demarrage() -> void:
	var panneau := _panneau()

	assert_false(panneau.visible)

func test_textes_fixes_du_panneau() -> void:
	var panneau := _panneau()

	assert_eq(panneau.get_node(CONTENU + "Titre").text, "Importer un joueur")
	assert_eq(panneau.get_node(CONTENU + "Introduction").text, "Un QR code valide contient les statistiques du joueur :")
	assert_eq(panneau.get_node(CONTENU + "Boutons/BoutonAccepter").text, "Accepter")
	assert_eq(panneau.get_node(CONTENU + "Boutons/BoutonRefuser").text, "Refuser")

func test_afficher_import_renseigne_les_trois_lignes_et_montre_le_panneau() -> void:
	var panneau := _panneau()

	panneau.afficher_import("Alice", "Campagne Test", "Niveau 03")

	assert_true(panneau.visible)
	assert_eq(panneau.get_node(CONTENU + "NomJoueur").text, "Joueur : Alice")
	assert_eq(panneau.get_node(CONTENU + "NomCampagne").text, "Campagne : Campagne Test")
	assert_eq(panneau.get_node(CONTENU + "NomNiveau").text, "Niveau : Niveau 03")

func test_afficher_import_accepte_des_valeurs_vides() -> void:
	var panneau := _panneau()

	panneau.afficher_import("", "", "")

	assert_true(panneau.visible)
	assert_eq(panneau.get_node(CONTENU + "NomJoueur").text, "Joueur : ")
	assert_eq(panneau.get_node(CONTENU + "NomCampagne").text, "Campagne : ")
	assert_eq(panneau.get_node(CONTENU + "NomNiveau").text, "Niveau : ")

func test_afficher_import_remplace_les_valeurs_precedentes() -> void:
	var panneau := _panneau()
	panneau.afficher_import("Alice", "C1", "N1")

	panneau.afficher_import("Bob", "C2", "N2")

	assert_eq(panneau.get_node(CONTENU + "NomJoueur").text, "Joueur : Bob")
	assert_eq(panneau.get_node(CONTENU + "NomCampagne").text, "Campagne : C2")
	assert_eq(panneau.get_node(CONTENU + "NomNiveau").text, "Niveau : N2")

func test_fermer_cache_le_panneau() -> void:
	var panneau := _panneau()
	panneau.afficher_import("Alice", "C1", "N1")

	panneau.fermer()

	assert_false(panneau.visible)

func test_fermer_conserve_les_textes() -> void:
	var panneau := _panneau()
	panneau.afficher_import("Alice", "C1", "N1")

	panneau.fermer()

	assert_eq(panneau.get_node(CONTENU + "NomJoueur").text, "Joueur : Alice")

func test_bouton_accepter_emet_accepter_seulement() -> void:
	var panneau := _panneau()
	panneau.afficher_import("Alice", "C1", "N1")
	watch_signals(panneau)

	panneau.get_node(CONTENU + "Boutons/BoutonAccepter").emit_signal("pressed")

	assert_signal_emit_count(panneau, "accepter", 1)
	assert_signal_not_emitted(panneau, "refuser")

func test_bouton_refuser_emet_refuser_seulement() -> void:
	var panneau := _panneau()
	panneau.afficher_import("Alice", "C1", "N1")
	watch_signals(panneau)

	panneau.get_node(CONTENU + "Boutons/BoutonRefuser").emit_signal("pressed")

	assert_signal_emit_count(panneau, "refuser", 1)
	assert_signal_not_emitted(panneau, "accepter")

func test_les_boutons_ne_ferment_pas_le_panneau_eux_memes() -> void:
	var panneau := _panneau()
	panneau.afficher_import("Alice", "C1", "N1")

	panneau.get_node(CONTENU + "Boutons/BoutonAccepter").emit_signal("pressed")
	panneau.get_node(CONTENU + "Boutons/BoutonRefuser").emit_signal("pressed")

	assert_true(panneau.visible)
