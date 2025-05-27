# Documentation de conception
Documentation de l'architecture et la conception du jeu:
- [Document de conception](docs/Godot-Color-Sort-For-Anna.md)

# Outils
Outils de productions et de résolution des plateaux de jeux:
- [Color sort for Anna TOOLS](https://github.com/leguims/color_sort_for_anna_tools)

# Liste des fonctionnalités

## V0.3.1 : Travaux pour la prochaine version

### Bug V0.3.0 :
- [à surveiller] L'affichage "Niveau = 5 - indice Plateau = 0 - Nombre de parties = <null>" est en erreur !

### Jeu
- Page "Campagne" : En même temps que le bouton "Commencer", faire des liens (en haut) vers chaque joueurs pour basculer d'une campagne à l'autre sans passer par le menu
- Lire les plateaux 'Solutions_classees.json' et enregistrer l'UUID. Si l'UUID n'est pas celui de la sauvegarde, effacer toutes les sauvegardes des joueurs.
- (option) enregistrer les dates de jeux et proposer une série de plateaux de chaque niveau. "Semaine 1", proposer les 1er plateaux de chaque niveau.
- (option) prévoir un json avec l'enregistrement des scores de chacun sur chaque semaine. Score total et score semaine.
- (Faro) Aligner les piles sur la même ligne pour que ca soit plus facile à jouer (-1 Totol)
- Découper "Gestion_Score" en plusieurs modules indépendants. Campagne, sauvegarde, traitement des données.
- Sauvegarder l'état du plateau en cours après chaque coup. Le joueur qui quitte le jeu, reprend là où il était. Quand il revient, il commence avec son temps moyen sur ce type de niveau.
- (Aleksandar): thème sur le fond du décors. Trop austère.
- Ajouter des points au score par ascension terminée.
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
- Dictionnaire pour les musiques en fonction des niveaux.
- Calculer les populations restantes de chaque difficulté et attribuer un nombre de plateau par niveaux à réaliser par ascension au minimum. Le chemin se rallonge en cas d'echecs.

#### Deploiement de versions
- changement de version : les nouveaux tableaux et les anciens tableaux sont en collision.
- définir le modèle de mise à jour : tout à zéro, on poursuit en cumulé, on poursuit en perdant l'ancien
- Sauvegarder le numéro de version dans la sauvegarde et l'utiliser lors du lancement d'une nouvelle version pour réaliser tous les travaux de mise à jour de changement de version nécessaire.
- prévoir un champs de sauvegarde avec les infos : plateau courant (niveau, indice, nom et "nom" actuel).
- enregistrer la liste des nom de plateaux achevés ?

#### Musique
- Réfléchir à l'utilisation des musiques.
  - Option 1 : 1 musique aléatoire à chaque plateau
  - Option 2 : 1 musique par tranche de progression dans l'ascension
  - Option 3 : 1 musique de debut d'ascension et de fin d'ascension constantes et de l'aléatoire sur le chemin
- Musique : (option 2) Attribuer des musiques en fonction de la phase ascensionnelle actuelle. 1 ascension fait défiler toutes les musiques.

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
- Représenter 2 jetons identiques l'un sur l'autre comme soudés
- voir si une astuce de zoom existe sur Godot pour grandir les piles suivant la taille des piles.
- Quand une pile est bloquée, activée une couleur sombre autours (inverse de la selection). Elle n'est plus selectionnable.

#### Ambiance
- (Anna) Le score est animé quand il augmente. Comme une machine à sous.
- (Faro) Ajouter de la musique dans les menus (+1 Totol)
- (option) détecter une position de plateau bloquée ou impossible.
- (Totol) Quand un joueur met du temps à jouer, faire une animation pour dire d'abandonner ou faire apparaître une main qui y invite. C'est du troll.

#### Musique
- Réfléchir à l'utilisation des musiques.
  - Option 1 : 1 musique aléatoire à chaque plateau
  - Option 2 : 1 musique par tranche de progression dans l'ascension
  - Option 3 : 1 musique de debut d'ascension et de fin d'ascension constantes et de l'aléatoire sur le chemin
- Musique : (option 2) Attribuer des musiques en fonction de la phase ascensionnelle actuelle. 1 ascension fait défiler toutes les musiques.

#### Accessibilité
- Le tremblement peut faire selectioner/désélectionner une pile dans le même temps. Faire une tempo pour sélectionner une pile afin de se protéger des tremblements.
- Quand une sélection de pile est faite, montrer les piles destination possible.
- Faire une sorte de buzz pour les mouvements interdits. Pas de son si la selection périme.

### Outillage

#### Revalidation
- ~~Revalidation Phase 2 : il faut décomposer en plusieurs phases, car en 8x3, après 90 minutes, il est toujours bloqué dans la première sous boucle.~~:heavy_check_mark:
	- ~~Vérifier à chaque étape de revalidation que le fichier est enregistré~~:heavy_check_mark:
	- ~~Comparer le resultat avec l'ancien algo~~:heavy_check_mark:
- ~~À chaque itération, repartir sur la nouvelle base et ne pas vérifier les plateaux effacés précedemment~~:heavy_check_mark:

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

## V0.3
- [Phase de tests internes](Tests_internes_V0.3.0.md)

# Demandes d'évolutions

Voici la liste ordonnées des évolutions votées lors de la version V0.3.0 (Rang | Score | Description):

1.	Score: 1,4	- Ajouter une option pour activer/désactiver la musique
2.	Score: 1,4	- Ajouter une option pour activer/désactiver les vibrations
3.	Score: 1,4	- Annuler la sélection de pile lors d'un pointage sur le fond d'écran
4.	Score: 1,4	- Des plateaux encore plus difficiles !
5.	Score: 1,6	- Ajouter une option pour activer/désactiver les bruitages
6.	Score: 1,7	- Au commencement d'une ascension, permettre à l'utilisateur de choisir la longueur de son ascension.
7.	Score: 1,7	- Réduire la similitude des plateaux de faible niveaux qui se ressemblent trop.
8.	Score: 1,9	- Baser la difficulté sur le nombre d'alternatives (les occasions de faire une erreur) de la solution
9.	Score: 2,0	- Lors d'un abandon, ne pas rejouer le même plateau abandonné, mais proposer un autre plateau de même difficulté.
10.	Score: 2,0	- Améliorer la précision de l'avancement dans l'ascension
11.	Score: 2,0	- La sélection ne met en surbrillance que les jetons concernés et pas la pile complète
12.	Score: 2,1	- Dans le menu principal, donner accès à des statistiques de jeu des joueurs.
13.	Score: 2,1	- Dans la page de statistiques, présenter des statistiques de "Campagne" : Pourcentage de complétion,  Temps de jeu, Nombre de parties, Nombre de défaites, Taux de. réussite, Série maximum de succès
14.	Score: 2,1	- Dans la page de statistiques, présenter des statistiques de "Ascension" : Pourcentage de complétion de l'ascension en cours, nombre d'ascension sans détour, la pl.us longue (temps, dépassement de plateaux) durée moyenne d'ascension (temps, plateaux), nombre d'ascension achevées
15.	Score: 2,1	- Prévoir 2 tableaux de scores : un classement globale et cumulatif de tous les plateaux joués et un classement par ascension.
16.	Score: 2,1	- Implémenter le "GLISSER" pour le déplacement de jeton en plus du mécanisme actuel.
17.	Score: 2,2	- Sauvegarder le jeu pendant la résolution d'un plateau pour reprendre au milieu d'un plateau.
18.	Score: 2,3	- Ajouter une description du but du jeu dans la description de l'application
19.	Score: 2,3	- Ajouter une description des règles du jeu dans la description de l'application.
20.	Score: 2,4	- Agrandir la zone de sélection autours de la pile, car elle est trop étroite..
21.	Score: 2,6	- Dans la page de statistiques, présenter des graphiques de statistiques de "Difficulté" : échecs par difficulté, taux de réussite, temps moyen, complétion.
22.	Score: 2,6	- Après une résolution ou abandon, représenter la variation du score avec sa composante "taux de réussite" et "temps de résolution" pour que le joueur comprenne les ressorts d'amélioration du score.
23.	Score: 2,9	- Ajouter une musique dans les menus
24.	Score: 3,0	- Prévoir des musiques différentes selon l'avancement dans l'ascension.
25.	Score: 3,0	- Ajouter des points spécifiques à la réussite d'une ascension dans le score..
26.	Score: 3,0	- En jeu, représenter les jetons contigus identiques comme "soudés"..
27.	Score: 3,0	- Quand un joueur tarde à résoudre un plateau, faire une animation pour l'inviter à abandonner (troll).
28.	Score: 3,2	- Réaliser une animation de jeton qui se déplace
29.	Score: 3,3	- Dans la page "Campagne" à coté du bouton "Menu", prévoir un bouton pour changer de joueur sans retourner au menu principal.
30.	Score: 3,3	- Ajouter des fonds et des emojis de plateaux à thème (exemple : une cuisine avec des jetons d'aliments)
31.	Score: 3,4	- Le score augmente comme sur une machine à sous.
32.	Score: 3,8	- Afficher une image en fond plutôt que le fond uni.
