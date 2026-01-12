// 🗄️ GESTIONNAIRE DE BASES DE DONNÉES
// Permet de créer, lister et gérer les bases de données Odoo

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/odoo_service.dart';
import '../utils/constants.dart';

class DatabaseManagerScreen extends StatefulWidget {
  const DatabaseManagerScreen({super.key});

  @override
  State<DatabaseManagerScreen> createState() => _DatabaseManagerScreenState();
}

class _DatabaseManagerScreenState extends State<DatabaseManagerScreen> {
  final _urlController = TextEditingController(text: AppConstants.defaultOdooUrl);
  final _masterPasswordController = TextEditingController(text: 'Hamza123-');
  final _dbNameController = TextEditingController();
  final _adminPasswordController = TextEditingController(text: 'admin');
  
  List<String> _databases = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    _loadDatabases();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _masterPasswordController.dispose();
    _dbNameController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadDatabases() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final databases = await OdooService.listDatabases(_urlController.text);
      
      if (mounted) {
        setState(() {
          _databases = databases;
          _isLoading = false;
          if (databases.isEmpty) {
            _message = 'Aucune base de données trouvée';
            _messageIsError = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _message = 'Erreur: $e';
          _messageIsError = true;
        });
      }
    }
  }

  Future<void> _createDatabase() async {
    if (_dbNameController.text.trim().isEmpty) {
      _showMessage('Veuillez entrer un nom de base de données', isError: true);
      return;
    }

    setState(() {
      _isCreating = true;
      _message = null;
    });

    try {
      final result = await OdooService.createDatabase(
        baseUrl: _urlController.text,
        masterPassword: _masterPasswordController.text,
        databaseName: _dbNameController.text.trim(),
        adminPassword: _adminPasswordController.text,
        lang: 'fr_FR',
        country: 'MA',
      );

      if (mounted) {
        setState(() {
          _isCreating = false;
          _message = result['message'];
          _messageIsError = !(result['success'] ?? false);
        });

        if (result['success'] == true) {
          _dbNameController.clear();
          await _loadDatabases();
          
          // Proposer de se connecter
          final connect = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Base créée'),
              content: Text('Voulez-vous vous connecter à "${result['database']}" ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('PLUS TARD'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('SE CONNECTER'),
                ),
              ],
            ),
          );

          if (connect == true && mounted) {
            context.push('/login', extra: {
              'url': _urlController.text,
              'database': result['database'],
            });
          }
        } else if (_messageIsError && _message != null && 
                   _message!.contains('collation')) {
          // Afficher directement l'aide pour les erreurs de collation
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showCollationHelp();
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreating = false;
          _message = 'Erreur: $e';
          _messageIsError = true;
        });
        
        // Afficher l'aide si c'est un problème de collation
        if (e.toString().contains('collation')) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showCollationHelp();
            }
          });
        }
      }
    }
  }

  void _showMessage(String message, {required bool isError}) {
    setState(() {
      _message = message;
      _messageIsError = isError;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionnaire de bases'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadDatabases,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ========================================
              // TITRE
              // ========================================
              Text(
                'Créer une nouvelle instance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Gérez vos bases de données Odoo',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // ========================================
              // FORMULAIRE DE CONFIGURATION
              // ========================================
              _buildSectionTitle('Configuration serveur'),
              const SizedBox(height: 12),
              
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL du serveur Odoo',
                  hintText: 'http://localhost:8070',
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _masterPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Master Password',
                  hintText: 'Défini dans odoo.conf',
                  prefixIcon: Icon(Icons.key),
                ),
              ),
              const SizedBox(height: 30),

              // ========================================
              // FORMULAIRE DE CRÉATION
              // ========================================
              _buildSectionTitle('Nouvelle base de données'),
              const SizedBox(height: 12),

              TextField(
                controller: _dbNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la base',
                  hintText: 'ex: odoo_production',
                  prefixIcon: Icon(Icons.storage),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _adminPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe admin',
                  hintText: 'Pour le compte admin',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton de création
              ElevatedButton.icon(
                onPressed: _isCreating ? null : _createDatabase,
                icon: _isCreating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.add_circle),
                label: Text(_isCreating ? 'CRÉATION EN COURS...' : 'CRÉER LA BASE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              // Message
              if (_message != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_messageIsError ? Colors.red : Colors.green)
                        .withAlpha((255 * 0.1).toInt()),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (_messageIsError ? Colors.red : Colors.green)
                          .withAlpha((255 * 0.3).toInt()),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _messageIsError ? Icons.error : Icons.check_circle,
                            color: _messageIsError ? Colors.red : Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _message!,
                              style: TextStyle(
                                color: _messageIsError ? Colors.red[900] : Colors.green[900],
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_messageIsError && _message!.contains('Solutions:')) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _showErrorHelp(),
                          icon: const Icon(Icons.help_outline, size: 18),
                          label: const Text('Voir l\'aide détaillée'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red[700],
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // ========================================
              // LISTE DES BASES EXISTANTES
              // ========================================
              _buildSectionTitle('Bases de données existantes'),
              const SizedBox(height: 12),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_databases.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Aucune base de données',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _databases.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[300]),
                    itemBuilder: (context, index) {
                      final db = _databases[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withAlpha((255 * 0.1).toInt()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.storage,
                            color: AppConstants.primaryColor,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          db,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'Base de données Odoo',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.login, size: 20),
                          onPressed: () {
                            context.push('/login', extra: {
                              'url': _urlController.text,
                              'database': db,
                            });
                          },
                          tooltip: 'Se connecter',
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 30),

              // ========================================
              // INFORMATIONS
              // ========================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha((255 * 0.1).toInt()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withAlpha((255 * 0.3).toInt())),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Informations',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Le Master Password est défini dans le fichier odoo.conf\n'
                      '• La création d\'une base peut prendre plusieurs minutes\n'
                      '• Les données de démo seront installées par défaut\n'
                      '• Langue: Français (fr_FR), Pays: Maroc (MA)',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text('Résolution de problème'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpSection(
                'Problème de collation PostgreSQL',
                'L\'erreur indique que PostgreSQL ne peut pas créer la base avec les paramètres de collation demandés.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Solution 1: Via pgAdmin/psql',
                '1. Ouvrez pgAdmin ou psql\n'
                '2. Exécutez:\n'
                '   CREATE DATABASE nom_base\n'
                '   TEMPLATE template0\n'
                '   LC_COLLATE \'C\'\n'
                '   LC_CTYPE \'C\'\n'
                '   ENCODING \'UTF8\';',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Solution 2: Modifier odoo.conf',
                'Ajoutez dans odoo.conf:\n'
                'db_template = template0',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Solution 3: Réinitialiser PostgreSQL',
                'Réinstallez PostgreSQL avec:\n'
                'initdb -D /path/to/data --locale=C --encoding=UTF8',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                'Vérifier le port',
                'Votre PostgreSQL utilise le port 5433 (non standard).\n'
                'Vérifiez dans odoo.conf:\n'
                'db_port = 5433',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('FERMER'),
          ),
        ],
      ),
    );
  }

  void _showCollationHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
            SizedBox(width: 8),
            Expanded(
              child: Text('Problème de collation détecté'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha((255 * 0.1).toInt()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withAlpha((255 * 0.3).toInt()),
                  ),
                ),
                child: const Text(
                  'PostgreSQL ne peut pas créer la base avec les collations demandées. Ceci est un problème courant sur Windows.',
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
              _buildHelpSection(
                '✅ Solution rapide (recommandée)',
                'Créez la base manuellement via pgAdmin:\n\n'
                '1. Ouvrez pgAdmin (http://localhost:5050)\n'
                '2. Right-click sur "Databases" → Create → Database\n'
                '3. Entrez le nom: ${_dbNameController.text}\n'
                '4. Allez dans l\'onglet "Definition"\n'
                '5. Template: template0\n'
                '6. LC_COLLATE: C\n'
                '7. LC_CTYPE: C\n'
                '8. Encoding: UTF8\n'
                '9. Cliquez "Save"',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                '⚙️ Solution permanente',
                'Modifiez odoo.conf et ajoutez:\n\n'
                '[options]\n'
                'db_template = template0\n\n'
                'Cela appliquera cette configuration à toutes les futures bases.',
              ),
              const SizedBox(height: 16),
              _buildHelpSection(
                '💾 Ou utilisez psql',
                'CREATE DATABASE "${_dbNameController.text}"\n'
                'TEMPLATE template0\n'
                'LC_COLLATE \'C\'\n'
                'LC_CTYPE \'C\'\n'
                'ENCODING \'UTF8\';',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('J\'AI COMPRIS'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showErrorHelp();
            },
            child: const Text('PLUS D\'OPTIONS'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
              fontFamily: content.contains('CREATE') || content.contains('db_') ? 'monospace' : null,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(AppConstants.secondaryColorValue),
      ),
    );
  }
}
