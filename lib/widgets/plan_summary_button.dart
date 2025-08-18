import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Importe seus próprios arquivos
import '../../cubits/store_manager_cubit.dart';
import '../../cubits/store_manager_state.dart';
import '../../core/feature_registry.dart';
import '../../models/subscription_summary.dart';


class PlanSummaryButton extends StatelessWidget {
  const PlanSummaryButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Usa o BlocBuilder para reagir às mudanças no estado da loja
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          // Mostra um estado de carregamento ou vazio se os dados não estiverem prontos
          return const SizedBox.shrink();
        }

        final subscription = state.activeStore?.relations.subscription;

        // Se não houver assinatura, não mostra nada
        if (subscription == null) {
          return const SizedBox.shrink();
        }

        return TextButton.icon(
          icon: const Icon(Icons.workspace_premium_outlined, size: 18),
          label: Text(
            subscription.planName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          onPressed: () {
            // Chama a função que exibe o diálogo com os detalhes
            _showPlanSummaryDialog(context, subscription);
          },
        );
      },
    );
  }
}

/// Função auxiliar que constrói e exibe o diálogo com o resumo do plano.
void _showPlanSummaryDialog(BuildContext context, SubscriptionSummary subscription) {
  // Mapa de ícones para cada tipo de limite
  final Map<String, IconData> limitIcons = {
    'Pedidos por Mês': Icons.shopping_cart_checkout,
    'Produtos no Cardápio': Icons.fastfood_outlined,
    'Categorias': Icons.category_outlined,
    'Usuários (Equipe)': Icons.groups_outlined,
    'Lojas/Filiais': Icons.store_outlined,
    'Dispositivos Ativos': Icons.devices_other_outlined,
    'Banners Promocionais': Icons.image_outlined,
  };

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            const Text('Resumo do seu Plano'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Chip(
                  label: Text(
                    subscription.planName,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (subscription.expiryDate != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
                    child: Text(
                      'Válido até: ${DateFormat('dd/MM/yyyy').format(subscription.expiryDate!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),

              // --- Seção de Limites ---
              const Text('Seus Limites Atuais', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              _buildLimitRow('Pedidos por Mês', subscription.monthlyOrderLimit, limitIcons['Pedidos por Mês']!),
              _buildLimitRow('Produtos no Cardápio', subscription.productLimit, limitIcons['Produtos no Cardápio']!),
              _buildLimitRow('Categorias', subscription.categoryLimit, limitIcons['Categorias']!),
              _buildLimitRow('Usuários (Equipe)', subscription.userLimit, limitIcons['Usuários (Equipe)']!),
              _buildLimitRow('Lojas/Filiais', subscription.locationLimit, limitIcons['Lojas/Filiais']!),
              _buildLimitRow('Dispositivos Ativos', subscription.maxActiveDevices, limitIcons['Dispositivos Ativos']!),
              _buildLimitRow('Banners Promocionais', subscription.bannerLimit, limitIcons['Banners Promocionais']!),
              const SizedBox(height: 20),

              // --- Seção de Funcionalidades ---
              const Text('Funcionalidades Inclusas', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              ...subscription.features.map((featureKey) {
                // Busca o nome amigável da feature no nosso registro
                final featureName = featureRegistry[featureKey] ?? featureKey;
                return _buildFeatureRow(featureName);
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Fechar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FilledButton(
            child: const Text('Gerenciar Assinatura'),
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Adicionar navegação para a tela de gerenciamento de planos
              // Ex: context.go('/stores/${storeId}/plans');
            },
          ),
        ],
      );
    },
  );
}

/// Widget auxiliar para exibir uma linha de limite (ex: "Produtos: 50").
Widget _buildLimitRow(String title, int? limit, IconData icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
        Text(
          limit?.toString() ?? 'Ilimitado',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

/// Widget auxiliar para exibir uma linha de feature inclusa.
Widget _buildFeatureRow(String name) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(name)),
      ],
    ),
  );
}
