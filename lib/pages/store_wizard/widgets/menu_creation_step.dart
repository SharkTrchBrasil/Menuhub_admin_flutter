import 'package:flutter/material.dart';

// Enum para representar a escolha do usuário
enum MenuCreationOption { manual, scan }

class MenuCreationStep extends StatefulWidget {
  const MenuCreationStep({super.key});

  @override
  State<MenuCreationStep> createState() => MenuCreationStepState();
}

class MenuCreationStepState extends State<MenuCreationStep> {
  // A propriedade 'selectedOption' será pública para que o wizard possa acessá-la
  MenuCreationOption selectedOption = MenuCreationOption.manual;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Como você quer cadastrar seu cardápio?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Escolha a forma que melhor se adapta a você. Você poderá alterar isso mais tarde.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildOptionCard(
              option: MenuCreationOption.manual,
              icon: Icons.edit_document,
              title: 'Cadastro Manual',
              subtitle: 'Ideal para quem quer controle total e cadastrar cada produto e categoria passo a passo.',
            ),
            const SizedBox(height: 24),
            _buildOptionCard(
              option: MenuCreationOption.scan,
              icon: Icons.camera_alt_outlined,
              title: 'Automático com Fotos (IA)',
              subtitle: 'Envie fotos do seu cardápio e deixe nossa inteligência artificial fazer o trabalho pesado por você.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required MenuCreationOption option,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = selectedOption == option;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = option;
        });
      },
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade600),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
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