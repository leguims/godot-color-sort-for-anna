# Module de partage des performances

Le module `PartagePerformances` fournit une API pour signer des enregistrements JSON et les présenter dans un QR. Il ne collecte pas les enregistrements : le code appelant lui transmet le dictionnaire extrait du niveau terminé.

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

Après fermeture du partage, le jeu reprend son parcours normal : niveau suivant ou statistiques de campagne. `MenuCampagne.afficher_partage_performances()` reste disponible pour afficher le panneau avec un dictionnaire fourni par un appelant.

Le panneau conserve deux options :

- Sur Android, « Partager le QR code » transmet l'image QR au dialogue natif de partage (`Share.share_texture`). Le joueur choisit ensuite l'application de destination.
- L'adresse `rangelescouleurspouranna@gmail.com` reste affichée et peut être copiée. Pour l'envoyer manuellement par courriel, le joueur peut faire une capture d'écran du QR et la joindre à son message.

Le projet n'envoie aucun courriel automatiquement.

## Réception et validation d'un QR

La scène expose `recevoir_image_qr(image: Image)`. Le décodage est asynchrone via Godot QR Plugin. Après validation de l'enveloppe et du HMAC avec la clé configurée, la scène émet `partage_qr_code(donnees_json: Dictionary)`. Aucune donnée n'est émise si le QR est mal formé, si la signature est invalide ou si le plugin n'est pas disponible.

```gdscript
$PanneauPartagePerformances.partage_qr_code.connect(_on_partage_qr_code)
$PanneauPartagePerformances.recevoir_image_qr(image_qr)

func _on_partage_qr_code(donnees_json: Dictionary) -> void:
    print(donnees_json)
```

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

Le plugin QR Godot Mobile v1.2 est utilisé pour Android et iOS. Le partage natif Godot Share v6.0 est utilisé pour Android. Ces addons sont exclus du dépôt par le `.gitignore` racine et doivent être installés localement. La génération du QR n'est disponible que lorsque son extension native est chargée sur les plateformes compatibles; le partage natif est proposé uniquement sur Android. L'adresse du courriel reste copiable sur toutes les plateformes.

## À développer

### Import des performances

- Ajouter un singleton en autoload, disponible dès le démarrage de l'application, pour recevoir les images QR partagées vers le jeu, y compris lorsque le panneau de partage n'est pas ouvert.
- Implémenter le parcours d'import : recevoir l'image, la transmettre au décodeur QR, valider l'enveloppe et la signature HMAC, puis émettre le signal `partage_qr_code` avec le dictionnaire JSON validé. Le signal permet aux autres composants Godot de réagir aux données importées.
- Les méthodes et le signal de base existent déjà dans le module : `recevoir_image_qr(image: Image)` lance le décodage et `partage_qr_code(donnees_json: Dictionary)` diffuse les données après validation. Il reste à connecter la réception système Android au singleton et à relier ce signal au parcours d'import du joueur.
- Si le QR et sa signature sont valides, créer une sauvegarde distincte pour le joueur importé, sans modifier la sauvegarde du joueur courant. Cette sauvegarde ne doit proposer aucun plateau à jouer.
- Éviter tout recouvrement avec les joueurs existants : ne jamais remplacer une sauvegarde en cas de collision de nom. Comparer les noms sans tenir compte de la casse et attribuer automatiquement un nom unique avec un suffixe (par exemple « (importé 2) »).
- Une fois l'import réussi, afficher les statistiques reçues dans le jeu. Le singleton prendra en charge la transition vers la scène appropriée, sans retour à la scène d'où l'import a été lancé.

### Évolution de l'export

- À terme, remplacer le panneau dédié par un bouton « Partager » directement dans le panneau de score de fin de niveau ou de fin de campagne.
- Le panneau de partage détaillé actuel est conservé uniquement pour la bêta-test et pourra être retiré lorsque l'export depuis les panneaux de score sera prêt.
