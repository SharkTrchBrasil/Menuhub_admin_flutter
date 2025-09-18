import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../widgets/app_image_form_field.dart';
import '../cubit/complement_form_cubit.dart';

class UnifiedProductForm extends StatelessWidget {
  final bool isPrepared;

  const UnifiedProductForm({super.key, required this.isPrepared});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ComplementFormCubit>();
    final state = context.watch<ComplementFormCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // --- Nome do Produto ---
        _buildFormField(
          label: "Nome do Complemento",
          initialValue: state.name,
          onChanged: isPrepared ? cubit.nameChanged : null,
          isRequired: isPrepared,
          readOnly: !isPrepared,
          validator: isPrepared
              ? (v) => (v == null || v.isEmpty) ? "Campo obrigatório" : null
              : null,

          suffixIcon: (!isPrepared && state.selectedCatalogProduct != null)
              ? IconButton(
            icon: const Icon(Icons.close),
            onPressed: cubit.resetIndustrializedFlow,
            tooltip: "Remover seleção e buscar novamente",
          )
              : null,
        ),

        const SizedBox(height: 16),

        // --- Descrição ---
        _buildFormField(
          label: "Descrição",
          initialValue: state.description,
          onChanged: isPrepared ? cubit.descriptionChanged : null,
          maxLines: 3,
          readOnly: !isPrepared,
        ),

        const SizedBox(height: 16),

        // --- Imagem (apenas para preparado) ---
        if (isPrepared)
          AppProductImageFormField(
            title: 'Imagem',
            initialValue: state.image,
            onChanged: cubit.imageChanged,
            validator: (ImageModel) {  },
          ),

        if (isPrepared) const SizedBox(height: 16),

        // --- Imagem (apenas leitura para industrializado) ---
        if (!isPrepared && state.image.url != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Imagem do produto",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Center(
                child: Image.network(
                  state.image.url!,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

        // --- Controle de Estoque ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Controle de estoque", style: TextStyle(fontSize: 16)),
            Switch(
              value: state.trackInventory,
              onChanged: cubit.trackInventoryChanged,
            ),
          ],
        ),

        if (state.trackInventory) ...[
          const SizedBox(height: 16),
          _buildFormField(
            label: 'Quantidade em estoque',
            initialValue: state.stockQuantity,
            onChanged: cubit.stockQuantityChanged,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],

        const SizedBox(height: 24),

        // --- Seção de Preços e Códigos ---
        const Text(
          "Informações de preço e identificação",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Layout responsivo para campos lado a lado em telas maiores
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            return isWide
                ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPriceField(cubit, state),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPdvCodeField(cubit, state, isPrepared),
                ),
              ],
            )
                : Column(
              children: [
                _buildPriceField(cubit, state),
                const SizedBox(height: 16),
                _buildPdvCodeField(cubit, state, isPrepared),
              ],
            );
          },
        ),

        const SizedBox(height: 32),

        // --- Botão de Ação ---
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            onPressed: cubit.submit,
            label: Text(isPrepared
                ? "Adicionar ao grupo"
                : "Adicionar produto industrializado"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        // Espaço extra para evitar que o teclado cubra campos
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required String initialValue,
    required Function(String)? onChanged,
    bool isRequired = false,
    bool readOnly = false,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon, // ✅ 2. ADICIONA O PARÂMETRO 'suffixIcon'
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: isRequired ? "$label*" : label,
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: suffixIcon, // ✅ 2. USA O PARÂMETRO AQUI
      ),
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }

  Widget _buildPriceField(ComplementFormCubit cubit, ComplementFormState state) {
    return TextFormField(
      initialValue: state.price,
      onChanged: cubit.priceChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        CentavosInputFormatter()
      ],
      decoration: const InputDecoration(
        labelText: "Preço Adicional (R\$)",
        prefixText: "R\$ ",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPdvCodeField(ComplementFormCubit cubit, ComplementFormState state, bool isPrepared) {
    return TextFormField(
      initialValue: state.pdvCode,
      onChanged: isPrepared ? cubit.pdvCodeChanged : null,
      readOnly: !isPrepared,
      decoration: InputDecoration(
        labelText: "Código PDV",
        filled: !isPrepared,
        fillColor: !isPrepared ? Colors.grey.shade100 : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}