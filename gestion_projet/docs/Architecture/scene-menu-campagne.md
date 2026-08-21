# Menu campagne

Type : UI

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/MenuCampagne/menu_campagne.gd`

## R'le

'cran interm'diaire entre l'ascension et le plateau. Il affiche l''tat du joueur et g're le lancement d'un plateau.

## Responsabilit' principale

- Le composant est la source de v'rit' de son p'rim'tre.
- Il ne doit pas absorber la logique des autres domaines en dehors de son r'le.
- Il communique par signaux, services et appels directs vers les pi'ces qui lui servent de d'pendances.

## D'pendances

- `ProgressionCampagneService`
- `StatsService`
- `FormatterMenuCampagne`
- `AudioService`

## Actions cl's

- Affiche les infos du joueur
- Choisit la longueur de l'ascension
- Lance le plateau et navigue vers les stats

## Points de vigilance

- L''cran ne doit pas 'crire directement la sauvegarde si la logique de persistance est d'j' dans un service.
- Les signaux doivent rester orient's m'tier et ne pas m'langer affichage, r'gles et donn'es.
- Le composant est plus lisible s'il ne contient qu'une logique sp'cifique ' son p'rim'tre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
