
# Liste des fonctionnailités

## V0.1 : Liste et organisation pour Godot:

- ~~Jeton : cube de couleur~~
  - ~~contient la repesentation d'un jeton~~

- Pile : Colonne sur un plateau de jeu
  - Contient les regles de jeu subjectives :
    - Accepte un/des jeton(s) de couleur,
    - Donne un/des jeton(s) de couleur,
    - Est_terminé (colonne pleine mono-couleur),
    - Est_vide (aucun jeton dans la pile),
    - Est_pleine (aucune emplacement vide dans la pile)
  - ~~Contient les caractéritstiques de la pile :~~
    - ~~taille~~
    - ~~Liste des jetons actuels~~
    - ~~Encodage d'une pile:~~
      - ~~"[0, 0, 0, 0]" = 4x'A' sur une pile de 4~~
      - ~~"[0, 0, 0, 0, 32, 32]" = 4x'A' + 2x' ' sur une pile de 6~~
      - ~~"[0, 1, 2, 32]" = 3x blocs et 1 case vide~~

- Plateau : ensemble des piles de jeu
  - ~~Associe plusieurs piles pour former le plateau~~
  - Contient les regles subjectives :
    - Liste des mouvements autorisés,
    - Est_terminé (toutes les colonnes sont terminées),
    - Est_bloqué (la liste des mouvements autorisés est vide)
    - ~~Encodage de plateau:~~
      - ~~"AABB.BBAA.    " signifie :~~
      - ~~pile 1 : "AABB"~~
      - ~~pile 2 : "BBAA"~~
      - ~~pile 3 : vide (4 emplacements)~~
    - ~~"ABAB.BABA.    . "~~
      - ~~pile 1 : "ABAB"~~
      - ~~pile 2 : "BABA"~~
      - ~~pile 3 : vide (4 emplacements)~~
      - ~~pile 4 : vide (1 emplacement)~~

- Menu :
  - ~~Page d'accueil~~
  - Liens entre les plateaux
  - ~~Ligne de saisie pour générer un plateau à résoudre.~~
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
  - Réaliser des tableaux dont la solution est un message (Anna.Loves.Sex).
  - Réorganiser Jeton et construction de plateau pour arriver à ce résultat.
- jeu en réseau : course de joueurs sur un même plateau avec chrono
- chrono enregistré sur les plateaux. Plateau masqué avant le départ. 
