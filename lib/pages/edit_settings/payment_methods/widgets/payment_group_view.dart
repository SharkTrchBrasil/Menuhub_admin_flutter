import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/pages/edit_settings/payment_methods/widgets/payment_method_tile.dart';


class PaymentGroupView extends StatelessWidget {
  final PaymentMethodGroup group;
  final int storeId;

  const PaymentGroupView({super.key, required this.group, required this.storeId});

  @override
  Widget build(BuildContext context) {


    return DefaultTabController(
      length: group.categories.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e descrição do grupo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 38,),
                Text(
                  group.title, // Ex: "Repasse via App"
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  group.description ?? 'Gerencie as formas de pagamento para este grupo.', // ✅ Simples assim!
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          // As abas para as categorias
          TabBar(
            // ✅ 2. ALINHA O CONJUNTO DE ABAS NO INÍCIO (ESQUERDA)
            tabAlignment: TabAlignment.start,
            isScrollable: true, // Permite rolar se houver muitas categorias
            tabs: group.categories.map((category) => Tab(text: category.name)).toList(),
          ),
          // O conteúdo de cada aba
          Expanded(
            child: TabBarView(
              children: group.categories.map((category) {
                // Usamos Wrap para responsividade automática (desktop/mobile)
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 16.0, // Espaço horizontal entre os itens
                    runSpacing: 16.0, // Espaço vertical entre as linhas
                    children: category.methods.map((method) {
                      return SizedBox(
                        // Define uma largura para os itens, bom para desktop
                        // Em telas pequenas, o Wrap vai quebrar a linha
                        width: MediaQuery.of(context).size.width > 600 ? 400 : double.infinity,
                        child: PaymentMethodTile(
                          method: method,
                          storeId: storeId,
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}