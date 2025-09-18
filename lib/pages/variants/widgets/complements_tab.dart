// Substitua o conteúdo do seu arquivo complements_tab.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/variant_option.dart';

import '../../variants/widgets/variant_option_tile.dart';


class ComplementsTab extends StatefulWidget {
  final List<VariantOption> options;
  final Function(List<VariantOption>) onOptionsChanged;
  final int? variantId;

  const ComplementsTab({
    super.key,
    required this.options,
    required this.onOptionsChanged,
    this.variantId,
  });

  @override
  State<ComplementsTab> createState() => _ComplementsTabState();
}

class _ComplementsTabState extends State<ComplementsTab> {

  void _addComplement() {
    // Cria uma nova opção vazia, pronta para ser preenchida.
    final newOption = VariantOption(
      variantId: widget.variantId,
      name_override: '', // Começa com nome vazio
      price_override: 0, // Começa com preço zero
    );

    final updatedList = [...widget.options, newOption];
    widget.onOptionsChanged(updatedList);
  }

  void _removeComplement(int optionIndex) {
    final updatedList = [...widget.options];
    updatedList.removeAt(optionIndex);
    widget.onOptionsChanged(updatedList);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (código do cabeçalho e busca, sem alterações)
          const SizedBox(height: 16),
          _buildTableHeader(),
          if (widget.options.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                  child: Text('Nenhum complemento adicionado a este grupo.')),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.options.length,
              itemBuilder: (context, index) {

                final option = widget.options[index];
                return VariantOptionTile(
                  key: ValueKey(option.id ?? 'new-$index'),
                  // Chave única para itens novos e existentes
                  option: option,
                 // onRemove: () => _removeComplement(index),
                  onUpdate: (updatedOption) {
                    // final updatedList = [...widget.options];
                    // updatedList[index] = updatedOption;
                    // widget.onOptionsChanged(updatedList);

                  }, index: option.id!,
                  onRemove: (VariantOption optionToRemove) {  },
                );
              },
              onReorder: (oldIndex, newIndex) {
                if (newIndex > oldIndex) newIndex -= 1;
                final updatedList = [...widget.options];
                final item = updatedList.removeAt(oldIndex);
                updatedList.insert(newIndex, item);
                widget.onOptionsChanged(updatedList);
              },
            ),
        ],
      ),
    );
  }


  Widget _buildTableHeader() {
    final headerStyle = TextStyle(
        color: Colors.grey.shade600, fontWeight: FontWeight.bold);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40), // Espaço para o drag handle
          SizedBox(width: 75, child: Text('Imagem', style: headerStyle)),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Text('Produto', style: headerStyle)),
          Expanded(flex: 2, child: Text('Canal de venda', style: headerStyle)),
          SizedBox(width: 130,
              child: Text(
                  'Preço', style: headerStyle, textAlign: TextAlign.right)),
          const SizedBox(width: 12),
          SizedBox(width: 130, child: Text('Código PDV', style: headerStyle)),
          const SizedBox(width: 12),
          SizedBox(width: 80,
              child: Text(
                  'Ações', style: headerStyle, textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}