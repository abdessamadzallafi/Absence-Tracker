# 🎓 API Absence Tracker ENIAD

API REST Express.js avec MySQL et Prisma pour gérer les absences des étudiants.

## 📋 Prérequis

- Node.js (version 18 ou supérieure)
- MySQL (version 8 ou supérieure)
- npm ou yarn

## 🚀 Installation

### 1. Cloner et installer les dépendances

```bash
cd server
npm install
```

### 2. Configuration de la base de données MySQL

Créez une base de données MySQL :

```sql
CREATE DATABASE absence_tracker;
CREATE USER 'absence_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON absence_tracker.* TO 'absence_user'@'localhost';
FLUSH PRIVILEGES;
```

### 3. Variables d'environnement

Créez un fichier `.env` à la racine du dossier `server` :

```env
DATABASE_URL="mysql://absence_user:your_password@localhost:3306/absence_tracker"
JWT_SECRET="your-super-secret-jwt-key-change-this"
PORT=3000
NODE_ENV=development
```

### 4. Générer le client Prisma et créer la base de données

```bash
# Générer le client Prisma
npm run prisma:generate

# Créer les tables dans MySQL
npm run prisma:push

# OU créer une migration (recommandé pour la production)
npm run prisma:migrate
```

## 🏃 Démarrage

### Mode développement (avec auto-reload)

```bash
npm run dev
```

### Mode production

```bash
npm start
```

L'API sera disponible sur `http://localhost:3000`

## 📚 Documentation API

### Authentification

#### `POST /api/auth/register`
Créer un compte professeur

```json
{
  "username": "prof123",
  "password": "motdepasse",
  "firstName": "Ahmed",
  "lastName": "Benali",
  "email": "ahmed.benali@eniad.ma"
}
```

#### `POST /api/auth/login`
Se connecter

```json
{
  "username": "prof123",
  "password": "motdepasse"
}
```

Réponse :
```json
{
  "message": "Connexion réussie",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": { ... }
}
```

**Important** : Utilisez le token dans l'en-tête `Authorization: Bearer {token}` pour toutes les requêtes protégées.

#### `GET /api/auth/me`
Obtenir les informations de l'utilisateur connecté

---

### Groupes

#### `GET /api/groups`
Liste tous les groupes

#### `GET /api/groups/:id`
Détails d'un groupe avec ses étudiants et modules

#### `POST /api/groups`
Créer un groupe

```json
{
  "name": "2AP-A",
  "filiere": "Développement Digital"
}
```

#### `PUT /api/groups/:id`
Modifier un groupe

#### `DELETE /api/groups/:id`
Supprimer un groupe

---

### Étudiants

#### `GET /api/students`
Liste tous les étudiants (filtre : `?groupId=1`)

#### `GET /api/students/:id`
Détails d'un étudiant avec son historique

#### `POST /api/students`
Créer un étudiant

```json
{
  "groupId": 1,
  "massar": "M123456789",
  "firstName": "Fatima",
  "lastName": "El Amrani",
  "email": "fatima@example.com"
}
```

#### `PUT /api/students/:id`
Modifier un étudiant

#### `DELETE /api/students/:id`
Supprimer un étudiant

---

### Modules

#### `GET /api/modules`
Liste tous les modules (filtre : `?groupId=1`)

#### `GET /api/modules/:id`
Détails d'un module avec ses sessions

#### `POST /api/modules`
Créer un module

```json
{
  "name": "Programmation Web",
  "semester": "S3",
  "groupId": 1
}
```

#### `PUT /api/modules/:id`
Modifier un module

#### `DELETE /api/modules/:id`
Supprimer un module

---

### Sessions

#### `GET /api/sessions`
Liste toutes les sessions (filtre : `?moduleId=1`)

#### `GET /api/sessions/:id`
Détails d'une session avec les présences

#### `POST /api/sessions`
Créer une session

```json
{
  "moduleId": 1,
  "date": "2024-01-15T00:00:00Z",
  "time": "10:00",
  "type": "cours"
}
```

#### `PUT /api/sessions/:id`
Modifier une session

#### `DELETE /api/sessions/:id`
Supprimer une session

---

### Présences

#### `GET /api/attendance/session/:sessionId`
Liste des présences d'une session

#### `POST /api/attendance/mark`
Marquer une présence

```json
{
  "sessionId": 1,
  "studentId": 5,
  "status": "present"
}
```

#### `POST /api/attendance/mark-bulk`
Marquer plusieurs présences

```json
{
  "sessionId": 1,
  "attendances": [
    { "studentId": 5, "status": "present" },
    { "studentId": 6, "status": "absent" },
    { "studentId": 7, "status": "justified" }
  ]
}
```

#### `GET /api/attendance/student/:studentId/history`
Historique des absences d'un étudiant (groupé par module)

#### `GET /api/attendance/stats`
Statistiques globales

Filtres optionnels : `?groupId=1&moduleId=2&startDate=2024-01-01&endDate=2024-12-31`

---

## 🛠️ Commandes Prisma utiles

```bash
# Ouvrir Prisma Studio (interface graphique)
npm run prisma:studio

# Générer le client Prisma après modification du schéma
npm run prisma:generate

# Créer une nouvelle migration
npx prisma migrate dev --name nom_de_la_migration

# Appliquer les migrations en production
npx prisma migrate deploy

# Réinitialiser la base de données (ATTENTION: supprime toutes les données)
npx prisma migrate reset
```

## 📁 Structure du projet

```
server/
├── prisma/
│   ├── schema.prisma          # Schéma de la base de données
│   └── migrations/            # Migrations SQL
├── src/
│   ├── config/
│   │   └── prisma.js          # Client Prisma
│   ├── controllers/           # Logique métier
│   ├── routes/                # Routes API
│   ├── middleware/            # Middleware (auth, erreurs)
│   ├── utils/                 # Utilitaires (validation)
│   └── app.js                 # Configuration Express
├── .env                       # Variables d'environnement
├── package.json
└── server.js                  # Point d'entrée
```

## 🔐 Sécurité

- Les mots de passe sont hashés avec bcrypt
- Authentification JWT (expire après 7 jours)
- Toutes les routes (sauf login/register) sont protégées
- Validation des données avec express-validator
- Protection CORS activée

## 📝 Notes

- Les statuts de présence : `present`, `absent`, `justified`
- Les types de session : `cours`, `td`, `tp`
- Les dates sont au format ISO 8601
- Les heures au format HH:mm (24h)

---

**Fait avec ❤️ pour ENIAD**
