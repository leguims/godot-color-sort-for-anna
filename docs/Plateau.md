# Scene "Plateau"

## Description

Cette classe correspond à la scene d'un plateau de jeu. Le plateau de jeu contient des piles de jetons qui contient des jetons. C'est l'espace dans lequel le joueur va tenter de résoudre le défi proposé. 

## Diagramme de classe

```mermaid
classDiagram

class plateau.tscn {
    Fond
    Timer SelectionPile
    Button BoutonAbandon
}

class plateau.gd {
    SIGNAL--> victoire
    SIGNAL--> plateau_invalide
    SIGNAL--> abandon
    |SCENE| pile_scene
    liste_piles
    string2int
    ESPACE
    sauvegarde_indice_pile_depart

    commencer_un_nouveau_plateau(String plateau_texte)
    effacer_le_plateau()
    est_valide(plateau_texte : String)
    _decoder_plateau(plateau_texte : String)
    _decoder_pile(pile_texte : String)
    _creer_un_plateau(piles : Array)
    _calculer_la_position_de_la_pile(nb_piles : int, indice_pile : int)
    on_pile_clique_gauche(indice_pile : int)
    _est_termine()
    _on_selection_pile_timeout()
    realiser_le_tansfert_de_pile(indice_pile_depart : int, indice_pile_arrivee : int)
    _on_bouton_abandon_pressed()
}

class Button{
    show()
    hide()
}

class Timer{
    start()
    stop()
}

class pile.tscn {
    choisir_reference()
    on_pile_clique_gauche()
    ajouter_les_jetons()
    choisir_position()
    selectionner()
    deselectionner()
    est_termine()
    est_vide()
    est_pleine()
    quelle_est_la_couleur_au_sommet()
    combien_de_jetons_identiques_au_sommet()
    accepte_jeton()
    retirer_le_dernier_jeton()
    ajouter_le_jeton_dans_le_vide()
    largeur()
}

    plateau.tscn --o plateau.gd
    plateau.gd --o pile.tscn : pile_scene
    plateau.gd --o Button
    plateau.gd --o Timer
```