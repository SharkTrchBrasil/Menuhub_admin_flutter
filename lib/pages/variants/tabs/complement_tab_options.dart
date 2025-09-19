import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/variant_option.dart';
import '../../../widgets/ds_primary_button.dart';
import '../cubits/variant_edit_cubit.dart';
import '../widgets/complement_card.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/edit_option_form.dart'; // ✅ 1. IMPORTAR O FORMULÁRIO
import 'package:totem_pro_admin/pages/variants/widgets/variant_option_tile.dart'; // ✅ 2. IMPORTAR O TILE CORRETO
import '../cubits/variant_edit_cubit.dart';

class ComplementsTabEdit extends StatelessWidget {
  const ComplementsTabEdit({super.key});

  // ✅ 3. MÉTODO PARA ABRIR O BOTTOMSHEET DE CRIAÇÃO/EDIÇÃO
  Future<void> _showEditCreateSheet(
      BuildContext context, {
        VariantOption? option, // Se for nulo, é criação. Se não, é edição.
        int? index,
      }) async {
    final cubit = context.read<VariantEditCubit>();
    final result = await showModalBottomSheet<VariantOption>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: EditOptionForm(
          option: option,
          onConfirm: (updatedOption) => Navigator.of(context).pop(updatedOption),
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );

    if (result != null) {
      if (option != null && index != null) {
        // Modo Edição
        cubit.updateOption(index, result);
      } else {
        // Modo Criação
        cubit.addOption(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return BlocBuilder<VariantEditCubit, VariantEditState>(
      builder: (context, state) {
        final cubit = context.read<VariantEditCubit>();
        final options = state.editableVariant.options;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Header com título e botão
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Complementos',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  // ✅ 4. O BOTÃO AGORA CHAMA NOSSO NOVO MÉTODO EM MODO DE CRIAÇÃO
                  onPressed: () => _showEditCreateSheet(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Complemento'),
                  // ... seus estilos
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Lista de complementos
            if (options.isEmpty)
              _buildEmptyState()
            else
            // ✅ 5. SUBSTITUIR O MAP SIMPLES POR UM ListView.builder COM O NOVO TILE
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return VariantOptionTile(
                    key: ValueKey(option.clientId), // Use uma chave única!
                    option: option,
                    index: index,
                    isMobile: isMobile,
                    onUpdate: (updatedOption) {
                      // O onUpdate do TILE já lida com a edição interna no Desktop.
                      // Para o Mobile, o BottomSheet é o principal, mas podemos conectar aqui também.
                      cubit.updateOption(index, updatedOption);
                    },
                    // Conecta a ação de remover do Tile diretamente ao Cubit
                    onRemove: (optionToRemove) => cubit.removeOption(optionToRemove),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum complemento adicionado',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Adicione complementos para que os clientes possam personalizar seus pedidos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8F8F8F),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
















//
// class ComplementsTabEdit extends StatelessWidget {
//   const ComplementsTabEdit({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<VariantEditCubit, VariantEditState>(
//       builder: (context, state) {
//         final options = state.editableVariant.options;
//
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 14.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Complementos',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF151515),
//                     ),
//                   ),
//                   DsButton(
//                     onPressed: () {
//                       context.read<VariantEditCubit>().addOption(VariantOption());
//                     },
//
//                     label: ' + Complemento',
//                     style: DsButtonStyle.secondary,
//
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//
//               // Lista de complementos
//               if (options.isEmpty)
//                 _buildEmptyState()
//               else
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: options.length,
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 16),
//                         child: ComplementCard(option: options[index]),
//                       );
//                     },
//                   ),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//
// }