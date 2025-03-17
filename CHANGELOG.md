# Liste des fonctionnalités

## V0.2 : Travaux pour la prochaine version
- jeu : Changer la couleur ou mettre en surbrillance le jeton ou la colonne selectionnée pour un mouvement.
- jeu : lire un JSON des niveaux/plateaux JSON
- jeu : enregistrer/lire un JSON (ou autre) des niveaux en cours
- jeu : sondage sur difficulté du plateau trop facile, bien, trop difficile. Abandon pour échec/réussite automatique
- jeu : si réussite, passer au niveau suivant, si échec descendre de niveau et passer au plateau suivant.
- jeu : prévoir un bouton de retour au menu pour abandonner
- jeu : menu en haut : campagne, éditer et références. ABANDON géré par la page d'accueil
- jeu : Page d'accueil : Nouveau joueur, campagne, scores, éditer et références.
- jeu : Page "Nouveau joueur" : apparence + edition du nom.
- jeu : Page "Campagne" : lien vers jeu + calcul du score + gestion du plateau à jouer + lien vers menu principal
- jeu : Page "Campagne" : Le nom du joueur courant, Niveau courant apparait dans l'écran "Commencer"
- jeu : Page "Menu principal" : L'accès à la campagne se fait par un bouton sans édition de texte
- jeu : Page "Scores" : apparence + calcul des scores + retour au menu principal
- jeu : Page "Editer un plateau" : apparence + edition plateau + jeu plateau + retour menu principal
- jeu : Page "Références" : apparence + retour menu principal
- jeu : Page "Références" : Lien vers les Crédits (GODOT, musique, effet sonore)
- jeu : prévoir un code pour que chaque joueur s'identifie.
- jeu : Détermination du score - Enregistrer le temps cumulé par niveau afin de le comptabiliser dans l'établissement du score. Rapide > lent
- jeu : Détermination du score - Enregistrer le nombre de partie jouées par niveau afin de comptabiliser les essais dans l'établissement du score. 1 essai > n essais
- jeu : Détermination du score - Le nombre d'essais devrait être plus pénalisant que le temps passé. Car pour réussir du premier coup, il faut bien analyser le plateau.
- jeu : Mesure de temps : faut-il comptabiliser le temps pour les victoires uniquements ?
- jeu : Quand un niveau est terminé, faire pointer sur le suivant pour être hors borne et ne plus rejouer le dernier niveau indéfiniement (supprimer 'plateau_victoire_dernier_plateau')
- outillage : produire un JSON des plateaux par niveau.
- outillage : réécrire les plateaux avec les "." pour identifier les "colonnes x lignes" et mélanger les plateaux de forme différentes
- outillage : construire un JSON selon une configuration qui indique le nombre de tableau de chaque niveau.

## V0.1 : Liste et organisation pour Godot:

- Jeton : cube de couleur
	- contient la repesentation d'un jeton
- Pile : Colonne sur un plateau de jeu
	- Contient les regles de jeu subjectives :
	- Accepte un/des jeton(s) de couleur,
	- Donne un/des jeton(s) de couleur,
	- Est_terminé (colonne pleine mono-couleur),
	- Est_vide (aucun jeton dans la pile),
	- Est_pleine (aucune emplacement vide dans la pile)
  - Contient les caractéritstiques de la pile :
	- taille
	- Liste des jetons actuels
	- Encodage d'une pile:
		- "[0, 0, 0, 0]" = 4x'A' sur une pile de 4
		- "[0, 0, 0, 0, 32, 32]" = 4x'A' + 2x' ' sur une pile de 6
		- "[0, 1, 2, 32]" = 3x blocs et 1 case vide
- Plateau : ensemble des piles de jeu
	- Associe plusieurs piles pour former le plateau
	- Contient les regles subjectives :
		- Liste des mouvements autorisés, ABANDON géré par le bouton 'Abandonner'
		- Est_terminé (toutes les colonnes sont terminées),
		- ~~Est_bloqué (la liste des mouvements autorisés est vide)~~ ABANDON géré par le bouton 'Abandonner'
	- Encodage de plateau:
		- "AABB.BBAA.    " signifie :
		- pile 1 : "AABB"
		- pile 2 : "BBAA"
		- pile 3 : vide (4 emplacements)
	- "ABAB.BABA.    . "
		- pile 1 : "ABAB"
		- pile 2 : "BABA"
		- pile 3 : vide (4 emplacements)
		- pile 4 : vide (1 emplacement)
- Menu :
	- Page d'accueil
	- Liens entre les plateaux
	- Ligne de saisie pour générer un plateau à résoudre.
	- ~~Lien vers les Crédits (GODOT, musique, effet sonore)~~ Reporté V0.2

### Bug V0.1 :
- ~~La recherche de solution n'implémente pas de déplacement obligatoire de plusieurs jetons~~:heavy_check_mark:
	- ~~"ABBA.AB  .AB  " : ce plateau est impossible~~:heavy_check_mark:
