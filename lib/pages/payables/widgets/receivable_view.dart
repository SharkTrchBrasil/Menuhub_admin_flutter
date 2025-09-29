import 'package:flutter/material.dart';
import 'package:totem_pro_admin/pages/payables/widgets/receivable_card.dart';

import '../../../models/store/store_receivable.dart';




// ✅ ADIÇÃO: View e Card para a aba de Contas a Receber
class ReceivablesView extends StatelessWidget {
  final List<StoreReceivable> receivables;
  final int storeId;
  final Function(StoreReceivable) onDeleteReceivable;

  const ReceivablesView({
    required this.receivables,
    required this.storeId,
    required this.onDeleteReceivable,
  });

  @override
  Widget build(BuildContext context) {
    if (receivables.isEmpty) {
      return const Center(child: Text('Nenhuma conta a receber encontrada.'));
    }
    int crossAxisCount = 1;
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) crossAxisCount = 3;
    else if (screenWidth >= 800) crossAxisCount = 2;

    return GridView.builder(
      padding: const EdgeInsets.all(28.0),
      itemCount: receivables.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount, mainAxisExtent: 180, crossAxisSpacing: 16, mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final receivable = receivables[index];
        return ReceivableCard(
          receivable: receivable,
          storeId: storeId,
          onDelete: () => onDeleteReceivable(receivable),
        );
      },
    );
  }
}
