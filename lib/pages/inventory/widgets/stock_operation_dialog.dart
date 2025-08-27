import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../../../core/enums/inventory_stock.dart';
import '../../../models/product.dart';




class StockOperationDialog extends StatefulWidget {
  final String title;
  final List<Product> products;
  final StockOperationType operationType;
  final void Function(Product product, int quantity, double? cost) onConfirm;

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
      final cost = widget.operationType == StockOperationType.add ? double.tryParse(_costController.text) : null;

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
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400, // Largura fixa para o dialog
        child: _selectedProduct == null ? _buildProductSelector() : _buildForm(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        if (_selectedProduct != null)
          ElevatedButton(
            onPressed: _onConfirm,
            child: const Text('Confirmar'),
          ),
      ],
    );
  }

  // Parte 1: Selecionar o Produto
  Widget _buildProductSelector() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          onChanged: (value) => setState(() => _searchTerm = value),
          decoration: const InputDecoration(
            labelText: 'Buscar produto...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _filteredProducts.isEmpty
              ? const Center(child: Text('Nenhum produto encontrado.'))
              : ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('Estoque atual: ${product.stockQuantity ?? 0}'),
                onTap: () => setState(() => _selectedProduct = product),
              );
            },
          ),
        ),
      ],
    );
  }

  // Parte 2: Preencher os detalhes da operação
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_selectedProduct!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Estoque atual: ${_selectedProduct!.stockQuantity ?? 0}'),
            trailing: TextButton(
              child: const Text('Trocar'),
              onPressed: () => setState(() => _selectedProduct = null),
            ),
          ),
          const Divider(),
          const SizedBox(height: 16),
          TextFormField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: 'Quantidade',
              border: const OutlineInputBorder(),
              suffixText: 'unidades',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Campo obrigatório';
              }
              final quantity = int.parse(value);
              if (quantity <= 0) {
                return 'Deve ser maior que zero';
              }
              if (widget.operationType == StockOperationType.remove && quantity > (_selectedProduct!.stockQuantity ?? 0)) {
                return 'Estoque insuficiente';
              }
              return null;
            },
          ),
          if (widget.operationType == StockOperationType.add) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Preço de Custo (por unidade)',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo obrigatório';
                }
                if (double.tryParse(value) == null) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),
          ]
        ],
      ),
    );
  }
}

