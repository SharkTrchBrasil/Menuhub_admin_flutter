import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StockManagementSection extends StatefulWidget {
  final bool isStockControlled;
  final int stockQuantity;
  final bool isImported;
  final ValueChanged<bool> onToggleControl;
  final ValueChanged<String> onQuantityChanged;

  const StockManagementSection({
    super.key,
    required this.isStockControlled,
    required this.stockQuantity,
    required this.isImported,
    required this.onToggleControl,
    required this.onQuantityChanged,
  });

  @override
  State<StockManagementSection> createState() => _StockManagementSectionState();
}

class _StockManagementSectionState extends State<StockManagementSection> {
  late final TextEditingController _stockController;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(text: widget.stockQuantity.toString());
  }

  @override
  void didUpdateWidget(covariant StockManagementSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newStockText = widget.stockQuantity.toString();
    if (_stockController.text != newStockText) {
      _stockController.text = newStockText;
    }
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se o produto for importado, não mostramos nada
    if (widget.isImported) {
      return const SizedBox.shrink();
    }

    // A UI agora é construída dentro de um Card para consistência
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.isStockControlled
            ? _buildActivatedState(context)
            : _buildDeactivatedState(context),
      ),
    );
  }

  // Layout para o estado DESATIVADO
  Widget _buildDeactivatedState(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Estoque", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text("Controle de estoque desativado", style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => widget.onToggleControl(true),
          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
          icon: const Icon(Icons.shopping_bag_outlined, size: 16),
          label: const Text("Ativar"),
        ),
      ],
    );
  }

  // Layout para o estado ATIVADO (similar ao layout do iFood)
  Widget _buildActivatedState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Estoque", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Switch(
              value: widget.isStockControlled,
              onChanged: widget.onToggleControl,
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _stockController,
          decoration: const InputDecoration(
            prefixText: 'Qtd. ',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: widget.onQuantityChanged,
        ),
        const SizedBox(height: 8),
        Text(
          'Caso o estoque acabe, o produto será pausado automaticamente.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}