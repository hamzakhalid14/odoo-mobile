// 📊 TABLEAU DE BORD - ÉCRAN PRINCIPAL APRÈS CONNEXION
// Affiche les informations de l'utilisateur et les modules disponibles

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/odoo_service.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final OdooService _odooService = OdooService(); // Utilise le singleton
  Map<String, dynamic>? _userInfo;
  List<ModuleInfo> _modules = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('🎯 DASHBOARD: initState() appelé');
    _loadData();
  }

  /// Charge les données de l'utilisateur et les modules
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('📊 Chargement des données du dashboard...');

      // Récupérer les infos utilisateur
      final userInfo = await _odooService.getUserInfo();
      
      // Récupérer les modules installés
      final modules = await _odooService.getInstalledModules();

      if (mounted) {
        setState(() {
          _userInfo = userInfo;
          _modules = modules;
          _isLoading = false;
        });

        print('✅ Données chargées');
        print('   Utilisateur: ${userInfo?['name'] ?? 'Inconnu'}');
        print('   Modules: ${modules.length}');
      }
    } catch (e) {
      print('❌ Erreur: $e');
      
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// Déconnexion
  Future<void> _logout() async {
    // Afficher une confirmation
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULER'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'DÉCONNEXION',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      try {
        await _odooService.fullLogout();
        
        if (mounted) {
          // Retour à l'accueil
          context.go('/');
        }
      } catch (e) {
        print('❌ Erreur logout: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================
      // BARRE D'APPLICATION
      // ========================================
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),

      // ========================================
      // CONTENU PRINCIPAL
      // ========================================
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ===== PROFIL UTILISATEUR =====
                      _buildUserProfileCard(),

                      const SizedBox(height: 20),

                      // ===== STATISTIQUES =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                        child: _buildStatsSection(),
                      ),

                      const SizedBox(height: 20),

                      // ===== MODULES INSTALLÉS =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                        child: _buildModulesSection(),
                      ),

                      const SizedBox(height: 20),

                      // ===== ACTIONS RAPIDES =====
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                        child: _buildQuickActionsSection(),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  /// Carte de profil utilisateur
  Widget _buildUserProfileCard() {
    final userName = _userInfo?['name'] ?? 'Utilisateur';
    final email = _userInfo?['email'] ?? 'email@example.com';
    final companyId = _userInfo?['company_id'] ?? ['1', 'Company'];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          // Nom
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Email
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          // Société
          Row(
            children: [
              Icon(
                Icons.business,
                size: 16,
                color: Colors.white.withOpacity(0.7),
              ),
              const SizedBox(width: 8),
              Text(
                companyId is List ? companyId[1] : 'Entreprise',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section de statistiques
  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Grille de stats
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              title: 'Modules',
              value: '${_modules.length}',
              icon: Icons.extension,
              color: Colors.blue,
            ),
            _buildStatCard(
              title: 'Connecté',
              value: 'OUI',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  /// Carte de statistique
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).toInt()),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: color.withAlpha((255 * 0.2).toInt())),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Section des modules installés
  Widget _buildModulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Modules installés',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withAlpha((255 * 0.1).toInt()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_modules.length}',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Liste des modules
        if (_modules.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.extension_off,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun module détecté',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _modules.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
              itemBuilder: (context, index) {
                final module = _modules[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: InkWell(
                    onTap: () => _showModuleDetails(module),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withAlpha((255 * 0.15).toInt()),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: AppConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.extension,
                                    size: 16,
                                    color: AppConstants.successColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      module.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                module.summary.isNotEmpty ? module.summary : 'Module installé',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppConstants.successColor.withAlpha((255 * 0.15).toInt()),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            module.state.toUpperCase(),
                            style: TextStyle(
                              color: AppConstants.successColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        
        // Résumé des modules
        if (_modules.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.infoColor.withAlpha((255 * 0.1).toInt()),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: AppConstants.infoColor.withAlpha((255 * 0.2).toInt()),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppConstants.infoColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_modules.length} module${_modules.length > 1 ? 's' : ''} installé${_modules.length > 1 ? 's' : ''} et actif${_modules.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppConstants.infoColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Section des actions rapides
  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                label: 'Actualiser',
                icon: Icons.refresh,
                onTap: _loadData,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                label: 'Déconnexion',
                icon: Icons.logout,
                onTap: _logout,
                isDestructive: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Bouton d'action rapide
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withAlpha((255 * 0.1).toInt())
                : AppConstants.primaryColor.withAlpha((255 * 0.1).toInt()),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: isDestructive 
                  ? Colors.red.withAlpha((255 * 0.2).toInt())
                  : AppConstants.primaryColor.withAlpha((255 * 0.2).toInt()),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isDestructive ? Colors.red : AppConstants.primaryColor,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDestructive ? Colors.red : AppConstants.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// État d'erreur
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Une erreur inconnue s\'est produite',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('RÉESSAYER'),
            ),
          ],
        ),
      ),
    );
  }

  void _showModuleDetails(ModuleInfo module) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withAlpha((255 * 0.1).toInt()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.extension, color: AppConstants.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          module.technicalName,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withAlpha((255 * 0.15).toInt()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      module.state.toUpperCase(),
                      style: TextStyle(
                        color: AppConstants.successColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (module.summary.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    module.summary,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildDetailChip('Version', module.version.isNotEmpty ? module.version : 'N/A'),
                  _buildDetailChip('Auteur', module.author.isNotEmpty ? module.author : 'N/A'),
                  _buildDetailChip('Application', module.technicalName),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Chip(
      backgroundColor: Colors.grey[100],
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
