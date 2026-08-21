# SauvegardeBddJoueursService

Type : Service de sauvegarde

Fichier principal : `sources/Singletons/Sauvegarde/bdd_joueurs_service.gd`

## R'le

Stockage de la progression sp'cifique ' chaque joueur : campagne, ascension courante, plateaux restant, scores et historique des parties.

## Responsabilit' principale

- Le composant est la source de v'rit' de son p'rim'tre.
- Il ne doit pas absorber la logique des autres domaines en dehors de son r'le.
- Il communique par signaux, services et appels directs vers les pi'ces qui lui servent de d'pendances.

## D'pendances

- `FichiersJsonService`
- `ProgressionCampagneService`
- `SauvegardeListeJoueursService`

## Actions cl's

- Lit / 'crit la sauvegarde du joueur
- G're les plateaux non jou's et les plateaux en cours
- Termine ou abandonne un plateau/ascension

## Points de vigilance

- L''cran ne doit pas 'crire directement la sauvegarde si la logique de persistance est d'j' dans un service.
- Les signaux doivent rester orient's m'tier et ne pas m'langer affichage, r'gles et donn'es.
- Le composant est plus lisible s'il ne contient qu'une logique sp'cifique ' son p'rim'tre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
