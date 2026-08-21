# Pile

Type : Scene

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/Plateau/Pile/pile.gd`

## R'le

Repr'sente une colonne, donc un tas de jetons et ses r'gles de s'lection / ordre.

## Responsabilit' principale

- Le composant est la source de v'rit' de son p'rim'tre.
- Il ne doit pas absorber la logique des autres domaines en dehors de son r'le.
- Il communique par signaux, services et appels directs vers les pi'ces qui lui servent de d'pendances.

## D'pendances

- `Jeton`
- `Plateau`
- `PlateauReglesDuJeuService`

## Actions cl's

- Applique les couleurs et la validit' du sommet
- Choisit le jeton de d'part et les destinations valides
- Marque les piles bloqu'es ou termin'es

## Points de vigilance

- L''cran ne doit pas 'crire directement la sauvegarde si la logique de persistance est d'j' dans un service.
- Les signaux doivent rester orient's m'tier et ne pas m'langer affichage, r'gles et donn'es.
- Le composant est plus lisible s'il ne contient qu'une logique sp'cifique ' son p'rim'tre.

## Voir aussi

- [README de l'architecture](README.md)
- [ProgressionCampagneService](service-progression-campagne.md)
- [SauvegardeBddJoueursService](service-bdd-joueurs.md)
