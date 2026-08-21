# Classique

Type : Gameplay

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/GamePlay/Classique/classique.gd`

## R'le

Gameplay principal. Une pile est gagn'e quand toutes les piles non vides sont monochromes.

## Responsabilit' principale

- Le composant est la source de v'rit' de son p'rim'tre.
- Il ne doit pas absorber la logique des autres domaines en dehors de son r'le.
- Il communique par signaux, services et appels directs vers les pi'ces qui lui servent de d'pendances.

## D'pendances

- `Plateau`
- `Campagne`
- `LogService`

## Actions cl's

- 'met victoire quand le plateau est termin'
- Relaye abandon et invalidit'
- Couvre la logique de victoire standard

## Points de vigilance

- L''cran ne doit pas 'crire directement la sauvegarde si la logique de persistance est d'j' dans un service.
- Les signaux doivent rester orient's m'tier et ne pas m'langer affichage, r'gles et donn'es.
- Le composant est plus lisible s'il ne contient qu'une logique sp'cifique ' son p'rim'tre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
