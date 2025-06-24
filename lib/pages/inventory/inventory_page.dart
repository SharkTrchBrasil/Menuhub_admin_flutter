import 'package:flutter/material.dart';






import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_list_controller.dart';
import '../../core/di.dart';
import '../../models/page_status.dart';
import '../../models/product.dart'; // Assuming you have a Product model
import '../../repositories/product_repository.dart'; // Assuming ProductRepository
import '../../widgets/app_availability_dot.dart'; // Assuming AppAvailabilityDot
import '../../widgets/app_counter_form_field.dart'; // Assuming AppCounterFormField
import '../../widgets/app_page_header.dart'; // Assuming AppPageHeader
import '../../widgets/app_page_status_builder.dart'; // Assuming AppPageStatusBuilder
import '../../widgets/app_primary_button.dart'; // Assuming AppPrimaryButton
import '../../widgets/app_table.dart'; // Assuming AppTable and its column types

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key, required this.storeId});

  final int storeId;

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late final AppListController<Product> productsController =
  AppListController<Product>(
    fetch: () => getIt<ProductRepository>().getProducts(widget.storeId),
  );

  // Set to store IDs of selected products for stock management
  Set<int> _selectedProductIds = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    // Listen to changes in the product list to update select all state
    productsController.addListener(_updateSelectAllState);
  }

  @override
  void dispose() {
    productsController.removeListener(_updateSelectAllState);
    super.dispose();
  }

  // Updates the _selectAll checkbox state based on current selections
  void _updateSelectAllState() {

    // if (productsController.status.status == PageStatusEnum.success) {
    //   final allProductIds = productsController.status.data?.map((p) => p.id!).toSet() ?? {};
    //   setState(() {
    //     _selectAll = _selectedProductIds.isNotEmpty && _selectedProductIds.containsAll(allProductIds);
    //   });

  //  }
  }

  // Toggles the selection of a single product
  void _toggleProductSelection(int productId, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedProductIds.add(productId);
      } else {
        _selectedProductIds.remove(productId);
      }
      _updateSelectAllState(); // Update select all checkbox
    });
  }

  // Toggles the selection of all products
  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        // _selectedProductIds = productsController.status.data
        //     ?.map((p) => p.id!)
        //     .toSet() ??
        //     {};
      } else {
        _selectedProductIds.clear();
      }
    });
  }

  // Shows a dialog to get the quantity for stock update
  Future<void> _showStockUpdateDialog(
      BuildContext context, Function(int quantity) onConfirm) async {
    int quantity = 1; // Default quantity

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Quantidade de Estoque'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Insira a quantidade para a operação de estoque:'),
              const SizedBox(height: 16),
              AppCounterFormField(
                initialValue: quantity,
                onChanged: (value) {
                  quantity = value;
                },
                minValue: 1, title: '', maxValue: 1, // Stock quantity should be at least 1
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                onConfirm(quantity);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  // Handles adding stock to selected products
  void _addStock() async {
    if (_selectedProductIds.isEmpty) {
      // You might want to show a message here
      return;
    }

    await _showStockUpdateDialog(context, (quantity) async {
      // Simulate API call to update stock
      print('Adding $quantity to products: $_selectedProductIds');
      // In a real app, you would call your repository here:
      // await getIt<ProductRepository>().updateProductStock(
      //     _selectedProductIds.toList(), quantity, true);

      // --- Mocking the update for demonstration ---
      // Find the products in the current list and update their stock
     // final currentProducts = productsController.status.data;
     //  if (currentProducts != null) {
     //    for (final productId in _selectedProductIds) {
     //      final product = currentProducts.firstWhere((p) => p.id == productId);
     //      // Assuming product has a stock field, e.g., product.stock += quantity;
     //      // For this example, we'll just print, as Product model might not have 'stock'
     //      print('Product ${product.name} stock increased by $quantity');
     //    }
     //  }
      // --- End Mocking ---

      setState(() {
        _selectedProductIds.clear();
        _selectAll = false;
      });
      productsController.refresh(); // Refresh the list to show updated stock
    });
  }

  // Handles removing stock from selected products
  void _removeStock() async {
    if (_selectedProductIds.isEmpty) {
      // You might want to show a message here
      return;
    }

    await _showStockUpdateDialog(context, (quantity) async {
      // Simulate API call to update stock
      print('Removing $quantity from products: $_selectedProductIds');
      // In a real app, you would call your repository here:
      // await getIt<ProductRepository>().updateProductStock(
      //     _selectedProductIds.toList(), quantity, false);

      // --- Mocking the update for demonstration ---
      // final currentProducts = productsController.status.data;
      // if (currentProducts != null) {
      //   for (final productId in _selectedProductIds) {
      //     final product = currentProducts.firstWhere((p) => p.id == productId);
      //     // Assuming product has a stock field, e.g., product.stock -= quantity;
      //     // For this example, we'll just print, as Product model might not have 'stock'
      //     print('Product ${product.name} stock decreased by $quantity');
      //   }
      // }
      // --- End Mocking ---

      setState(() {
        _selectedProductIds.clear();
        _selectAll = false;
      });
      productsController.refresh(); // Refresh the list to show updated stock
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          AppPageHeader(
            title: 'Produtos',
            canPop: false,
            actions: [
              AppPrimaryButton(
                  label: 'Novo produto',
                  onPressed: () {
                    context.go('/stores/${widget.storeId}/products/new');
                  }),
            ],
          ),
          const SizedBox(height: 16), // Spacing below header

          // Stock action buttons, visible only when products are selected
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _selectedProductIds.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppPrimaryButton(
                    label: 'Remover Estoque',
                    onPressed: _removeStock,
                  //  color: Colors.red.shade700, // A distinct color for removal
                  ),
                  const SizedBox(width: 16),
                  AppPrimaryButton(
                    label: 'Adicionar Estoque',
                    onPressed: _addStock,
                  ),
                ],
              ),
            )
                : const SizedBox.shrink(), // Hide when no products are selected
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: productsController,
            builder: (_, __) {
              return AppPageStatusBuilder<List<Product>>(
                tryAgain: productsController.refresh,
                status: productsController.status,
                successBuilder: (products) {
                  return AppTable<Product>(
                    items: products,
                    maxWidth: 800,
                    columns: [
                      // New column for product selection checkbox
                      AppTableColumnWidget(
                        title: '',
                        width: const FixedColumnWidth(48),
                        dataSelector: (product) => Checkbox(
                          value: _selectedProductIds.contains(product.id),
                          onChanged: (bool? selected) {
                            _toggleProductSelection(product.id!, selected);
                          },
                        ),
                      ),
                      AppTableColumnWidget(
                        title: '', // Empty title for the dot column
                        width: const FixedColumnWidth(48),
                        dataSelector: (product) => AppAvailabilityDot(
                          available: product.available,
                        ),
                      ),
                      AppTableColumnImage(
                        title: 'Imagem',
                        width: const FixedColumnWidth(90),
                        dataSelector: (product) => product.image!.url!,
                      ),
                      AppTableColumnString(
                        title: 'Nome',
                        dataSelector: (product) => product.name,
                      ),
                      AppTableColumnString(
                        title: 'Descrição',
                        dataSelector: (product) => product.description,
                      ),
                      AppTableColumnString(
                        title: 'Categoria',
                        dataSelector: (product) => product.category!.name,
                      ),
                      AppTableColumnMoney(
                        title: 'Preço base',
                        dataSelector: (product) => product.basePrice!,
                      ),
                      AppTableColumnWidget(
                        title: 'Ações',
                        width: const FixedColumnWidth(120),
                        dataSelector: (product) => Row(
                          children: [
                            IconButton(
                              onPressed: () => context.go(
                                  '/stores/${widget.storeId}/products/${product.id}'),
                              icon: const Icon(
                                Icons.edit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
