import 'package:easy_localization/easy_localization.dart'; // Importe se você usa internacionalização
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/widgets/app_availability_dot.dart';
import '../../../services/dialog_service.dart';
import '../../../core/di.dart'; // Para acessar o ProductRepository
import '../../../repositories/product_repository.dart'; // Para a lógica de exclusão

class VariantOptionListItem extends StatefulWidget {
  const VariantOptionListItem({
    super.key,
    required this.option,
    required this.storeId,
    required this.variantId,
    required this.onSaved,
  });

  final int storeId;
  final int variantId;
  final VariantOption option;
  final void Function()? onSaved;

  @override
  State<VariantOptionListItem> createState() => _VariantOptionListItemState();
}

class _VariantOptionListItemState extends State<VariantOptionListItem> {
  VariantOption get option => widget.option;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Ajustado o padding vertical para 4.0
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Ajustado o padding vertical
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
          border: Border.all(
            color: Colors.grey.shade200, // Adiciona uma borda sutil
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAvailabilityDot(available: option.available),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.name,
                    style: const TextStyle(
                      fontSize: 15, // Levemente maior
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (option.description != null && option.description!.isNotEmpty) // Verifica se não é nulo e não está vazio
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        option.description!, // Agora é seguro usar !
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16), // Reduzido o espaço para o preço/botão

            option.isFree
                ? Text(
              'Grátis'.tr(),
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500, // Mais forte
                fontSize: 13,
              ),
            )
                : Text(
              NumberFormat.simpleCurrency(locale: 'pt_BR')
                  .format((option.price ?? 0) / 100),
              style: const TextStyle(
                fontSize: 14, // Levemente maior
                fontWeight: FontWeight.w600, // Mais forte
              ),
            ),
            const SizedBox(width: 8), // Espaço antes do menu de 3 pontinhos

            // --- PopupMenuButton para editar/excluir ---
            PopupMenuButton<String>(
              tooltip: '', // Desabilita o tooltip padrão para não conflitar
              onSelected: (value) {
                if (value == 'edit') {
                  _editOption();
                } else if (value == 'delete') {
                  _deleteOption();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 18),
                      const SizedBox(width: 8),
                      Text('Editar opção'.tr()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text('Excluir opção'.tr()),
                    ],
                  ),
                ),
              ],
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Métodos de Ação ---

  Future<void> _editOption() async {
    await DialogService.showVariantsOptionsDialog(
      context,
      widget.storeId,
      widget.variantId,
      id: widget.option.id,
      onSaved: widget.onSaved,
    );
  }

  Future<void> _deleteOption() async {
    final confirmed = await DialogService.showConfirmationDialog(
      context,
      title: 'Confirmar Exclusão'.tr(),
      content:
      'Tem certeza que deseja excluir a opção "${option.name}"?'.tr(),
    );

    if (confirmed == true) {
      if (!mounted) return;
      // Você pode adicionar um indicador de carregamento aqui se desejar
      // setState(() => _isLoading = true);

      try {
        await getIt<ProductRepository>().deleteVariantOption(
          widget.storeId,
          widget.variantId,
          option.id!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opção "${option.name}" excluída com sucesso.'.tr()),
            ),
          );
        }
        widget.onSaved?.call(); // Chama o callback para atualizar a lista pai
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir opção: ${e.toString()}'.tr()),
            ),
          );
        }
      } finally {
        // if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}