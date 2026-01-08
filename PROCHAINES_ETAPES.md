# 🎓 Prochaines étapes - Extension de l'application

Maintenant que vous avez l'app de base, voici comment l'améliorer.

---

## 🔄 Étape 1: Afficher des contacts (Partenaires)

### Créer un nouvel écran: contacts_screen.dart

```dart
class ContactsScreen extends StatefulWidget {
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Map> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    // Récupérer les contacts
    // await OdooService().call('res.partner', 'search_read', 
    //   [[], ['id', 'name', 'email', 'phone']])
  }

  @override
  Widget build(BuildContext context) {
    // ListView des contacts
  }
}
```

### Ajouter la méthode dans OdooService

```dart
Future<List<Map>> getPartners() async {
  final params = {
    'jsonrpc': '2.0',
    'method': 'call',
    'params': {
      'service': 'object',
      'method': 'execute_kw',
      'args': [
        _database,
        _uid,
        _password,
        'res.partner',
        'search_read',
        [],
        ['id', 'name', 'email', 'phone'],
      ],
    },
    'id': 1,
  };

  final response = await http.post(...);
  // Retourner les contacts
}
```

### Ajouter route dans main.dart

```dart
GoRoute(
  path: '/contacts',
  builder: (context, state) => const ContactsScreen(),
),
```

### Ajouter lien dans Dashboard

```dart
ElevatedButton(
  onPressed: () => context.push('/contacts'),
  child: Text('Voir les contacts'),
),
```

---

## 💰 Étape 2: Afficher les commandes de vente

### Créer orders_screen.dart

```dart
class OrdersScreen extends StatefulWidget {
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  Future<void> loadOrders() async {
    // Récupérer les commandes
    // List orders = await OdooService().getOrders();
  }

  @override
  Widget build(BuildContext context) {
    // Afficher liste des commandes avec montant, date, statut
  }
}
```

### Service Odoo

```dart
Future<List<Map>> getOrders() async {
  // Model: sale.order
  // Fields: id, name, amount_total, order_date, state
  // Filter: [['state', 'in', ['draft', 'sale']]]
}
```

---

## 📋 Étape 3: Afficher les factures

### Créer invoices_screen.dart

Similaire aux commandes:
- Model: `account.move`
- Fields: `id, name, amount_total, invoice_date, state`
- Filter: `[['move_type', '=', 'out_invoice']]`

---

## 🏢 Étape 4: Créer une nouvelle fiche contact

### Créer create_contact_screen.dart

```dart
class CreateContactScreen extends StatefulWidget {
  @override
  State<CreateContactScreen> createState() => _CreateContactScreenState();
}

class _CreateContactScreenState extends State<CreateContactScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  Future<void> saveContact() async {
    // Créer le contact
    int id = await OdooService().create(
      'res.partner',
      {
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      },
    );
    
    if (id > 0) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact créé: $id')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formulaire avec 3 champs
    // Bouton Sauvegarder
  }
}
```

### Ajouter méthode dans OdooService

```dart
Future<int> create(String model, Map<String, dynamic> values) async {
  final params = {
    'jsonrpc': '2.0',
    'method': 'call',
    'params': {
      'service': 'object',
      'method': 'execute_kw',
      'args': [
        _database,
        _uid,
        _password,
        model,
        'create',
        [values],
      ],
    },
    'id': 1,
  };

  final response = await http.post(...);
  // Retourner l'ID du nouvel enregistrement
}
```

---

## 🔍 Étape 5: Ajouter recherche et filtrage

### Paramètres de recherche

```dart
// Chercher par nom
Future<List> search(String model, String query) {
  return OdooService().search(
    model,
    [['name', 'ilike', query]],
  );
}

// Filtrer par statut
Future<List> filterByStatus(String status) {
  return OdooService().search(
    'sale.order',
    [['state', '=', status]],
  );
}
```

### UI avec SearchBar

```dart
class ContactsScreen extends StatefulWidget {
  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map> allContacts = [];
  List<Map> filteredContacts = [];

  Future<void> loadAll() async {
    allContacts = await OdooService().getPartners();
    setState(() => filteredContacts = allContacts);
  }

  void filterContacts(String query) {
    if (query.isEmpty) {
      setState(() => filteredContacts = allContacts);
    } else {
      setState(() {
        filteredContacts = allContacts
            .where((c) => c['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),
      body: Column(
        children: [
          // SearchBar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: filterContacts,
              decoration: InputDecoration(
                hintText: 'Chercher...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          
          // Liste filtrée
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                var contact = filteredContacts[index];
                return ListTile(
                  title: Text(contact['name']),
                  subtitle: Text(contact['email'] ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎨 Étape 6: Améliorer le design

### Ajouter des icônes en fonction du type

```dart
Icon getStatusIcon(String status) {
  switch(status) {
    case 'draft': return Icon(Icons.edit, color: Colors.orange);
    case 'sale': return Icon(Icons.check, color: Colors.green);
    case 'cancel': return Icon(Icons.close, color: Colors.red);
    default: return Icon(Icons.info);
  }
}

String getStatusText(String status) {
  switch(status) {
    case 'draft': return 'Brouillon';
    case 'sale': return 'Confirmé';
    case 'cancel': return 'Annulé';
    default: return status;
  }
}
```

### Cartes personnalisées

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(12),
    child: Row(
      children: [
        getStatusIcon(order['state']),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '${order['amount_total']} DA',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Text(getStatusText(order['state']),
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    ),
  ),
)
```

---

## 🔔 Étape 7: Ajouter des notifications

### Utiliser fluttertoast

```dart
import 'package:fluttertoast/fluttertoast.dart';

// Succès
Fluttertoast.showToast(
  msg: "Contact créé avec succès!",
  backgroundColor: Colors.green,
);

// Erreur
Fluttertoast.showToast(
  msg: "Erreur lors de la création",
  backgroundColor: Colors.red,
);
```

---

## 📊 Étape 8: Ajouter des graphiques

### Installer le package

```yaml
dependencies:
  charts_flutter: ^0.12.0  # ou fl_chart: ^0.61.0
```

### Exemple avec fl_chart

```dart
import 'package:fl_chart/fl_chart.dart';

class SalesChartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [
              FlSpot(1, 100),
              FlSpot(2, 150),
              FlSpot(3, 120),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## 🧪 Étape 9: Ajouter des tests

### Test simple

```dart
// test/odoo_service_test.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OdooService login', () async {
    final service = OdooService();
    service.initialize(
      baseUrl: 'http://localhost:8070',
      database: 'odoo15',
      username: 'admin',
      password: 'Hamza123-',
    );
    
    bool success = await service.login();
    expect(success, true);
  });
}
```

### Lancer les tests

```bash
flutter test
```

---

## 🚀 Étape 10: Déployer l'app

### Android (APK)

```bash
flutter build apk --release
# Fichier: build/app/outputs/apk/release/app-release.apk
```

### iPhone (IPA)

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

---

## 💡 Conseils

1. **Toujours vérifier `mounted`** avant setState
2. **Utiliser async/await** pour les requêtes
3. **Afficher un loading** pendant les appels serveur
4. **Gérer les erreurs** avec try/catch
5. **Tester localement** avant de déployer
6. **Documenter le code** avec des commentaires
7. **Respecter DRY** (Don't Repeat Yourself)
8. **Utiliser des constantes** pour les hardcoded values

---

## 📚 Ressources

- [Odoo API Documentation](https://www.odoo.com/documentation/)
- [Flutter Widgets Catalog](https://flutter.dev/docs/development/ui/widgets)
- [pub.dev](https://pub.dev/) - Packages Flutter
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

---

Bonne chance dans votre développement! 🚀
