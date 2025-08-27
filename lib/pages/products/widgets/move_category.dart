import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/store_manager_cubit.dart';
import '../../../models/category.dart';
class MoveToCategoryDialog extends StatefulWidget {
  final List<Category> allCategories;
  final List<int> selectedProductIds;

  const MoveToCategoryDialog({
    super.key,
    required this.allCategories,
    required this.selectedProductIds,
  });

  @override
  State<MoveToCategoryDialog> createState() => _MoveToCategoryDialogState();
}

class _MoveToCategoryDialogState extends State<MoveToCategoryDialog> {
  Category? _chosenCategory;

  void _confirmMove() {
    if (_chosenCategory == null) return;

    // Chama o novo método do Cubit
    context.read<StoresManagerCubit>().moveProductsToCategory(
      productIds: widget.selectedProductIds,
      targetCategoryId: _chosenCategory!.id!,
    );

    Navigator.of(context).pop(); // Fecha o dialog
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mover produtos para categoria'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selecione a categoria de destino para os ${widget.selectedProductIds.length} produtos selecionados:'),
          const SizedBox(height: 16),
          DropdownButtonFormField<Category>(
            value: _chosenCategory,
            hint: const Text('Escolha uma categoria'),
            isExpanded: true,
            items: widget.allCategories
                .map((cat) =>
                DropdownMenuItem(value: cat, child: Text(cat.name)))
                .toList(),
            onChanged: (val) => setState(() => _chosenCategory = val),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar')),
        FilledButton(
          onPressed: _chosenCategory != null ? _confirmMove : null,
          child: const Text('Mover Produtos'),
        ),
      ],
    );
  }
}

