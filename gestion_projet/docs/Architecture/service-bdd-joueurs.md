# SauvegardeBddJoueursService

Type : Service de sauvegarde

Fichier principal : `sources/Singletons/Sauvegarde/bdd_joueurs_service.gd`

## Rôle

Sauvegarde du profil et de la progression du joueur. Il garde l’état du compte, de l’ascension et des données de jeu en cours.

## Responsabilité principale

- Lit et écrit les données personnelles du joueur courant.
- Conserve les plateaux restants, l’ascension en cours et l’état de progression.
- Fournit la source de vérité des données de joueur pour la campagne et l’UI.

## Dépendances

- `FichiersJsonService`
- `ProgressionCampagneService`
- `SauvegardeListeJoueursService`

## Actions clés

- Lit / écrit la sauvegarde du joueur
- Gère les plateaux non joués et les plateaux en cours
- Termine ou abandonne un plateau/ascension

## Durée des plateaux

- Pendant le jeu, un Timer du bandeau enregistre la durée majorée : 60 secondes dès le début, puis 60 secondes supplémentaires chaque minute. Le chronomètre affiche le temps réel.
- Une fin normale enregistre le temps réel. Après une interruption, la dernière durée sauvegardée est conservée et la date de fin est estimée par `date_debut + duree` ; le plateau est abandonné pour être rejoué, ou passé lors d'un remplacement de campagne.
- Une fermeture brutale pendant une écriture ou avant la mise à jour périodique peut empêcher la sauvegarde de la dernière valeur. Si le jeu est suspendu, le Timer ne rattrape pas automatiquement les minutes écoulées pendant la suspension.

## Points de vigilance

- L'écran ne doit pas écrire directement la sauvegarde si la logique de persistance est déjà dans un service.
- Les signaux doivent rester orientés métier et ne pas mélanger affichage, règles et données.
- Le composant est plus lisible s'il ne contient qu'une logique spécifique à son périmètre.

## Voir aussi

- [README de l'architecture](README.md)
- [Menu principal](scene-menu-principal.md)
- [Campagne](scene-campagne.md)
