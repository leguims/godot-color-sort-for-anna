# Documentation de conception
Documentation de l'architecture et la conception du jeu:
- [Document de conception](docs/Godot-Color-Sort-For-Anna.md)

# Outils
Outils de productions et de résolution des plateaux de jeux:
- [Color sort for Anna TOOLS](https://github.com/leguims/color_sort_for_anna_tools)

# Demandes d'évolutions
Listes des évolutions votées par les testeurs:
- [Evolutions](Evolutions.md)

# Liste des fonctionnalités

Depuis la phase de tests internes de la version V0.3.0, les fonctionnalités sont votées par les testeurs. L'attribution des fonctionnailités par versions ci-dessous devrait devenir obsolète pour préférer un classement global des testeurs. Cependant, les deux vont vivre pendant une phase de transition.

## V0.3.6 : Travaux pour la prochaine version

### Bug V0.3.0 :
- [à surveiller] L'affichage "Niveau = 5 - indice Plateau = 0 - Nombre de parties = <null>" est en erreur !

### Bug V0.3.2 :
- bug sur score d'ascension qui est calculé sur le nombre de niveaux restant dans le jeu plutot que les niveaux effectivement réalisés dans l'ascension courante.
- dernière ascension, la même musique pendant toute l'ascension.


### Jeu
- Page "Campagne" : En même temps que le bouton "Commencer", faire des liens (en haut) vers chaque joueurs pour basculer d'une campagne à l'autre sans passer par le menu
- Lire les plateaux 'Solutions_classees.json' et enregistrer l'UUID. Si l'UUID n'est pas celui de la sauvegarde, effacer toutes les sauvegardes des joueurs.
- (option) enregistrer les dates de jeux et proposer une série de plateaux de chaque niveau. "Semaine 1", proposer les 1er plateaux de chaque niveau.
- (option) prévoir un json avec l'enregistrement des scores de chacun sur chaque semaine. Score total et score semaine.
- (Faro) Aligner les piles sur la même ligne pour que ca soit plus facile à jouer (-1 Totol)
- Sauvegarder l'état du plateau en cours après chaque coup. Le joueur qui quitte le jeu, reprend là où il était. Quand il revient, il commence avec son temps moyen sur ce type de niveau.
- (Aleksandar): thème sur le fond du décors. Trop austère.
- ~~Ajouter des points au score par ascension terminée.~~:heavy_check_mark:
- Quand le jeu est terminé (campagne 100%), afficher un globe à coté du nom du joueur dans le menu principal
- Sauvegarder l'état du plateau en cours après chaque coup. Le joueur qui quitte le jeu, reprend là où il était. Quand il revient, il commence avec son temps moyen sur ce type de niveau.

#### Ascensions
- Gérer la difficulté relative des différentes 'ascensions':
- Si un (ensemble de) niveau(x) elevé(s) est(sont) pauvres, les attribuer lors des dernieres ascensions
- Qualifier les félicitations en fonction de la hauteur de l'ascension (pic du midi, ... mont blanc ... Everest).
- Classement des ascensions :
	- https://spherama.com/classements/montagnes/ascension/classement-des-montagnes-par-difficulte-ascension-monde.php
	- https://climbfinder.com/fr/classement?l=415%3Fs%3Dhighest&s=cotacol
- Prévoir un algo pour programmer l'ascension et la mémoriser.
- Prévoir de donner le choix de l'ascension au départ en indiquant les quantités de chacunes des ascensions et le temps à prévoir.
- Enregistrer le score dans les infos 'joueur' quand l'ascension est terminée. Le score intermédiaire est calculé avec le score enregistré et le calcul partiel. "Score=f(essais, temps)"
- Le nombre de coups minimum d'une solution est connu, il est possible de l'inclure dans le calcul du score.
- Prevoir une musique spéciale pour la réussite de la derniere ascension possible et le message de félicitations.
- Calculer les populations restantes de chaque difficulté et attribuer un nombre de plateau par niveaux à réaliser par ascension au minimum. Le chemin se rallonge en cas d'echecs.

#### Statistiques
- Inclure un bouton statistiques dans le menu principal
- Page de statisques contient (de haut en bas):
  - En haut : Nom du joueur + bouton pour changer de joueur
  - Campagne:
    - Pourcentage de complétion,
    - Temps de jeu,
    - Nombre de parties
    - Nombre de défaites
    - Taux de réussite
    - Série maximum de succès
  - Ascension:
    - Pourcentage de complétion de l'ascension en cours,
    - nombre d'ascension sans détour,
    - la plus longue (temps, dépassement de plateaux)
    - durée moyenne d'ascension (temps, plateaux), 
    - nombre d'ascension achevées 
  - Niveau (notion artificielle à construire):
    - Idée de représentation graphique : Dessiner une courbe avec x=niveaux et y=f(x)=echecs, taux de réussite ...
    - Idée : Representer les courbes sur 1 mois d'activité et comparer au dernier mois (en pointillé) 
    - échecs par niveau, 
    - taux de réussite par niveau, 
    - temps moyen par niveau,
    - complétion par niveau,
    - Plateau:
    - le plus rapide (temps, profondeur) 
    - le plus long (temps, profondeur) 

#### Android
- Pour Android : voir si une astuce de zoom existe sur Godot pour grandir les piles suivant la taille des piles.

#### Deploiement de versions
- changement de version : les nouveaux tableaux et les anciens tableaux sont en collision.
- définir le modèle de mise à jour : tout à zéro, on poursuit en cumulé, on poursuit en perdant l'ancien
- Sauvegarder le numéro de version dans la sauvegarde et l'utiliser lors du lancement d'une nouvelle version pour réaliser tous les travaux de mise à jour de changement de version nécessaire.
- prévoir un champs de sauvegarde avec les infos : plateau courant (niveau, indice, nom et "nom" actuel).
- enregistrer la liste des nom de plateaux achevés ?

#### Ambiance
- (Anna) Le score est animé quand il augmente. Comme une machine à sous.
- (Faro) Ajouter de la musique dans les menus (+1 Totol)
- (option) détecter une position de plateau bloquée ou impossible.
- (Totol) Quand un joueur met du temps à jouer, faire une animation pour dire d'abandonner ou faire apparaître une main qui y invite. C'est du troll.
- (Guigui) messages d'amour pour joueuse d'amour !

#### Accessibilité
- Le tremblement peut faire selectioner/désélectionner une pile dans le même temps. Faire une tempo pour sélectionner une pile afin de se protéger des tremblements.
- Faire une sorte de buzz pour les mouvements interdits. Pas de son si la selection périme.

### Outillage
- Rendre parametrable depuis les scripts "outil_*" les chemins vers "Analyses" et "Solutions"

#### Recherche de plateaux
- Ajouter un "outil_divers" pour reset les parametres de recherche de plateaux

#### Revalidation
- Ajouter un "outil_divers" pour reset les parametres de revalidation des plateaux
- ~~Similarité : Difflib : inclus dans python~~ Réalisé avec Rapidfuzz
- Similarité : Pour réduire les similarité : Rapidfuzz + seuil à ajuster (75% et plus). Voir s'il faut l'appliquer sur le fichier complet de solutions. Application sur "revalidation" = gain de temps + application sur "Solutions" pour gain de plaisir de jeu.

#### Difficulté de plateau
- ~~Dans la recherche de solution, réorganiser pour conserver:~~:heavy_check_mark:
  - ~~La solution la plus courte (1 seule)~~:heavy_check_mark:
  - ~~La quantité de solution pour chaque longueur~~:heavy_check_mark:
- ~~Baser la difficulté sur le nombre d'alternatives (les occasions de faire une erreur) de la solution~~:heavy_check_mark:
  - ~~noter avec la solution le nombre de coups possibles à chaque étapes.~~:heavy_check_mark:
  - ~~une étape sans alternative est inintéressante.~~:heavy_check_mark:
  - ~~Définir la difficulté:~~:heavy_check_mark:
    - ~~Parcourir la solution la plus courte~~:heavy_check_mark:
    - ~~À chaque coup, identifier s'il y a plusieurs coups jouables.~~:heavy_check_mark:
    - ~~Difficulté = multiplier les coups legaux à chaque étape. Comme ça "1 coup" est neutre sur le score final.~~:heavy_check_mark:

#### Divers
- pour les plateaux sans solution, lancer une recherche en ajoutant 1 colonne d'une seule ligne OU 1 case vide sur la derniere colonne.
- classer_les_solutions_tronquer.py : produire un UUID dans le fichier des solutions.
- classer_les_solutions_tronquer.py : Ajouter des filtres lors de la selection des plateaux:
	- nombre de colonnes min/max
	- nombre de lignes min/max
	- nombre de coups de la solution min/max

## V1.0 : Pour une version long terme
### Jeu
- faire une animation du bloc qui se déplace
- enregistrer dans les données immédiatement les déplacements, mais l'animation décide quand afficher/masquer les jetons selon son avancement. (idée, plusieurs coups sont enchaînés et joués même si l'animation n'est pas terminée. Le résultat donne une séquence d'animation magique)
- pour les jetons, dissocier les caractéristiques : indice de jeton, couleur, nom, famille. Une famille pourrait avoir plusieurs jetons avec un nom ou une couleur différente.
- réfléchir à une écriture de plateau qui porte l'organisation des piles dans le plateau. Par exemple '.' pour le changement de pile et '..' pour le changement de ligne.
- varier la représentation des jetons et le fond du plateau :
	- fruits avec fond de cuisine,
	- médicaments avec fond d'hôpital,
	- animaux avec un zoo,
	- pacman/fantômes et le labyrinthe
- Surement faisable avec des EMOJI : String.chr(unicode) (https://www.unicode.org/emoji/charts/emoji-list.html)
- Idee de nouveau gameplay, chaque colonne est en mouvement, comme si les jetons étaient sur un tapis roulant. Le joueurs doit donner l'ordre d'échange au bon moment !
- (Anna) Réaliser une version portugaise.

## V2.0 : Idées du futur:
- Game play "Message" :
	- Réaliser des tableaux dont la solution est un message (Anna.Loves.Sex).
	- Réorganiser Jeton et construction de plateau pour arriver à ce résultat.
	- (Aleksandar): +1 sur le mode avec des mots.
- jeu en réseau : course de joueurs sur un même plateau avec chrono
- chrono enregistré sur les plateaux. Plateau masqué avant le départ.
- fond de plateaux dynamiques :
	- un hublot avec des nuages qui passent
	- des oiseaux qui passent
	- des feuilles d'automne qui passent

## V3.0 : Ascension émotionnelle plutot qu'une montagne

### Campagne

L'ascension doit refléter:
- une relation amoureuse naissante
- une relation à entretenir
- relation avec incompréhension.
- reconstruction difficile,
- une relation à réparer
- après reconstruction/réparation, une attention quotidienne est plus facile

Des messages doivent apparaître pour la ponctuer :
- texte : maxime, proverbe, message Anna
  - Avec toi dans une cage, je me sens en liberté.
  - En cage à tes côtés, je peux voler vers des cieux merveilleux.
- audio : message Anna
- animation : représentation d'une émotion d'Anna.

Ce qui était la campagne avant doit devenir "jeu libre".

Le tableau des scores doit se dissocier.
- jeu libre = points
- campagne = coeurs

# Phases de tests

## V0.3.0
- [Phase de tests internes](Tests_internes_V0.3.0.md)
