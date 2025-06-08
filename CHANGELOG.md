# Liste des fonctionnalités

## V0.3.1 : Travaux réalisés

### Jeu
- Découper "Gestion_Score" en plusieurs modules indépendants. Campagne, sauvegarde, traitement des données.
- Ajouter des points au score par ascension terminée.
- Annuler la sélection de pile lors d'un pointage sur le fond d'écran
- La sélection ne met en surbrillance que les jetons concernés et pas la pile
- En jeu, représenter les jetons contigus identiques comme "soudés".

#### Ascensions
- Dictionnaire pour les musiques en fonction des niveaux.
- Au commencement d'une ascension, permettre à l'utilisateur de choisir la longueur de son ascension.
- Lors d'un abandon, ne pas rejouer le même plateau abandonné, mais proposer un autre plateau de même difficulté.
- Après une résolution ou abandon, représenter la variation du score avec sa composante "taux de réussite" et "temps de résolution" pour que le joueur comprenne les ressorts d'amélioration du score.
- Ajouter des points spécifiques à la réussite d'une ascension dans le score.

#### Musique
- Attribuer des musiques en fonction de la phase ascensionnelle actuelle. 1 ascension fait défiler toutes les musiques.
- Prévoir des musiques différentes selon l'avancement dans l'ascension.

#### Graphisme
- Représenter 2 jetons identiques l'un sur l'autre comme soudés
- Quand une pile est bloquée, activée une couleur sombre autours (inverse de la selection). Elle n'est plus selectionnable.

#### Congiguration du jeu
- Ajouter une option pour activer/désactiver la musique
- Ajouter une option pour activer/désactiver les vibrations
- Ajouter une option pour activer/désactiver les bruitages

### Outillage

#### Revalidation
- Revalidation Phase 2 : il faut décomposer en plusieurs phases, car en 8x3, après 90 minutes, il est toujours bloqué dans la première sous boucle.
	- Vérifier à chaque étape de revalidation que le fichier est enregistré
	- Comparer le resultat avec l'ancien algo
- À chaque itération, repartir sur la nouvelle base et ne pas vérifier les plateaux effacés précedemment

#### Accélération de recherche
- Ajouter un champs "Dernier plateau recherche" pour reprendre la recherche de plateau plus efficacement.

## V0.3.0 : Travaux réalisés

### Jeu
- Ajouter un pictogramme dans les scores pour le TOP 3. Ajouter ce pictogramme dans les infos joueurs de la campagne.
- Gérer un fichier de plateaux avec des niveaux discontinus
- (Anna) retour au menu devient menu
- (Anna) supprimer score dans les infos joueur
- (Anna) progression campagne : carré blanc = montagne.
- (Anna) Remplacer la progression campagne par le nombre d'ascensions des dernières 24h.
- (Anna) Laisser le nombre d'ascensions de manière permanente dans les infos joueurs (trop difficile pour etre volatile)

#### Menu principal
- Supprimer la tuile "Nouveau Joueur"
- Dans le menu "Campagne", ajouter après la liste des joueurs une tuile " + "
- Dans le menu "Campagne, la tuile " + " est éditable, réalise la vérification du nom et ajoute le nouveau joueur

#### Ascensions
- Gérer plusieurs 'ascensions' avec tous les plateaux:
  - 1 ascension = Atteindre un niveau maximum et finir 1 plateau
  - Afficher le message de felicitations "Everest"
  - Réinitiliser le niveau au plus bas pour réaliser un autre "Everest" sur un autre chemin.
- Faire apparaitre l'avancement dans l'ascension. La distance jusqu'à la fin ... (peut-etre une jauge pour chaque niveau)
  	- Remplacer "Niveau X.Y" par "Campagne : XX%" avant de commencer une nouvelle ascension
  	- Remplacer "Niveau X.Y" par "Ascension : XX%" pendant une ascension
- Ajouter un champs 'Ascension' dans les infos joueur pour indiquer le niveau de terminaison de l'ascension actuelle.

#### Android
- Pour Android : réorganiser les piles au centre de l'écran
- Pour Android : élargir la zone de clique pour les piles. Trop de frustration avec des cliques doigts dans le vide.
- Pour Android : essayer un export Web pour voir si cela fonctionne
- Editeur de plateau : La ligne de saisie est masquée par le clavier. Elle doit être en haut de l'écran.
- Faire vibrer le telephone lors de déplacement
- Faire vibrer FORT le telephone lors d'une pile achevée et bloquée.
- Faire vibrer plus FORT le telephone lorsque la partie est gagnée.

#### Graphisme
- Lors de la selection, eclairer le contours des piles d'arrivées valides.
- Quand une pile est bloquée, entourer la pile avec la couleur de jeton assombrie (inverse de la selection). Elle n'est plus selectionnable.

### Outillage
- outils : utiliser le module "logging" pour tracer l'avancement des threads dans leur tâches.
	- traces Plateau : utiliser le module "logging" pour tracer l'avancement dans la classe.
	- traces LotDePlateaux : utiliser le module "logging" pour tracer l'avancement dans la classe.
	- traces ResoudrePlateau : utiliser le module "logging" pour tracer l'avancement dans la classe.
	- traces ExportJSON : utiliser le module "logging" pour tracer l'avancement dans la classe.
- Enregistrer le format "plateau_ligne_texte_universel" dans tous les JSON.
- Vérifier sur un petit plateau (ex: 3x6) :
	- le parcours des combinaisons
	- l'arrêt du parcours
	- la reprise

#### Revalidation
- Réaliser un script d'élagage des plateaux valides.
	- 'ABC.CBA' ==(A devient B)== 'BAC.CAB'
	- Etat des lieux :
		- "ABA.CBA.CBC.   " : filtré
		- "ACA.ACB.BCB.   " : conservé
		- "BAB.CAB.CAC.   " : filtré
		- "BAB.BAC.CAC.   " : filtré
		- "ABA.ABC.CBC.   " : filtré
		- "ACA.BCA.BCB.   " : filtré
		- Pour filtrer ce doublon, il faut appliquer les permutations de jetons à chaque permutations de piles.~~
- 'classer_les_solutions.py' Réaliser un script d'élagage des solutions quand un plateau de départ a déjà une colonne de résolue.
- 'chercheur_de_plateaux.py' Ne pas considérer les plateaux avec une pile déjà résolue.

#### Accélération de recherche
- Rénovation et Accélération des recherches:
	- Dans les analyses JSON 'Analyses\Plateaux_*\Plateaux_*.json:
		- Supprimer les champs 'debut' + 'fin' + 'durée'
		- Ajouter un champs 'revalidation phase 1 terminee'
		- Ajouter un champs 'revalidation phase 2 terminee'
		- Ajouter un mecanisme de classement systématique des listes de plateaux avant de produire le JSON.
		- Ajouter un champs 'dernier plateau revalide' pour reprise de validation.
		- Modifier l'algorithme de reprise de recherche de plateau : boucler et itérer tant que toutes les solutions connues ne sont pas identifiées.
	- Dans 'chercheur_de_plateaux.py', filtrer uniquement les plateaux valides et les plateaux avec un pile résolue.
	- Dans 'revalider_les_plateaux.py', appliquer l'ensemble des filtre, dont ceux qui sont long (permutations de piles ou de jetons).
	- Avec la simplification de la recherche, les compteurs de changements deviennent inutiles. (compter_plateau_a_ignorer)
	- (recherche) Pour la recherche de plateaux, voir si la reprise directement sur le dernier plateau trouvé permet de gagner du temps dans les itérations. Mais dans ce cas, il faut etre capable de s'arreter quand le tour du compteur est réalisé. C'est à dire que la permutation 'plateau.pour_permutations' apparait.
- Itération LotDePlateaux : Idée d'optimisation : Lors de la recherche, avant de tester la validité, passer toutes les itérations avec la première colonne pleine de 'A'.
- LotDePlateaux : Idée d'optimisation : Réaliser cette optimisation sur la dernière colonne avec la case vide ' '
- Itération LotDePlateaux : Idée d'optimisation : Après étude, lorsque la premiere colonne est vidée de ses 'A', ils ne reviendront plus, c'est la fin de l'itération.
- Itération LotDePlateaux : Idée d'optimisation : Trouver la premiere permutation valide proposée par l'outil de permutation et en extraire une regle 'Colonnes x Lignes'
- Itération LotDePlateaux : Idée d'optimisation : Implémenter ce départ et évaluer le gain. "2x6" passe de 10mins à 5mins.
- Itération LotDePlateaux : Idée d'optimisation : Trouver la 1ere permutation valide devrait dispenser de faire les combinaisons avec la colonne 'A' pleine.
- Itération LotDePlateaux : Idée d'optimisation : Lors de la recherche, avant de tester la validité, passer toutes les itérations sans 'A' dans la première colonne.
- Ajouter un champs "Dernier plateau a valider" pour reprendre la recherche de plateau plus efficacement.

#### Difficulté de plateau
- Définir le niveau de difficulté d'un plateau selon les critères suivants :
	- longueur solution et nombre de jetons sur le plateau (exhaustif)
		- SurfacePlateau = NombreDePiles x NombreDeJetonParPile du plateau effectif
		- SurfacePlateauMax = NombreDePilesMax x NombreDeJetonParPileMax (11x3 = max actuel; 12x12 = max théroique à court terme)
		- ProfondeurSolution = Nombre de mouvements pour la solution
		- Difficulté = Entier de ( ProfondeurSolution x SurfacePlateauMax / SurfacePlateau)

## V0.2 : Travaux réalisés
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

### Bug V0.2 :
- ~~Le Bandeau d'information joueur n'a pas le score à jour après avoir joué (avéré sur l'affichage en fin d'ascension)~~:heavy_check_mark:
  - ~~RAZ memoire + premier tableau fini. Score (bandeau info joueur) = 3600; Score (écran score) = 3776; Score (retour bandeau info joueur) = 3776~~:heavy_check_mark:
- ~~Quand une pile est pleine, elle peut encore être selectionnée alors qu'elle devient immuable.~~:heavy_check_mark:
- ~~Les cliques entre 2 jetons ne sont pas pris en compte.~~:heavy_check_mark:
- ~~l'algorithme de difficulté est mauvais pour un plateau 3x5 qui est surclassé ! ("AABAA.A    .BBBB " 3x5 en X coups = difficulté 28) bien plus facile que ("BCA.CDB.CDA.BDA.   " 5x3 en X coups = 10)~~ Abandon (c'est la cohabitation de l'ancienne échelle de difficulté de 1 à 10 qui cause cette discontinuité.)
- ~~BUG ancien : Sur le plateau de jeu, agrandir la fenetre preserve les piles. Par contre, si l'agrandissement a lieu avant d'appuyer sur le bouton commencer, les piles ne vont pas apparaitre.~~:heavy_check_mark:
-  ~~Ajout d'un nouveau joueur sans nom est accepté.~~:heavy_check_mark:
-  ~~Ajout d'un nouveau joueur puis clique sur campagne double tous les joeurs.~~:heavy_check_mark:

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
