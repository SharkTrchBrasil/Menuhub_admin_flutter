import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/enums/beverage.dart';
import 'package:totem_pro_admin/core/enums/foodtags.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field.dart';
import 'product_attributes_section.dart';
import 'stock_management_card.dart';

class ProductDetailsForm extends StatefulWidget {
  final Product product;
  final bool isImported;

  // Callbacks para todas as interações
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<ImageModel?> onImageChanged;
  final ValueChanged<bool> onControlStockToggled;
  final ValueChanged<String> onStockQuantityChanged;
  final ValueChanged<FoodTag> onDietaryTagToggled;
  final ValueChanged<BeverageTag> onBeverageTagToggled;
  final ValueChanged<int?> onServesUpToChanged;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onUnitChanged;

  const ProductDetailsForm({
    super.key,
    required this.product,
    required this.isImported,
    required this.onNameChanged,
    required this.onDescriptionChanged,
    required this.onImageChanged,
    required this.onControlStockToggled,
    required this.onStockQuantityChanged,
    required this.onDietaryTagToggled,
    required this.onBeverageTagToggled,
    required this.onServesUpToChanged,
    required this.onWeightChanged,
    required this.onUnitChanged,
  });

  @override
  State<ProductDetailsForm> createState() => _ProductDetailsFormState();
}

class _ProductDetailsFormState extends State<ProductDetailsForm> {

  // ✅ 2. OS CONTROLLERS AGORA VIVEM NO ESTADO DO WIDGET
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // ✅ 3. INICIALIZAMOS OS CONTROLLERS UMA ÚNICA VEZ
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description);

    // ✅ 4. ADICIONAMOS LISTENERS PARA NOTIFICAR O CUBIT
    //    Isso é mais performático que usar onChanged no TextFormField
    _nameController.addListener(() {
      widget.onNameChanged(_nameController.text);
    });
    _descriptionController.addListener(() {
      widget.onDescriptionChanged(_descriptionController.text);
    });
  }

  @override
  void didUpdateWidget(covariant ProductDetailsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ 5. SINCRONIZAMOS OS CONTROLLERS SE O PRODUTO MUDAR EXTERNAMENTE
    //    Isso acontece se o CUBIT receber dados de outra fonte (ex: socket)
    if (widget.product.name != oldWidget.product.name && widget.product.name != _nameController.text) {
      _nameController.text = widget.product.name;
    }
    if (widget.product.description != oldWidget.product.description && widget.product.description != _descriptionController.text) {
      _descriptionController.text = widget.product.description ?? '';
    }
  }

  @override
  void dispose() {
    // ✅ 6. LIMPAMOS OS CONTROLLERS
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }











  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
     // padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detalhes', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Preencha todos os detalhes sobre o novo item do seu cardápio.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // ✅ 7. CHAMADA AO NOVO HELPER DE TEXTFIELD
          _buildTextField(
            context: context,
            controller: _nameController,
            label: "Nome do Produto",
            placeholder: "Ex: Molho pomodoro",
            maxLength: 80,
            readOnly:  widget.isImported,
            validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 24),

          // ✅ 8. CHAMADA AO NOVO HELPER DE TEXTAREA
          _buildTextArea(
            context: context,
            controller: _descriptionController,
            label: "Descrição",
            placeholder: "Ex: Molho de tomate italiano clássico...",
            maxLength: 1000,
            readOnly:  widget.isImported,
          ),
          const SizedBox(height: 24),

          AppProductImageFormField(
            title: 'Imagem do produto',
            initialValue: widget.product.image,
            enabled: widget.isImported,
            onChanged: widget.onImageChanged,
          ),
          const SizedBox(height: 24),

          StockManagementCard(
            isStockControlled: widget.product.controlStock,
            stockQuantity: widget.product.stockQuantity,
            isImported: widget.isImported,
            onToggleControl: widget.onControlStockToggled,
            onQuantityChanged: widget.onStockQuantityChanged,
          ),
          const SizedBox(height: 34),

          ProductAttributesSection(
            product: widget.product,
            isImported: widget.isImported,
            onServesUpToChanged: widget.onServesUpToChanged,
            onWeightChanged: widget.onWeightChanged,
            onUnitChanged: widget.onUnitChanged,
            onDietaryTagToggled: widget.onDietaryTagToggled,
            onBeverageTagToggled: widget.onBeverageTagToggled,
          ),
        ],
      ),
    );
  }



  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String placeholder,
    int? maxLength, // Tornando maxLength opcional
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 1. O LABEL AGORA É UM WIDGET 'Text' SEPARADO E FIXO
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF151515),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // ✅ 2. O TEXTFORMFIELD USA 'hintText' EM VEZ DE 'labelText'
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          readOnly: readOnly,
          validator: validator,
          decoration: InputDecoration(
            hintText: placeholder, // Usa hintText para o placeholder
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
            ),
            // ... (outras propriedades de decoration)
            filled: readOnly,
            fillColor: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String placeholder,
    int? maxLength,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 1. O LABEL TAMBÉM É UM WIDGET 'Text' SEPARADO
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF151515),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // ✅ 2. O TEXTFORMFIELD TAMBÉM USA 'hintText'
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: 3,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
            ),
            // ... (outras propriedades de decoration)
            filled: readOnly,
            fillColor: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
          ),
        ),
      ],
    );
  }
}