# StatsService

Type : Service

Fichier principal : `sources/Singletons/stats_service.gd`

## R'le

Agr'gateur de statistiques. Il lit l''tat de sauvegarde pour exposer les KPI et quantit's utiles ' l''cran de statistiques.

## Responsabilit' principale

- Le composant est la source de v'rit' de son p'rim'tre.
- Il ne doit pas absorber la logique des autres domaines en dehors de son r'le.
- Il communique par signaux, services et appels directs vers les pi'ces qui lui servent de d'pendances.

## D'pendances

- `SauvegardeBddJoueursService`
- `SauvegardeConfigurationService`
- `LogService`

## Actions cl's

- Calcule le taux de completion
- D'duit la dur'e moyenne des ascensions et des plateaux
- Expose les infos pour l'UI de statistiques

## Points de vigilance

- L''cran ne doit pas 'crire directement la sauvegarde si la logique de persistance est d'j' dans un service.
- Les signaux doivent rester orient's m'tier et ne pas m'langer affichage, r'gles et donn'es.
- Le composant est plus lisible s'il ne contient qu'une logique sp'cifique ' son p'rim'tre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
