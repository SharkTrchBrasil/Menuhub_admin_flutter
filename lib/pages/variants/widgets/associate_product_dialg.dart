import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/minimal_product.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

import '../../../core/di.dart';

class AssociateProductsDialog extends StatefulWidget {
  final int storeId;
  final int variantId;
  final VoidCallback? onSaved;

  const AssociateProductsDialog({
    super.key,
    required this.storeId,
    required this.variantId,
    this.onSaved,
  });

  @override
  State<AssociateProductsDialog> createState() => _AssociateProductsDialogState();
}

class _AssociateProductsDialogState extends State<AssociateProductsDialog> {
  final productRepo = getIt<ProductRepository>();

  List<MinimalProduct> allProducts = [];
  Set<int> selectedProductIds = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    try {
      // Busca todos os produtos da loja
      final response = await productRepo.getMinimalProducts(widget.storeId);
      // Busca os produtos já associados a esta variante
      final selected = await productRepo.getProductsLinkedToVariant(widget.storeId, widget.variantId);

      setState(() {
        allProducts = response.fold((l) => [], (r) => r);

        selectedProductIds = selected.toSet();
        loading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar produtos: $e');
      setState(() => loading = false);
    }
  }

  Future<void> toggleProduct(int productId, bool selected) async {
    setState(() {
      if (selected) {
        selectedProductIds.add(productId);
      } else {
        selectedProductIds.remove(productId);
      }
    });

    await productRepo.saveVariantsForProduct(
      widget.storeId,
      productId,
      selected ? [widget.variantId] : [],
    );

    if (widget.onSaved != null) widget.onSaved!();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Associar produtos'),
      content: SizedBox(
        width: 500,
        height: 600,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          itemCount: allProducts.length,
          itemBuilder: (context, index) {
            final product = allProducts[index];
            final selected = selectedProductIds.contains(product.id);
            return CheckboxListTile(
              title: Text(product.name),
              value: selected,
              onChanged: (v) => toggleProduct(product.id!, v!),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}
