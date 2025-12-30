# 📋 Absence Tracker

**Absence Tracker** est une application complète de suivi des absences destinée aux établissements éducatifs.  
Elle permet de digitaliser entièrement la gestion des présences, d’automatiser le pointage et de visualiser des statistiques fiables, tout en offrant un mode hors ligne partiel.

---

## 🎯 Objectifs du projet

- Remplacer les registres papier et la saisie manuelle
- Centraliser les données d’absences
- Faciliter le suivi académique et l’analyse statistique
- Proposer une solution moderne, sécurisée et multiplateforme

---

## 🏗️ Architecture Générale

Le projet suit une architecture **Client – Serveur** :

- **Frontend** : Application Flutter multiplateforme
- **Backend** : API REST avec Node.js
- **Base de données** : MySQL
- **Communication** : HTTP/HTTPS (JSON)

---

## 📱 Frontend – Flutter (`ab_tracker`)

Application multiplateforme : **Android, iOS, Web, Windows, Linux, macOS**

### 🔧 Technologies utilisées
- **Langage** : Dart (SDK ≥ 3.4.0)
- **Gestion d’état** : flutter_riverpod
- **Navigation** : go_router
- **Base de données locale** : sqflite
- **HTTP Client** : dio
- **Graphiques** : fl_chart
- **Export** : PDF, CSV (pdf, printing, csv, share_plus)

### 📂 Structure du projet
lib/
├── features/
│ ├── auth/
│ ├── students/
│ ├── groups/
│ ├── modules_sessions/
│ └── attendance/
└── core/

# 🖥️ Backend – API REST (`server`)

API REST développée avec Node.js.

### 🔧 Technologies utilisées
- **Framework** : Express.js
- **ORM** : Prisma
- **Base de données** : MySQL
- **Authentification** : JWT (jsonwebtoken)
- **Sécurité** : bcryptjs
- **Validation** : express-validator

### 📂 Structure de l’API
server/src/
├── routes/
│ ├── auth/
│ ├── students/
│ ├── groups/
│ ├── modules/
│ ├── sessions/
│ └── attendance/
├── controllers/
└── middleware/

## 🚀 Fonctionnalités Principales

- 🔐 Authentification sécurisée (JWT)
- 👨‍🎓 Gestion des étudiants
- 👥 Gestion des groupes et classes
- 📚 Gestion des modules et séances
- ✅ Pointage des absences
- 📊 Statistiques et tableaux de bord
- 📶 Mode hors ligne partiel (SQLite)
- 📄 Export des données (PDF / CSV)

