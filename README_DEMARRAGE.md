# 🚀 Application Mobile Odoo - Guide de démarrage

## ✅ Prérequis

### Sur votre PC
- **Flutter** 3.10+ ([installer](https://flutter.dev/docs/get-started/install))
- **Odoo 15** installé et configuré
- **Android Studio** ou **VS Code** avec plugin Flutter
- **Python 3.8+** pour Odoo

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

## 🎯 Démarrage rapide

### 1️⃣ Vérifier que tout est en place

```bash
# Vérifier Flutter
flutter --version

# Vérifier que Odoo fonctionne
# Sur http://localhost:8070

# Créer une base "odoo15"
```

### 2️⃣ Installer les dépendances Flutter

```bash
cd odoo_mobile_app
flutter pub get
```

### 3️⃣ Vérifier la compilation

```bash
flutter analyze
flutter doctor
```

### 4️⃣ Lancer sur émulateur ou téléphone

```bash
# Sur émulateur Android
flutter run

# Sur téléphone (USB):
flutter run -d <device_id>

# Sur navigateur web (test):
flutter run -d chrome
```

## 📱 Utilisation de l'app

### Écran d'accueil
- Bienvenue, infos sur l'app
- Boutons: **Commencer**, **Vérifier Odoo**

### Choix de l'instance
- **Continuer**: réutiliser session précédente
- **Se connecter**: nouvelles identifiants
- **Vérifier l'instance**: tester l'URL Odoo

### Connexion
1. **URL**: http://localhost:8070 (ou IP du PC)
2. **Base**: odoo15
3. **Utilisateur**: admin
4. **Mot de passe**: Hamza123-
5. Cliquer **SE CONNECTER**

### Tableau de bord
- Infos utilisateur (nom, email, société)
- Nombre de modules installés
- Boutons: **Actualiser**, **Déconnexion**

## 🔧 Configuration

### Localhost vs IP

**Si vous testez sur l'émulateur:**
```
http://localhost:8070  ✅ Fonctionne
```

**Si vous testez sur téléphone physique:**
```
http://192.168.X.X:8070  ✅ (remplacer par IP de votre PC)
```

Pour trouver l'IP de votre PC:
```bash
# Windows
ipconfig

# Mac/Linux
ifconfig
```

## 🐛 Dépannage

### Erreur: "Impossible de contacter Odoo"

**Solutions:**
1. Vérifiez que Odoo est démarré
2. Visitez `http://localhost:8070` dans le navigateur
3. Vérifiez le port (par défaut 8070)
4. Redémarrez Odoo

**Sur téléphone:**
- Utilisez l'IP du PC, pas localhost
- Assurez-vous que PC et téléphone sont sur le même WiFi
- Désactivez le firewall temporairement

### Erreur: "Identifiants incorrects"

**Vérifiez:**
- Base de données: `odoo15`
- Utilisateur: `admin`
- Mot de passe: `Hamza123-`
- URL: `http://localhost:8070`

### Erreur: "port 5432 not found" (Odoo)

C'est la base de données PostgreSQL qui ne tourne pas:
```bash
# Windows
net start postgresql

# Mac
brew services start postgresql

# Linux
sudo systemctl start postgresql
```

### Flutter ne se lance pas

```bash
# Nettoyer le cache
flutter clean

# Réinstaller les dépendances
flutter pub get

# Reconstruire
flutter run
```

## 📝 Détails techniques

### Architecture

```
Login Flow:
1. WelcomeScreen → initiation
2. InstanceChoiceScreen → choix
3. LoginScreen → saisie identifiants
4. OdooService.login() → authentification JSON-RPC
5. SaveCredentials → stockage local
6. DashboardScreen → affichage données
```

### Services
- **OdooService**: gestion Odoo, stockage, requêtes
- **SharedPreferences**: sauvegarde locale identifiants
- **go_router**: navigation entre écrans

### Patterns utilisés
- **Singleton**: OdooService
- **Provider**: gestion d'état (si nécessaire)
- **JSON-RPC**: API Odoo

## 🌐 API Odoo utilisée

### JSON-RPC Endpoints

**Authentification:**
```
POST /jsonrpc
→ service: "common"
→ method: "authenticate"
```

**Lectures de données:**
```
POST /jsonrpc
→ service: "object"
→ method: "execute_kw"
→ args: [db, uid, password, model, method, ...]
```

## 💡 Conseils développement

### Ajouter une fonctionnalité

1. **Créer le service** (OdooService)
   ```dart
   Future<List<String>> getPartners() async { ... }
   ```

2. **Créer l'écran** (NewScreen.dart)
   ```dart
   class NewScreen extends StatefulWidget { ... }
   ```

3. **Ajouter la route** (main.dart)
   ```dart
   GoRoute(path: '/new', builder: ..., )
   ```

4. **Ajouter navigation**
   ```dart
   context.push('/new');
   ```

### Debug

```dart
// Imprimer en log
print('Debug: $variable');

// Utiliser le débogueur
flutter run
# Tapez 'w' pour hot reload
# Tapez 'r' pour hot restart
```

## 📚 Ressources

- [Documentation Flutter](https://flutter.dev/docs)
- [Flutter Packages](https://pub.dev)
- [Odoo API](https://www.odoo.com/documentation/14.0/developer/)
- [go_router docs](https://pub.dev/packages/go_router)
- [shared_preferences](https://pub.dev/packages/shared_preferences)

## ✨ Fonctionnalités futures possibles

- [ ] Afficher les contacts
- [ ] Créer/modifier des documents
- [ ] Notifications temps réel
- [ ] Mode offline
- [ ] Importation/exportation
- [ ] Biométrie (fingerprint)
- [ ] Chats/Messages
- [ ] Calendrier/Tâches

## 📞 Support

Pour les problèmes:
1. Vérifier les logs: `flutter run` affiche les erreurs
2. Utiliser `flutter doctor` pour diagnostiquer
3. Nettoyer et reconstruire: `flutter clean && flutter pub get`
4. Consulter la documentation Flutter

---

**Bon développement! 🎉**
