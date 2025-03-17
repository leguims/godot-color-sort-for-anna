# Scene "EditerUnPlateau"

## Description

Cette classe est le point d'entrée du projet GODOT. Elle représente le 1er menu de l'IHM et oriente vers les différentes activités.

## Diagramme de classe

```mermaid
classDiagram
class editer_un_plateau.tscn {
    PlateauDeJeu
    Menu
    Audio.Musique
    Audio.SonCommencer
    Audio.SonFinDePartie
    Audio.SonEchec
    _ready()
    _on_menu_commencer_plateau()
    _on_menu_saisie_plateau(String new_text)
    _editer_plateau_texte(String plateau)
    _on_plateau_de_jeu_victoire()
    _on_plateau_de_jeu_plateau_invalide()
    _on_plateau_de_jeu_abandon()
}

    Node --|> editer_un_plateau.tscn
    editer_un_plateau.tscn --o plateau.tscn
    editer_un_plateau.tscn --o menu.tscn
    editer_un_plateau.tscn --o Audio

class menu.tscn {
    set_script()
	modifier_tempo_message()
	modifier_message_vertical_align()
	show()
	afficher_accueil()
    cacher_accueil()
    afficher_victoire()
    afficher_plateau_invalide()
    afficher_abandon()
}

class plateau.tscn {
    est_valide()
    effacer_le_plateau()
    commencer_un_nouveau_plateau()
}

class Audio { play() }
```