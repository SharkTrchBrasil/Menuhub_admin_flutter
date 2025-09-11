import 'package:flutter/material.dart';

import '../../../models/product.dart';


class ProductCardDesktop extends StatelessWidget {

  final Product product;
  final bool isSelected;
  final VoidCallback onTap;
  final int storeId;



  const ProductCardDesktop({super.key, required this.product, required this.isSelected, required this.onTap, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabeçalho da tabela
          const TableHeader(),
          // Linhas da tabela
          Expanded(
            child: ListView(
              children: const [
                ProductTableRow(
                  productName: '2 Geladinhos Gourmet feitos com Geleia de Morango caseira, preparada artesanalme',
                  description: 'Bife acebolado',
                  classification: 'Item principal',
                  availableIn: 'Bebidas',
                  status: ProductStatus.categoryPaused,
                  imageUrl: 'https://static-images.ifood.com.br/pratos/3900c306-26fe-4d16-acac-1b57791c6dda/202507272200_8IIB_i.jpg',
                ),
                ProductTableRow(
                  productName: 'Bolo Cac Milho com Coco',
                  description: 'Compra por peso',
                  classification: 'Item principal',
                  availableIn: 'Doces',
                  status: ProductStatus.complementWithoutPrice,
                  imageUrl: 'https://static-images.ifood.com.br/pratos/820af392-002c-47b1-bfae-d7ef31743c7f/202204181221_dzhse5mipfn.jpg',
                ),
                ProductTableRow(
                  productName: 'Coca-Cola',
                  description: '',
                  classification: 'Item principal',
                  availableIn: 'Açais, Bebidas + 1',
                  status: ProductStatus.promotion,
                  imageUrl: 'https://static-images.ifood.com.br/pratos/820af392-002c-47b1-bfae-d7ef31743c7f/202410251738_gacxmhpa7dk.jpeg',
                ),
                ProductTableRow(
                  productName: 'Hambuerguer',
                  description: 'Produto pausado',
                  classification: 'Item principal',
                  availableIn: 'Bebidas',
                  status: ProductStatus.outOfStock,
                  imageUrl: 'https://static-images.ifood.com.br/pratos/3900c306-26fe-4d16-acac-1b57791c6dda/202507311404_3F6E_i.jpg',
                ),
                ProductTableRow(
                  productName: 'Top Burgão',
                  description: 'File, Cebola, Pão, Alface',
                  classification: 'Item principal',
                  availableIn: 'Hamburguers (1)',
                  status: ProductStatus.normal,
                  imageUrl: 'https://static-images.ifood.com.br/pratos/3900c306-26fe-4d16-acac-1b57791c6dda/202507272201_L180_i.jpg',
                ),
              ],
            ),
          ),
          // Rodapé da tabela
          const TableFooter(),
        ],
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  const TableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBEBEB))),
      ),
      child: const Row(
        children: [
          SizedBox(width: 60, child: _HeaderCheckbox()),
          SizedBox(width: 100, child: Text('Imagem', style: TextStyle(fontSize: 14, color: Colors.grey))),
          Expanded(flex: 3, child: Text('Produto', style: TextStyle(fontSize: 14, color: Colors.grey))),
          Expanded(flex: 1, child: Text('Classificação', style: TextStyle(fontSize: 14, color: Colors.grey))),
          Expanded(flex: 1, child: Text('Disponível em', style: TextStyle(fontSize: 14, color: Colors.grey))),
          SizedBox(width: 120, child: Text('Ações', style: TextStyle(fontSize: 14, color: Colors.grey))),
        ],
      ),
    );
  }
}

class _HeaderCheckbox extends StatelessWidget {
  const _HeaderCheckbox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Checkbox(
        value: false,
        onChanged: (value) {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

enum ProductStatus {
  normal,
  categoryPaused,
  complementWithoutPrice,
  outOfStock,
  promotion
}

class ProductTableRow extends StatelessWidget {
  final String productName;
  final String description;
  final String classification;
  final String availableIn;
  final ProductStatus status;
  final String imageUrl;

  const ProductTableRow({
    super.key,
    required this.productName,
    required this.description,
    required this.classification,
    required this.availableIn,
    required this.status,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: status == ProductStatus.outOfStock || status == ProductStatus.categoryPaused
            ? const Color(0xFFFFF8EB)
            : Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFEBEBEB))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          SizedBox(width: 60, child: _ProductCheckbox()),
          // Imagem
          SizedBox(width: 100, child: _ProductImage(imageUrl: imageUrl)),
          // Informações do produto
          Expanded(
            flex: 3,
            child: _ProductInfo(
              productName: productName,
              description: description,
              status: status,
            ),
          ),
          // Classificação
          Expanded(
            flex: 1,
            child: Text(
              classification,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          // Disponível em
          Expanded(
            flex: 1,
            child: Text(
              availableIn,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          // Ações
          SizedBox(width: 120, child: _ProductActions(status: status)),
        ],
      ),
    );
  }
}

class _ProductCheckbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Checkbox(
        value: false,
        onChanged: (value) {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: const Center(
                child: Text(
                  'Alterar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final String productName;
  final String description;
  final ProductStatus status;

  const _ProductInfo({
    required this.productName,
    required this.description,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status indicator
        if (status != ProductStatus.normal && status != ProductStatus.promotion)
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.info_outline,
                  color: _getStatusColor(status),
                  size: 12,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusText(status),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        if (status != ProductStatus.normal && status != ProductStatus.promotion)
          const SizedBox(height: 4),
        // Nome do produto
        Text(
          productName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // Descrição
        if (description.isNotEmpty) const SizedBox(height: 4),
        if (description.isNotEmpty)
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(ProductStatus status) {
    switch (status) {
      case ProductStatus.categoryPaused:
      case ProductStatus.outOfStock:
        return const Color(0xFFE7A74E);
      case ProductStatus.complementWithoutPrice:
        return const Color(0xFFEA1D2C);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(ProductStatus status) {
    switch (status) {
      case ProductStatus.categoryPaused:
        return 'Categoria pausada';
      case ProductStatus.complementWithoutPrice:
        return 'Complemento sem preço';
      case ProductStatus.outOfStock:
        return 'Produto sem estoque';
      default:
        return '';
    }
  }
}

class _ProductActions extends StatelessWidget {
  final ProductStatus status;

  const _ProductActions({required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Botão Pausar
        Tooltip(
          message: 'Pausar em tudo',
          child: IconButton(
            icon: const Icon(Icons.pause, size: 20),
            color: status == ProductStatus.outOfStock || status == ProductStatus.categoryPaused
                ? const Color(0xFFEA1D2C).withOpacity(0.5)
                : const Color(0xFFEA1D2C),
            onPressed: status == ProductStatus.outOfStock || status == ProductStatus.categoryPaused
                ? null
                : () {},
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        // Botão Ativar
        Tooltip(
          message: 'Ativar em tudo',
          child: IconButton(
            icon: const Icon(Icons.play_arrow, size: 20),
            color: status == ProductStatus.outOfStock || status == ProductStatus.categoryPaused
                ? const Color(0xFFEA1D2C)
                : const Color(0xFFEA1D2C).withOpacity(0.5),
            onPressed: status == ProductStatus.outOfStock || status == ProductStatus.categoryPaused
                ? () {}
                : null,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}

class TableFooter extends StatelessWidget {
  const TableFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEBEBEB))),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Exibindo 5 de 19',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          // Aqui viriam os controles de paginação
        ],
      ),
    );
  }
}