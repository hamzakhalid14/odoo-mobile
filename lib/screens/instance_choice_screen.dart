// 📋 ÉCRAN DE CHOIX D'INSTANCE
// Permet de choisir entre connexion existante ou nouvelle

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/odoo_service.dart';
import '../utils/constants.dart';

class InstanceChoiceScreen extends StatefulWidget {
  const InstanceChoiceScreen({super.key});

  @override
  State<InstanceChoiceScreen> createState() => _InstanceChoiceScreenState();
}

class _InstanceChoiceScreenState extends State<InstanceChoiceScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _savedCredentials;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final credentials = await OdooService.getSavedCredentials();
      
      // Vérifier si des identifiants sont sauvegardés
      final isLoggedIn = await OdooService.isLoggedIn();
      
      if (mounted) {
        setState(() {
          _savedCredentials = isLoggedIn ? credentials : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accéder à Odoo'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ========================================
                    // TITRE
                    // ========================================
                    Text(
                      'Comment voulez-vous accéder à Odoo ?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // ========================================
                    // OPTION 1: CONNEXION SAUVEGARDÉE
                    // ========================================
                    if (_savedCredentials != null)
                      _buildOption(
                        context,
                        icon: Icons.check_circle_outline,
                        title: 'Continuer',
                        subtitle: 'Utiliser votre dernière session',
                        description: 'Utilisateur: ${_savedCredentials!['user_name'] ?? 'Admin'}\n'
                            'Instance: ${_savedCredentials!['url']}',
                        onTap: () async {
                          // Vérifier la connexion
                          final isValid = await OdooService.isLoggedIn();
                          if (isValid && mounted) {
                            context.go('/dashboard');
                          } else if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Session expirée. Veuillez vous reconnecter.'),
                              ),
                            );
                          }
                        },
                        color: AppConstants.successColor,
                      ),

                    if (_savedCredentials != null) const SizedBox(height: 20),

                    // ========================================
                    // OPTION 2: NOUVELLE CONNEXION
                    // ========================================
                    _buildOption(
                      context,
                      icon: Icons.login,
                      title: 'Se connecter',
                      subtitle: 'Nouvelle connexion Odoo',
                      description: 'Entrez vos identifiants pour vous connecter\nà votre instance Odoo',
                      onTap: () => context.push('/login'),
                      color: AppConstants.primaryColor,
                    ),

                    const SizedBox(height: 20),

                    // ========================================
                    // OPTION 3: VÉRIFIER L'INSTANCE
                    // ========================================
                    _buildOption(
                      context,
                      icon: Icons.cloud_done,
                      title: 'Vérifier l\'instance',
                      subtitle: 'Tester la connexion',
                      description: 'Vérifiez si votre serveur Odoo\nest accessible et fonctionnel',
                      onTap: () => context.push('/check-instance'),
                      color: Colors.orange,
                    ),

                    const SizedBox(height: 30),

                    // ========================================
                    // INFORMATION
                    // ========================================
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha((255 * 0.1).toInt()),
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                        border: Border.all(
                          color: Colors.blue.withAlpha((255 * 0.3).toInt()),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'À propos',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Cette application vous permet de vous connecter '
                            'à votre serveur Odoo 15 installé localement.\n\n'
                            'Assurez-vous que Odoo est démarré sur le port 8070.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.6,
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

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Row(
            children: [
              // Icône
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha((255 * 0.1).toInt()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Flèche
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
