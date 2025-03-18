# Outils
Outils de productions et de résolution des plateaux de jeux:
 - [Color sort for Anna TOOLS](https://github.com/leguims/color_sort_for_anna_tools)

# Liste des fonctionnalités

## V0.2 : Travaux pour la prochaine version

### Bug V0.2 :
- Le Bandeau d'information joueur n'a pas le score à jour après avoir joué (à reproduire)


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
- (Faro) Ajouter de la musique dans les menus (+1 Totol)
- (Faro) Aligner les piles sur la même ligne pour que ca soit plus facile à jouer (-1 Totol)
- Définir une notion d'ascension:
	- Définition:
		- Une ascension est une session de jeu qui commence au niveau le plus bas et se termine au niveau le plus haut.
		- En cas de réussite d'un plateau lors d'une ascension, le joueur passe au niveau supérieur
		- En cas d'échec d'un plateau lors d'une ascension, le joueur retourne au niveau inférieur (nouveau plateau)
		- En cas de réussite sur un plateau du dernier niveau, l'ascension est terminée et le joueur est félicité.
		- (option) En cas d'echec sur un plateau du premier niveau, l'ascension est terminée et le joueur est encouragé à recommencer.
	- Gérer plusieurs 'ascensions' avec tous les plateaux:
		- 1 ascension = Atteindre un niveau maximum et finir 1 plateau
		- Afficher le message de felicitations "Everest"
		- Réinitiliser le niveau au plus bas pour réaliser un autre "Everest" sur un autre chemin.
	- Gérer la difficulté relative des différentes 'ascensions':
		- Si un (ensemble de) niveau(x) elevé(s) est(sont) pauvres, les attribuer lors des dernieres ascensions
		- Qualifier les félicitations en fonction de la hauteur de l'ascension (pic du midi, ... mont blanc ... Everest).
		- Classement des ascensions :
			- https://spherama.com/classements/montagnes/ascension/classement-des-montagnes-par-difficulte-ascension-monde.php
			- https://climbfinder.com/fr/classement?l=415%3Fs%3Dhighest&s=cotacol
		- Prévoir un algo pour programmer l'ascension et la mémoriser.
	- Prévoir de donner le choix de l'ascension au départ en indiquant les quantités de chacunes des ascensions et le temps à prévoir.
	- Faire apparaitre l'avancement dans l'ascension. La distance jusqu'à la fin ... (peut-etre une jauge pour chaque niveau)
	- Musique : Attribuer des musiques en fonction de la phase ascensionnelle actuelle. 1 ascension fait défiler toutes les musiques.
	- Enregistrer le score dans les infos 'joueur' quand l'ascension est terminée. Le score intermédiaire est calculé avec le score enregistré et le calcul partiel. "Score=f(essais, temps)"
	- Prevoir une musique spéciale pour la réussite de la derniere ascension possible et le message de félicitations.
	- Ajouter un champs 'Ascension' dans les infos joueur pour indiquer le niveau de terminaison de l'ascension actuelle.

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
	- ~~Etat des lieux :~~
		- ~~"ABA.CBA.CBC.   " : filtré~~ :heavy_check_mark:
		- ~~"ACA.ACB.BCB.   " : conservé~~ :heavy_check_mark:
		- ~~"BAB.CAB.CAC.   " : filtré~~ :heavy_check_mark:
		- ~~"BAB.BAC.CAC.   " : filtré~~ :heavy_check_mark:
		- ~~"ABA.ABC.CBC.   " : filtré~~ :heavy_check_mark:
		- ~~"ACA.BCA.BCB.   " : filtré~~ :heavy_check_mark:
		- ~~Pour filtrer ce doublon, il faut appliquer les permutations de jetons à chaque permutations de piles.~~
- ~~'classer_les_solutions.py' Réaliser un script d'élagage des solutions quand un plateau de départ a déjà une colonne de résolue.~~:heavy_check_mark:
- ~~'chercheur_de_plateaux.py' Ne pas considérer les plateaux avec une pile déjà résolue.~~:heavy_check_mark:
- ~~outils : utiliser le module "logging" pour tracer l'avancement des threads dans leur tâches.~~:heavy_check_mark:
	- ~~traces Plateau : utiliser le module "logging" pour tracer l'avancement dans la classe.~~:heavy_check_mark:
	- ~~traces LotDePlateaux : utiliser le module "logging" pour tracer l'avancement dans la classe.~~:heavy_check_mark:
	- ~~traces ResoudrePlateau : utiliser le module "logging" pour tracer l'avancement dans la classe.~~:heavy_check_mark:
	- ~~traces ExportJSON : utiliser le module "logging" pour tracer l'avancement dans la classe.~~:heavy_check_mark:
- ~~Enregistrer le format "plateau_ligne_texte_universel" dans tous les JSON.~~:heavy_check_mark:
- ~~Rénovation et Accélération des recherches:~~:heavy_check_mark:
	- ~~Dans les analyses JSON 'Analyses\Plateaux_*\Plateaux_*.json:~~:heavy_check_mark:
		- ~~Supprimer les champs 'debut' + 'fin' + 'durée'~~:heavy_check_mark:
		- ~~Ajouter un champs 'revalidation phase 1 terminee'~~:heavy_check_mark:
		- ~~Ajouter un champs 'revalidation phase 2 terminee'~~:heavy_check_mark:
		- ~~Ajouter un mecanisme de classement systématique des listes de plateaux avant de produire le JSON.~~:heavy_check_mark:
		- ~~implementer 'lt()' dans la classe Plateau pour ce faire.~~ Non necessaire.
		- ~~Ajouter un champs 'dernier plateau revalide' pour reprise de validation.~~:heavy_check_mark:
		- ~~Modifier l'algorithme de reprise de recherche de plateau : boucler et itérer tant que toutes les solutions connues ne sont pas identifiées.~~:heavy_check_mark:
	- ~~Dans 'chercheur_de_plateaux.py', filtrer uniquement les plateaux valides et les plateaux avec un pile résolue.~~:heavy_check_mark:
	- ~~Dans 'revalider_les_plateaux.py', appliquer l'ensemble des filtre, dont ceux qui sont long (permutations de piles ou de jetons).~~:heavy_check_mark:
	- ~~Avec la simplification de la recherche, les compteurs de changements deviennent inutiles. (compter_plateau_a_ignorer)~~:heavy_check_mark:
	- ~~(recherche) Pour la recherche de plateaux, voir si la reprise directement sur le dernier plateau trouvé permet de gagner du temps dans les itérations. Mais dans ce cas, il faut etre capable de s'arreter quand le tour du compteur est réalisé. C'est à dire que la permutation 'plateau.pour_permutations' apparait.~~:heavy_check_mark:
- ~~BUG : la reprise de recherche s'arrête avant d'avoir tout essayé. (plateau initial produit à nouveau)~~ Corrigé ci-dessous (stop = absence de 'A')
- ~~BUG : Encore trop de plateau avec une colonne déjà terminée sont validés~~ Corrigé
- ~~Itération LotDePlateaux : Idée d'optimisation : Lors de la recherche, avant de tester la validité, passer toutes les itérations sans 'A' dans la première colonne.~~:heavy_check_mark:
- ~~Itération LotDePlateaux : Idée d'optimisation : Lors de la recherche, avant de tester la validité, passer toutes les itérations avec la première colonne pleine de 'A'.~~:heavy_check_mark:
- ~~LotDePlateaux : Idée d'optimisation : Réaliser cette optimisation sur la dernière colonne avec la case vide ' '~~:heavy_check_mark:
- ~~Itération LotDePlateaux : Idée d'optimisation : Après étude, lorsque la premiere colonne est vidée de ses 'A', ils ne reviendront plus, c'est la fin de l'itération.~~:heavy_check_mark:
- ~~Itération LotDePlateaux : Idée d'optimisation : Trouver la premiere permutation valide proposée par l'outil de permutation et en extraire une regle 'Colonnes x Lignes'~~:heavy_check_mark:
- ~~Itération LotDePlateaux : Idée d'optimisation : Implémenter ce départ et évaluer le gain.~~:heavy_check_mark: "2x6" passe de 10mins à 5mins.
- ~~Itération LotDePlateaux : Idée d'optimisation : Trouver la 1ere permutation valide devrait dispenser de faire les combinaisons avec la colonne 'A' pleine.~~:heavy_check_mark:
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
