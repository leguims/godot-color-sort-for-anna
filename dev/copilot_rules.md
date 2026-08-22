# Copilot – Instructions globales pour mon projet Godot

Ce fichier contient toutes les consignes destinées à GitHub Copilot pour garantir un code propre, cohérent, et conforme à l’architecture API/Logic utilisée dans ce projet.

---

## 1. Règles générales pour GitHub Copilot

- Respecter le pattern **API/Logic**.
- Ne jamais mélanger **UI** et **logique métier**.
- Ne pas inventer de nodes ou de chemins de nodes.
- Ne pas créer de singletons non nécessaires.
- Utiliser **snake_case** pour les noms de variables et méthodes.
- Préférer des méthodes **courtes**, **claires**, et à **responsabilité unique**.
- Documenter les méthodes publiques.
- Ne jamais utiliser `get_node()` dans la logique métier.
- Ne jamais faire de logique métier dans les scripts UI.

---

## 2. Structure API/Logic Godot

### 2.1. Fichier API (`<Module>API.gd`)

- Contient uniquement :
  - des **signaux**
  - des **méthodes publiques**
- Ne contient **aucune logique métier**.
- Délègue tout à `<Module>Logic.gd`.
- Sert d’interface entre UI et Logic.

### 2.2. Fichier Logic (`<Module>Logic.gd`)

- Contient la **logique métier interne**.
- Ne contient :
  - aucun signal
  - aucun accès à l’UI
  - aucun `get_node()`
- Doit être **testable**, **isolé**, **propre**.

### 2.3. Fichier UI (`<Module>UI.gd`)

- Interagit uniquement avec `<Module>API.gd`.
- Ne contient **aucune logique métier**.
- Peut émettre des signaux vers l’API.

---

## 3. Modèle de module complet

```text
<Module>/
    <Module>API.gd
    <Module>Logic.gd
    <Module>UI.tscn
    <Module>UI.gd
```

## 4. Instructions pour les scènes Godot (fichier *.tscn)

```text
# CONTEXTE POUR COPILOT
# Cette scène contient :
# - Un Button nommé "PlayButton"
# - Un Label nommé "StatusLabel"
# - Un Timer nommé "AutoStartTimer"
# Chemins de nodes :
# - $PlayButton
# - $Panel/StatusLabel
# - $AutoStartTimer
```

## Consignes pour refactoriser un fichier

```text
# INSTRUCTIONS POUR COPILOT
# - Identifier les responsabilités multiples.
# - Extraire la logique métier dans <Nom>Logic.gd.
# - Garder uniquement les méthodes publiques dans ce fichier.
# - Ajouter des signaux si l’UI doit réagir.
# - Ne pas modifier les signatures publiques existantes.
```
