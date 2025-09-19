import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/product.dart';

import '../../../widgets/app_image_manager.dart';

class FlavorDetailsTab extends StatelessWidget {
  final Product product;
  final ValueChanged<Product> onUpdate;

  const FlavorDetailsTab({super.key, required this.product, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalhes', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Preencha todos os detalhes sobre o novo item do seu cardápio.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Campo Nome do Sabor
          TextFormField(
            initialValue: product.name,
            decoration: const InputDecoration(
              labelText: 'Nome do Sabor',
              hintText: 'Ex: Pizza de Frango com Catupiry',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => onUpdate(product.copyWith(name: value)),
          ),
          const SizedBox(height: 24),

          // Campo Descrição
          TextFormField(
            initialValue: product.description,
            decoration: const InputDecoration(
              labelText: 'Descrição (ingredientes)',
              hintText: 'Ex: Molho de tomate, mussarela, frango desfiado...',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            onChanged: (value) => onUpdate(product.copyWith(description: value)),
          ),
          const SizedBox(height: 24),

          // Uploader de Imagem

          // ✅ SUBSTITUA O _buildImageUploader PELO AppImageManager
          AppImageManager(
            title: 'Imagens do Sabor',
            images: product.images,
            onChanged: (newImages) {
              // Chama o callback 'onUpdate' com a nova lista de imagens
              onUpdate(product.copyWith(images: newImages));
            },
          ),

        ],
      ),
    );
  }


}