# Scene "Campagne"

## Description

Cette classe correspond à la scène de la campagne. Cette classe doit gerer les victoires, les defaites du joueur et lui faire suivre un chemin de plateaux en fonction de sa réussite. La campagne enregistre aussi des indicateurs (nombre de parties, avancement dans les plateaux, temps de résolution ...) afin de pouvoir calculer le score du joueur. C'est la campagne qui enregistre l'avancement du joueur dans l'ensemble des plateaux existants.

## Diagramme de classe

```mermaid
classDiagram
class campagne.tscn {
    |SCENE| PlateauDeJeu
    |SCENE| Menu
    Audio.Musique
    Audio.SonCommencer
    Audio.SonFinDePartie
    Audio.SonEchec
    heure_debut_en_ms
    duree_en_ms
    _ready()
    _on_menu_commencer_plateau()
    _lancer_plateau_de_campagne(String plateau)
    _on_plateau_de_jeu_victoire()
    _on_plateau_de_jeu_plateau_invalide()
    _on_plateau_de_jeu_abandon()
}

    Node --|> campagne.tscn
    campagne.tscn --o plateau.tscn
    campagne.tscn --o menu_campagne.gd : set_script(MenuCampagne)
    menu.gd --|> menu_campagne.gd
    campagne.tscn --o Audio
    campagne.tscn --> GestionScore

class GestionScore {
    commencer()
    gagner(duree_en_ms)
    la_campagne_est_terminee()
    l_ascension_est_terminee()
    abandonner()
}

namespace menu.tscn {
    class menu.gd {
        SIGNAL--> commencer_plateau
        SIGNAL--> saisie_plateau
        _ready()
        mettre_a_jour_infos_joueur()
        modifier_tempo_message()
        modifier_message_vertical_align()
        cacher_accueil()
        _afficher_message()
        _on_tempo_message_timeout()
        _on_bouton_commencer_pressed()
        _on_saisie_edition_plateau_text_submitted()
        _on_bouton_menu_principal_pressed()
    }
    
    class menu_campagne.gd {
        modifier_tempo_message()
        modifier_message_vertical_align()
        show()
        afficher_accueil()
        cacher_accueil()
        afficher_fin_campagne()
        afficher_fin_ascension()
        afficher_victoire(duree_en_ms / 1000)
        afficher_abandon()
    }
}

class plateau.tscn {
    SIGNAL--> victoire
    SIGNAL--> plateau_invalide
    SIGNAL--> abandon
    est_valide()
    effacer_le_plateau()
    commencer_un_nouveau_plateau()
}

class Audio { play() }
```
