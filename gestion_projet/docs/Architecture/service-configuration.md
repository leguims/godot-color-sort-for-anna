# SauvegardeConfigurationService

Type : Service de sauvegarde

Fichier principal : `sources/Singletons/Sauvegarde/configuration_service.gd`

## R'le

M'morise les r'glages globaux (musique, effets, vibration, version du jeu).

## Responsabilit' principale

- Le composant est la source de v'rit' de son p'rim'tre.
- Il ne doit pas absorber la logique des autres domaines en dehors de son r'le.
- Il communique par signaux, services et appels directs vers les pi'ces qui lui servent de d'pendances.

## D'pendances

- `FichiersJsonService`

## Actions cl's

- Lit et 'crit la configuration du jeu
- V'rifie la version et migre les anciennes sauvegardes si n'cessaire

## Points de vigilance

- L''cran ne doit pas 'crire directement la sauvegarde si la logique de persistance est d'j' dans un service.
- Les signaux doivent rester orient's m'tier et ne pas m'langer affichage, r'gles et donn'es.
- Le composant est plus lisible s'il ne contient qu'une logique sp'cifique ' son p'rim'tre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
