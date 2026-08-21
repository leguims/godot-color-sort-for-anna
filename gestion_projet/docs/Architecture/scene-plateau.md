# Plateau

Type : Scene

Fichier principal : `sources/Scenes/MenuPrincipal/Campagne/Plateau/plateau.gd`

## R'le

Moteur du plateau : construit les piles, valide les mouvements et relaye la fin de partie au gameplay.

## Responsabilit' principale

- Le composant est la source de v'rit' de son p'rim'tre.
- Il ne doit pas absorber la logique des autres domaines en dehors de son r'le.
- Il communique par signaux, services et appels directs vers les pi'ces qui lui servent de d'pendances.

## D'pendances

- `PlateauLayoutService`
- `PlateauDecodeurService`
- `PlateauReglesDuJeuService`
- `SauvegardeBddJoueursService`
- `AudioService`
- `VibrationService`

## Actions cl's

- Cr'e les piles ' partir du texte du plateau
- Valide le d'placement d'un jeton ou d'une pile
- D'tecte la fin de partie via le callback gameplay

## Points de vigilance

- L''cran ne doit pas 'crire directement la sauvegarde si la logique de persistance est d'j' dans un service.
- Les signaux doivent rester orient's m'tier et ne pas m'langer affichage, r'gles et donn'es.
- Le composant est plus lisible s'il ne contient qu'une logique sp'cifique ' son p'rim'tre.

## Voir aussi

- [README de l'architecture](README.md)
- [ProgressionCampagneService](service-progression-campagne.md)
- [SauvegardeBddJoueursService](service-bdd-joueurs.md)
