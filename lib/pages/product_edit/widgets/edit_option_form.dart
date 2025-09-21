// lib/pages/product_edit/widgets/edit_option_form.dart

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field.dart'; // Import necessário
import 'package:totem_pro_admin/models/image_model.dart';      // Import necessário

// ✅ Importe o seu StockManagementCard
import 'package:totem_pro_admin/pages/product_edit/widgets/stock_management_card.dart';

import '../../../widgets/ds_primary_button.dart';

class EditOptionForm extends StatefulWidget {
  final VariantOption? option; // ✅ Agora aceita null
  final ValueChanged<VariantOption> onConfirm;
  final VoidCallback onCancel;

  const EditOptionForm({
    super.key,
    this.option, // ✅ Pode ser null
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<EditOptionForm> createState() => _EditOptionFormState();
}



class _EditOptionFormState extends State<EditOptionForm> {
  // ✅ 1. Controllers para todos os campos
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockQuantityController;

  // O estado do 'image' e 'controlStock' será gerenciado aqui
  late ImageModel? _image;
  late bool _hasStockControl;

  @override
  void initState() {
    super.initState();
    final option = widget.option;

    // ✅ Se option for null (modo criação), use valores padrão
    _nameController = TextEditingController(text: option?.name_override ?? '');
    _descriptionController = TextEditingController(text: option?.description ?? '');
    _priceController = TextEditingController(
      text: option?.price_override != null
          ? UtilBrasilFields.obterReal((option?.price_override ?? 0) / 100)
          : '',
    );
    _stockQuantityController = TextEditingController(
        text: option?.stock_quantity.toString() ?? '0'
    );

    _hasStockControl = option?.track_inventory ?? false;
    _image = option?.image;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
  }

  void _confirm() {
    final priceInCents =
    (UtilBrasilFields.converterMoedaParaDouble(_priceController.text) * 100)
        .toInt();

    // ✅ Se estamos criando uma nova opção (option é null)
    if (widget.option == null) {
      final newOption = VariantOption(
        id: null, // Será gerado pelo backend
        name_override: _nameController.text,
        description: _descriptionController.text,
        price_override: priceInCents,
        track_inventory: _hasStockControl,
        stock_quantity: int.tryParse(_stockQuantityController.text) ?? 0,
        image: _image,
        // Adicione outros campos necessários com valores padrão
        available: true,
        linked_product_id: null,
        // ... outros campos
      );
      widget.onConfirm(newOption);
    } else {
      // ✅ Se estamos editando uma opção existente
      final updatedOption = widget.option!.copyWith(
        name_override: _nameController.text,
        description: _descriptionController.text,
        price_override: priceInCents,
        track_inventory: _hasStockControl,
        stock_quantity: int.tryParse(_stockQuantityController.text) ?? 0,
        image: _image,
      );
      widget.onConfirm(updatedOption);
    }
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Cabeçalho ---
          // No build do EditOptionForm, ajuste o título:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  widget.option == null ? "Criar Complemento" : "Editar Complemento",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              IconButton(icon: const Icon(Icons.close), onPressed: widget.onCancel),
            ],
          ),



          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child:

                Padding(
                  padding: const EdgeInsets.only(top: 48.0),
                  child: _buildNameField(),
                ),
              ),
              const SizedBox(width: 16),
              // Campo de imagem no estilo iFood
              AppImageFormField(
                title: "",
                initialValue: _image,
                onChanged: (newImage) {
                  // Quando a imagem é alterada no widget filho,
                  // atualizamos o estado local deste formulário.
                  setState(() {
                    _image = newImage;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),
          _buildDescriptionField(),
          const SizedBox(height: 24),

          // Campo de Preço (não precisa de um método separado)
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(
              labelText: 'Preço Adicional',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter()],
          ),
          const SizedBox(height: 24),

          // ✅ 4. INTEGRAÇÃO DO StockManagementCard
          StockManagementCard(
            isStockControlled: _hasStockControl,
            stockQuantity: int.tryParse(_stockQuantityController.text) ?? 0,
            isImported: widget.option?.linked_product_id != null, // Desabilita se for um produto importado
            onToggleControl: (newValue) {
              setState(() {
                _hasStockControl = newValue;
              });
            },
            onQuantityChanged: (newQuantity) {
              // O controller do StockManagementCard é interno, então atualizamos o nosso
              _stockQuantityController.text = newQuantity;
            },
          ),
          const SizedBox(height: 24),

          // --- Footer com botões ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: DsButton(
                  onPressed: widget.onCancel,
                  requiresConnection: false,
                  style: DsButtonStyle.secondary,


                  label: 'Cancelar',
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: DsButton(
                  onPressed: _confirm,
                  child: const Text('Salvar Alterações'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Métodos de construção para manter o build limpo
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nome do Complemento',
        border: OutlineInputBorder(),
      ),
      maxLength: 80,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Descrição (opcional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      maxLength: 1000,
    );
  }
}