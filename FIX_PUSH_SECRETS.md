# 🔐 Corriger le push bloqué (secrets détectés)

GitHub bloque le push car des clés secrètes (Supabase, Mapbox) sont dans l'historique Git.

## ✅ Solution : créer un historique propre

Les secrets ont été retirés de `lib/main.dart`. Les commandes suivantes créent un nouveau commit sans historique contenant des secrets.

### Commandes à exécuter

```powershell
cd C:\yadeli

# 1. Sauvegarder l'état actuel (les placeholders sont déjà dans main.dart)
git add .

# 2. Créer une branche sans historique (orphan)
git checkout --orphan temp-main

# 3. Tout ajouter et committer
git add -A
git commit -m "Initial commit - Yadeli"

# 4. Remplacer main par cette branche propre
git branch -D main
git branch -m main

# 5. Pousser (remplacer le remote si besoin)
git remote set-url origin https://github.com/GemimaOndele/Yadeli.git
git push -u origin main --force
```

### ⚠️ Après le push

1. **Configurer les clés** : éditer `lib/main.dart` et remplacer :
   - `VOTRE_PROJECT` → votre URL Supabase
   - `VOTRE_CLE_ANON` → votre clé anon Supabase
   - `VOTRE_TOKEN_MAPBOX` → votre token Mapbox

2. **Ne pas committer** ces clés. Garder ces modifications en local uniquement.

3. **Supprimer** `backend_app/.env` du suivi Git : `git rm --cached backend_app/.env` (déjà fait si le fichier est dans .gitignore)
