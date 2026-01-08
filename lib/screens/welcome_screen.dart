// 🏠 ÉCRAN D'ACCUEIL - Premier écran de l'application

import 'package:flutter/material.dart'; // Widgets Material Design
import 'package:go_router/go_router.dart'; // Navigation
import '../utils/constants.dart'; // Constantes

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BACKGROUND
      backgroundColor: Colors.white,
      
      // BODY PRINCIPALE
      body: SafeArea(
        // SafeArea évite la notch et la barre de statut
        child: SingleChildScrollView(
          // Permet le scroll si l'écran est trop petit
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ESPACE EN HAUT
                const SizedBox(height: 40),
                
                // 1. LOGO ODOO
                _buildLogo(),
                
                const SizedBox(height: 40),
                
                // 2. TITRE PRINCIPAL
                _buildTitle(),
                
                const SizedBox(height: 16),
                
                // 3. SOUS-TITRE
                _buildSubtitle(),
                
                const SizedBox(height: 60),
                
                // 4. BOUTON PRINCIPAL
                _buildMainButton(context),
                
                const SizedBox(height: 20),
                
                // 5. BOUTON SECONDAIRE
                _buildSecondaryButton(context),
                
                const SizedBox(height: 40),
                
                // 6. INFORMATIONS DE CONFIGURATION
                _buildConfigInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // =========================================
  // MÉTHODES DE CONSTRUCTION DES WIDGETS
  // =========================================
  
  /// Construit le logo Odoo
  Widget _buildLogo() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        // Gradient de couleur Odoo
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF714B67), // Violet Odoo
            Color(0xFF8E5A7C), // Violet clair
          ],
        ),
        borderRadius: BorderRadius.circular(75), // Cercle parfait
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.business_outlined, // Icône entreprise
        size: 70,
        color: Colors.white,
      ),
    );
  }
  
  /// Construit le titre principal
  Widget _buildTitle() {
    return const Text(
      AppConstants.appName,
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: Color(AppConstants.secondaryColorValue),
        letterSpacing: 1.5,
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }
  
  /// Construit le sous-titre
  Widget _buildSubtitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        'Gérez votre entreprise depuis votre mobile\nAccédez à Odoo 15 partout, tout le temps',
        style: TextStyle(
          fontSize: 16,
          color: Colors.blueGrey,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  /// Construit le bouton principal
  Widget _buildMainButton(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Prend toute la largeur
      height: AppConstants.buttonHeight,
      child: ElevatedButton(
        onPressed: () {
          // Naviguer vers l'écran de choix d'instance
          context.go('/instance-choice');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('COMMENCER'),
            SizedBox(width: 12),
            Icon(Icons.arrow_forward_rounded, size: 22),
          ],
        ),
      ),
    );
  }
  
  /// Construit le bouton secondaire
  Widget _buildSecondaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppConstants.buttonHeight,
      child: OutlinedButton(
        onPressed: () {
          // Aller directement à la connexion
          context.go('/login');
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: BorderSide(
            color: AppConstants.primaryColor,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('SE CONNECTER DIRECTEMENT'),
      ),
    );
  }
  
  /// Affiche les informations de configuration
  Widget _buildConfigInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded, 
                   color: Colors.orange, 
                   size: 20),
              SizedBox(width: 8),
              Text(
                'Configuration Odoo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppConstants.loginInstructions,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blueGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}