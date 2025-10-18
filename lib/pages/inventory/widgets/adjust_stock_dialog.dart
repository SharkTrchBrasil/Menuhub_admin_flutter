import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/products/product.dart';


import '../../products/cubit/products_cubit.dart';

class AdjustStockDialog extends StatefulWidget {
  final Product product;
  final int storeId;

  const AdjustStockDialog({
    super.key,
    required this.product,
    required this.storeId,
  });

  @override
  State<AdjustStockDialog> createState() => _AdjustStockDialogState();
}

class _AdjustStockDialogState extends State<AdjustStockDialog> {
  late final TextEditingController _quantityController;
  late final TextEditingController _minStockController;
  late bool _controlStock;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controlStock = widget.product.controlStock;
    _quantityController = TextEditingController(text: widget.product.stockQuantity.toString());
    _minStockController = TextEditingController(text: widget.product.minStock.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (_formKey.currentState!.validate()) {
      context.read<ProductsCubit>().adjustStock(
        storeId: widget.storeId,
        product: widget.product,
        controlStock: _controlStock,
        newQuantity: int.parse(_quantityController.text),
        newMinStock: int.parse(_minStockController.text),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 450,
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
                    const Icon(Icons.settings_suggest_outlined, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gerenciar Estoque',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.product.name,
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile.adaptive(
                      title: const Text('Controlar Estoque', style: TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(_controlStock ? 'Ativado' : 'Desativado'),
                      value: _controlStock,
                      onChanged: (value) => setState(() => _controlStock = value),

                    ),
                    const SizedBox(height: 24),
                    AnimatedOpacity(
                      opacity: _controlStock ? 1.0 : 0.4,
                      duration: const Duration(milliseconds: 300),
                      child: AbsorbPointer(
                        absorbing: !_controlStock,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _quantityController,
                                decoration: const InputDecoration(labelText: 'Quantidade Atual'),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _minStockController,
                                decoration: const InputDecoration(labelText: 'Estoque Mínimo'),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (v) => (v == null || v.isEmpty) ? 'Obrigatório' : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _onConfirm,
                            child: const Text('Salvar Ajustes'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}