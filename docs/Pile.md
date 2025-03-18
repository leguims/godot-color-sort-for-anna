# Scene "Pile"

## Description

Cette classe correspond à la scene d'une pile. La pile contient de jetons qui ont chacun une apparence propre. C'est un element de jeu autonome qui a ses propres regles de modifications.

## Diagramme de classe

```mermaid
classDiagram

class pile.tscn {
    Fond
}

class pile.gd {
    SIGNAL--> clique_gauche
    |SCENE| jeton_scene
    liste_jetons
    reference_parent
    position
    marge
    couleur_de_deselection
    couleur_de_selection

    choisir_reference(int reference)
    ajouter_les_jetons(Array jetons)
    ajouter_le_jeton_dans_le_vide(int jeton_a_ajouter)
    retirer_le_dernier_jeton()
    choisir_position(Vector2 nouvelle_position)
    _ajuster_position_fond()
    selectionner()
    deselectionner()
    largeur()
    hauteur()
    effacer_la_pile()
    est_valide(Array jetons)
    est_vide()
    est_pleine()
    est_termine()
    quelle_est_la_couleur_au_sommet()
    combien_de_jetons_identiques_au_sommet()
    combien_de_cases_vides_au_sommet()
    accepte_jeton(int indice, int nombre)
    _calculer_la_position_du_jeton(int indice_jeton)
    on_jeton_clique_gauche(int _indice_jeton)
}

class jeton.tscn {
    choisir_reference()
    on_jeton_clique_gauche()
    choisir_position()
    choisir_jeton()
    est_vide()
    largeur()
    hauteur()
}

    pile.tscn --o pile.gd
    pile.gd --o jeton.tscn : jeton_scene
```