# AudioService

Type : Service

Fichier principal : `sources/Singletons/audio_service.gd`

## R'le

Moteur audio global. Il d'cide de la musique courant et des effets sonores ' jouer selon l''tat du jeu et l''tat de configuration.

## Responsabilit' principale

- Le composant est la source de v'rit' de son p'rim'tre.
- Il ne doit pas absorber la logique des autres domaines en dehors de son r'le.
- Il communique par signaux, services et appels directs vers les pi'ces qui lui servent de d'pendances.

## D'pendances

- `SauvegardeConfigurationService`
- `StatsService`

## Actions cl's

- Joue les musiques de progression d'ascension
- Joue les sons d'interface / mouvement / victoire / abandon

## Points de vigilance

- L''cran ne doit pas 'crire directement la sauvegarde si la logique de persistance est d'j' dans un service.
- Les signaux doivent rester orient's m'tier et ne pas m'langer affichage, r'gles et donn'es.
- Le composant est plus lisible s'il ne contient qu'une logique sp'cifique ' son p'rim'tre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
