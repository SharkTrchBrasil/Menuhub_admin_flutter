import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_image.dart';

import '../../../models/products/product.dart';
import '../cubit/bulk_category_cubit.dart';
import '../cubit/bulk_category_state.dart';

// =========================================================================
// ✅ PASSO 1: CRIAR O MIXIN COM TODA A LÓGICA DE ESTADO
// =========================================================================
// Em: steps_bulk_category/step2.dart

// =========================================================================
// ✅ MIXIN COM A LÓGICA FINAL E CORRIGIDA
// =========================================================================
mixin _ProductPriceLogicMixin<T extends StatefulWidget> on State<T> {
  late final TextEditingController _priceController;
  late final TextEditingController _promoPriceController;
  late final TextEditingController _pdvController;
  bool _isPromoActive = false;

  Product get product;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  // A lógica de inicialização estava correta, não precisa de mudanças.
  void _initializeControllers() {
    final cubitState = context.read<BulkAddToCategoryCubit>().state;
    final targetCategory = cubitState.targetCategory!;
    try {
      final existingLink = product.categoryLinks.firstWhere(
            (link) => link.categoryId == targetCategory.id,
      );
      _priceController = TextEditingController(text: UtilBrasilFields.obterReal(existingLink.price / 100));
      _promoPriceController = TextEditingController(
          text: existingLink.promotionalPrice != null
              ? UtilBrasilFields.obterReal(existingLink.promotionalPrice! / 100)
              : '');
      _pdvController = TextEditingController(text: existingLink.posCode ?? '');
      _isPromoActive = existingLink.isOnPromotion;
    } catch (e) {
      _priceController = TextEditingController(text: UtilBrasilFields.obterReal((product.price ?? 0) / 100));
      _promoPriceController = TextEditingController();
      _pdvController = TextEditingController();
      _isPromoActive = false;
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _promoPriceController.dispose();
    _pdvController.dispose();
    super.dispose();
  }

  // ✅ CORREÇÃO: Passa o 'product.id' nulável para o Cubit
  void _togglePromotion() {
    final cubit = context.read<BulkAddToCategoryCubit>();
    setState(() {
      _isPromoActive = !_isPromoActive;
      cubit.togglePromotionForProduct(product.id, _isPromoActive);

      if (!_isPromoActive) {
        _promoPriceController.clear();
        cubit.updatePromotionalPriceForProduct(product.id, null);
      }
    });
  }

  // --- Widgets de campo de texto com 'onChanged' corrigido ---

  Widget buildPriceField() {
    final cubit = context.read<BulkAddToCategoryCubit>();
    return TextFormField(
      controller: _priceController,
      decoration: InputDecoration(
        labelText: 'Preço',
        prefixText: 'R\$ ',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        suffixIcon: IconButton(
          icon: Icon(Icons.discount,
              color: _isPromoActive ? Theme.of(context).primaryColor : Colors.grey.shade600),
          onPressed: _togglePromotion,
          tooltip: "Aplicar desconto",
        ),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter()],
      onChanged: (value) {
        // ✅ CORREÇÃO: Lida com a string vazia e passa o 'product.id' nulável
        final priceInCents = value.isEmpty
            ? 0
            : (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt();
        cubit.updatePriceForProduct(product.id, priceInCents);
      },
    );
  }

  Widget buildPromoPriceField() {
    final cubit = context.read<BulkAddToCategoryCubit>();
    return TextFormField(
      controller: _promoPriceController,
      decoration: InputDecoration(
        labelText: 'Preço Promocional',
        prefixText: 'R\$ ',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      style: TextStyle(color: Theme.of(context).primaryColor),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter()],
      onChanged: (value) {
        // ✅ CORREÇÃO: Lida com a string vazia e passa o 'product.id' nulável
        final promoPriceInCents = value.isEmpty
            ? null
            : (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt();
        cubit.updatePromotionalPriceForProduct(product.id, promoPriceInCents);
      },
    );
  }

  Widget buildPdvField() {
    final cubit = context.read<BulkAddToCategoryCubit>();
    return TextFormField(
      controller: _pdvController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: "Código PDV",
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
      ),
      // ✅ CORREÇÃO: Passa o 'product.id' nulável
      onChanged: (value) => cubit.updatePosCodeForProduct(product.id, value),
    );
  }
}





// =========================================================================
// WIDGET PRINCIPAL DA TELA (SEM MUDANÇAS SIGNIFICATIVAS)
// =========================================================================
class Step2SetPrices extends StatelessWidget {
  const Step2SetPrices({super.key});

  @override
  Widget build(BuildContext context) {
    // ... (build principal sem alterações)
    final isMobile = MediaQuery.of(context).size.width < 768;

    return BlocBuilder<BulkAddToCategoryCubit, BulkAddToCategoryState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Text(
                "Defina preço e código PDV para cada produto",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            if (!isMobile) _buildTableHeader(),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: state.selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = state.selectedProducts[index];
                  // Passa a key para garantir a reconstrução correta
                  return isMobile
                      ? _MobileProductPriceCard(key: ValueKey(product.id), product: product)
                      : _DesktopProductPriceRow(key: ValueKey(product.id), product: product);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: Colors.grey[100],
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text("Produto", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text("Preço", style: TextStyle(fontWeight: FontWeight.bold))),
          // Adicionado espaço para o preço promocional no cabeçalho
          Expanded(flex: 2, child: SizedBox()),
          Expanded(flex: 2, child: Text("Código PDV", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

// =========================================================================
// ✅ PASSO 2: APLICAR O MIXIN NOS WIDGETS DE UI
// =========================================================================

// WIDGET PARA DESKTOP
class _DesktopProductPriceRow extends StatefulWidget {
  final Product product;
  const _DesktopProductPriceRow({super.key, required this.product});

  @override
  State<_DesktopProductPriceRow> createState() => _DesktopProductPriceRowState();
}

class _DesktopProductPriceRowState extends State<_DesktopProductPriceRow>
    with _ProductPriceLogicMixin<_DesktopProductPriceRow> {
  // A Mágica: Toda a lógica de initState, dispose, controllers e toggle já existe!
  @override
  Product get product => widget.product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(product.name, overflow: TextOverflow.ellipsis),
          ),
          Expanded(flex: 2, child: buildPriceField()),
          const SizedBox(width: 16),
          // Mostra o campo de promoção se estiver ativo
          if (_isPromoActive)
            Expanded(flex: 2, child: buildPromoPriceField())
          else // Adiciona um espaço vazio para manter o alinhamento
            const Expanded(flex: 2, child: SizedBox()),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: buildPdvField()),
        ],
      ),
    );
  }
}

// WIDGET PARA MOBILE
class _MobileProductPriceCard extends StatefulWidget {
  final Product product;
  const _MobileProductPriceCard({super.key, required this.product});

  @override
  State<_MobileProductPriceCard> createState() => _MobileProductPriceCardState();
}

class _MobileProductPriceCardState extends State<_MobileProductPriceCard>
    with _ProductPriceLogicMixin<_MobileProductPriceCard> {
  // Novamente, toda a lógica já vem do Mixin!
  @override
  Product get product => widget.product;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductInfo(),
          const SizedBox(height: 16),
          buildPriceField(),
          // Mostra o campo de promoção se estiver ativo
          if (_isPromoActive) ...[
            const SizedBox(height: 12),
            buildPromoPriceField(),
          ],
          const SizedBox(height: 12),
          buildPdvField(),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProductImage(imageUrl: product.images.first.url),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              if (product.description != null && product.description!.isNotEmpty)
                Text(
                  product.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}