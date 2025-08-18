import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeSetupPage extends StatelessWidget {
  final int storeId;

  const WelcomeSetupPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícone ou Logo
                Icon(
                  Icons.storefront_outlined,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),

                // Mensagem de Boas-vindas
                const Text(
                  'Bem-vindo(a) à sua nova loja!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Faltam apenas alguns passos para você começar a vender. Siga o checklist abaixo para deixar tudo pronto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 40),

                // Checklist de Configuração
                _buildChecklistItem(
                  context,
                  title: '1. Configure as informações da sua loja',
                  subtitle: 'Adicione seu logo, endereço e informações de contato.',
                  icon: Icons.info_outline,
                  route: '/stores/$storeId/wizard-settings',
                ),
                _buildChecklistItem(
                  context,
                  title: '2. Defina seus horários de funcionamento',
                  subtitle: 'Informe aos seus clientes quando você está aberto.',
                  icon: Icons.access_time,
                  route: '/stores/$storeId/settings/hours',
                ),
                _buildChecklistItem(
                  context,
                  title: '3. Cadastre suas formas de pagamento',
                  subtitle: 'Configure quais métodos você aceita (dinheiro, cartão, Pix).',
                  icon: Icons.payment,
                  route: '/stores/$storeId/platform-payment-methods',
                ),
                _buildChecklistItem(
                  context,
                  title: '4. Adicione seu primeiro produto',
                  subtitle: 'Comece a montar seu cardápio ou catálogo.',
                  icon: Icons.add_shopping_cart,
                  route: '/stores/$storeId/products',
                ),
                const SizedBox(height: 40),

                // Botão de Ação Principal
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    // Leva para o primeiro passo da configuração
                    context.go('/stores/$storeId/settings');
                  },
                  child: const Text('Iniciar Configuração'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para os itens do checklist
  Widget _buildChecklistItem(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required String route,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go(route),
      ),
    );
  }
}