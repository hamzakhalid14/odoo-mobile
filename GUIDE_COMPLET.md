# 📱 GUIDE COMPLET: Application Flutter Odoo

## 🎯 Vue d'ensemble

Cette application Flutter vous permet de vous connecter à votre serveur Odoo 15 installé localement et d'accéder à vos données depuis votre téléphone.

## 📚 Structure de l'application

```
lib/
├── main.dart                 # Point d'entrée, routes
├── screens/
│   ├── welcome_screen.dart   # Écran d'accueil
│   ├── login_screen.dart     # Écran de connexion
│   ├── check_instance_screen.dart  # Vérification de l'URL Odoo
│   ├── create_instance_screen.dart # Instructions de création
│   ├── instance_choice_screen.dart # Choix connexion existante ou nouvelle
│   └── dashboard_screen.dart  # Tableau de bord (après connexion)
├── services/
│   └── odoo_service.dart     # Service de communication avec Odoo
└── utils/
    └── constants.dart        # Constantes de l'app
```

## 🚀 Flux de l'application

```
┌─────────────────┐
│  WelcomeScreen  │ (Accueil)
└────────┬────────┘
         │
         ├──→ InstanceChoiceScreen (Choix)
         │    ├──→ LoginScreen (Se connecter)
         │    ├──→ CheckInstanceScreen (Vérifier URL)
         │    └──→ CreateInstanceScreen (Créer instance)
         │
         └──→ DashboardScreen (Après connexion)
```

## 🔐 Processus de connexion détaillé

### 1️⃣ Initialisation
- L'app démarre
- Vérifie si l'utilisateur est déjà connecté
- Redirige vers le dashboard ou l'accueil

### 2️⃣ Écran de bienvenue
- Affiche les fonctionnalités
- Propose 3 options:
  - **Commencer**: va à InstanceChoiceScreen
  - **Vérifier Odoo**: teste la connexion
  - **Se connecter**: va directement à LoginScreen

### 3️⃣ Choix de l'instance
- Si session existe: permet de continuer
- Sinon: propose de se connecter ou vérifier

### 4️⃣ Connexion
- Saisie: URL, base de données, utilisateur, mot de passe
- Envoie requête JSON-RPC à Odoo
- Sauvegarde les identifiants localement
- Redirige au dashboard

### 5️⃣ Tableau de bord
- Affiche infos utilisateur
- Liste les modules installés
- Permet déconnexion

## 📡 Communication avec Odoo

### Configuration Odoo
```
[options]
admin_passwd = Hamza123-
addons_path = addons,custom_addons
db_host = localhost
db_port = 5433
db_user = odoo
db_password = odoo
db_name = odoo15
http_port = 8070
```

### Endpoints utilisés

#### 1. Vérification de l'instance
```
GET /web/health
→ Retourne 200 si Odoo répond
```

#### 2. Authentification
```
POST /jsonrpc
{
  "jsonrpc": "2.0",
  "method": "call",
  "params": {
    "service": "common",
    "method": "authenticate",
    "args": ["odoo15", "admin", "Hamza123-", {}]
  },
  "id": 1
}
→ Retourne l'user ID si succès
```

#### 3. Récupérer infos utilisateur
```
POST /jsonrpc
{
  "params": {
    "service": "object",
    "method": "execute_kw",
    "args": ["odoo15", 2, "password", "res.users", "read", 
             [2], ["id", "name", "email", "company_id"]]
  }
}
```

#### 4. Modules installés
```
POST /jsonrpc
{
  "params": {
    "service": "object",
    "method": "execute_kw",
    "args": ["odoo15", 2, "password", "ir.module.module", "search_read",
             [["state", "=", "installed"]], ["name"]]
  }
}
```

## 🛠️ Classes principales

### OdooService
Service singleton pour toutes les communications avec Odoo.

**Méthodes principales:**
- `initialize()` - Configure le service
- `login()` - Authentifie l'utilisateur
- `getUserInfo()` - Récupère infos de l'utilisateur connecté
- `getInstalledModules()` - Liste des modules
- `logout()` - Déconnecte
- `checkInstance()` - Vérifie si Odoo est accessible
- `isLoggedIn()` - Vérifie si session valide
- `getSavedCredentials()` - Récupère identifiants sauvegardés

### Screens
Chaque écran est un StatefulWidget ou StatelessWidget avec son UI et logique.

## 💾 Stockage local

L'app utilise SharedPreferences pour sauvegarder:
- URL Odoo
- Nom de la base
- Identifiants utilisateur
- ID utilisateur
- État de connexion

**Clés:**
```dart
keyOdooUrl = 'odoo_url'
keyOdooDatabase = 'odoo_database'
keyUsername = 'username'
keyOdooUserId = 'odoo_user_id'
keyIsLoggedIn = 'is_logged_in'
```

## 🎨 Thème de l'app

### Couleurs
- **Primaire**: #714B67 (violet Odoo)
- **Secondaire**: #2C3E50 (bleu foncé)
- **Succès**: #4CAF50 (vert)
- **Erreur**: #F44336 (rouge)

### Typographie
- Material Design 3
- Roboto font
- Responsive design

## 🚪 Navigation

L'app utilise `go_router` pour la navigation:
- Routes nommées
- Paramètres passables
- Redirections automatiques
- Gestion des erreurs 404

## 📝 Exemple d'utilisation

```dart
// Dans un écran
final odooService = OdooService();
odooService.initialize(
  baseUrl: 'http://localhost:8070',
  database: 'odoo15',
  username: 'admin',
  password: 'Hamza123-',
);

final success = await odooService.login();
if (success) {
  final userInfo = await odooService.getUserInfo();
  final modules = await odooService.getInstalledModules();
}
```

## 🐛 Dépannage

### "Impossible de contacter Odoo"
1. Vérifiez que Odoo est démarré
2. Vérifiez l'URL (port 8070)
3. Si sur téléphone: utilisez l'IP du PC au lieu de localhost

### "Identifiants incorrects"
- Vérifiez le nom de la base (odoo15)
- Vérifiez l'utilisateur (admin)
- Vérifiez le mot de passe (Hamza123-)

### "Session expirée"
- Supprimer les données locales: SharedPreferences.getInstance().clear()
- Se reconnecter

## 📦 Dépendances

```yaml
http: ^1.2.1              # Requêtes HTTP
provider: ^6.1.5          # Gestion d'état
go_router: ^14.3.0        # Navigation
shared_preferences: ^2.2.2 # Stockage local
flutter_form_builder: ^10.2.0 # Formulaires
flutter_spinkit: ^5.2.0   # Animations
fluttertoast: ^8.2.4      # Notifications
```

## ✅ Checklist avant de lancer

- [ ] Odoo 15 est installé et démarré
- [ ] Base de données "odoo15" existe
- [ ] Port 8070 est accessible
- [ ] Sur téléphone: IP du PC est correcte
- [ ] flutter pub get executé
- [ ] Pas d'erreurs flutter analyze

## 🎓 Concepts Flutter clés

- **StatelessWidget**: UI statique (WelcomeScreen)
- **StatefulWidget**: UI dynamique (LoginScreen, DashboardScreen)
- **Scaffold**: Structure de page (AppBar, Body, etc)
- **BuildContext**: Contexte pour navigation/snackbars
- **Async/Await**: Appels réseau asynchrones
- **Shared Preferences**: Stockage persistant
- **go_router**: Système de routes

