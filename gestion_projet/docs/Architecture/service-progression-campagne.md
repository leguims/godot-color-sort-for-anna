# ProgressionCampagneService

Type : Service

Fichier principal : `sources/Singletons/progression_campagne_service.gd`

## R'le

Le c'ur de la logique de progression. Il choisit le joueur, initialise une ascension, avance le niveau courant et publie les 'v'nements de victoire ou d'abandon.

## Responsabilit' principale

- Le composant est la source de v'rit' de son p'rim'tre.
- Il ne doit pas absorber la logique des autres domaines en dehors de son r'le.
- Il communique par signaux, services et appels directs vers les pi'ces qui lui servent de d'pendances.

## D'pendances

- `SauvegardeBddJoueursService`
- `SauvegardeListeJoueursService`
- `SauvegardeTableauDesScoresService`
- `ScoreService`

## Actions cl's

- Cr'e une nouvelle ascension
- Passe au niveau sup'rieur ou inf'rieur selon le r'sultat
- 'met les signaux progression_ascension et fin_ascension

## Points de vigilance

- L''cran ne doit pas 'crire directement la sauvegarde si la logique de persistance est d'j' dans un service.
- Les signaux doivent rester orient's m'tier et ne pas m'langer affichage, r'gles et donn'es.
- Le composant est plus lisible s'il ne contient qu'une logique sp'cifique ' son p'rim'tre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
