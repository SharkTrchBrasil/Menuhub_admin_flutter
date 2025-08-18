import 'package:flutter/material.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';

class MainItemCategoryForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController categoryNameController;
  final TextEditingController productNameController;
  final TextEditingController productPriceController;

  const MainItemCategoryForm({
    super.key,
    required this.formKey,
    required this.categoryNameController,
    required this.productNameController,
    required this.productPriceController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. Crie a Categoria', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          AppTextField(
            controller: categoryNameController,
            title: 'Nome da Categoria',
            hint: 'Ex: Pizzas, Bebidas',
            validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 32),
          const Text('2. Adicione o Primeiro Produto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          AppTextField(
            controller: productNameController,
            title: 'Nome do Produto',
            hint: 'Ex: Pizza de Calabresa',
            validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: productPriceController,
            title: 'Preço (R\$)',
            hint: 'Ex: 29,90',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
          ),
        ],
      ),
    );
  }
}