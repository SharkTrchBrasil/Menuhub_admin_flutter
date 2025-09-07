import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/image_model.dart'; // Certifique-se de que ImageModel está importado
import 'package:totem_pro_admin/pages/product_edit/cubit/edit_product_cubit.dart';

import '../widgets/product_attributes_section.dart';

class ProductDetailsTab extends StatefulWidget {
  const ProductDetailsTab({super.key});

  @override
  State<ProductDetailsTab> createState() => _ProductDetailsTabState();
}

class _ProductDetailsTabState extends State<ProductDetailsTab> {
  // ✅ 1. DECLARAMOS OS CONTROLLERS COMO VARIÁVEIS DE ESTADO
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // Acessa o CUBIT uma única vez para pegar o estado inicial do produto
    final cubit = context.read<EditProductCubit>();
    final initialProduct = cubit.state.editedProduct;

    // ✅ 2. INICIALIZAMOS OS CONTROLLERS UMA ÚNICA VEZ COM OS VALORES DO PRODUTO
    _nameController = TextEditingController(text: initialProduct.name);
    _descriptionController = TextEditingController(text: initialProduct.description);

    // Opcional: Adicionar listeners para enviar as mudanças ao CUBIT imediatamente
    // _nameController.addListener(() => cubit.nameChanged(_nameController.text));
    // _descriptionController.addListener(() => cubit.descriptionChanged(_descriptionController.text));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ 3. Adiciona listeners aqui ou em initState, se preferir.
    // O addListener é mais performático do que chamar o onChanged do BlocBuilder
    // em cada reconstrução do widget.
    final cubit = context.read<EditProductCubit>();
    _nameController.addListener(() {
      if (_nameController.text != cubit.state.editedProduct.name) {
        cubit.nameChanged(_nameController.text);
      }
    });
    _descriptionController.addListener(() {
      if (_descriptionController.text != cubit.state.editedProduct.description) {
        cubit.descriptionChanged(_descriptionController.text);
      }
    });
  }


  @override
  void dispose() {
    // ✅ 4. LIMPAMOS OS CONTROLLERS PARA EVITAR VAZAMENTO DE MEMÓRIA
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<EditProductCubit, EditProductState>(
      // Otimização: Reconstroi só quando os dados visíveis nesta aba mudam
      buildWhen: (prev, current) =>
      prev.editedProduct.name != current.editedProduct.name ||
          prev.editedProduct.description != current.editedProduct.description ||
          prev.editedProduct.image != current.editedProduct.image ||
          prev.editedProduct.masterProductId != current.editedProduct.masterProductId,
      builder: (context, state) {
        final cubit = context.read<EditProductCubit>();
        final product = state.editedProduct;
        final isImported = product.masterProductId != null;


        if (_nameController.text != product.name ) {
          _nameController.text = product.name;
        }
        if (_descriptionController.text != product.description ) {
          _descriptionController.text = product.description ?? "";
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Principais informações",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF151515),
                ),
              ),
              const SizedBox(height: 24),

              // Campo de Nome
              _buildTextField(
                context: context,
                controller: _nameController, // ✅ AGORA USAMOS O CONTROLLER DO ESTADO
                label: "Nome do Produto",
                placeholder: "Ex: Molho pomodoro",
                maxLength: 80,
                readOnly: isImported,
                // onChanged: cubit.nameChanged, // REMOVIDO: O listener do controller já faz isso
                validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 24),

              // Campo de Descrição
              _buildTextArea(
                context: context,
                controller: _descriptionController, // ✅ AGORA USAMOS O CONTROLLER DO ESTADO
                label: "Descrição",
                placeholder: "Ex: Molho de tomate italiano clássico, preparado com tomates maduros.",
                maxLength: 1000,
                readOnly: isImported,
                // onChanged: cubit.descriptionChanged, // REMOVIDO: O listener do controller já faz isso
              ),
              const SizedBox(height: 24),

              // Seção de Imagem
              const Text(
                "Imagem do produto",
                style: TextStyle(
                  color: Color(0xFF151515),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _buildImageSection(
                context: context,
                image: product.image,
                isImported: isImported,
                onChanged: cubit.imageChanged, // ✅ TIPO CORRETO AGORA
              ),
              const SizedBox(height: 24),

              // Seção de Estoque
              _buildStockSection(
                isImported: isImported,
                // Adicione aqui a lógica de estoque se necessário
              ),
              const SizedBox(height: 24),


              ProductAttributesSection(
                product: product,

                onServesUpToChanged: cubit.servesUpToChanged,
                onWeightChanged: cubit.weightChanged,
                onUnitChanged: cubit.unitChanged,


                onDietaryTagToggled: cubit.toggleDietaryTag,


                onBeverageTagToggled: cubit.toggleBeverageTag,
              ),

            ],
          ),
        );
      },
    );
  }

  // --- Métodos de Construção Auxiliares ---

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required int maxLength,
    bool readOnly = false,
    Function(String)? onChanged, // Manter o onChanged aqui é opcional se usar listeners
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF151515),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          readOnly: readOnly,
          onChanged: onChanged, // Se não usar listener, este é importante
          validator: validator,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF0083CC)),
            ),
            contentPadding: const EdgeInsets.all(12),
            filled: readOnly,
            fillColor: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${controller.text.length}/$maxLength",
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 12,
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
    required int maxLength,
    bool readOnly = false,
    Function(String)? onChanged, // Manter o onChanged aqui é opcional se usar listeners
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF151515),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: 3,
          readOnly: readOnly,
          onChanged: onChanged, // Se não usar listener, este é importante
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF0083CC)),
            ),
            contentPadding: const EdgeInsets.all(12),
            filled: readOnly,
            fillColor: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${controller.text.length}/$maxLength",
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection({
    required BuildContext context,
    ImageModel? image, // ✅ AGORA É DO TIPO CORRETO ImageModel?
    required bool isImported,
    required ValueChanged<ImageModel?> onChanged, // ✅ AGORA É ValueChanged<ImageModel?>
  }) {
    final hasImage = image != null;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Preview da imagem
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFF5F5F5),
                    image: hasImage
                        ? DecorationImage(
                      image: NetworkImage(image.url.toString()),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: !hasImage
                      ? const Icon(
                    Icons.fastfood,
                    size: 32,
                    color: Color(0xFF666666),
                  )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasImage)
                        Text(
                          image.url ?? "imagem_produto.jpg", // ✅ USANDO O NOME DO ARQUIVO
                          style: const TextStyle(
                            color: Color(0xFF151515),
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (!isImported)
                            IconButton(
                              onPressed: () {


                              },
                              icon: const Icon(Icons.edit, size: 20, color: Color(0xFFEA1D2C)),
                              tooltip: "Alterar foto",
                            ),
                          if (hasImage && !isImported)
                            IconButton(
                              onPressed: () {
                                // Lógica para remover imagem
                                onChanged(null); // Remove a imagem, enviando null para o CUBIT
                              },
                              icon: const Icon(Icons.delete, size: 20, color: Color(0xFFEA1D2C)),
                              tooltip: "Remover foto",
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSection({
    bool isImported = false,
    // Adicione um ValueChanged<bool> para controlar o estado do estoque
    // required bool isStockEnabled,
    // required ValueChanged<bool> onToggleStock,
  }) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            "Estoque",
            style: TextStyle(
              color: Color(0xFF151515),
              fontSize: 14,
            ),
          ),
        ),
        if (!isImported)
          ElevatedButton(
            onPressed: () {
              // Lógica para ativar/desativar estoque
              // onToggleStock(!isStockEnabled);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA1D2C),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Row(
              children: [
                Icon(Icons.shopping_bag, size: 16, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  "Ativar", // Ou "Desativar" dependendo do estado
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
      ],
    );
  }




}