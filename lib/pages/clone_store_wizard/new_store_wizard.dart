import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewStoreOptionsPage extends StatelessWidget {
  const NewStoreOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botão X para fechar - visível em todos os dispositivos
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Fecha a página atual
              if (context.canPop()) {
                context.pop();
              } else {
                // Fallback caso não possa fazer pop
                context.go('/');
              }
            },
            tooltip: 'Fechar', // Acessibilidade
          ),
        ],
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título principal
                Text(
                  'Como você quer começar?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),

                // Descrição
                Text(
                  'Escolha uma das opções abaixo para configurar sua nova loja.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // Opção 1 - Criar do Zero
                _buildOptionCard(
                  context,
                  icon: Icons.add_business_outlined,
                  title: 'Criar do Zero',
                  description: 'Comece uma loja novinha em folha, configurando cada detalhe do seu jeito.',
                  onTap: () {
                    context.go('/stores/new/wizard');
                  },
                ),
                const SizedBox(height: 24),

                // Opção 2 - Clonar Loja Existente
                _buildOptionCard(
                  context,
                  icon: Icons.copy_all_outlined,
                  title: 'Clonar Loja Existente',
                  description: 'Economize tempo clonando produtos, configurações e mais de uma loja que você já gerencia.',
                  onTap: () {
                    context.go('/stores/new/clone');
                  },
                ),

                // Botão de Cancelar adicional para mobile (opcional)
                if (MediaQuery.of(context).size.width < 600) ...[
                  const SizedBox(height: 32),
                  _buildCancelButton(context),
                ],
              ],
            ),
          ),
        ),
      ),

      // Botão de cancelar no footer para desktop (opcional)
      bottomNavigationBar: MediaQuery.of(context).size.width >= 600
          ? _buildBottomCancelButton(context)
          : null,
    );
  }

  Widget _buildOptionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(
            MediaQuery.of(context).size.width < 600 ? 20.0 : 24.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone responsivo
              Icon(
                icon,
                size: MediaQuery.of(context).size.width < 600 ? 32 : 40,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: MediaQuery.of(context).size.width < 600 ? 16 : 20),

              // Conteúdo de texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width < 600
                            ? Theme.of(context).textTheme.titleLarge!.fontSize! * 0.9
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                        fontSize: MediaQuery.of(context).size.width < 600
                            ? Theme.of(context).textTheme.bodyMedium!.fontSize! * 0.9
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Seta indicadora
              Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: MediaQuery.of(context).size.width < 600 ? 14 : 16
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Botão de cancelar para o footer (desktop)
  Widget _buildBottomCancelButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCancelButton(context),
        ],
      ),
    );
  }

  // Botão de cancelar reutilizável
  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width < 600 ? double.infinity : null,
      child: OutlinedButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          side: BorderSide(color: Colors.grey.shade400),
        ),
        child: Text(
          'Cancelar',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: MediaQuery.of(context).size.width < 600 ? 16 : null,
          ),
        ),
      ),
    );
  }
}