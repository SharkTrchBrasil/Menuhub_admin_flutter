// Substitua o conteúdo do seu arquivo variant_option_tile.dart

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totem_pro_admin/models/variant_option.dart';

class VariantOptionTile extends StatefulWidget {
  final VariantOption option;
  final VoidCallback onRemove;
  final Function(VariantOption) onUpdate;
  final int index;

  const VariantOptionTile({
    super.key,
    required this.option,
    required this.onRemove,
    required this.onUpdate,
    required this.index,
  });

  @override
  State<VariantOptionTile> createState() => _VariantOptionTileState();
}

class _VariantOptionTileState extends State<VariantOptionTile> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _pdvController;

  @override
  void initState() {
    super.initState();
    // Usa os overrides para os campos editáveis, ou vazio se for nulo
    _nameController = TextEditingController(text: widget.option.name_override ?? '');
    _priceController = TextEditingController(
      text: UtilBrasilFields.obterReal((widget.option.price_override ?? 0) / 100),
    );
    _pdvController = TextEditingController(text: widget.option.pos_code ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _pdvController.dispose();
    super.dispose();
  }

  void _updateField({String? name, int? price, String? posCode}) {
    final updatedOption = widget.option.copyWith(
      name_override: name,
      price_override: price,
      pos_code: posCode,
    );
    widget.onUpdate(updatedOption);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {}, // Pode ser usado para abrir um seletor de produto no futuro
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
          child: Row(
            children: [
              ReorderableDragStartListener(
                index: widget.index,
                child: const MouseRegion(cursor: SystemMouseCursors.grab, child: Icon(Icons.drag_indicator)),
              ),
              const SizedBox(width: 24),
              // Imagem
              SizedBox(
                width: 75,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: widget.option.imagePath != null
                      ? Image.network(widget.option.imagePath!, width: 60, height: 48, fit: BoxFit.cover)
                      : Container(width: 60, height: 48, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
                ),
              ),
              const SizedBox(width: 12),
              // Produto/Nome
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: widget.option.resolvedName.isNotEmpty ? widget.option.resolvedName : 'Nome do complemento'),
                  onEditingComplete: () => _updateField(name: _nameController.text),
                  onTapOutside: (_) => _updateField(name: _nameController.text),
                ),
              ),
              const SizedBox(width: 12),
              // Canal de venda (Placeholder)
              const Expanded(flex: 2, child: Text('Aplicativo iFood')),
              // Preço
              SizedBox(
                width: 130,
                child: TextFormField(
                  controller: _priceController,
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
                  decoration: InputDecoration(hintText: UtilBrasilFields.obterReal(widget.option.resolvedPrice / 100)),
                  onEditingComplete: () => _updateField(price: (UtilBrasilFields.converterMoedaParaDouble(_priceController.text) * 100).toInt()),
                  onTapOutside: (_) => _updateField(price: (UtilBrasilFields.converterMoedaParaDouble(_priceController.text) * 100).toInt()),
                ),
              ),
              const SizedBox(width: 12),
              // Código PDV
              SizedBox(
                width: 130,
                child: TextFormField(
                  controller: _pdvController,
                  decoration: const InputDecoration(hintText: 'Código'),
                  onEditingComplete: () => _updateField(posCode: _pdvController.text),
                  onTapOutside: (_) => _updateField(posCode: _pdvController.text),
                ),
              ),
              const SizedBox(width: 12),
              // Ações
              SizedBox(
                width: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Switch(
                      value: widget.option.available,
                      onChanged: (value){}
                    ),
                    IconButton(icon: Icon(Icons.delete_outline, color: Colors.red.shade700), onPressed: widget.onRemove),
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