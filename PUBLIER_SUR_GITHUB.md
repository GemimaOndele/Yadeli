# 🚀 Publier le projet sur votre propre GitHub

> Guide pour republier Yadeli depuis le dépôt de Beni vers votre propre compte GitHub.

---

## 📋 Étapes

### 1️⃣ Créer un nouveau dépôt sur GitHub

1. Aller sur [github.com](https://github.com) et se connecter
2. Cliquer sur **« + »** → **« New repository »**
3. Remplir :
   - **Repository name** : `yadeli` (ou autre nom)
   - **Description** : `Application de logistique et transport au Congo 🇨🇬 — Brazzaville`
   - **Visibility** : Public ou Private
   - ⚠️ **Ne pas** cocher « Initialize with README » (le projet en a déjà un)
4. Cliquer sur **« Create repository »**

### 2️⃣ Préparer le dépôt local

```bash
cd C:\yadeli

# Vérifier le remote actuel (pointe vers le dépôt de Beni)
git remote -v

# Supprimer l'ancien remote
git remote remove origin

# Ajouter votre dépôt comme nouveau remote
git remote add origin https://github.com/GemimaOndele/yadeli.git
```

### 3️⃣ Pousser le code

```bash
# Pousser la branche principale
git push -u origin main

# Ou si la branche s'appelle master :
git push -u origin master
```

### 4️⃣ Vérifier

- Ouvrir `https://github.com/GemimaOndele/yadeli` dans le navigateur
- Vérifier que le README, les docs et le code sont bien présents

---

## 📁 Fichiers à ne pas committer

Le `.gitignore` exclut déjà :
- `backend_app/.env` (secrets)
- `build/`, `.dart_tool/`
- Fichiers de configuration locaux

---

## 🔄 Synchroniser avec le dépôt de Beni (optionnel)

Si vous voulez garder une référence au dépôt original :

```bash
# Ajouter le dépôt de Beni comme "upstream"
git remote add upstream https://github.com/BENI_USERNAME/yadeli.git

# Récupérer les mises à jour
git fetch upstream

# Fusionner (si besoin)
git merge upstream/main
```

---

<p align="center">
  ✅ Projet prêt à être publié sur votre GitHub
</p>
