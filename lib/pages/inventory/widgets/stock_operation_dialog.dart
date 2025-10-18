// stock_operation_dialog.dart
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/enums/inventory_stock.dart';
import '../../../models/products/product.dart';

class StockOperationDialog extends StatefulWidget {
  final String title;
  final List<Product> products;
  final StockOperationType operationType;
  final void Function(Product product, int quantity, int? cost) onConfirm;

  const StockOperationDialog({
    required this.title,
    required this.products,
    required this.operationType,
    required this.onConfirm,
  });

  @override
  State<StockOperationDialog> createState() => StockOperationDialogState();
}

class StockOperationDialogState extends State<StockOperationDialog> {
  final _formKey = GlobalKey<FormState>();
  Product? _selectedProduct;
  String _searchTerm = '';

  final _quantityController = TextEditingController();
  final _costController = TextEditingController();

  List<Product> get _filteredProducts {
    if (_searchTerm.isEmpty) {
      return widget.products;
    }
    return widget.products.where((p) => p.name.toLowerCase().contains(_searchTerm.toLowerCase())).toList();
  }

  void _onConfirm() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.parse(_quantityController.text);
      final cost = widget.operationType == StockOperationType.add ? int.tryParse(_costController.text) : null;

      widget.onConfirm(_selectedProduct!, quantity, cost);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.operationType == StockOperationType.add ? Icons.add_circle_outline : Icons.remove_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Search
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          onChanged: (value) => setState(() => _searchTerm = value),
                          decoration: InputDecoration(
                            hintText: 'Buscar produto...',
                            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Product List
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _filteredProducts.isEmpty
                              ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 48,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhum produto encontrado',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                              : ListView.builder(
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              final isSelected = _selectedProduct?.id == product.id;
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                                  ),
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: Colors.grey[100],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        product.images.first.url ?? '',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.inventory_2_outlined,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected ? Theme.of(context).primaryColor : null,
                                    ),
                                  ),
                                  subtitle: Text(
                                    product.controlStock ? 'Estoque: ${product.stockQuantity ?? 0}' : 'Sem controle',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  )
                                      : null,
                                  onTap: () => setState(() => _selectedProduct = product),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Form
                      if (_selectedProduct != null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                decoration: InputDecoration(
                                  labelText: 'Quantidade',
                                  prefixIcon: Icon(Icons.numbers, color: Colors.grey[500]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Informe a quantidade';
                                  }
                                  final quantity = int.tryParse(value);
                                  if (quantity == null || quantity <= 0) {
                                    return 'Quantidade inválida';
                                  }
                                  if (widget.operationType == StockOperationType.remove) {
                                    final currentStock = _selectedProduct!.stockQuantity ?? 0;
                                    if (quantity > currentStock) {
                                      return 'Quantidade maior que o estoque atual ($currentStock)';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            if (widget.operationType == StockOperationType.add) ...[
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _costController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    CentavosInputFormatter(moeda: true),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: 'Custo Unitário (R\$)',
                                    prefixIcon: Icon(Icons.attach_money, color: Colors.grey[500]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (widget.operationType == StockOperationType.add) {
                                      if (value == null || value.isEmpty) {
                                        return 'Informe o custo';
                                      }
                                      final cost = int.tryParse(value);
                                      if (cost == null || cost <= 0) {
                                        return 'Custo inválido';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: _onConfirm,
                                style: FilledButton.styleFrom(
                                  backgroundColor: widget.operationType == StockOperationType.add ? Colors.green : Colors.orange,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  widget.operationType == StockOperationType.add ? 'Adicionar Entrada' : 'Realizar Baixa',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}