// 🔨 ÉCRAN DE CRÉATION D'INSTANCE
// Affiche des instructions pour créer une nouvelle instance Odoo

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';

class CreateInstanceScreen extends StatelessWidget {
  const CreateInstanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une instance'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
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
                'Créer une nouvelle instance Odoo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                'Suivez ces étapes pour mettre en place une instance Odoo locale',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // ========================================
              // 2️⃣ ÉTAPES DE CRÉATION
              // ========================================
              _buildStep(
                number: 1,
                title: 'Installer Odoo',
                description: 'Téléchargez et installez Odoo 15 depuis odoo.com',
                commands: [
                  'git clone https://github.com/odoo/odoo.git --depth=1',
                  'cd odoo',
                  'git checkout 15.0',
                ],
              ),
              const SizedBox(height: 20),

              _buildStep(
                number: 2,
                title: 'Installer les dépendances',
                description: 'Installez les packages Python nécessaires',
                commands: [
                  'pip install -r requirements.txt',
                ],
              ),
              const SizedBox(height: 20),

              _buildStep(
                number: 3,
                title: 'Configuration PostgreSQL',
                description: 'Créez une base de données PostgreSQL',
                commands: [
                  'createdb odoo15',
                  'createuser -P odoo',
                ],
              ),
              const SizedBox(height: 20),

              _buildStep(
                number: 4,
                title: 'Modifier la configuration',
                description: 'Mettez à jour le fichier odoo.conf',
                commands: [
                  '[options]',
                  'admin_passwd = Hamza123-',
                  'addons_path = addons,custom_addons',
                  'db_host = localhost',
                  'db_port = 5433',
                  'db_user = odoo',
                  'db_password = odoo',
                  'db_name = odoo15',
                  'http_port = 8070',
                ],
              ),
              const SizedBox(height: 20),

              _buildStep(
                number: 5,
                title: 'Démarrer le serveur',
                description: 'Lancez Odoo en mode développement',
                commands: [
                  'python odoo-bin -c odoo.conf --dev=all',
                ],
              ),

              const SizedBox(height: 30),

              // ========================================
              // 3️⃣ VÉRIFICATION
              // ========================================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.successColor.withAlpha((255 * 0.1).toInt()),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(
                    color: AppConstants.successColor.withAlpha((255 * 0.3).toInt()),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Instance prête',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Une fois Odoo lancé, vous pouvez:\n'
                      '1. Accéder à Odoo sur http://localhost:8070\n'
                      '2. Créer une nouvelle base de données\n'
                      '3. Utiliser cette application mobile pour vous connecter',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ========================================
              // 4️⃣ BOUTONS D'ACTION
              // ========================================
              ElevatedButton.icon(
                onPressed: () => context.push('/check-instance'),
                icon: const Icon(Icons.cloud_done),
                label: const Text('VÉRIFIER L\'INSTANCE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () => context.push('/login'),
                icon: const Icon(Icons.login),
                label: const Text('ALLER À LA CONNEXION'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required String description,
    required List<String> commands,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
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
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Commandes
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: commands.map((cmd) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  cmd,
                  style: const TextStyle(
                    color: Colors.green,
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
