# Module de partage des performances

Le module `PartagePerformances` fournit une API pour signer des enregistrements JSON, les présenter dans un QR et ouvrir le client de messagerie. Il ne collecte pas les enregistrements : le code appelant lui transmet le dictionnaire extrait du niveau terminé.

## Intégration avec les enregistrements du niveau

Après avoir extrait les enregistrements, appeler le menu de campagne :

```gdscript
$MenuCampagne.afficher_partage_performances(enregistrements_du_niveau)
```

Le dictionnaire doit être sérialisable en JSON. À la fin d'un niveau ou de la campagne, le panneau de score s'affiche en premier. Lorsque le joueur le quitte, le partage s'ouvre automatiquement et lit les données via `PartagePerformancesAPI.lire_donnees_dernier_niveau()` :

```gdscript
{
    "nom": SauvegardeBddJoueursService.lire_nom_joueur(),
    "niveau": SauvegardeBddJoueursService.enregistrement_lire_dernier_niveau()
}
```

Après fermeture du partage, le jeu reprend son parcours normal : niveau suivant ou statistiques de campagne. `MenuCampagne.afficher_partage_performances()` reste disponible pour afficher le panneau avec un dictionnaire fourni par un appelant. Le bouton de courriel ouvre un message adressé à `rangelescouleurspouranna@gmail.com`; l'utilisateur doit prendre la capture d'écran et l'ajouter lui-même en pièce jointe.

## Format du QR

Le QR contient un objet JSON de la forme :

```json
{
  "version": 1,
  "algorithme": "HMAC-SHA256",
  "donnees_json": "{\"niveau\":3}",
  "signature": "empreinte hexadécimale"
}
```

La signature porte sur les octets UTF-8 exacts de `donnees_json`. Le texte JSON des enregistrements est donc conservé dans l'enveloppe pour permettre au destinataire de recalculer la signature sans ambiguïté de sérialisation.

## Clé et sécurité

La clé est définie par `partage_performances/cle_hmac` dans `sources/project.godot`. La valeur livrée est une clé de démonstration à remplacer. Toute clé incluse dans une application distribuée peut être extraite : ce HMAC aide à détecter une altération accidentelle, mais ne prouve pas l'authenticité d'un score face à un client modifié. Pour une validation fiable, le HMAC devra être produit par un service serveur qui conserve la clé hors du jeu.

## Plateformes

Le plugin QR Godot Mobile v1.2 est inclus pour Android et iOS. La génération du QR n'est disponible que lorsque son extension native est chargée sur ces plateformes. Le panneau affiche un message d'erreur sur les exports Web et Windows; le lien de courriel reste utilisable.
