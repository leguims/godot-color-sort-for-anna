# Menu principal

Type : Scene

Fichier principal : `sources/Scenes/MenuPrincipal/menu_principal.gd`

## R'le

Point d'entr'e de la navigation du jeu. G're la s'lection du joueur, ouverture de la campagne, scores, r'f'rences et configuration.

## Responsabilit' principale

- Le composant est la source de v'rit' de son p'rim'tre.
- Il ne doit pas absorber la logique des autres domaines en dehors de son r'le.
- Il communique par signaux, services et appels directs vers les pi'ces qui lui servent de d'pendances.

## D'pendances

- `ProgressionCampagneService`
- `SauvegardeListeJoueursService`
- `SauvegardeConfigurationService`
- `AudioService`

## Actions cl's

- Ouvre les sc'nes de campagne, scores et r'f'rences
- Affiche et met ' jour les boutons de joueurs
- Applique les r'glages audio/vibration

## Points de vigilance

- L''cran ne doit pas 'crire directement la sauvegarde si la logique de persistance est d'j' dans un service.
- Les signaux doivent rester orient's m'tier et ne pas m'langer affichage, r'gles et donn'es.
- Le composant est plus lisible s'il ne contient qu'une logique sp'cifique ' son p'rim'tre.

## Voir aussi

- [README de l'architecture](README.md)
- [ProgressionCampagneService](service-progression-campagne.md)
- [SauvegardeBddJoueursService](service-bdd-joueurs.md)
