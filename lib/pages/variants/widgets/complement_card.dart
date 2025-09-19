import 'package:flutter/material.dart';
import 'package:brasil_fields/brasil_fields.dart';
import '../../../models/variant_option.dart';

class ComplementCard extends StatelessWidget {
  final VariantOption option;

  const ComplementCard({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    final priceString = UtilBrasilFields.obterReal(option.resolvedPrice / 100);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do card
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagem do complemento
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: option.imagePath != null && option.imagePath!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      option.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.fastfood, color: Color(0xFFE0E0E0), size: 32),
                    ),
                  )
                      : const Icon(Icons.fastfood, color: Color(0xFFE0E0E0), size: 32),
                ),

                const SizedBox(width: 16),

                // Nome do complemento e informações
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.resolvedName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF151515),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Preço
                      Row(
                        children: [
                          Text(
                            priceString,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF151515),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Menu de opções
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF666666)),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Color(0xFF666666)),
                          SizedBox(width: 8),
                          Text('Editar', style: TextStyle(color: Color(0xFF151515))),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Color(0xFFEB0033)),
                          SizedBox(width: 8),
                          Text('Excluir', style: TextStyle(color: Color(0xFFEB0033))),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      // TODO: Implementar edição
                    } else if (value == 'delete') {
                      // TODO: Implementar exclusão
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEBEBEB)),

            // Informações adicionais
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoItem(
                    title: 'Código PDV',
                    value: option.pos_code?.isNotEmpty == true ? option.pos_code! : '-',
                  ),
                  _InfoItem(
                    title: 'Descrição',
                    value: option.description?.isNotEmpty == true ? option.description! : 'Sem descrição',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const _InfoItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF151515),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}