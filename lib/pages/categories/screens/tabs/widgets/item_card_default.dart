import 'package:flutter/material.dart';
import '../../../../../models/option_item.dart';

class DoughItemCard extends StatefulWidget {
  final OptionItem item;
  final ValueChanged<OptionItem> onUpdate;
  final VoidCallback onRemove;
  final bool isFirstItem;

  const DoughItemCard({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onRemove,
    this.isFirstItem = false,
  });

  @override
  State<DoughItemCard> createState() => _DoughItemCardState();
}

class _DoughItemCardState extends State<DoughItemCard> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _pdvController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(
      text: widget.item.price > 0 ? (widget.item.price / 100).toStringAsFixed(2) : '',
    );
    _pdvController = TextEditingController(text: widget.item.externalCode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _pdvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Campo Nome
                _buildMobileField(
                  label: 'Nome',
                  hintText: 'Ex. Tradicional',
                  controller: _nameController,
                  onChanged: (value) => widget.onUpdate(widget.item.copyWith(name: value)),
                ),
                const SizedBox(height: 16),

                // Linha com Preço e Status
                Row(
                  children: [
                    // Preço
                    Expanded(
                      child: _buildMobileField(
                        label: 'Preço',
                        hintText: 'R\$ 0,00',
                        controller: _priceController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) {
                          final priceInCents = ((double.tryParse(value.replaceAll(',', '.')) ?? 0) * 100).round();
                          widget.onUpdate(widget.item.copyWith(price: priceInCents));
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Status de vendas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 48,

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [

                                Switch(
                                  value: widget.item.isActive,
                                  onChanged: (value) => widget.onUpdate(widget.item.copyWith(isActive: value)),


                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Código PDV
                _buildMobileField(
                  label: 'Cód. PDV',
                  hintText: '000',
                  controller: _pdvController,
                  onChanged: (value) => widget.onUpdate(widget.item.copyWith(externalCode: value)),
                ),
              ],
            ),
          ),

          // Divisor e botão de remover
          const Divider(height: 1, color: Color(0xFFEBEBEB)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remover'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: keyboardType,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// Widget principal para gerenciar as massas
class DoughManagementScreen extends StatefulWidget {
  const DoughManagementScreen({super.key});

  @override
  State<DoughManagementScreen> createState() => _DoughManagementScreenState();
}

class _DoughManagementScreenState extends State<DoughManagementScreen> {
  final List<OptionItem> doughItems = [
    OptionItem(
      name: '',
      price: 0,
      externalCode: '',
      isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova categoria'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lista de massas
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: doughItems.length,
              itemBuilder: (context, index) {
                return DoughItemCard(
                  item: doughItems[index],
                  onUpdate: (updatedItem) {
                    setState(() {
                      doughItems[index] = updatedItem;
                    });
                  },
                  onRemove: () {
                    if (doughItems.length > 1) {
                      setState(() {
                        doughItems.removeAt(index);
                      });
                    }
                  },
                  isFirstItem: index == 0,
                );
              },
            ),

            const SizedBox(height: 16),

            // Botão para adicionar nova massa
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    doughItems.add(OptionItem(
                      name: '',
                      price: 0,
                      externalCode: '',
                      isActive: true,
                    ));
                  });
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Adicionar massa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEB0033),
                  side: const BorderSide(color: Color(0xFFEB0033)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFEB0033),
                      side: const BorderSide(color: Color(0xFFEB0033)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEB0033),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Continuar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}