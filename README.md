# 10Vin 🍷

Application iOS pour recenser et suivre tous les vins que vous avez dégustés dans votre vie.

## 📱 Fonctionnalités

### Feed Social
- Découvrez les vins goûtés par les utilisateurs que vous suivez
- Likez et commentez les publications
- Partagez vos expériences de dégustation

### Ajout de Vins
- Formulaire complet pour enregistrer un vin :
  - Type (Rouge, Blanc, Rosé, Champagne)
  - Cépage
  - Domaine
  - Millésime
  - Région
  - Notes de dégustation
  - Note sur 10

### Profil Utilisateur
- Visualisez tous vos vins goûtés
- Gérez votre wish-list
- Modifiez votre profil et photo
- Paramètres de confidentialité (Public, Privé, Secret)

### Paramètres
- Modification du profil
- Sélection de la langue (Français/Anglais)
- Niveaux de confidentialité
- Gestion de la photo de profil (Galerie/Caméra)

## 🛠 Technologies

- **SwiftUI** : Interface utilisateur moderne
- **Swift** : Langage de programmation
- **Firebase** : Backend (à implémenter)
  - Authentification Google + Email/Mot de passe
  - Firestore pour la base de données
  - Storage pour les images

## 🎨 Design

Design moderne et professionnel inspiré du monde du vin :
- Palette de couleurs : Rouge bordeaux, Or, Crème
- Typographie élégante avec polices serif
- Interface intuitive et épurée

## 🌍 Localisation

L'application est entièrement localisée en :
- 🇫🇷 Français
- 🇬🇧 Anglais

## 📋 Prérequis

- Xcode 16.2 ou supérieur
- iOS 16.6 ou supérieur
- Swift 5.0

## 🚀 Installation

1. Cloner le repository :
```bash
git clone https://github.com/VOTRE_USERNAME/10Vin.git
cd 10Vin
```

2. Ouvrir le projet dans Xcode :
```bash
open 10Vin.xcodeproj
```

3. Configurer le projet :
   - Sélectionner votre équipe de développement
   - Configurer les certificats de signature

4. Build et Run dans Xcode

## 🔐 Permissions

L'application nécessite les permissions suivantes :
- **Caméra** : Pour prendre une photo de profil
- **Galerie Photo** : Pour sélectionner une photo de profil

## 📝 Structure du Projet

```
10Vin/
├── Components/          # Composants réutilisables
│   ├── FeedPostCard.swift
│   ├── ImagePicker.swift
│   └── WineCard.swift
├── Models/             # Modèles de données
│   ├── FeedPost.swift
│   ├── PrivacyLevel.swift
│   ├── User.swift
│   ├── Wine.swift
│   └── WineViewModel.swift
├── Resources/          # Ressources (localisations)
│   ├── en.lproj/
│   └── fr.lproj/
├── Theme/              # Thème et design
│   └── WineTheme.swift
├── Utils/              # Utilitaires
│   └── Localization.swift
└── Views/              # Vues principales
    ├── AddWineView.swift
    ├── EditProfileView.swift
    ├── FeedView.swift
    ├── FilterView.swift
    ├── MainTabView.swift
    ├── PhotoSelectionView.swift
    ├── ProfileView.swift
    └── SettingsView.swift
```

## 🔄 Backend (À venir)

L'intégration Firebase est prévue pour :
- Authentification (Google + Email/Mot de passe)
- Base de données Firestore
- Stockage des images (Storage)
- Notifications push

## 📄 Licence

Ce projet est privé.

## 👤 Auteur

Pierre ROBERT

---

*Développé avec ❤️ et 🍷*
