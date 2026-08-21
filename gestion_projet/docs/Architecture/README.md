# Architecture du projet

Ce document resume les grandes familles de scripts et le role de chacun, sans se baser uniquement sur les commentaires. Il a ete verifie sur les fichiers reels du projet dans `sources/Scenes` et `sources/Singletons`.

## Vue d'ensemble rapide

Le projet se lit mieux si on le pense en 4 couches distinctes, qui communiquent entre elles mais ne doivent pas se melanger :

```text
UI / navigation
    menu_principal.gd
    campagne.gd
    menu_campagne.gd
    statistiques.gd
        | lit les donnees de services
        v
Gameplay / regles de partie
    classique.gd
    qui_perd_gagne.gd
    plateau.gd
    pile.gd
    jeton.gd
        | decide la fin de partie / emet les evenements
        v
Services / orchestration
    progression_campagne_service.gd
    score_service.gd
    stats_service.gd
    audio_service.gd
    vibration_service.gd
    log_service.gd
        | garde l'etat du systeme et les calculs transverses
        v
Persistence / donnees
    bdd_joueurs_service.gd
    bdd_plateaux_service.gd
    liste_joueurs_service.gd
    tableau_scores_service.gd
    configuration_service.gd
    fichiers_json_service.gd
```

Ce schéma mental est important :

- L'UI ne doit pas contenir la logique de progression du jeu.
- Le gameplay ne doit pas gérer la persistance des joueurs.
- Les services sont le point de convergence de l'état global.
- La sauvegarde est la source de vérité des données.

## 1. Les grandes familles de scripts

### A. Scenes de navigation et d'entree
Ce sont les ecrans qui dirigent le flux du jeu et ouvrent les autres scenes.

- `menu_principal.gd`
  - Point d'entree du projet.
  - Gere la creation d'un joueur, le choix du profil, l'acces a la campagne, aux scores et aux references.
  - Ne contient pas la logique metier des plateaux : il delegue vers les services.

- `campagne.gd`
  - Orchestrateur de la campagne.
  - Choisit le bon gameplay, lance un plateau, suit les victoires/defaites et pilote la progression globale.
  - Relie la logique de progression a l'interface du menu campagne.

- `scores.gd`
  - Ecran du classement.
  - Lit le tableau des scores et affiche le rang et le score global.

- `retour_menu_principal.gd`
  - Simple ecran de reference / retour.
  - Son role est surtout de navigation, pas de logique de jeu.

### B. Scenes de gameplay
Ce sont les regles specifiques a une variante de jeu.

- `classique.gd`
  - Gameplay standard.
  - Detecte si le plateau est termine selon la logique "piles non vides et monochromes".
  - Emet les signaux de victoire, abandon ou plateau invalide.

- `qui_perd_gagne.gd`
  - Variante de gameplay.
  - Relaye la fin de partie selon une regle specifique.
  - Sa logique reste isolee du moteur de plateau.

### C. Scenes de plateau, piles et jetons
Ce sont les elements du moteur de jeu du plateau.

- `plateau.gd`
  - Moteur du plateau.
  - Cree les piles, valide les deplacements, determine les selections et relaye la fin de partie.
  - C'est le point central de la mecanique de jeu sur le plateau.

- `pile.gd`
  - Represente une colonne du plateau.
  - Gere les jetons contenus, leur ordre, leur selection, leur couleur au sommet, leur statut termine/bloque.
  - C'est le composant qui sait si une pile est jouable ou non.

- `jeton.gd`
  - Unite visuelle et logique d'un jeton.
  - Gere la couleur, la selection, la soudure entre jetons identiques, et la position dans la pile.

- `decodeur_service.gd`
  - Outil de parsing du plateau.
  - Convertit une chaine de plateau en structure exploitable par le moteur.

- `layout_service.gd`
  - Service de placement.
  - Calcule la disposition des piles et la position de chaque element sur l'ecran.

- `regle_du_jeu_service.gd`
  - Regles de mouvement et validation des transferts.
  - Applique les conditions booleennes permettant ou refusant un deplacement.

### D. Scenes d'interface et de statistiques
Ce sont les ecrans d'affichage de l'etat du joueur.

- `menu_campagne.gd`
  - Interface intermediaire entre la campagne et le plateau.
  - Affiche l'etat du joueur, la longueur d'ascension, les messages de victoire/defaite et le bouton de demarrage.

- `statistiques.gd`
  - Tableau de bord des performances.
  - Lit les services statistiques et affiche KPI / valeurs de campagne / ascension / plateau.

- `kpi.gd`
  - Petit composant d'affichage de metrique.
  - Ne calcule pas : il affiche simplement des valeurs dans un format reutilisable.

- `diagramme_en_barres.gd`
  - Composant visuel pour representer des series ou comparaisons.

- `courbe.gd`
  - Composant visuel pour tracer l'evolution de donnees temporelles ou progressives.

- `clavier.gd`
  - Clavier virtuel pour la saisie d'un pseudo.
  - N'a pas de logique de jeu : il relaye simplement la saisie a la scene appelante.

### E. Services globaux du jeu
Ce sont les pieces qui gardent l'etat du systeme et exposent des methodes transverses.

- `audio_service.gd`
  - Joue les musiques et effets sonores du jeu.
  - Choisit la musique selon le niveau de progression de l'ascension.

- `log_service.gd`
  - Service de debug.
  - Centralise l'affichage des logs et erreurs du projet.

- `vibration_service.gd`
  - Retour haptique du jeu.
  - S'applique uniquement si les vibrations sont activees.

- `progression_campagne_service.gd`
  - Coeur de la progression.
  - Gere les ascensions, les changements de niveau, la fin de campagne et les signaux de progression.

- `score_service.gd`
  - Calcule le score obtenu apres une victoire.
  - Integre le temps, le ratio, l'ascension, la campagne et le bonus specifique.

- `stats_service.gd`
  - Agrege les donnees de jeu pour produire les statistiques visibles.
  - Il ne rend pas l'UI ; il fournit les chiffres.

### F. Services de sauvegarde et donnees
Ce sont les services qui lisent et ecrivent les donnees persistantes.

- `bdd_joueurs_service.gd`
  - Sauvegarde de la progression du joueur courant.
  - Gere le nom, les plateaux restants, l'ascension en cours, les parties, etc.

- `bdd_plateaux_service.gd`
  - Banque de niveaux et de plateaux.
  - Lit le fichier JSON de campagne et fournit les listes de plateaux.

- `liste_joueurs_service.gd`
  - Index central des joueurs connus.
  - Gere la correspondance entre nom et fichier de sauvegarde.

- `tableau_scores_service.gd`
  - Classement des joueurs.
  - Gere score, rang, affichage et trophee.

- `configuration_service.gd`
  - Parametres globaux du jeu : version, musique, effets sonores, vibrations.

- `fichiers_json_service.gd`
  - Couche technique pour lire et ecrire les fichiers JSON.
  - Centralise le parsing et les erreurs de lecture/ecriture.

## 2. Role general de chaque famille

- Les scenes de navigation pilotent le flux du jeu.
- Les scenes de gameplay ne stockent pas l'etat persistant du joueur.
- Les scenes de plateau sont le moteur de la mecanique de jeu.
- Les services fournissent l'etat global et la logique transversale.
- Les services de sauvegarde sont la source de verite des donnees.
- Les interfaces (UI) lisent les services pour afficher les informations, sans decider de la logique metier.

## 3. Regle de separation claire

- Les scenes s'occupent du rendu et de l'orchestration.
- Les services gerent les regles et les donnees transverses.
- Les regles specifiques a un mode de jeu restent dans les scripts de gameplay.
- La persistance n'est pas dans la scene de plateau ni dans l'UI.

## 4. En resume

Si on simplifie l'architecture du projet :

- `menu_principal` lance le jeu.
- `campagne` decide du chemin de progression.
- `plateau` execute le gameplay visuel.
- `pile` et `jeton` representent les briques du plateau.
- `classique` et `qui_perd_gagne` definissent les variantes de victoire.
- `progression_campagne_service` pilote la structure de progression.
- `bdd_*` et `tableau_scores` protege les donnees persistantes.
- `audio`, `score`, `stats` et `vibration` donnent le comportement global du systeme.

Pour aller plus loin, voir les fichiers detailles dans ce dossier :

- [scene-menu-principal.md](scene-menu-principal.md)
- [scene-campagne.md](scene-campagne.md)
- [scene-plateau.md](scene-plateau.md)
- [service-progression-campagne.md](service-progression-campagne.md)
- [service-bdd-joueurs.md](service-bdd-joueurs.md)
- [service-stats.md](service-stats.md)
