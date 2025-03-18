# Scene "Jeton"

## Description

Cette classe correspond à la scene d'un jeton. Le jeton est l'element de jeu le plus petit et le plus visible sur le plateau. Il a plusieurs apparences.

## Diagramme de classe

```mermaid
classDiagram

class jeton.tscn {
    Carre
    Fond
}

class jeton.gd {
    SIGNAL--> clique_gauche
    dict _jetons
    indice_jeton
    couleur
    nom
    position_initiale_carre
    position_initiale_nom
    reference_parent

    func _ready()
    _process(float _delta)
    choisir_reference(int reference)
    choisir_jeton(int indice, bool redimensionner = false)
    choisir_position(Vector2 nouvelle_position)
    hauteur()
    largeur()
    position()
    est_vide()
    _on_carre_gui_input(InputEvent event)
}

    jeton.tscn --o jeton.gd
```