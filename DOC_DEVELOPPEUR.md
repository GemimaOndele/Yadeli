# 📘 Guide Développeur — Yadeli 🇨🇬

> Documentation complète pour configurer et faire fonctionner l'application Yadeli (logistique & transport au Congo, Brazzaville).

---

## 📋 Table des matières

1. [Prérequis](#-1-prérequis)
2. [Cloner et installer](#-2-cloner-et-installer)
3. [Configuration Supabase](#-3-configuration-supabase)
4. [Configuration Mapbox](#-4-configuration-mapbox)
5. [Variables d'environnement](#-5-variables-denvironnement)
6. [Lancer l'application](#-6-lancer-lapplication)
7. [Commandes utiles](#-7-commandes-utiles)
8. [Structure du code](#-8-structure-du-code)
9. [Dépannage](#-9-dépannage)

---

## 🔧 1. Prérequis

### Outils à installer

| Outil | Version | Lien | Vérification |
|-------|---------|------|--------------|
| **Flutter** | 3.2+ | [flutter.dev](https://docs.flutter.dev/get-started/install) | `flutter --version` |
| **Git** | 2.x | [git-scm.com](https://git-scm.com) | `git --version` |
| **Android Studio** | - | [developer.android.com](https://developer.android.com/studio) | Émulateur Android, build |
| **CMake** | 3.x | Inclus avec Flutter | Build Windows/Linux |
| **VS Code** ou **Cursor** | - | - | Éditeur recommandé |

### Vérifier Flutter

```bash
flutter doctor
```

Tous les crochets doivent être verts (✓). Si Android n'est pas configuré :

```bash
flutter doctor --android-licenses
```

---

## 📥 2. Cloner et installer

### Étape A : Cloner le dépôt

```bash
# Cloner depuis votre fork GitHub
git clone https://github.com/GemimaOndele/yadeli.git
cd yadeli
```

### Étape B : Récupérer les dépendances

```bash
flutter pub get
```

### Étape C : Vérifier que tout compile

```bash
flutter analyze
```

---

## 🗄️ 3. Configuration Supabase

### Étape A : Créer un projet Supabase

1. Aller sur [supabase.com/dashboard](https://supabase.com/dashboard)
2. Cliquer sur **New Project**
3. Choisir un nom (ex. `yadeli`), un mot de passe pour la base, une région
4. Attendre la création du projet

### Étape B : Récupérer les clés API

1. Dans le projet : **Project Settings** (⚙️) → **API**
2. Noter :
   - **Project URL** : `https://xxxxx.supabase.co`
   - **anon public** : clé JWT commençant par `eyJ...`

### Étape C : Configurer les clés (local uniquement)

1. Copier le fichier exemple : `lib/config.dart.example` → `lib/config.dart`
2. Éditer `lib/config.dart` et remplacer les placeholders par vos clés
3. `config.dart` est dans `.gitignore` — **ne sera jamais publié sur GitHub**

### Étape D : Appliquer les migrations

Depuis `backend_app/` :

```bash
cd backend_app

# Si Supabase CLI installé :
supabase db push

# Sinon : exécuter manuellement les fichiers SQL dans
# supabase/migrations/ via le SQL Editor du dashboard Supabase
```

**Fichiers à exécuter dans l'ordre :**
1. `20251223005102_init_schema.sql`
2. `20251223014306_create_orders_table.sql`

### Étape E : Créer la table `profiles`

Dans **SQL Editor** Supabase :

```sql
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  phone TEXT,
  email TEXT,
  gender TEXT DEFAULT 'homme',
  languages TEXT[] DEFAULT ARRAY['FR'],
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
```

### Étape F : Configurer l'authentification email

1. **Authentication** → **Providers** → **Email** : activé par défaut
2. **Authentication** → **URL Configuration** :
   - **Site URL** : `https://votredomaine.com` ou `http://localhost:3000` pour le dev
3. **Authentication** → **Providers** → **Email** → **OTP length** : `8` (si code à 8 chiffres)

### Étape G : Déployer l'Edge Function `create-order`

```bash
cd backend_app
supabase functions deploy create-order
```

Ou via le dashboard : **Edge Functions** → créer une fonction `create-order` avec le code de `supabase/functions/create-order/index.ts`.

---

## 🗺️ 4. Configuration Mapbox

> Mapbox est utilisé pour les cartes sur **Android et iOS** uniquement. Web et Windows utilisent Flutter Map.

### Étape A : Créer un compte Mapbox

1. [account.mapbox.com](https://account.mapbox.com)
2. Créer un compte gratuit

### Étape B : Récupérer le token

1. **Account** → **Access tokens**
2. Copier le **Default public token** (commence par `pk.`)
3. Pour le SDK mobile, un **Secret token** (commence par `sk.`) peut être nécessaire — créer un token avec les scopes `styles:read`, `fonts:read`, `tiles:read`

### Étape C : Modifier le code

Dans `lib/main.dart` :

```dart
if (isMapboxSupported) {
  MapboxOptions.setAccessToken("VOTRE_TOKEN_MAPBOX");
}
```

---

## 🔐 5. Variables d'environnement

### Backend (Edge Functions)

Copier le template :

```bash
cd backend_app
cp .env.example .env
```

Éditer `.env` :

```
SUPABASE_URL=https://VOTRE_PROJECT_REF.supabase.co
SUPABASE_SERVICE_ROLE_KEY=votre_clé_service_role
```

> ⚠️ La **Service Role Key** se trouve dans **Project Settings** → **API** → `service_role` (secret). Ne jamais la committer !

---

## 🚀 6. Lancer l'application

### Émulateur Android

```bash
# Lister les appareils
flutter devices

# Lancer (remplacer emulator-5556 par l'ID affiché)
flutter run -d emulator-5556
```

### Mode Release (APK)

```bash
flutter run --release -d emulator-5556
```

### Web

```bash
flutter run -d chrome
```

### Build Web (production)

```bash
flutter build web
# Sortie : build/web/
```

### Windows

```bash
flutter run -d windows
```

### iOS (sur Mac uniquement)

```bash
flutter run -d ios
```

---

## 📜 7. Commandes utiles

| Commande | Description |
|----------|-------------|
| `flutter pub get` | Installer les dépendances |
| `flutter clean` | Nettoyer le cache de build |
| `flutter analyze` | Vérifier le code |
| `flutter test` | Lancer les tests |
| `flutter devices` | Lister les appareils |
| `flutter run` | Lancer en mode debug |
| `flutter run --release` | Lancer en mode release |
| `flutter build apk` | Générer l'APK Android |
| `flutter build web` | Générer le build Web |
| `flutter build windows` | Générer l'exe Windows |

---

## 📂 8. Structure du code

### Écrans principaux

| Fichier | Rôle |
|---------|------|
| `auth_screen.dart` | Inscription / Connexion |
| `verify_otp_screen.dart` | Saisie du code OTP |
| `map_order_screen.dart` | Carte, commande, menu principal |
| `booking_flow_screen.dart` | Flux de réservation |
| `ride_in_progress_screen.dart` | Trajet en cours |
| `ai_chat_support_screen.dart` | Assistance IA |
| `client_space_screen.dart` | Espace client |

### Services

| Service | Rôle |
|---------|------|
| `user_service.dart` | Profil utilisateur, Supabase |
| `order_service.dart` | Création de commandes |
| `locale_service.dart` | Langue, contraste |
| `location_service.dart` | Géolocalisation |

---

## 🔧 9. Dépannage

### Erreur : "device not found"

- Démarrer l'émulateur avant `flutter run`
- Vérifier avec `flutter devices`

### Erreur : "ADB exited with exit code 1"

- Redémarrer l'émulateur
- Désinstaller l'app : `flutter run --uninstall-only -d DEVICE_ID`
- Vérifier l'espace disque de l'émulateur

### Erreur : "Invalid JWT" ou 401

- Vérifier que l'URL et la clé Supabase dans `main.dart` sont correctes
- Vérifier que l'utilisateur est bien connecté

### Emails de confirmation non reçus

- Vérifier **Authentication** → **Email Templates**
- Vérifier le dossier spam
- Voir [SUPABASE_CONFIG.md](SUPABASE_CONFIG.md)

### Mapbox ne s'affiche pas

- Vérifier que le token est valide
- Mapbox ne fonctionne pas sur Web/Windows (Flutter Map est utilisé)

---

<p align="center">
  📘 <strong>Documentation développeur Yadeli</strong> 🇨🇬 — Logistique & Transport au Congo
</p>
