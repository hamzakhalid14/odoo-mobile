// 📍 FICHIER DES CONSTANTES DE L'APPLICATION
// Toutes les valeurs fixes sont regroupées ici pour faciliter la maintenance

import 'package:flutter/material.dart';

class AppConstants {
  // ================================
  // 1. CONFIGURATION ODOO PAR DÉFAUT
  // ================================
  
  // URL de votre instance Odoo locale
  // localhost pour émulateur, IP pour téléphone physique
  static const String defaultOdooUrl = 'http://localhost:8070';
  
  // Base de données par défaut (odoo15 selon votre config)
  static const String defaultDatabase = 'odoo15';
  
  // ================================
  // 2. TEXTES DE L'APPLICATION
  // ================================
  
  // Nom de l'application
  static const String appName = 'Odoo Mobile';
  
  // Message de bienvenue
  static const String welcomeMessage = 'Connectez-vous à votre ERP Odoo';
  
  // Instructions pour le test
  static const String loginInstructions = 
      'Pour tester :\n• URL: http://localhost:8070\n• Base: odoo15\n• Utilisateur: admin\n• Mot de passe: admin (mot de passe par défaut)';
  
  // ================================
  // 3. CONFIGURATION API
  // ================================
  
  // Timeout pour les requêtes HTTP (10 secondes)
  static const Duration apiTimeout = Duration(seconds: 10);
  
  // Durée des animations
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // ================================
  // 4. DIMENSIONS ET ESPACEMENTS
  // ================================
  
  // Padding par défaut
  static const double defaultPadding = 16.0;
  
  // Hauteur des boutons
  static const double buttonHeight = 56.0;
  
  // Rayon des bordures arrondies
  static const double borderRadius = 12.0;
  
  // ================================
  // 5. COULEURS DE L'APPLICATION
  // ================================
  
  // Couleur principale (violet Odoo)
  static const int primaryColorValue = 0xFF714B67; // #714B67
  
  // Couleur secondaire (bleu foncé)
  static const int secondaryColorValue = 0xFF2C3E50; // #2C3E50
  
  // Couleur de succès (vert)
  static const int successColorValue = 0xFF4CAF50; // #4CAF50
  
  // Couleur d'erreur (rouge)
  static const int errorColorValue = 0xFFF44336; // #F44336
  
  // Couleur d'avertissement (orange)
  static const int warningColorValue = 0xFFFF9800; // #FF9800
  
  // Couleur d'information (bleu)
  static const int infoColorValue = 0xFF2196F3; // #2196F3
  
  // ================================
  // 6. MESSAGES D'ERREUR
  // ================================
  
  // Erreurs de connexion
  static const String connectionError = 
      'Impossible de se connecter à Odoo.\nVérifiez:\n1. Odoo est démarré\n2. L\'URL est correcte\n3. Le port 8070 est accessible';
  
  static const String invalidCredentials = 
      'Identifiants incorrects.\nUtilisez:\nadmin / Hamza123-';
  
  // ================================
  // 7. CLÉS DE STOCKAGE LOCAL
  // ================================
  
  static const String keyOdooUrl = 'odoo_url';
  static const String keyOdooDatabase = 'odoo_database';
  static const String keyOdooSessionId = 'odoo_session_id';
  static const String keyOdooUserId = 'odoo_user_id';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUsername = 'username';
  static const String keyPassword = 'password';
  
  // ================================
  // 8. MÉTHODES UTILES
  // ================================
  
  // Convertir une valeur hex en Color
  static Color get primaryColor => Color(primaryColorValue);
  static Color get secondaryColor => Color(secondaryColorValue);
  static Color get successColor => Color(successColorValue);
  static Color get errorColor => Color(errorColorValue);
  static Color get warningColor => Color(warningColorValue);
  static Color get infoColor => Color(infoColorValue);
  
  // Vérifier si une URL est localhost
  static bool isLocalhost(String url) {
    return url.contains('localhost') || url.contains('127.0.0.1');
  }
  
  // Obtenir l'URL pour l'app mobile
  // Sur téléphone physique, utiliser l'IP du PC
  static String getMobileUrl(String baseUrl) {
    if (isLocalhost(baseUrl)) {
      // Pour téléphone sur même réseau WiFi
      return baseUrl.replaceAll('localhost', '192.168.1.100');
    }
    return baseUrl;
  }
}