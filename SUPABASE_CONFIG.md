# Configuration Supabase pour Yadeli

## Lien « Confirmer mon compte » dans l'email (localhost / ERR_CONNECTION_REFUSED)

Si le bouton « Confirmer mon compte » dans l'email redirige vers `localhost:3000` et affiche une erreur, c'est parce que l'URL du site est mal configurée dans Supabase.

### Solution

1. Ouvrez le **Tableau de bord Supabase** : https://supabase.com/dashboard
2. Sélectionnez votre projet Yadeli
3. Allez dans **Authentication** → **URL Configuration**
4. Modifiez **Site URL** :
   - Pour une app mobile : utilisez une URL publique (ex. `https://votredomaine.com` ou `https://yadeli.app`)
   - Pour le développement : vous pouvez laisser `http://localhost:3000` mais le lien dans l'email ne fonctionnera pas sur téléphone

### Recommandation pour une app mobile

Les utilisateurs doivent **saisir le code OTP manuellement** dans l'app, pas cliquer sur le lien. Le lien peut être consommé par les filtres anti-spam des clients email (Gmail, Outlook) avant que l'utilisateur ne clique, ce qui provoque l'erreur « Token has expired ».

L'app Yadeli affiche déjà une note invitant à saisir le code plutôt qu'à utiliser le lien.

### Longueur du code OTP

Par défaut Supabase envoie 6 chiffres. Pour 8 chiffres :
- **Authentication** → **Providers** → **Email** → **OTP length** : 8
