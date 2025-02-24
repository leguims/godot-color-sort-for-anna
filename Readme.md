
# Liste des fonctionnalités

## V0.1 : Liste et organisation pour Godot:

- ~~Jeton : cube de couleur~~
  - ~~contient la repesentation d'un jeton~~:heavy_check_mark:
- ~~Pile : Colonne sur un plateau de jeu~~
  - ~~Contient les regles de jeu subjectives :~~:heavy_check_mark:
	- ~~Accepte un/des jeton(s) de couleur,~~:heavy_check_mark:
	- ~~Donne un/des jeton(s) de couleur,~~:heavy_check_mark:
	- ~~Est_terminé (colonne pleine mono-couleur),~~:heavy_check_mark:
	- ~~Est_vide (aucun jeton dans la pile),~~:heavy_check_mark:
	- ~~Est_pleine (aucune emplacement vide dans la pile)~~:heavy_check_mark:
  - ~~Contient les caractéritstiques de la pile :~~:heavy_check_mark:
	- ~~taille~~:heavy_check_mark:
	- ~~Liste des jetons actuels~~:heavy_check_mark:
	- ~~Encodage d'une pile:~~:heavy_check_mark:
	  - ~~"[0, 0, 0, 0]" = 4x'A' sur une pile de 4~~:heavy_check_mark:
	  - ~~"[0, 0, 0, 0, 32, 32]" = 4x'A' + 2x' ' sur une pile de 6~~:heavy_check_mark:
	  - ~~"[0, 1, 2, 32]" = 3x blocs et 1 case vide~~:heavy_check_mark:
- ~~Plateau : ensemble des piles de jeu~~
  - ~~Associe plusieurs piles pour former le plateau~~:heavy_check_mark:
  - ~~Contient les regles subjectives :~~
	- ~~Liste des mouvements autorisés,~~ ABANDON géré par le bouton 'Abandonner'
	- ~~Est_terminé (toutes les colonnes sont terminées),~~:heavy_check_mark:
	- ~~Est_bloqué (la liste des mouvements autorisés est vide)~~ ABANDON géré par le bouton 'Abandonner'
	- ~~Encodage de plateau:~~:heavy_check_mark:
	  - ~~"AABB.BBAA.    " signifie :~~:heavy_check_mark:
	  - ~~pile 1 : "AABB"~~:heavy_check_mark:
	  - ~~pile 2 : "BBAA"~~:heavy_check_mark:
	  - ~~pile 3 : vide (4 emplacements)~~:heavy_check_mark:
	- ~~"ABAB.BABA.    . "~~:heavy_check_mark:
	  - ~~pile 1 : "ABAB"~~:heavy_check_mark:
	  - ~~pile 2 : "BABA"~~:heavy_check_mark:
	  - ~~pile 3 : vide (4 emplacements)~~:heavy_check_mark:
	  - ~~pile 4 : vide (1 emplacement)~~:heavy_check_mark:
- ~~Menu :~~
  - ~~Page d'accueil~~:heavy_check_mark:
  - ~~Liens entre les plateaux~~:heavy_check_mark:
  - ~~Ligne de saisie pour générer un plateau à résoudre.~~:heavy_check_mark:
  - ~~Lien vers les Crédits (GODOT, musique, effet sonore)~~ Reporté V0.2

### Bug V0.1 :
- ~~La recherche de solution n'implémente pas de déplacement obligatoire de plusieurs jetons~~:heavy_check_mark:
   - ~~"ABBA.AB  .AB  " : ce plateau est impossible~~:heavy_check_mark:

## V0.2 : Travaux pour la prochaine version
   - ~~jeu : Changer la couleur ou mettre en surbrillance le jeton ou la colonne selectionnée pour un mouvement.~~:heavy_check_mark:
   - ~~jeu : lire un JSON des niveaux/plateaux JSON~~:heavy_check_mark:
   - ~~jeu : enregistrer/lire un JSON (ou autre) des niveaux en cours~~:heavy_check_mark:
   - ~~jeu : sondage sur difficulté du plateau trop facile, bien, trop difficile.~~ Abandon pour échec/réussite automatique
   - ~~jeu : si réussite, passer au niveau suivant, si échec descendre de niveau et passer au plateau suivant.~~:heavy_check_mark:
   - ~~jeu : prévoir un bouton de retour au menu pour abandonner~~:heavy_check_mark:
   - ~~jeu : menu en haut : campagne, éditer et références.~~ ABANDON géré par la page d'accueil
   - ~~jeu : Page d'accueil : Nouveau joueur, campagne, scores, éditer et références.~~:heavy_check_mark:
   - ~~jeu : Page "Nouveau joueur" : apparence + edition du nom.~~:heavy_check_mark:
   - ~~jeu : Page "Campagne" : lien vers jeu + calcul du score + gestion du plateau à jouer + lien vers menu principal~~:heavy_check_mark:
   - ~~jeu : Page "Campagne" : Le nom du joueur courant, Niveau courant apparait dans l'écran "Commencer"~~:heavy_check_mark:
   - ~~jeu : Page "Menu principal" : L'accès à la campagne se fait par un bouton sans édition de texte~~:heavy_check_mark:
   - ~~jeu : Page "Scores" : apparence + calcul des scores + retour au menu principal~~:heavy_check_mark:
   - ~~jeu : Page "Editer un plateau" : apparence + edition plateau + jeu plateau + retour menu principal~~:heavy_check_mark:
   - ~~jeu : Page "Références" : apparence + retour menu principal~~:heavy_check_mark:
   - ~~jeu : Page "Références" : Lien vers les Crédits (GODOT, musique, effet sonore)~~:heavy_check_mark:
   - ~~jeu : prévoir un code pour que chaque joueur s'identifie.~~:heavy_check_mark:
   - ~~jeu : Détermination du score - Enregistrer le temps cumulé par niveau afin de le comptabiliser dans l'établissement du score. Rapide > lent~~:heavy_check_mark:
   - ~~jeu : Détermination du score - Enregistrer le nombre de partie jouées par niveau afin de comptabiliser les essais dans l'établissement du score. 1 essai > n essais~~:heavy_check_mark:
   - ~~jeu : Détermination du score - Le nombre d'essais devrait être plus pénalisant que le temps passé. Car pour réussir du premier coup, il faut bien analyser le plateau.~~:heavy_check_mark:
   - ~~jeu : Mesure de temps : faut-il comptabiliser le temps pour les victoires uniquements ?~~:heavy_check_mark:
   - ~~jeu : Quand un niveau est terminé, faire pointer sur le suivant pour être hors borne et ne plus rejouer le dernier niveau indéfiniement (supprimer 'plateau_victoire_dernier_plateau')~~:heavy_check_mark:
   - ~~outillage : produire un JSON des plateaux par niveau.~~:heavy_check_mark:
   - ~~outillage : réécrire les plateaux avec les "." pour identifier les "colonnes x lignes" et mélanger les plateaux de forme différentes~~:heavy_check_mark:
   - ~~outillage : construire un JSON selon une configuration qui indique le nombre de tableau de chaque niveau.~~:heavy_check_mark:

### Bug V0.2 :
- Le Bandeau d'information joueur n'a pas le score à jour après avoir joué


## V0.3 : Travaux pour la prochaine version

### Jeu
   - réfléchir à l'utilisation des musiques.
   - Page "Campagne" : faire apparaitre l'avancement dans la campagne. La distance jusqu'à la fin ... (peut-etre une jauge pour chaque niveau)
   - Page "Campagne" : En même temps que le bouton "Commencer", faire des liens (en haut) vers chaque joueurs pour basculer d'une campagne à l'autre sans passer par le menu
   - Lire les plateaux 'Solutions_classees.json' et enregistrer l'UUID. Si l'UUID n'est pas celui de la sauvegarde, effacer toutes les sauvegardes des joueurs.
   - ~~Ajouter un pictogramme dans les scores pour le TOP 3. Ajouter ce pictogramme dans les infos joueurs de la campagne.~~:heavy_check_mark:
   - (option) enregistrer les dates de jeux et proposer une série de plateaux de chaque niveau. "Semaine 1", proposer les 1er plateaux de chaque niveau.
   - (option) prévoir un json avec l'enregistrement des scores de chacun sur chaque semaine. Score total et score semaine.
   - (option) détecter une position de plateau bloquée ou impossible.
   - ~~Gérer un fichier de plateaux avec des niveaux discontinus~~:heavy_check_mark:

### Outillage
   - ~~Définir le niveau de difficulté d'un plateau selon les critères suivants :~~:heavy_check_mark:
	  - ~~longueur solution et nombre de colonne sur le plateau (simpliste)~~ Abandonné
	  - ~~longueur solution et nombre de jetons sur le plateau (exhaustif)~~:heavy_check_mark:
		- ~~SurfacePlateau = NombreDePiles x NombreDeJetonParPile du plateau effectif~~:heavy_check_mark:
		- ~~SurfacePlateauMax = NombreDePilesMax x NombreDeJetonParPileMax (11x3 = max actuel; 12x12 = max théroique à court terme)~~:heavy_check_mark:
		- ~~ProfondeurSolution = Nombre de mouvements pour la solution~~:heavy_check_mark:
		- ~~Difficulté = Entier de ( ProfondeurSolution x SurfacePlateauMax / SurfacePlateau)~~:heavy_check_mark:
   - ~~Réaliser un script d'élagage des plateaux valides.~~:heavy_check_mark:
	  - ~~'ABC.CBA' ==(echange de piles)== 'CBA.ABC'~~ Déjà en place
	  - ~~'ABC.CBA' ==(A devient B)== 'BAC.CAB'~~:heavy_check_mark:
	  - Etat des lieux :
		    - "ABA.CBA.CBC.   " : filtré :heavy_check_mark:
		    - "ACA.ACB.BCB.   " : conservé :heavy_check_mark:
		    - "BAB.CAB.CAC.   " : conservé => doublon. :heavy_exclamation_mark:
		    - "BAB.BAC.CAC.   " : filtré :heavy_check_mark:
		    - "ABA.ABC.CBC.   " : filtré :heavy_check_mark:
		    - "ACA.BCA.BCB.   " : filtré :heavy_check_mark:
		    - Pour filtrer ce doublon, il faut appliquer les permutations de jetons à chaque permutations de piles.
   - ~~'classer_les_solutions.py' Réaliser un script d'élagage des solutions quand un plateau de départ a déjà une colonne de résolue.~~:heavy_check_mark:
   - ~~'chercheur_de_plateaux.py' Ne pas considérer les plateaux avec une pile déjà résolue.~~:heavy_check_mark:
   - pour les plateaux sans solution, lancer une recherche en ajoutant 1 colonne d'une seule ligne OU 1 case vide sur la derniere colonne.
   - outils : 'classer les solutions tronquer' produire un UUID dans le fichier des solutions.
   - ~~outils : utiliser le module "logging" pour tracer l'avancement des threads dans leur tâches.~~:heavy_check_mark:
    - traces Plateau : utiliser le module "logging" pour tracer l'avancement dans la classe.
    - traces LotDePlateaux : utiliser le module "logging" pour tracer l'avancement dans la classe.
    - traces ResoudrePlateau : utiliser le module "logging" pour tracer l'avancement dans la classe.
    - traces ExportJSON : utiliser le module "logging" pour tracer l'avancement dans la classe.
   - ~~Enregistrer le format "plateau_ligne_texte_universel" dans tous les JSON.~~:heavy_check_mark:
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


## V2.0 : Idées du futur:
- Game play "Message" :
  - Réaliser des tableaux dont la solution est un message (Anna.Loves.Sex).
  - Réorganiser Jeton et construction de plateau pour arriver à ce résultat.
- jeu en réseau : course de joueurs sur un même plateau avec chrono
- chrono enregistré sur les plateaux. Plateau masqué avant le départ.
- fond de plateaux dynamiques :
   - un hublot avec des nuages qui passent
   - des oiseaux qui passent
   - des feuilles d'automne qui passent
