import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StockManagementCard extends StatefulWidget {
  final bool isStockControlled;
  final int stockQuantity;
  final bool isImported;
  final ValueChanged<bool> onToggleControl;
  final ValueChanged<String> onQuantityChanged;

  const StockManagementCard({
    super.key,
    required this.isStockControlled,
    required this.stockQuantity,
    required this.isImported,
    required this.onToggleControl,
    required this.onQuantityChanged,
  });

  @override
  State<StockManagementCard> createState() => _StockManagementCardState();
}

class _StockManagementCardState extends State<StockManagementCard> {
  late final TextEditingController _stockController;
  final FocusNode _stockFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(text: widget.stockQuantity.toString());
  }

  @override
  void didUpdateWidget(covariant StockManagementCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newStockText = widget.stockQuantity.toString();
    if (_stockController.text != newStockText) {
      _stockController.text = newStockText;
    }
  }

  @override
  void dispose() {
    _stockController.dispose();
    _stockFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        crossFadeState: widget.isStockControlled
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: _buildDeactivatedState(context),
        secondChild: _buildActivatedState(context),
      ),
    );
  }

  // Layout para o estado DESATIVADO
  Widget _buildDeactivatedState(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Estoque",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF151515),
            ),
          ),
        ),
      //  if (!widget.isImported)
          ElevatedButton(
            onPressed: () => widget.onToggleControl(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEB0033),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Row(
              children: [
                Icon(Icons.shopping_bag_outlined, size: 16),
                SizedBox(width: 8),
                Text('Ativar'),
              ],
            ),
          ),
      ],
    );
  }

  // Layout para o estado ATIVADO (estilo iFood)
  Widget _buildActivatedState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Estoque",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF151515),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de quantidade (estilo iFood)
            Expanded(
              child: Container(
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Text(
                        'Qtd.',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        focusNode: _stockFocusNode,

                      //  readOnly: widget.isImported,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: widget.onQuantityChanged,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF151515),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Botão de remover (estilo iFood)
           // if (!widget.isImported)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20,
                      color: Color(0xFFEB0033)),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEF),
                    padding: const EdgeInsets.all(8),

                  ),
                  onPressed: () => widget.onToggleControl(false),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Caso o estoque acabe, o produto será pausado automaticamente.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}