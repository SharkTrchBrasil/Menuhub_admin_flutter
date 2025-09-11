import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';

class ProductCategoriesManager extends StatelessWidget {
  final List<ProductCategoryLink> categoryLinks;
  final VoidCallback onAddCategory;
  final ValueChanged<ProductCategoryLink> onUpdateLink;
  final ValueChanged<ProductCategoryLink> onRemoveLink;
  final ValueChanged<ProductCategoryLink> onTogglePause;

  const ProductCategoriesManager({
    super.key,
    required this.categoryLinks,
    required this.onAddCategory,
    required this.onUpdateLink,
    required this.onRemoveLink,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Disponível em:',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione o produto em uma ou mais categorias e defina suas regras de venda.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          if (isMobile)
            _buildMobileView()
          else
            _buildDesktopView(),

          const SizedBox(height: 16),

          _buildAddCategoryButton(),
        ],
      ),
    );
  }

  Widget _buildDesktopView() {
    return Column(
      children: [
        _buildTableHeader(),
        const Divider(height: 1),
        if (categoryLinks.isEmpty)
          _buildEmptyState()
        else
          ...categoryLinks.map((link) => _CategoryLinkRow(
            key: ValueKey(link.category?.id),
            link: link,
            onUpdate: onUpdateLink,
            onRemove: onRemoveLink,
            onTogglePause: onTogglePause,
          )),
      ],
    );
  }

  Widget _buildMobileView() {
    return Column(
      children: [
        if (categoryLinks.isEmpty)
          _buildEmptyState()
        else
          ...categoryLinks.map((link) => _CategoryLinkCard(
            key: ValueKey(link.category?.id),
            link: link,
            onUpdate: onUpdateLink,
            onRemove: onRemoveLink,
            onTogglePause: onTogglePause,
          )),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.category_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "Este produto precisa estar em pelo menos uma categoria.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCategoryButton() {
    return FilledButton.icon(
      onPressed: onAddCategory,
      icon: const Icon(Icons.add),
      label: const Text("Adicionar categoria"),
      style: FilledButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Widget _buildTableHeader() {
    final headerStyle = TextStyle(
      color: Colors.grey.shade700,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text("CATEGORIA", style: headerStyle)),
          Expanded(flex: 2, child: Text("PREÇO", style: headerStyle)),
          Expanded(flex: 2, child: Text("PROMOÇÃO", style: headerStyle)),
          Expanded(flex: 2, child: Text("CÓDIGO PDV", style: headerStyle)),
          const SizedBox(width: 96),
        ],
      ),
    );
  }
}

class _CategoryLinkRow extends StatelessWidget {
  final ProductCategoryLink link;
  final ValueChanged<ProductCategoryLink> onUpdate;
  final ValueChanged<ProductCategoryLink> onRemove;
  final ValueChanged<ProductCategoryLink> onTogglePause;

  const _CategoryLinkRow({
    super.key,
    required this.link,
    required this.onUpdate,
    required this.onRemove,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.category?.name ?? 'Carregando...',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusChip(),
              ],
            ),
          ),
          _buildPriceField(
            key: ValueKey('price_${link.category?.id}'),
            initialValue: UtilBrasilFields.obterReal(link.price / 100),
            label: 'Preço',
            onChanged: (value) {
              final priceInCents = (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt();
              onUpdate(link.copyWith(price: priceInCents));
            },
          ),
          const SizedBox(width: 12),
          _buildPriceField(
            key: ValueKey('promo_${link.category?.id}'),
            initialValue: link.promotionalPrice != null ? UtilBrasilFields.obterReal(link.promotionalPrice! / 100) : '',
            label: 'Promoção',
            onChanged: (value) {
              final priceInCents = value.isNotEmpty ? (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt() : null;
              onUpdate(link.copyWith(promotionalPrice: priceInCents));
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _buildPdvField(),
          ),
          const SizedBox(width: 12),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Chip(
      label: Text(
        link.isAvailable ? 'Ativo' : 'Pausado',
        style: TextStyle(
          fontSize: 12,
          color: link.isAvailable ? Colors.green.shade800 : Colors.orange.shade800,
        ),
      ),
      backgroundColor: link.isAvailable ? Colors.green.shade50 : Colors.orange.shade50,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildPriceField({Key? key, required String initialValue, required String label, required ValueChanged<String> onChanged}) {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              key: key,
              initialValue: initialValue,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(fontWeight: FontWeight.w500),
              ),
              style: const TextStyle(fontSize: 14),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter()],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdvField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cód. PDV',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            key: ValueKey('pdv_${link.category?.id}'),
            initialValue: link.posCode,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              hintText: 'Ex: XGAHTQ',
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: (value) => onUpdate(link.copyWith(posCode: value)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: 96,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              link.isAvailable ? Icons.pause : Icons.play_arrow,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: link.isAvailable ? Colors.orange.shade50 : Colors.green.shade50,
              foregroundColor: link.isAvailable ? Colors.orange : Colors.green,
            ),
            onPressed: () => onTogglePause(link),
            tooltip: link.isAvailable ? 'Pausar' : 'Ativar',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
            ),
            onPressed: () => onRemove(link),
            tooltip: 'Remover',
          ),
        ],
      ),
    );
  }
}

class _CategoryLinkCard extends StatelessWidget {
  final ProductCategoryLink link;
  final ValueChanged<ProductCategoryLink> onUpdate;
  final ValueChanged<ProductCategoryLink> onRemove;
  final ValueChanged<ProductCategoryLink> onTogglePause;

  const _CategoryLinkCard({
    super.key,
    required this.link,
    required this.onUpdate,
    required this.onRemove,
    required this.onTogglePause,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com título e ações
          _buildCardHeader(),

          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status
             //   _buildStatusRow(),
              //  const SizedBox(height: 20),

                // Campos de preço
                _buildPriceFields(),
                const SizedBox(height: 16),

                // Campo PDV
                _buildPdvField(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
       // color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              link.category?.name ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  link.isAvailable ? Icons.pause : Icons.play_arrow,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: link.isAvailable ? Colors.orange.shade50 : Colors.green.shade50,
                  foregroundColor: link.isAvailable ? Colors.orange : Colors.green,
                ),
                onPressed: () => onTogglePause(link),
                tooltip: link.isAvailable ? 'Pausar' : 'Ativar',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                ),
                onPressed: () => onRemove(link),
                tooltip: 'Remover',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        Icon(
          link.isAvailable ? Icons.check_circle : Icons.pause_circle,
          color: link.isAvailable ? Colors.green : Colors.orange,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          link.isAvailable ? 'Disponível nesta categoria' : 'Pausado nesta categoria',
          style: TextStyle(
            color: link.isAvailable ? Colors.green.shade800 : Colors.orange.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceFields() {
    return Row(
      children: [
        Expanded(
          child: _buildPriceField(
            key: ValueKey('price_mobile_${link.category?.id}'),
            initialValue: UtilBrasilFields.obterReal(link.price / 100),
            label: 'Preço normal',
            onChanged: (value) {
              final priceInCents = (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt();
              onUpdate(link.copyWith(price: priceInCents));
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPriceField(
            key: ValueKey('promo_mobile_${link.category?.id}'),
            initialValue: link.promotionalPrice != null ? UtilBrasilFields.obterReal(link.promotionalPrice! / 100) : '',
            label: 'Preço promocional',
            onChanged: (value) {
              final priceInCents = value.isNotEmpty ? (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt() : null;
              onUpdate(link.copyWith(promotionalPrice: priceInCents));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField({Key? key, required String initialValue, required String label, required ValueChanged<String> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            key: key,
            initialValue: initialValue,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              prefixText: 'R\$ ',
              prefixStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            style: const TextStyle(fontSize: 15),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter()],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPdvField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Código PDV (Opcional)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            key: ValueKey('pdv_mobile_${link.category?.id}'),
            initialValue: link.posCode,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              hintText: 'Ex: XGAHTQ',
            ),
            style: const TextStyle(fontSize: 15),
            onChanged: (value) => onUpdate(link.copyWith(posCode: value)),
          ),
        ),
      ],
    );
  }
}