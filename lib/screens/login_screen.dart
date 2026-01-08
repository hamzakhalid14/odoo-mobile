// 🔐 ÉCRAN DE CONNEXION
// Permet à l'utilisateur d'entrer ses identifiants Odoo

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/odoo_service.dart';
import '../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  final Map<String, dynamic>? extraData;

  const LoginScreen({super.key, this.extraData});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // =========================================
  // VARIABLES D'ÉTAT
  // =========================================
  
  final _urlController = TextEditingController();
  final _databaseController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _showPassword = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    
    // Pré-remplir avec les valeurs par défaut ou les données reçues
    _urlController.text = widget.extraData?['url'] ?? AppConstants.defaultOdooUrl;
    _databaseController.text = widget.extraData?['database'] ?? AppConstants.defaultDatabase;
    _usernameController.text = widget.extraData?['username'] ?? 'admin';
  }

  @override
  void dispose() {
    _urlController.dispose();
    _databaseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================================
  // MÉTHODE DE CONNEXION
  // =========================================
  
  Future<void> _handleLogin() async {
    // Nettoyer le message d'erreur précédent
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Valider les champs
    if (_urlController.text.isEmpty ||
        _databaseController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Tous les champs sont obligatoires';
        _isLoading = false;
      });
      return;
    }

    try {
      print('🔐 Tentative de connexion...');
      print('📋 URL: ${_urlController.text}');
      print('📋 Database: ${_databaseController.text}');
      print('📋 Username: ${_usernameController.text}');

      // ÉTAPE 1: Vérifier l'instance d'abord
      print('🔍 Étape 1: Vérification de l\'instance...');
      final checkResult = await OdooService.checkInstance(_urlController.text);
      
      if (!checkResult['success']) {
        setState(() {
          _errorMessage = 'Odoo n\'est pas accessible:\n${checkResult['message']}\n\n'
              'Assurez-vous que:\n'
              '1. Odoo est démarré\n'
              '2. Le port 8070 est correct\n'
              '3. L\'URL est correcte';
          _isLoading = false;
        });
        return;
      }
      
      print('✅ Instance accessible, connexion en cours...');

      // ÉTAPE 2: Initialiser le service Odoo
      final odooService = OdooService();
      odooService.initialize(
        baseUrl: _urlController.text,
        database: _databaseController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );

      // ÉTAPE 3: Tenter la connexion
      print('🔐 Étape 2: Authentification...');
      final success = await odooService.login();

      if (!mounted) return;

      if (success) {
        print('✅ Connexion réussie !');
        
        // Afficher message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Connexion réussie !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Attendre un peu puis aller au dashboard
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          print('📊 Navigation vers dashboard...');
          context.go('/dashboard');
        }
      } else {
        print('❌ Échec de connexion');
        setState(() {
          _errorMessage = 'Identifiants incorrects.\n\n'
              'Vérifiez:\n'
              '• Base de données: ${_databaseController.text}\n'
              '• Utilisateur: ${_usernameController.text}\n'
              '• Mot de passe\n\n'
              'Essayez: admin / Hamza123-';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erreur exception: $e');
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur inattendue:\n$e\n\n'
              'Vérifiez la console pour plus de détails.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BARRE DE NAVIGATION
      appBar: AppBar(
        title: const Text('Se connecter'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),

      // CONTENU PRINCIPAL
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ========================================
              // 1️⃣ TITRE
              // ========================================
              Text(
                'Connexion à Odoo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Entrez vos paramètres Odoo',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),

              // ========================================
              // 2️⃣ MESSAGE D'ERREUR (si présent)
              // ========================================
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.errorColor.withAlpha((255 * 0.1).toInt()),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: AppConstants.errorColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_errorMessage != null) const SizedBox(height: 20),

              // ========================================
              // 3️⃣ CHAMPS DE FORMULAIRE
              // ========================================
              
              // URL ODOO
              TextField(
                controller: _urlController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'URL Odoo',
                  hintText: 'http://localhost:8070',
                  prefixIcon: const Icon(Icons.link),
                  helperText: 'URL de votre serveur Odoo',
                ),
              ),
              const SizedBox(height: 20),

              // BASE DE DONNÉES
              TextField(
                controller: _databaseController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Base de données',
                  hintText: 'odoo15',
                  prefixIcon: const Icon(Icons.storage),
                  helperText: 'Nom de votre base de données',
                ),
              ),
              const SizedBox(height: 20),

              // NOM D'UTILISATEUR
              TextField(
                controller: _usernameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Utilisateur',
                  hintText: 'admin',
                  prefixIcon: const Icon(Icons.person),
                  helperText: 'Login Odoo',
                ),
              ),
              const SizedBox(height: 20),

              // MOT DE PASSE
              TextField(
                controller: _passwordController,
                enabled: !_isLoading,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _showPassword = !_showPassword);
                    },
                  ),
                  helperText: 'Votre mot de passe Odoo',
                ),
              ),
              const SizedBox(height: 30),

              // ========================================
              // 4️⃣ BOUTON DE CONNEXION
              // ========================================
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'SE CONNECTER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              // ========================================
              // 5️⃣ BOUTON SECONDAIRE
              // ========================================
              OutlinedButton(
                onPressed: _isLoading ? null : () => context.pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'RETOUR',
                  style: TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 30),

              // ========================================
              // 6️⃣ ASTUCE D'AIDE
              // ========================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.infoColor.withAlpha((255 * 0.1).toInt()),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: AppConstants.infoColor.withAlpha((255 * 0.3).toInt()),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Configuration par défaut',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'URL: http://localhost:8070\n'
                      'Base: odoo15\n'
                      'User: admin\n'
                      'Pass: Hamza123-',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
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
}
