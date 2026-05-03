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

## V0.4.0 : Travaux pour la prochaine version

### Bug V0.3.0 :
- [à surveiller] L'affichage "Niveau = 5 - indice Plateau = 0 - Nombre de parties = <null>" est en erreur !

### Bug V0.3.2 :
- bug sur score d'ascension qui est calculé sur le nombre de niveaux restant dans le jeu plutot que les niveaux effectivement réalisés dans l'ascension courante.
- dernière ascension, la même musique pendant toute l'ascension.

### Bug V0.3.6 :
- après un abandon, on peut continuer de résoudre un plateau et même le résoudre malgré les menus affichés


### Jeu
- Page "Campagne" : En même temps que le bouton "Commencer", faire des liens (en haut) vers chaque joueurs pour basculer d'une campagne à l'autre sans passer par le menu
- Lire les plateaux 'Solutions_classees.json' et enregistrer l'UUID. Si l'UUID n'est pas celui de la sauvegarde, effacer toutes les sauvegardes des joueurs.
- (option) enregistrer les dates de jeux et proposer une série de plateaux de chaque niveau. "Semaine 1", proposer les 1er plateaux de chaque niveau.
- (option) prévoir un json avec l'enregistrement des scores de chacun sur chaque semaine. Score total et score semaine.
- (Faro) Aligner les piles sur la même ligne pour que ca soit plus facile à jouer (-1 Totol)
- Sauvegarder l'état du plateau en cours après chaque coup. Le joueur qui quitte le jeu, reprend là où il était. Quand il revient, il commence avec son temps moyen sur ce type de niveau.
- (Aleksandar): thème sur le fond du décors. Trop austère.
- Quand le jeu est terminé (campagne 100%), afficher un globe à coté du nom du joueur dans le menu principal
- Sauvegarder l'état du plateau en cours après chaque coup. Le joueur qui quitte le jeu, reprend là où il était. Quand il revient, il commence avec son temps moyen sur ce type de niveau.
- Selon ton humeur, demander 5 plateaux faciles ou 5 ultras difficiles. (mode libre)
- pour les plateaux impossibles à perdre, les classer dans DÉTENTE
- pour les plateaux impossibles à gagner, proposer au joueur de trouver la combinaison pour perdre. (Mode No Win)
- ~~Pouvoir passer l'apercu du score du plateau par un clique sur l'ecran.~~:heavy_check_mark:

#### Refactoring
- ~~Structurer tout le dépot pour réorganiser les sources, les outils et les tests~~:heavy_check_mark:
    - ~~plus de singleton~~
    - ~~découpage des scenes menu_campagne.gd, campagne.gd et menu_principale.gd~~

#### Ascensions
- Gérer la difficulté relative des différentes 'ascensions':
- Si un (ensemble de) niveau(x) elevé(s) est(sont) pauvres, les attribuer lors des dernieres ascensions
- Qualifier les félicitations en fonction de la hauteur de l'ascension (pic du midi, ... mont blanc ... Everest).
- Classement des ascensions :
	- https://spherama.com/classements/montagnes/ascension/classement-des-montagnes-par-difficulte-ascension-monde.php
	- https://climbfinder.com/fr/classement?l=415%3Fs%3Dhighest&s=cotacol
- Prévoir un algo pour programmer l'ascension et la mémoriser.
- Le nombre de coups minimum d'une solution est connu, il est possible de l'inclure dans le calcul du score.
- Prevoir une musique spéciale pour la réussite de la derniere ascension possible et le message de félicitations.
- Calculer les populations restantes de chaque difficulté et attribuer un nombre de plateau par niveaux à réaliser par ascension au minimum. Le chemin se rallonge en cas d'echecs.
- est ce qu'il faut limiter les ascensions (logo montagne) à une ascension maximum ?
- Il faudrait prevoir un jeu libre avec choix de difficulté et choix de longueur d'ascension + La campagne qui orchestre les longueurs d'ascensions à faire (10 puis 20 ...)
- TRICHE ANATOLE :
    - Quand anatole comme 'nom' on peux mettre n'importe quelle couleur sur n'importe quelle couleur et ça marche mais pas beaucoup de point
    - Il y aura un bouton gagner Ou quand tout les Block seront dans une case remplie

#### Statistiques
- ~~Inclure un bouton statistiques dans le menu campagne~~:heavy_check_mark:
- Outils visuels:
  - ~~KPI : Bouton carré avec un chiffre~~:heavy_check_mark:
    - ~~Durée moyenne d’une partie~~
    - ~~Niveau maximum atteint~~
    - ~~Nombre total de parties~~
    - ~~Temps total de jeu~~
  - GAUGE (Jauge) : jauge circulaire ou semi-circulaire
    - Progression vers un objectif mensuel
    - Pourcentage de niveaux complétés
    - Temps de jeu par rapport à un objectif
  - Bar chart (daigramme en barres) : 
    - Victoires / défaites
    - Nombre de parties par jour
    - Temps de jeu par mois
  - Line chart (courbe) : 
    - Temps de jeu par mois
    - Durée moyenne des parties au fil du temps
  - Le plus simple sur GODOT 4.5: utiliser la bibliotheque de base.
    - Control + TextureProgressBar + Label + Graphiques "faits maison"
- Page de statisques contient (de haut en bas):
  - ~~En haut : Nom du joueur + bouton pour changer de joueur~~:heavy_check_mark:
  - Campagne:
    - ~~[KPI] Pourcentage de complétion,~~:heavy_check_mark:
    - ~~[KPI] Temps de jeu,~~:heavy_check_mark:
    - [Line chart] Temps de jeu,
    - [Bar chart 1] Nombre de parties
    - [Bar chart 1] Nombre de défaites
    - ~~[KPI] Taux de réussite~~:heavy_check_mark:
    - ~~[KPI] Série maximum de succès~~:heavy_check_mark:
  - Ascension:
    - ~~[KPI] Pourcentage de complétion de l'ascension en cours,~~:heavy_check_mark:
    - ~~[KPI] nombre d'ascension sans détour,~~:heavy_check_mark:
    - ~~[KPI] la plus longue (temps, dépassement de plateaux)~~:heavy_check_mark:
    - [Line chart] durée d'ascension (temps, plateaux), 
    - ~~[KPI] durée moyenne d'ascension (temps, plateaux),~~:heavy_check_mark:
    - ~~[KPI] nombre d'ascension achevées ~~:heavy_check_mark:
  - Niveau (notion artificielle à construire):
    - [Line chart] Idée de représentation graphique : Dessiner une courbe avec x=niveaux et y=f(x)=echecs, taux de réussite ...
    - [Line chart] Idée : Representer les courbes sur 1 mois d'activité et comparer au dernier mois (en pointillé) 
    - [Bar chart 2] échecs par niveau, 
    - [Bar chart 2] taux de réussite par niveau, 
    - [Bar chart 2] temps moyen par niveau,
    - [Bar chart 2] complétion par niveau,
  - Plateau:
    - ~~[KPI] le plus rapide (temps, profondeur)~~:heavy_check_mark:
    - ~~[KPI] le plus long (temps, profondeur)~~:heavy_check_mark:
- Prévoir un téléchargement des stats:
    - nommer le téléphone + compte google
    - indiquer la date de création.
    - zipper les données : comptes de jeux, scores et séquences de jeu.
    - réaliser un SHA1 de l'ensemble
    - envoyer le tout à l'adresse mail du jeu.
    - Prévoir côté mail :
      - vérifier le zip avec le SHA1
      - créer une base de donnée avec tous les joueurs
      - faire un classement de tout le monde.
- Automatisation des scores:
    - activer Google Play Games Services (GPGS)
    - créer un leaderboard
    - enregistrer l'ID. 
    - importer le plug in GPGS dans godot.
    - https://godotengine.org/asset-library/asset/2440#:~:text=2.0%20Tools%204.0%20Community,%2D%20Load%20events%20by%20ids

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
- ~~Decomposer les outils pour réaliser un forkflow (pipeline)~~:heavy_check_mark:

#### Refactoring
- ~~Structurer tout le dépot pour réorganiser les sources, les outils et les tests~~:heavy_check_mark:
    - ~~arbrescence : core, io_utils, tests et pipeline~~
- ~~Améliorer le code pour simplifier la maintenance:~~:heavy_check_mark:
    - ~~creer des modules~~
    - ~~faire une API~~
    - ~~realiser des methodes deporter dans des ficheirs à theme~~
    - ~~Réalisé pour : plateau.py, lot_de_plateaux.py et resoudre.py~~

#### Recherche de plateaux
- Ajouter un "outil_divers" pour reset les parametres de recherche de plateaux

#### Revalidation
- Ajouter un "outil_divers" pour reset les parametres de revalidation des plateaux
- Similarité : Pour réduire les similarité : Rapidfuzz + seuil à ajuster (75% et plus). Voir s'il faut l'appliquer sur le fichier complet de solutions. Application sur "revalidation" = gain de temps + application sur "Solutions" pour gain de plaisir de jeu.

#### Difficulté de plateau
- ~~Dans la recherche de solution, réorganiser pour conserver:~~:heavy_check_mark:
  - ~~La quantité de blocage pour chaque longueur~~:heavy_check_mark:
- ~~Baser la difficulté le rapport : Nb Blocage / (Nb Blocage + Nb Solutionsd)~~:heavy_check_mark:
- ~~Difficulté entre 0 et 100 (le plus difficile)~~:heavy_check_mark:

#### Etape 5 : Tronquer les solutions => Exporter solution vers GODOT
- Dans l'étape 5 (tronquer), ajouter un suffixe au plateau pour indiquer qu'il y a différentes longueurs de solutions.
- Dans le jeu, à l'affichage du plateau, faire apparaître "Défi 6 coups" car 6 est le nombre de coups minimum (dans cet exemple).
- Lors du calcul de score, ajouter un score spécifique sur la longueur.
  - Longueur max = 0 points.
  - Longueur min = max points
  - et un pourcentage entre les deux.
- Les infos de solutions sont séparées par un caractère spécial. Je propose le suffixe suivant:
  - "|MIN:6|MAX:7"
  - Solution la plus courte en 6 coups.
  - Solution la plus longue en 7 coups.
- Renommer l'étape 5. Ce n'est pas tronquer les solutions, c'est produire le fichier de solutions au format du jeu godot. Tronquer, ajouter infos plateau et autres. "Étape 5 = Exporter solution vers godot"

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
