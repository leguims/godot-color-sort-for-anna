
# Liste des fonctionnailités

## V0.1 : Liste et organisation pour Godot:

	:white_check_mark: - ~~Jeton : cube de couleur~~
		:white_check_mark: - ~~contient la repesentation d'un jeton~~

	:black_square_button: Pile : Colonne sur un plateau de jeu
		:black_square_button: Contient les regles de jeu subjectives :
			:black_square_button: Accepte un/des jeton(s) de couleur,
			:black_square_button: Donne un/des jeton(s) de couleur,
			:black_square_button: Est_terminé (colonne pleine mono-couleur),
			:black_square_button: Est_vide (aucun jeton dans la pile),
			:black_square_button: Est_pleine (aucune emplacement vide dans la pile)
		:white_check_mark: - ~~Contient les caractéritstiques de la pile :~~
			:white_check_mark: - ~~taille~~
			:white_check_mark: - ~~Liste des jetons actuels~~
		:white_check_mark: - ~~Encodage d'une pile:~~
			:white_check_mark: - ~~"[0, 0, 0, 0]" = 4x'A' sur une pile de 4~~
			:white_check_mark: - ~~"[0, 0, 0, 0, 32, 32]" = 4x'A' + 2x' ' sur une pile de 6~~
			:white_check_mark: - ~~"[0, 1, 2, 32]" = 3x blocs et 1 case vide~~

	- Plateau : ensemble des piles de jeu
		:white_check_mark: - ~~Associe plusieurs piles pour former le plateau~~
		- Contient les regles subjectives :
			- Liste des mouvements autorisés,
			- Est_terminé (toutes les colonnes sont terminées),
			- Est_bloqué (la liste des mouvements autorisés est vide)
		:white_check_mark: - ~~Encodage de plateau:~~
			:white_check_mark: - ~~"AABB.BBAA.    " signifie :~~
				:white_check_mark: - ~~pile 1 : "AABB"~~
				:white_check_mark: - ~~pile 2 : "BBAA"~~
				:white_check_mark: - ~~pile 3 : vide (4 emplacements)~~
			:white_check_mark: - ~~"ABAB.BABA.    . "~~
				:white_check_mark: - ~~pile 1 : "ABAB"~~
				:white_check_mark: - ~~pile 2 : "BABA"~~
				:white_check_mark: - ~~pile 3 : vide (4 emplacements)~~
				:white_check_mark: - ~~pile 4 : vide (1 emplacement)~~

	- Menu :
		:white_check_mark: - ~~Page d'accueil~~
		- Liens entre les plateaux
		:white_check_mark: - ~~Ligne de saisie pour générer un plateau à résoudre.~~
		- Lien vers les Crédits (GODOT, musique, effet sonore)

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
		- Réaliser des tableaux dont la solution est un message (Anna.Love.Sex).
		- Réorganiser Jeton et construction de plateau pour arriver à ce résultat.
        - jeu en réseau : course de joueurs sur un même plateau avec chrono
        - chrono enregistré sur les plateaux. Plateau masqué avant le départ. 
