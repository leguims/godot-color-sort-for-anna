
# Liste des fonctionnalités

## V0.1 : Liste et organisation pour Godot:

- ~~Jeton : cube de couleur~~:heavy_check_mark:
  - ~~contient la repesentation d'un jeton~~:heavy_check_mark:

- ~~Pile : Colonne sur un plateau de jeu~~:heavy_check_mark:
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

- Plateau : ensemble des piles de jeu
  - ~~Associe plusieurs piles pour former le plateau~~:heavy_check_mark:
  - Contient les regles subjectives :
	- ~~Liste des mouvements autorisés,~~ ABANDON
	- ~~Est_terminé (toutes les colonnes sont terminées),~~:heavy_check_mark:
	- Est_bloqué (la liste des mouvements autorisés est vide)
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

- Menu :
  - ~~Page d'accueil~~:heavy_check_mark:
  - Liens entre les plateaux
  - ~~Ligne de saisie pour générer un plateau à résoudre.~~:heavy_check_mark:
  - Lien vers les Crédits (GODOT, musique, effet sonore)

### Bug V0.1 :
- La recherche de solution n'implémente pas de déplacement obligatoire de plusieurs jetons
- "ABBA.AB  .AB  " : ce plateau est impossible

## V0.2 : Travaux pour la prochaine version V0.2 :
   - outillage : produire un JSON des plateaux par niveau.
   - jeu : enregistrer et lire un JSON des niveaux en cours
   - jeu : sondage sur difficulté du plateau trop facile, bien, trop difficile.
   - jeu : prévoir un bouton de retour au menu pour abandonner
   - jeu : menu en haut : campagne, éditer et crédits.
   - outillage : réécrire les plateaux avec les "." pour identifier les "colonnes x lignes" et mélanger les plateaux de forme différentes
   - outillage : construire un JSON selon une configuration qui indique le nombre de tableau de chaque niveau.
   - pour les plateaux sans solution, lancer une recherche en ajoutant 1 colonne d'une seule ligne.
   - réfléchir à l'utilisation des musiques.
   - détecter une position de plateau bloquée ou impossible.


## V1.0 : Pour une version long terme V1.0 :
  - faire une animation du bloc qui se déplace
  - enregistrer dans les données immédiatement les déplacements, mais l'animation décide quand afficher/masquer les jetons selon son avancement. (idée, plusieurs coups sont enchaînés et joués même si l'animation n'est pas terminée. Le résultat donne une séquence d'animation magique)
  - pour les jetons, dissocier les caractéristiques : indice de jeton, couleur, nom, famille. Une famille pourrait avoir plusieurs jetons avec un nom ou une couleur différente.
  - réfléchir à une écriture de plateau qui porte l'organisation des piles dans le plateau. 


## V2.0 : Idées du futur:
- Game play "Message" :
  - Réaliser des tableaux dont la solution est un message (Anna.Loves.Sex).
  - Réorganiser Jeton et construction de plateau pour arriver à ce résultat.
- jeu en réseau : course de joueurs sur un même plateau avec chrono
- chrono enregistré sur les plateaux. Plateau masqué avant le départ. 
