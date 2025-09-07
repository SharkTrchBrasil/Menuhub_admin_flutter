import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/product.dart';

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
          _buildImageUploader(context),
        ],
      ),
    );
  }

  Widget _buildImageUploader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Imagem do item', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            // TODO: Implementar a lógica de seleção de imagem (Image Picker)
            // Ao selecionar, chame onUpdate(product.copyWith(image: novaImagem))
          },
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, ),
            ),
            child: product.image?.url != null
                ? Image.network(product.image!.url!, fit: BoxFit.cover)
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade600, size: 40),
                const SizedBox(height: 8),
                const Text('Escolher imagem'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}