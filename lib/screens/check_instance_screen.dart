// 🔍 ÉCRAN DE VÉRIFICATION D'INSTANCE
// Permet de vérifier si Odoo est accessible à une URL donnée

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/odoo_service.dart';
import '../utils/constants.dart';

class CheckInstanceScreen extends StatefulWidget {
  const CheckInstanceScreen({super.key});

  @override
  State<CheckInstanceScreen> createState() => _CheckInstanceScreenState();
}

class _CheckInstanceScreenState extends State<CheckInstanceScreen> {
  // =========================================
  // VARIABLES D'ÉTAT
  // =========================================
  
  final _urlController = TextEditingController();
  bool _isChecking = false;
  String? _lastUrl;
  Map<String, dynamic>? _checkResult;

  @override
  void initState() {
    super.initState();
    _urlController.text = AppConstants.defaultOdooUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  // =========================================
  // MÉTHODE DE VÉRIFICATION
  // =========================================
  
  Future<void> _checkInstance() async {
    setState(() {
      _isChecking = true;
      _lastUrl = _urlController.text;
      _checkResult = null;
    });

    try {
      print('🔍 Vérification de ${ _urlController.text}');

      // Appeler le service pour vérifier l'instance
      final result = await OdooService.checkInstance(_urlController.text);

      if (mounted) {
        setState(() {
          _checkResult = result;
          _isChecking = false;
        });

        // Afficher un SnackBar avec le résultat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? ''),
            backgroundColor: result['success'] ?? false 
                ? Colors.green 
                : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur: $e');
      
      if (mounted) {
        setState(() {
          _checkResult = {
            'success': false,
            'message': 'Erreur: ${e.toString()}',
          };
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BARRE DE NAVIGATION
      appBar: AppBar(
        title: const Text('Vérifier Odoo'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
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
              // 1️⃣ ILLUSTRATION
              // ========================================
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withAlpha((255 * 0.1).toInt()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_done,
                    size: 60,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // ========================================
              // 2️⃣ TITRE
              // ========================================
              Text(
                'Vérifier votre instance Odoo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                'Entrez l\'URL de votre serveur Odoo '
                'pour vérifier s\'il est accessible',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // ========================================
              // 3️⃣ CHAMP D'URL
              // ========================================
              TextField(
                controller: _urlController,
                enabled: !_isChecking,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'URL Odoo',
                  hintText: 'http://localhost:8070',
                  prefixIcon: const Icon(Icons.link),
                  helperText: 'Exemple: http://192.168.1.100:8070',
                ),
              ),
              const SizedBox(height: 30),

              // ========================================
              // 4️⃣ BOUTON DE VÉRIFICATION
              // ========================================
              ElevatedButton.icon(
                onPressed: _isChecking ? null : _checkInstance,
                icon: _isChecking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isChecking ? 'Vérification...' : 'VÉRIFIER'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey[300],
                ),
              ),

              const SizedBox(height: 30),

              // ========================================
              // 5️⃣ RÉSULTAT DE LA VÉRIFICATION
              // ========================================
              if (_checkResult != null)
                _buildResultCard(_checkResult!),

              const SizedBox(height: 30),

              // ========================================
              // 6️⃣ BOUTON D'ACTION SECONDAIRE
              // ========================================
              if (_checkResult != null && (_checkResult!['success'] ?? false))
                ElevatedButton(
                  onPressed: () {
                    // Aller à l'écran de connexion avec l'URL testée
                    context.push(
                      '/login',
                      extra: {
                        'url': _urlController.text,
                        'database': AppConstants.defaultDatabase,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login),
                      SizedBox(width: 8),
                      Text('CONTINUER À LA CONNEXION'),
                    ],
                  ),
                ),

              if (_checkResult != null && (_checkResult!['success'] ?? false))
                const SizedBox(height: 12),

              // ========================================
              // 7️⃣ CONSEILS
              // ========================================
              if (_checkResult == null || !(_checkResult!['success'] ?? false))
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha((255 * 0.1).toInt()),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: Colors.orange.withAlpha((255 * 0.3).toInt()),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Conseils',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '1. Vérifiez que Odoo est démarré\n'
                        '2. Utilisez http (pas https) pour un serveur local\n'
                        '3. Vérifiez le port (par défaut 8070)\n'
                        '4. Sur téléphone physique, utilisez l\'IP du PC\n'
                        '5. Assurez-vous d\'être sur le même réseau WiFi',
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

  // =========================================
  // MÉTHODE HELPER: CONSTRUIRE LA CARTE DE RÉSULTAT
  // =========================================
  
  Widget _buildResultCard(Map<String, dynamic> result) {
    final success = result['success'] ?? false;
    final message = result['message'] ?? 'Résultat inconnu';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success
            ? AppConstants.successColor.withAlpha((255 * 0.1).toInt())
            : AppConstants.errorColor.withAlpha((255 * 0.1).toInt()),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: success
              ? AppConstants.successColor.withAlpha((255 * 0.3).toInt())
              : AppConstants.errorColor.withAlpha((255 * 0.3).toInt()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du résultat
          Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error_outline,
                color: success ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                success ? '✅ Succès' : '❌ Erreur',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: success ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Message
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),

          // URL testée
          if (_lastUrl != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'URL testée: $_lastUrl',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
