# Qui perd gagne

Type : Gameplay

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/GamePlay/QuiPerdGagne/qui_perd_gagne.gd`

## R'le

Variant de gameplay o' la victoire est atteinte lorsque les piles non vides sont termin'es et les piles vides ne sont plus jouables.

## Responsabilit' principale

- Le composant est la source de v'rit' de son p'rim'tre.
- Il ne doit pas absorber la logique des autres domaines en dehors de son r'le.
- Il communique par signaux, services et appels directs vers les pi'ces qui lui servent de d'pendances.

## D'pendances

- `Plateau`
- `Campagne`
- `LogService`

## Actions cl's

- 'met victoire lorsque la r'gle de jeu est satisfaite
- Relaye les signaux d'abandon et d'erreur

## Points de vigilance

- L''cran ne doit pas 'crire directement la sauvegarde si la logique de persistance est d'j' dans un service.
- Les signaux doivent rester orient's m'tier et ne pas m'langer affichage, r'gles et donn'es.
- Le composant est plus lisible s'il ne contient qu'une logique sp'cifique ' son p'rim'tre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
