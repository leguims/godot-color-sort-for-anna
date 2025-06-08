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

## V0.3.1 : Travaux pour la prochaine version

### Bug V0.3.0 :
- [à surveiller] L'affichage "Niveau = 5 - indice Plateau = 0 - Nombre de parties = <null>" est en erreur !

### Jeu
- Page "Campagne" : En même temps que le bouton "Commencer", faire des liens (en haut) vers chaque joueurs pour basculer d'une campagne à l'autre sans passer par le menu
- Lire les plateaux 'Solutions_classees.json' et enregistrer l'UUID. Si l'UUID n'est pas celui de la sauvegarde, effacer toutes les sauvegardes des joueurs.
- (option) enregistrer les dates de jeux et proposer une série de plateaux de chaque niveau. "Semaine 1", proposer les 1er plateaux de chaque niveau.
- (option) prévoir un json avec l'enregistrement des scores de chacun sur chaque semaine. Score total et score semaine.
- (Faro) Aligner les piles sur la même ligne pour que ca soit plus facile à jouer (-1 Totol)
- ~~Découper "Gestion_Score" en plusieurs modules indépendants. Campagne, sauvegarde, traitement des données.~~:heavy_check_mark:
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
- Prevoir une musique spéciale pour la réussite de la derniere ascension possible et le message de félicitations.
- ~~Dictionnaire pour les musiques en fonction des niveaux.~~:heavy_check_mark:
- Calculer les populations restantes de chaque difficulté et attribuer un nombre de plateau par niveaux à réaliser par ascension au minimum. Le chemin se rallonge en cas d'echecs.

#### Musique
- ~~Réfléchir à l'utilisation des musiques.~~:heavy_check_mark:
  - ~~Option 1 : 1 musique aléatoire à chaque plateau~~:heavy_check_mark:
  - ~~Option 2 : 1 musique par tranche de progression dans l'ascension~~:heavy_check_mark:
  - ~~Option 3 : 1 musique de debut d'ascension et de fin d'ascension constantes et de l'aléatoire sur le chemin~~:heavy_check_mark:
- ~~Musique : (option 2) Attribuer des musiques en fonction de la phase ascensionnelle actuelle. 1 ascension fait défiler toutes les musiques.~~:heavy_check_mark:

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

#### Graphisme
- ~~Représenter 2 jetons identiques l'un sur l'autre comme soudés~~:heavy_check_mark:
- voir si une astuce de zoom existe sur Godot pour grandir les piles suivant la taille des piles.
- ~~Quand une pile est bloquée, activée une couleur sombre autours (inverse de la selection). Elle n'est plus selectionnable.~~:heavy_check_mark:

#### Ambiance
- (Anna) Le score est animé quand il augmente. Comme une machine à sous.
- (Faro) Ajouter de la musique dans les menus (+1 Totol)
- (option) détecter une position de plateau bloquée ou impossible.
- (Totol) Quand un joueur met du temps à jouer, faire une animation pour dire d'abandonner ou faire apparaître une main qui y invite. C'est du troll.

#### Accessibilité
- Le tremblement peut faire selectioner/désélectionner une pile dans le même temps. Faire une tempo pour sélectionner une pile afin de se protéger des tremblements.
- ~~Quand une sélection de pile est faite, montrer les piles destination possible.~~:heavy_check_mark:
- Faire une sorte de buzz pour les mouvements interdits. Pas de son si la selection périme.

### Outillage

- Rendre parametrable depuis les scripts "outil_*" les chemins vers "Analyses" et "Solutions"

#### Recherche de plateaux
- Ajouter un "outil_divers" pour reset les parametres de recherche de plateaux

#### Revalidation
- ~~Revalidation Phase 2 : il faut décomposer en plusieurs phases, car en 8x3, après 90 minutes, il est toujours bloqué dans la première sous boucle.~~:heavy_check_mark:
	- ~~Vérifier à chaque étape de revalidation que le fichier est enregistré~~:heavy_check_mark:
	- ~~Comparer le resultat avec l'ancien algo~~:heavy_check_mark:
- ~~À chaque itération, repartir sur la nouvelle base et ne pas vérifier les plateaux effacés précedemment~~:heavy_check_mark:
- Ajouter un "outil_divers" pour reset les parametres de revalidation des plateaux

#### Accélération de recherche
- ~~Ajouter un champs "Dernier plateau recherche" pour reprendre la recherche de plateau plus efficacement.~~:heavy_check_mark:

#### Difficulté de plateau
- Difficulté :
    - (Anna) Pour la difficulté d'un plateau, inclure l'inverse du nombre de solutions existantes.
    - Il est possible que l'ordre des difficulté soit mal classé
    - ~~Il est possible que les anciens "ordre" de 1 à 10 soient encore dans la liste alors qu'ils sont hors borne~~:heavy_check_mark:
    - Diagnostic : Vérifier les difficultés calculées
    - Diagnostic : Vérifier l'ordre des plateaux dans le jeu
    - Diagnostic : Vérifier la longueur de la solution minimale

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

# Phases de tests

## V0.3.0
- [Phase de tests internes](Tests_internes_V0.3.0.md)
