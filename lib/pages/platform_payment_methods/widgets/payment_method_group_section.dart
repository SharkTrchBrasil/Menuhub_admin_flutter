import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
// ✅ Importamos o item individual que será exibido no grid
import 'payment_method_item.dart';

class PaymentMethodGroupSection extends StatelessWidget {
  final PaymentMethodGroup group;
  final Function(PlatformPaymentMethod, bool) onActivationChanged;

  const PaymentMethodGroupSection({
    super.key,
    required this.group,
    required this.onActivationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título do Grupo (Ex: "Cartões de Crédito")
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
          child: Text(
            group.title, // Usamos o 'title' que é mais amigável
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),

        // ✅ ================== GRID DE MÉTODOS CORRIGIDO ==================
        // Usamos LayoutBuilder para tornar o grid responsivo
        LayoutBuilder(
          builder: (context, constraints) {
            // Define quantas colunas o grid terá com base na largura da tela
            final crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 400 ? 2 : 1);

            return GridView.builder(
              shrinkWrap: true, // Para o GridView não tentar ter altura infinita dentro de um Column
              physics: const NeverScrollableScrollPhysics(), // Desabilita o scroll do próprio grid
              itemCount: group.methods.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 10, // Ajuste a proporção para o seu layout
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final method = group.methods[index];
                return PaymentMethodItem(
                  method: method,
                  onChanged: (newValue) => onActivationChanged(method, newValue),
                );
              },
            );
          },
        ),
        // ================== FIM DA CORREÇÃO ==================

        const SizedBox(height: 25),
        Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }
}