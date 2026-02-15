<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" alt="Supabase" />
  <img src="https://img.shields.io/badge/Mapbox-000000?style=for-the-badge&logo=mapbox&logoColor=white" alt="Mapbox" />
</p>

<h1 align="center">🚕 Yadeli</h1>
<h3 align="center">Application de transport & livraison à Brazzaville</h3>

<p align="center">
  <em>Inspirée d'Uber, Bolt et Citymapper — Livraison, courses, déménagement</em>
</p>

---

## 📋 Table des matières

- [🎯 Présentation](#-présentation)
- [✨ Fonctionnalités](#-fonctionnalités)
- [🛠️ Stack technique](#️-stack-technique)
- [📁 Structure du projet](#-structure-du-projet)
- [🚀 Démarrage rapide](#-démarrage-rapide)
- [📚 Documentation](#-documentation)
- [🤝 Contribution](#-contribution)

---

## 🎯 Présentation

**Yadeli** est une application mobile multiplateforme (Android, iOS, Web, Windows) permettant de :

| Service | Description |
|---------|-------------|
| 🚗 **Courses** | Réservation de trajets type taxi/VTC |
| 📦 **Livraison** | Envoi de colis à domicile |
| 🚚 **Déménagement** | Services de déménagement avec estimation de prix |

L'app cible le marché de **Brazzaville (Congo)** et propose une interface multilingue (Français, Anglais, Lingala, Kituba).

---

## ✨ Fonctionnalités

### 🔐 Authentification
- Inscription / Connexion par email
- Vérification OTP par email (code à 8 chiffres)
- Gestion du profil utilisateur (nom, téléphone, photo, langues)

### 🗺️ Carte & Localisation
- Carte interactive (Mapbox sur mobile, Flutter Map sur Web/Desktop)
- Géolocalisation et recherche d'adresses
- Partage de position en temps réel

### 📱 Services
- **Espace client** : historique des trajets, factures, récapitulatifs
- **Assistance IA** : chat vocal et texte pour le support
- **Paiement** : intégration prête pour les moyens de paiement
- **Notifications** : SMS/Email/WhatsApp (mode démo)

### ⚙️ Paramètres
- Choix de la langue (FR, EN, Lingala, Kituba)
- Réglage du contraste visuel
- Thème Material 3

---

## 🛠️ Stack technique

| Outil | Rôle |
|-------|------|
| **Flutter 3.x** | Framework UI multiplateforme |
| **Supabase** | Backend (Auth, Base de données, Edge Functions) |
| **Mapbox** | Cartes sur Android/iOS |
| **Flutter Map** | Cartes sur Web/Windows |
| **Dart 3.2+** | Langage |

### Dépendances principales
- `supabase_flutter` — Authentification & base de données
- `geolocator` / `geocoding` — Localisation
- `mapbox_maps_flutter` — Cartes mobiles
- `flutter_map` — Cartes Web/Desktop
- `speech_to_text` — Reconnaissance vocale
- `image_picker` — Photo de profil
- `pdf` / `printing` — Factures PDF

---

## 📁 Structure du projet

```
yadeli/
├── 📂 lib/                    # Code source Flutter
│   ├── main.dart              # Point d'entrée
│   ├── 📂 screens/            # Écrans de l'app (40+ écrans)
│   ├── 📂 services/           # Logique métier (auth, commandes, etc.)
│   ├── 📂 models/             # Modèles de données
│   ├── 📂 widgets/            # Composants réutilisables
│   ├── 📂 l10n/               # Traductions (FR, EN, Lingala, Kituba)
│   └── 📂 src/                # Code spécifique plateforme (Mapbox, etc.)
├── 📂 backend_app/            # Backend Supabase
│   ├── supabase/
│   │   ├── functions/         # Edge Functions (create-order, etc.)
│   │   └── migrations/        # Schéma SQL
│   └── .env.example           # Template des variables d'environnement
├── 📂 android/                # Configuration Android
├── 📂 ios/                    # Configuration iOS
├── 📂 web/                    # Configuration Web
├── 📂 windows/                # Configuration Windows
├── 📂 assets/images/          # Images et icônes
├── DOC_DEVELOPPEUR.md         # 📘 Guide développeur complet
├── GUIDE_UTILISATEUR.md       # 📗 Guide utilisateur
└── SUPABASE_CONFIG.md        # ⚙️ Config Supabase (emails, OTP)
```

---

## 🚀 Démarrage rapide

### Prérequis
- **Flutter SDK** 3.2+ ([Installation](https://docs.flutter.dev/get-started/install))
- **Compte Supabase** ([supabase.com](https://supabase.com))
- **Clé Mapbox** ([mapbox.com](https://mapbox.com)) — pour Android/iOS

### Installation en 3 étapes

```bash
# 1️⃣ Cloner le dépôt
git clone https://github.com/GemimaOndele/yadeli.git
cd yadeli

# 2️⃣ Installer les dépendances
flutter pub get

# 3️⃣ Lancer l'app (émulateur ou appareil connecté)
flutter run
```

📘 **Guide complet** : voir [DOC_DEVELOPPEUR.md](DOC_DEVELOPPEUR.md) pour la configuration Supabase, Mapbox, et toutes les étapes détaillées.

---

## 📚 Documentation

| Document | Contenu |
|----------|---------|
| [DOC_DEVELOPPEUR.md](DOC_DEVELOPPEUR.md) | Configuration, commandes, étapes de A à Z pour développeurs |
| [GUIDE_UTILISATEUR.md](GUIDE_UTILISATEUR.md) | Guide utilisateur de l'application |
| [SUPABASE_CONFIG.md](SUPABASE_CONFIG.md) | Configuration emails, OTP, Site URL Supabase |

---

## 🤝 Contribution

Les contributions sont les bienvenues. Voir [DOC_DEVELOPPEUR.md](DOC_DEVELOPPEUR.md) pour les conventions de code et le workflow.

---

<p align="center">
  <strong>Yadeli</strong> — Transport & Livraison à Brazzaville 🇨🇬
</p>
