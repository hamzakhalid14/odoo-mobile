// 🚀 SERVICE ODOO - COMMUNICATION AVEC ODOO 15
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ModuleInfo {
  final int id;
  final String name;
  final String technicalName;
  final String state;
  final String author;
  final String version;
  final String summary;
  final String category;
  final String license;
  final String website;
  final bool isApplication;

  ModuleInfo({
    required this.id,
    required this.name,
    required this.technicalName,
    required this.state,
    required this.author,
    required this.version,
    required this.summary,
    required this.category,
    required this.license,
    required this.website,
    required this.isApplication,
  });

  factory ModuleInfo.fromJson(Map<String, dynamic> json) {
    return ModuleInfo(
      id: json['id'] as int,
      name: (json['display_name'] ?? json['name'] ?? 'Module').toString(),
      technicalName: (json['name'] ?? '').toString(),
      state: (json['state'] ?? 'uninstalled').toString(),
      author: (json['author'] ?? 'Inconnu').toString(),
      version: (json['latest_version'] ?? json['installed_version'] ?? '1.0').toString(),
      summary: (json['summary'] ?? json['shortdesc'] ?? '').toString(),
      category: (json['category_id'] is List ? json['category_id'][1] : json['category_id'] ?? 'Autre').toString(),
      license: (json['license'] ?? 'LGPL-3').toString(),
      website: (json['website'] ?? '').toString(),
      isApplication: json['application'] ?? false,
    );
  }
}

class OdooService {
  static final OdooService _instance = OdooService._internal();
  
  late String _baseUrl;
  late String _database;
  late String _username;
  late String _password;
  int? _uid;

  OdooService._internal();

  factory OdooService() {
    return _instance;
  }

  // =========================================
  // CONFIGURATION
  // =========================================
  
  void initialize({
    required String baseUrl,
    required String database,
    required String username,
    required String password,
  }) {
    _baseUrl = baseUrl;
    _database = database;
    _username = username;
    _password = password;
    
    if (_baseUrl.endsWith('/')) {
      _baseUrl = _baseUrl.substring(0, _baseUrl.length - 1);
    }
  }

  // =========================================
  // AUTHENTIFICATION
  // =========================================
  
  /// Vérifier si instance Odoo est accessible
  static Future<Map<String, dynamic>> checkInstance(String url) async {
    try {
      final response = await http.get(
        Uri.parse('$url/web/health'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Instance Odoo trouvée et accessible !',
        };
      } else {
        return {
          'success': false,
          'message': 'Instance non accessible (HTTP ${response.statusCode})',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Impossible de contacter Odoo: $e',
      };
    }
  }

  /// Se connecter à Odoo
  Future<bool> login() async {
    try {
      print('🔐 LOGIN: Début de l\'authentification');
      print('   URL: $_baseUrl/jsonrpc');
      print('   DB: $_database');
      print('   User: $_username');
      
      final Map<String, dynamic> params = {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'service': 'common',
          'method': 'authenticate',
          'args': [_database, _username, _password, {}],
        },
        'id': 1,
      };

      print('📤 LOGIN: Envoi de la requête...');
      final response = await http.post(
        Uri.parse('$_baseUrl/jsonrpc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(params),
      ).timeout(AppConstants.apiTimeout);

      print('📥 LOGIN: Réponse reçue - Status: ${response.statusCode}');
      print('📄 LOGIN: Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        
        print('🔍 LOGIN: Analyse de la réponse...');
        
        if (responseBody.containsKey('result') && responseBody['result'] != false) {
          _uid = responseBody['result'];
          print('✅ LOGIN: Succès ! UID = $_uid');
          
          await _saveCredentials();
          print('💾 LOGIN: Identifiants sauvegardés');
          
          return true;
        } else if (responseBody.containsKey('error')) {
          print('❌ LOGIN: Erreur dans la réponse: ${responseBody['error']}');
          return false;
        } else {
          print('❌ LOGIN: Réponse invalide: $responseBody');
          return false;
        }
      } else {
        print('❌ LOGIN: Code HTTP incorrect: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // =========================================
  // RÉCUPÉRATION DES DONNÉES
  // =========================================

  Future<Map<String, dynamic>?> getUserInfo() async {
    print('👤 getUserInfo: _uid = $_uid, _database = $_database, _baseUrl = $_baseUrl');
    
    if (_uid == null) {
      print('❌ getUserInfo: UID est null !');
      return null;
    }

    try {
      final Map<String, dynamic> params = {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'service': 'object',
          'method': 'execute_kw',
          'args': [
            _database,
            _uid,
            _password,
            'res.users',
            'read',
            [_uid],
            {'fields': ['id', 'name', 'email', 'company_id']},
          ],
        },
        'id': 1,
      };

      print('📤 getUserInfo: Envoi requête...');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/jsonrpc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(params),
      ).timeout(AppConstants.apiTimeout);

      print('📥 getUserInfo: Réponse Status ${response.statusCode}');
      print('📄 getUserInfo: Body ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        
        if (responseBody.containsKey('result') && responseBody['result'] is List) {
          final List<dynamic> result = responseBody['result'];
          if (result.isNotEmpty) {
            print('✅ getUserInfo: Données trouvées: ${result[0]}');
            return result[0] as Map<String, dynamic>;
          }
        }
      }
      print('❌ getUserInfo: Pas de résultat');
      return null;
    } catch (e) {
      print('❌ getUserInfo: Erreur $e');
      return null;
    }
  }

  Future<List<ModuleInfo>> getInstalledModules() async {
    print('📦 getInstalledModules: _uid = $_uid');
    
    if (_uid == null) {
      print('❌ getInstalledModules: UID est null !');
      return [];
    }

    try {
      // ÉTAPE 1: Chercher les modules avec state='installed'
      final Map<String, dynamic> searchParams = {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'service': 'object',
          'method': 'execute_kw',
          'args': [
            _database,
            _uid,
            _password,
            'ir.module.module',
            'search',
            [[['state', '=', 'installed']]],  // Triple brackets pour le domaine
          ],
        },
        'id': 1,
      };

      print('📤 getInstalledModules: Recherche modules installés...');
      
      final searchResponse = await http.post(
        Uri.parse('$_baseUrl/jsonrpc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(searchParams),
      ).timeout(AppConstants.apiTimeout);

      print('📥 getInstalledModules (search): Status ${searchResponse.statusCode}');

      if (searchResponse.statusCode == 200) {
        final Map<String, dynamic> searchBody = jsonDecode(searchResponse.body);
        
        if (searchBody.containsKey('result') && searchBody['result'] is List) {
          final List<dynamic> allModuleIds = searchBody['result'];
          print('✅ Trouvé ${allModuleIds.length} modules installés');
          
          if (allModuleIds.isEmpty) {
            print('⚠️  Aucun module installé');
            return [];
          }

          // Limiter à 200 modules max pour éviter surcharge
          final List<dynamic> moduleIds = allModuleIds.length > 200 
              ? allModuleIds.sublist(0, 200) 
              : allModuleIds;
          
          if (allModuleIds.length > 200) {
            print('⚠️  Limité à 200 modules sur ${allModuleIds.length}');
          }

          // ÉTAPE 2: Lire les détails des modules
          // Note: read() attend [ids] comme premier arg, pas ids directement
          final Map<String, dynamic> readParams = {
            'jsonrpc': '2.0',
            'method': 'call',
            'params': {
              'service': 'object',
              'method': 'execute_kw',
              'args': [
                _database,
                _uid,
                _password,
                'ir.module.module',
                'read',
                [moduleIds],
                {
                  'fields': [
                    'id',
                    'name',
                    'display_name',
                    'summary',
                    'shortdesc',
                    'state',
                    'author',
                    'website',
                    'latest_version',
                    'installed_version',
                    'application',
                    'license',
                    'category_id',
                  ],
                },
              ],
            },
            'id': 1,
          };

          print('📤 getInstalledModules: Lecture des détails...');
          
          final readResponse = await http.post(
            Uri.parse('$_baseUrl/jsonrpc'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(readParams),
          ).timeout(AppConstants.apiTimeout);

          print('📥 getInstalledModules (read): Status ${readResponse.statusCode}');

          if (readResponse.statusCode == 200) {
            final Map<String, dynamic> readBody = jsonDecode(readResponse.body);
            
            if (readBody.containsKey('result') && readBody['result'] is List) {
              final List<ModuleInfo> installedModules = [];
              
              for (var module in readBody['result']) {
                if (module is Map && module['id'] != null) {
                  installedModules.add(ModuleInfo.fromJson(module.cast<String, dynamic>()));
                }
              }
              
              print('✅ getInstalledModules: ${installedModules.length} modules récupérés');
              return installedModules;
            } else if (readBody.containsKey('error')) {
              print('❌ getInstalledModules (read): Erreur ${readBody['error']}');
            }
          }
        } else if (searchBody.containsKey('error')) {
          print('❌ getInstalledModules (search): Erreur ${searchBody['error']['message']}');
        }
      }
      
      print('❌ getInstalledModules: Impossible de récupérer les modules');
      return [];
    } catch (e) {
      print('❌ getInstalledModules: Exception $e');
      return [];
    }
  }

  // =========================================
  // GESTION DE SESSION
  // =========================================

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(AppConstants.keyOdooUrl, _baseUrl);
    await prefs.setString(AppConstants.keyOdooDatabase, _database);
    await prefs.setString(AppConstants.keyUsername, _username);
    await prefs.setString(AppConstants.keyPassword, _password);
    if (_uid != null) {
      await prefs.setInt(AppConstants.keyOdooUserId, _uid!);
    }
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    
    return {
      'url': prefs.getString(AppConstants.keyOdooUrl) ?? AppConstants.defaultOdooUrl,
      'database': prefs.getString(AppConstants.keyOdooDatabase) ?? AppConstants.defaultDatabase,
      'username': prefs.getString(AppConstants.keyUsername) ?? 'admin',
      'password': prefs.getString(AppConstants.keyPassword) ?? '',
      'user_id': prefs.getInt(AppConstants.keyOdooUserId) ?? 0,
      'user_name': prefs.getString('user_name') ?? 'Administrateur',
      'session_id': prefs.getString(AppConstants.keyOdooSessionId) ?? '',
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(AppConstants.keyOdooUrl);
    await prefs.remove(AppConstants.keyOdooDatabase);
    await prefs.remove(AppConstants.keyUsername);
    await prefs.remove(AppConstants.keyPassword);
    await prefs.remove(AppConstants.keyOdooUserId);
    await prefs.remove(AppConstants.keyIsLoggedIn);
    await prefs.remove(AppConstants.keyOdooSessionId);
  }

  /// Réinitialise l'état en mémoire et efface le stockage
  Future<void> fullLogout() async {
    _uid = null;
    _password = '';
    await OdooService.logout();
  }

  // =========================================
  // GESTION DES BASES DE DONNÉES
  // =========================================

  /// Liste toutes les bases de données disponibles sur le serveur
  static Future<List<String>> listDatabases(String baseUrl) async {
    try {
      print('📋 Récupération de la liste des bases de données...');
      
      final Map<String, dynamic> params = {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'service': 'db',
          'method': 'list',
          'args': [],
        },
        'id': 1,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/jsonrpc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(params),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        
        if (responseBody.containsKey('result') && responseBody['result'] is List) {
          final List<String> databases = (responseBody['result'] as List)
              .map((e) => e.toString())
              .toList();
          print('✅ ${databases.length} base(s) de données trouvée(s)');
          return databases;
        }
      }
      
      print('❌ Impossible de récupérer la liste des bases de données');
      return [];
    } catch (e) {
      print('❌ Erreur listDatabases: $e');
      return [];
    }
  }

  /// Crée une nouvelle base de données
  static Future<Map<String, dynamic>> createDatabase({
    required String baseUrl,
    required String masterPassword,
    required String databaseName,
    required String adminPassword,
    String lang = 'fr_FR',
    String? country,
  }) async {
    try {
      print('🔨 Création de la base de données: $databaseName');
      
      final Map<String, dynamic> params = {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'service': 'db',
          'method': 'create_database',
          'args': [
            masterPassword,      // Master password du serveur
            databaseName,        // Nom de la base
            true,                // demo data
            lang,                // Langue
            adminPassword,       // Mot de passe admin
            'admin',             // Login admin
            country ?? 'MA',     // Pays
          ],
        },
        'id': 1,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/jsonrpc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(params),
      ).timeout(const Duration(minutes: 5)); // Création peut être longue

      print('📥 Réponse création DB: Status ${response.statusCode}');
      print('📄 Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        
        if (responseBody.containsKey('error')) {
          final error = responseBody['error'];
          String errorMsg = error['data']?['message'] ?? error['message'] ?? 'Erreur inconnue';
          
          // Détecter les erreurs PostgreSQL courantes
          if (errorMsg.contains('collationnements') || errorMsg.contains('collation')) {
            errorMsg = 'Erreur PostgreSQL: Problème de collation/encodage.\n\n'
                'Solutions:\n'
                '1. Utilisez template0: CREATE DATABASE $databaseName TEMPLATE template0 LC_COLLATE \'C\' LC_CTYPE \'C\';\n'
                '2. Ou configurez PostgreSQL avec initdb --locale=C\n'
                '3. Vérifiez le port PostgreSQL (5433 détecté, standard: 5432)';
          } else if (errorMsg.contains('connection') || errorMsg.contains('connexion')) {
            errorMsg = 'Impossible de se connecter à PostgreSQL.\n\n'
                'Vérifiez que:\n'
                '• PostgreSQL est démarré\n'
                '• Le port est correct (actuellement 5433)\n'
                '• L\'utilisateur odoo existe avec les droits CREATEDB\n'
                '• Le fichier pg_hba.conf autorise les connexions locales';
          } else if (errorMsg.contains('password') || errorMsg.contains('authentication')) {
            errorMsg = 'Erreur d\'authentification PostgreSQL ou Master Password incorrect';
          }
          
          return {
            'success': false,
            'message': errorMsg,
            'raw_error': error.toString(),
          };
        }
        
        if (responseBody.containsKey('result')) {
          print('✅ Base de données créée avec succès');
          return {
            'success': true,
            'message': 'Base de données "$databaseName" créée avec succès',
            'database': databaseName,
          };
        }
      }
      
      return {
        'success': false,
        'message': 'Erreur HTTP ${response.statusCode}',
      };
    } catch (e) {
      print('❌ Erreur createDatabase: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: ${e.toString()}\n\nVérifiez que le serveur Odoo est accessible',
      };
    }
  }

  /// Duplique une base de données existante
  static Future<Map<String, dynamic>> duplicateDatabase({
    required String baseUrl,
    required String masterPassword,
    required String sourceDb,
    required String targetDb,
  }) async {
    try {
      print('📋 Duplication: $sourceDb → $targetDb');
      
      final Map<String, dynamic> params = {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'service': 'db',
          'method': 'duplicate_database',
          'args': [masterPassword, sourceDb, targetDb],
        },
        'id': 1,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/jsonrpc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(params),
      ).timeout(const Duration(minutes: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        
        if (responseBody.containsKey('error')) {
          return {
            'success': false,
            'message': responseBody['error']['data']?['message'] ?? 'Erreur de duplication',
          };
        }
        
        if (responseBody.containsKey('result') && responseBody['result'] == true) {
          return {
            'success': true,
            'message': 'Base de données dupliquée avec succès',
          };
        }
      }
      
      return {'success': false, 'message': 'Erreur inconnue'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  /// Supprime une base de données
  static Future<Map<String, dynamic>> dropDatabase({
    required String baseUrl,
    required String masterPassword,
    required String databaseName,
  }) async {
    try {
      print('🗑️ Suppression de la base: $databaseName');
      
      final Map<String, dynamic> params = {
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'service': 'db',
          'method': 'drop',
          'args': [masterPassword, databaseName],
        },
        'id': 1,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/jsonrpc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(params),
      ).timeout(AppConstants.apiTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        
        if (responseBody.containsKey('error')) {
          return {
            'success': false,
            'message': responseBody['error']['data']?['message'] ?? 'Erreur de suppression',
          };
        }
        
        if (responseBody.containsKey('result') && responseBody['result'] == true) {
          return {
            'success': true,
            'message': 'Base de données supprimée',
          };
        }
      }
      
      return {'success': false, 'message': 'Erreur inconnue'};
    } catch (e) {
      return {'success': false, 'message': 'Erreur: $e'};
    }
  }

  // =========================================
  // GETTERS
  // =========================================
  
  String get baseUrl => _baseUrl;
  String get database => _database;
  String get username => _username;
  int? get uid => _uid;
  bool get isConnected => _uid != null;
}
