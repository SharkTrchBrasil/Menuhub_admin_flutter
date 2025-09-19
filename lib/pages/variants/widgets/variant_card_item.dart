import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ✅ IMPORT ADICIONADO
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart'; // ✅ IMPORT ADICIONADO
import 'package:totem_pro_admin/models/variant.dart';

class VariantCardItem extends StatelessWidget {
  final Variant variant;
  final bool isSelected;
  final VoidCallback onTap;
  final int storeId;

  const VariantCardItem({
    super.key,
    required this.variant,
    required this.isSelected,
    required this.onTap,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 1. PEGA A INSTÂNCIA DO CUBIT PRINCIPAL
    final storesManagerCubit = context.read<StoresManagerCubit>();
    // ✅ 2. CHAMA O MÉTODO AUXILIAR PARA OBTER O TEXTO
    final linkedProductsText = storesManagerCubit.getPreviewForVariant(variant);

    return Opacity(
      opacity: variant.available ? 1.0 : 0.6,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFFEB0033) // Cor do iFood
                : const Color(0xFFEBEBEB), // Cinza claro
            width: isSelected ? 2 : 1,
          ),
        ),
        color: isSelected
            ? const Color(0xFFFFEBEF) // Rosa claro do iFood
            : Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Checkbox (código continua o mesmo)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFEB0033) // Cor do iFood
                          : const Color(0xFFA3A3A3), // Cinza
                      width: 2,
                    ),
                    color: isSelected
                        ? const Color(0xFFEB0033) // Cor do iFood
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                    Icons.check,
                    size: 18,
                    color: Colors.white,
                  )
                      : null,
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.fastfood_outlined,
                  color: Color(0xFF666666),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        variant.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF151515),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // ✅ 3. USA A STRING GERADA PELO CUBIT
                      Text(
                        linkedProductsText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // ✅ 4. BOTÃO DE OPÇÕES COM NAVEGAÇÃO
                IconButton(
                  tooltip: 'Editar grupo',
                  onPressed: () {
                    context.goNamed(
                      'variant-edit',
                      pathParameters: {
                        'storeId': storeId.toString(),
                        'variantId': variant.id!.toString(),
                      },
                      extra: variant,
                    );
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}