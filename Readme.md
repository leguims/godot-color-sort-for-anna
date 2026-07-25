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

Depuis la phase de tests internes de la version V0.3.0, les fonctionnalités sont votées par les testeurs. L'attribution des fonctionnalités par versions ci-dessous devrait devenir obsolète pour préférer un classement global des testeurs. Cependant, les deux vont vivre pendant une phase de transition.

## V0.4.4 : Travaux pour la prochaine version

### Bugs

#### Bug V0.3.0 :
- [à surveiller] L'affichage "Niveau = 5 - indice Plateau = 0 - Nombre de parties = <null>" est en erreur !

#### Bug V0.4.0 :
- Définir une combinaison secrete pour declencher l'export des fichiers JSON.

### Jeu
- (Faro) Aligner les piles sur la même ligne pour que ca soit plus facile à jouer (-1 Totol)
- Sauvegarder l'état du plateau en cours après chaque coup. Le joueur qui quitte le jeu, reprend là où il était. Quand il revient, il commence avec son temps moyen sur ce type de niveau.
- (Aleksandar): thème sur le fond du décors. Trop austère.
- Sauvegarder l'état du plateau en cours après chaque coup. Le joueur qui quitte le jeu, reprend là où il était. Quand il revient, il commence avec son temps moyen sur ce type de niveau.
- Selon ton humeur, demander 5 plateaux faciles ou 5 ultras difficiles. (mode libre)
- pour les plateaux impossibles à perdre, les classer dans DÉTENTE
- pour les plateaux impossibles à gagner, proposer au joueur de trouver la combinaison pour perdre. (Mode No Win)
- Pouvoir effacer un joueur (avec confirmation)
- Effacer automatiquement un joueur sans fichier de statistiques.
- Ajouter un menu pour effacer un joueur (avec resolution d'un plateau pour confirmer)

#### Web
- ~~Filtrer le menu des vibrations~~
- ~~Ajouter un clavier pour ajouter un joueur~~
- ~~Afficher l'avancement dans l'ascension + Campagne au lieu des icones moches. (Android, Windows et WEB)~~
- Ajouter un menu pour exporter les sauvegardes (avec chiffrage secret)
- Ajouter un menu pour importer les sauvegardes chiffrées
- Ajouter un clavier virtuel pour saisir le nom du joueur

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
- Campagne progressive qui impose les ascensions
- Jeu libre avec les plateaux résolus en campagne (statistiques protégées de l'entrainement)

#### Statistiques
- Outils visuels:
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
  - Campagne:
    - [Line chart] Temps de jeu,
    - [Bar chart 1] Nombre de parties
    - [Bar chart 1] Nombre de défaites
  - Ascension:
    - [Line chart] durée d'ascension (temps, plateaux), 
  - Niveau (notion artificielle à construire):
    - [Line chart] Idée de représentation graphique : Dessiner une courbe avec x=niveaux et y=f(x)=echecs, taux de réussite ...
    - [Line chart] Idée : Representer les courbes sur 1 mois d'activité et comparer au dernier mois (en pointillé) 
    - [Bar chart 2] échecs par niveau, 
    - [Bar chart 2] taux de réussite par niveau, 
    - [Bar chart 2] temps moyen par niveau,
    - [Bar chart 2] complétion par niveau,
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
- ~~prévoir un champs de sauvegarde avec les infos : plateau courant (niveau, indice, nom et "nom" actuel).~~ ABANDON (je ne comprends plus)

#### Ambiance
- (Anna) Le score est animé quand il augmente. Comme une machine à sous.
- (Faro) Ajouter de la musique dans les menus (+1 Totol)
- (option) détecter une position de plateau bloquée ou impossible.
- (Totol) Quand un joueur met du temps à jouer, faire une animation pour dire d'abandonner ou faire apparaître une main qui y invite. C'est du troll.
- (Guigui) messages d'amour pour joueuse d'amour !
- (copilot) Ajouter des defis (complete en moins de X mouvements)
- (Guigui) Pour le son de fin de rangée, interroger la taille de la rangée pour boucler un son en fonction de sa taille.
- (Guigui) Changer de thème quand on joue une 2onde fois un plateau en échec. (Rouge avec un logo "Attention")
- (Guigui) en jeu, afficher la complétion de l'ascension et de la campagne sous le nom sous forme de pourcentage.

#### Accessibilité
- Le tremblement peut faire selectioner/désélectionner une pile dans le même temps. Faire une tempo pour sélectionner une pile afin de se protéger des tremblements.
- ~~Faire une sorte de buzz pour les mouvements interdits. Pas de son si la selection périme.~~ V0.4.3

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
