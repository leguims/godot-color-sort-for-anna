# Campagne

Type : Scene

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/campagne.gd`

## R'le

Orchestre une ascension de niveaux et relie le MenuCampagne au gameplay courant.

## Responsabilit' principale

- Le composant est la source de v'rit' de son p'rim'tre.
- Il ne doit pas absorber la logique des autres domaines en dehors de son r'le.
- Il communique par signaux, services et appels directs vers les pi'ces qui lui servent de d'pendances.

## D'pendances

- `ProgressionCampagneService`
- `SauvegardeBddJoueursService`
- `SauvegardeTableauDesScoresService`
- `StatsService`
- `AudioService`

## Actions cl's

- Lance le bon gameplay pour un plateau
- Met ' jour la progression de l'ascension
- Fais 'voluer l''tat de victoire ou d'abandon

## Points de vigilance

- L''cran ne doit pas 'crire directement la sauvegarde si la logique de persistance est d'j' dans un service.
- Les signaux doivent rester orient's m'tier et ne pas m'langer affichage, r'gles et donn'es.
- Le composant est plus lisible s'il ne contient qu'une logique sp'cifique ' son p'rim'tre.

## Voir aussi

- [README de l'architecture](README.md)
- [ProgressionCampagneService](service-progression-campagne.md)
- [SauvegardeBddJoueursService](service-bdd-joueurs.md)
