import 'package:flutter/material.dart';

import '../../../models/product_variant_link.dart';
import '../../../models/variant.dart';
import '../../../models/variant_option.dart';



class VariantLinkCard extends StatelessWidget {
  final ProductVariantLink link;

  const VariantLinkCard({super.key, required this.link});

  // Helper para formatar o nome do Enum
  String _formatVariantType(VariantType type) {
    switch(type) {
      case VariantType.INGREDIENTS: return "Ingredientes";
      case VariantType.SPECIFICATIONS: return "Especificações";
      case VariantType.CROSS_SELL: return "Venda Cruzada";
      default: return "Outro";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1, margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: _buildCollapsedHeader(),
        trailing: const SizedBox.shrink(),
        children: [_buildExpandedContent()],
      ),
    );
  }

  Widget _buildCollapsedHeader() {
    // ✅ Usa os dados de 'link' e 'link.variant'
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Row(
            children: [
              Icon(Icons.category_outlined, color: Colors.blue[800], size: 14),
              const SizedBox(width: 4),
              Text(_formatVariantType(link.variant.type), style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(link.variant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 2),
              Text("Contém ${link.variant.options.length} complementos", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Tooltip(message: "Pausar grupo", child: IconButton(onPressed: () {}, icon: Icon(Icons.pause_circle_outline, color: Colors.grey[600]))),
            Tooltip(message: "Remover grupo", child: IconButton(onPressed: () {}, icon: Icon(Icons.delete_outline, color: Colors.grey[600]))),
          ],
        )
      ],
    );
  }

  Widget _buildExpandedContent() {
    // ✅ Usa as regras de 'link'
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown("Este grupo é:", link.isRequired ? "Obrigatório" : "Opcional"),
              ),
              const SizedBox(width: 16),
              _buildQuantityStepper("Qtd. Mínima", link.minSelectedOptions.toString()),
              const SizedBox(width: 16),
              _buildQuantityStepper("Qtd. Máxima", link.maxSelectedOptions.toString()),
            ],
          ),
          const SizedBox(height: 24),
          _buildComplementTable(),
        ],
      ),
    );
  }
// Outros widgets de helper que não foram definidos no seu código, adicionei versões simplificadas aqui.
  Widget _buildDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityStepper(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.remove, color: Colors.grey.shade400, size: 20),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Icon(Icons.add, color: Colors.deepPurple, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  //... Os outros métodos como _buildQuantityStepper usam os dados de `link`


  Widget _buildComplementTable() {
    // ✅ Itera sobre 'link.variant.options'
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            SizedBox(width: 40),
            Expanded(flex: 3, child: Text("Complemento", style: TextStyle(color: Colors.grey, fontSize: 12))),
            Expanded(flex: 2, child: Text("Preço", style: TextStyle(color: Colors.grey, fontSize: 12))),
            SizedBox(width: 80),
          ],
        ),
        const Divider(),
        ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: link.variant.options.length,
          itemBuilder: (context, index) {
            final option = link.variant.options[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.drag_indicator, color: Colors.grey),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: option.imagePath != null && option.imagePath!.isNotEmpty
                        ? Image.network(option.imagePath!, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported))
                        : Container(width: 40, height: 40, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: Text(option.resolvedName, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Expanded(flex: 2, child: Text("R\$ ${(option.resolvedPrice / 100).toStringAsFixed(2)}")),
                  SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.pause, size: 20, color: Colors.grey)),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey)),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        )
      ],
    );
  }
}

