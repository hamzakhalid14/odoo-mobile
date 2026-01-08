// 🎯 POINT D'ENTRÉE PRINCIPAL DE L'APPLICATION
// Configure le thème, les routes et l'état global

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import des écrans
import 'screens/welcome_screen.dart';
import 'screens/instance_choice_screen.dart';
import 'screens/check_instance_screen.dart';
import 'screens/create_instance_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

// Import des services
import 'services/odoo_service.dart';

// Import des constantes
import 'utils/constants.dart';

// =========================================
// FONCTION MAIN - POINT DE DÉPART
// =========================================
void main() async {
  // 1. Assurer que Flutter est initialisé
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Vérifier si l'utilisateur est déjà connecté
  final bool hadLoggedInFlag = await OdooService.isLoggedIn();

  // 3. Tenter une restauration sûre de la session (sans null !)
  bool restored = false;
  if (hadLoggedInFlag) {
    print('🔄 Restauration de la session...');
    final credentials = await OdooService.getSavedCredentials();

    final String url = (credentials['url'] ?? '').toString();
    final String database = (credentials['database'] ?? '').toString();
    final String username = (credentials['username'] ?? '').toString();
    final String password = (credentials['password'] ?? '').toString();

    final bool hasAll = url.isNotEmpty && database.isNotEmpty && username.isNotEmpty && password.isNotEmpty;

    if (hasAll) {
      final odooService = OdooService();
      try {
        odooService.initialize(
          baseUrl: url,
          database: database,
          username: username,
          password: password,
        );
        final ok = await odooService.login();
        restored = ok;
        if (ok) {
          print('✅ Session restaurée');
        } else {
          print('⚠️  Restauration échouée, retour à l\'accueil');
        }
      } catch (e, st) {
        debugPrint('❌ Erreur restauration: $e\n$st');
        restored = false;
      }
    } else {
      print('⚠️  Identifiants incomplets en stockage, restauration ignorée');
    }
  }

  // État incohérent: flag présent mais restauration impossible => nettoyer
  if (hadLoggedInFlag && !restored) {
    await OdooService.logout();
  }

  // 4. Démarrer l'application avec l'état réel (restauré ou non)
  runApp(MyApp(isInitiallyLoggedIn: restored));
}

// =========================================
// CLASSE PRINCIPALE DE L'APPLICATION
// =========================================
class MyApp extends StatelessWidget {
  final bool isInitiallyLoggedIn;
  
  const MyApp({super.key, required this.isInitiallyLoggedIn});

  @override
  Widget build(BuildContext context) {
    // Création du routeur
    final GoRouter router = GoRouter(
      initialLocation: isInitiallyLoggedIn ? '/dashboard' : '/',
      routes: [
        // ROUTE 1: ACCUEIL
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const WelcomeScreen(),
        ),
        
        // ROUTE 2: CHOIX D'INSTANCE
        GoRoute(
          path: '/instance-choice',
          name: 'instance-choice',
          builder: (context, state) => const InstanceChoiceScreen(),
        ),
        
        // ROUTE 3: VÉRIFICATION D'INSTANCE
        GoRoute(
          path: '/check-instance',
          name: 'check-instance',
          builder: (context, state) => const CheckInstanceScreen(),
        ),
        
        // ROUTE 4: CRÉATION D'INSTANCE
        GoRoute(
          path: '/create-instance',
          name: 'create-instance',
          builder: (context, state) => const CreateInstanceScreen(),
        ),
        
        // ROUTE 5: CONNEXION
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => LoginScreen(
            extraData: state.extra as Map<String, dynamic>?, // Permet de passer des données
          ),
        ),
        
        // ROUTE 6: TABLEAU DE BORD
        GoRoute(
          path: '/dashboard',
          name: 'dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
      
      // GESTION DES ERREURS 404
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Page non trouvée'),
          backgroundColor: AppConstants.errorColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              Text(
                'Page non trouvée',
                style: TextStyle(
                  fontSize: 24,
                  color: AppConstants.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'L\'URL "${state.uri.path}" n\'existe pas',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
      
      // REDIRECTIONS (dynamiques selon l'état courant du service)
      redirect: (context, state) {
        final connected = OdooService().isConnected;

        // Empêche l'accès au dashboard si non connecté
        if (state.uri.path == '/dashboard' && !connected) {
          return '/login';
        }

        // Si déjà connecté et sur l'accueil, aller au dashboard
        if (state.uri.path == '/' && connected) {
          return '/dashboard';
        }

        return null; // Pas de redirection
      },
    );

    // CONFIGURATION DE L'APPLICATION
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false, // Cache "DEBUG"
      
      // THÈME MATERIAL DESIGN 3
      theme: ThemeData(
        useMaterial3: true,
        
        // COULEUR PRINCIPALE
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          brightness: Brightness.light,
        ),
        
        // TYPOGRAPHIE
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
        
        // BOUTONS
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        // CHAMPS DE FORMULAIRE
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(color: AppConstants.primaryColor),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.all(16),
        ),
        
        // CARTES
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      
      // ROUTER CONFIGURATION
      routerConfig: router,
    );
  }
}