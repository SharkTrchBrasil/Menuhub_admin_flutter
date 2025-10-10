// widgets/desktop_complement_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/pages/product_groups/cubit/create_complement_cubit.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/product_type_dropbox.dart';
import 'package:totem_pro_admin/widgets/app_image_form_field.dart';

import '../cubit/complement_form_cubit.dart';

class DesktopComplementForm extends StatefulWidget {
  final VariantOption complement;
  final int index;

  const DesktopComplementForm({
    super.key,
    required this.complement,
    required this.index,
  });

  @override
  State<DesktopComplementForm> createState() => _DesktopComplementFormState();
}

class _DesktopComplementFormState extends State<DesktopComplementForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _pdvController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final complement = widget.complement;
    _nameController = TextEditingController(text: complement.name_override ?? '');
    _descriptionController = TextEditingController(text: complement.description ?? '');
    final priceString = UtilBrasilFields.obterReal((complement.price_override ?? 0) / 100);
    _priceController = TextEditingController(text: priceString);
    _pdvController = TextEditingController(text: complement.pos_code ?? '');
  }

  void _updateCubit(VariantOption updatedComplement) {
    context.read<CreateComplementGroupCubit>().updateComplementOption(widget.index, updatedComplement);
  }

  void _updateName(String newName) {
    _updateCubit(widget.complement.copyWith(name_override: newName));
  }

  void _updateDescription(String newDescription) {
    _updateCubit(widget.complement.copyWith(description: newDescription));
  }

  void _updatePrice(String newPrice) {
    final cents = UtilBrasilFields.converterMoedaParaDouble(newPrice) * 100;
    _updateCubit(widget.complement.copyWith(price_override: cents.toInt()));
  }

  void _updatePdvCode(String newCode) {
    _updateCubit(widget.complement.copyWith(pos_code: newCode));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _pdvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          // Body com grid layout
          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildFormGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEBEBEB))),
      ),
      child: Row(
        children: [
          const Icon(Icons.add, size: 20, color: Colors.black),
          const SizedBox(width: 12),
          const Text(
            "Criar novo complemento",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.black),
            onPressed: () {
              // Opcional: adicionar funcionalidade de fechar se necessário
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormGrid(BuildContext context) {
    return Column(
      children: [
        // Seletor de Tipo de Produto
        _buildProductTypeDropdown(context),
        const SizedBox(height: 24),

        // Grid de campos
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.8,
          ),
          children: [
            _buildNameField(),
            _buildImageField(),
            _buildDescriptionField(),
            _buildSalesChannelsTable(),
          ],
        ),
      ],
    );
  }

  Widget _buildProductTypeDropdown(BuildContext context) {

    final cubit = context.watch<ComplementFormCubit>();
    final state = cubit.state;


    // Reaproveitando o mesmo dropdown do mobile
    return Container(
      width: double.infinity,
      child: ProductTypeDropdown(
        isPrepared: state.isPrepared,
        onChanged: (value) => cubit.toggleProductType(value),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nome do Produto",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: "Ex: Molho pomodoro",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: const TextStyle(fontSize: 14),
          maxLength: 80,
          onChanged: _updateName,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${_nameController.text.length}/80',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Descrição",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: "Ex: Molho de tomate italiano clássico, preparado com tomates maduros.",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            alignLabelWithHint: true,
          ),
          style: const TextStyle(fontSize: 14),
          maxLines: 5,
          maxLength: 1000,
          onChanged: _updateDescription,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${_descriptionController.text.length}/1000',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Imagem",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        AppImageFormField(
          title: "",
          initialValue: widget.complement.image,
          onChanged: (newImage) {
            final updatedComplement = widget.complement.copyWith(
              image: newImage ?? const ImageModel(),
            );
            _updateCubit(updatedComplement);
          },
          size: 120,
          showTitle: false,
        ),
      ],
    );
  }

  Widget _buildSalesChannelsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Canais de Venda",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEBEBEB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            children: [
              // Header da tabela
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                children: [
                  _buildTableHeader("Canal de venda"),
                  _buildTableHeader("Preço"),
                  _buildTableHeader("Código PDV"),
                ],
              ),
              // Linha de dados
              TableRow(
                children: [
                  _buildChannelCell(),
                  _buildPriceCell(),
                  _buildPdvCell(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildChannelCell() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFEA1D2C),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.shopping_bag, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            "Aplicativo iFood",
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCell() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: TextFormField(
        controller: _priceController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "0,00",
          prefixText: "R\$ ",
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(fontSize: 14),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          CentavosInputFormatter(),
        ],
        onChanged: _updatePrice,
      ),
    );
  }

  Widget _buildPdvCell() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: TextFormField(
        controller: _pdvController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Código PDV",
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(fontSize: 14),
        onChanged: _updatePdvCode,
      ),
    );
  }
}