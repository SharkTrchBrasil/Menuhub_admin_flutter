import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../models/option_item.dart';
import '../../../../../widgets/app_image_form_field.dart';
import '../../../../edit_settings/citys/add_edit_city_page.dart';

class PizzaSizeItemCard extends StatefulWidget {
  final OptionItem item;
  final ValueChanged<OptionItem> onUpdate;
  final VoidCallback onRemove;

  const PizzaSizeItemCard({
    required this.item,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  @override
  State<PizzaSizeItemCard> createState() => PizzaSizeItemCardState();
}

class PizzaSizeItemCardState extends State<PizzaSizeItemCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _pdvController;
  late final TextEditingController _slicesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _priceController = TextEditingController(text: (widget.item.price / 100).toStringAsFixed(2));
    _pdvController = TextEditingController(text: widget.item.externalCode);
    _slicesController = TextEditingController(text: widget.item.slices?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _pdvController.dispose();
    _slicesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com título e botão de remover
                _buildHeader(),
                const SizedBox(height: 20),

                // Layout responsivo para conteúdo
                if (isMobile) _buildMobileLayout() else _buildDesktopLayout(),

                const SizedBox(height: 16),

                // Status switch
                _buildStatusSwitch(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Configuração do Tamanho',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        IconButton(
          onPressed: widget.onRemove,
          icon: Icon(Icons.delete_outline, color: Colors.red[400]),
          iconSize: 20,
          tooltip: "Remover tamanho",
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        // Linha 1: Imagem e Nome
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageUploader(),
            const SizedBox(width: 20),
            Expanded(child: _buildNameField()),
          ],
        ),
        const SizedBox(height: 20),

        // Linha 2: Campos numéricos
        Row(
          children: [
            Expanded(child: _buildSlicesField()),
            const SizedBox(width: 16),
            Expanded(child: _buildPriceField()),
            const SizedBox(width: 16),
            Expanded(child: _buildPdvField()),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: _buildFlavorsSelector()),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Imagem centralizada no mobile
        Center(child: _buildImageUploader()),
        const SizedBox(height: 20),

        // Campos em coluna
        _buildNameField(),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _buildSlicesField()),
            const SizedBox(width: 12),
            Expanded(child: _buildPriceField()),
          ],
        ),
        const SizedBox(height: 16),

        _buildPdvField(),
        const SizedBox(height: 16),

        _buildFlavorsSelector(),
      ],
    );
  }

  Widget _buildImageUploader() {
    return Column(
      children: [
        // ✅ 2. SUBSTITUA O CONTAINER ANTIGO PELO WIDGET REUTILIZÁVEL
        AppImageFormField(
          title: "", // O título é implícito, não precisamos dele aqui.
          initialValue: widget.item.image,
          onChanged: (newImage) {
            // ✅ 3. A MÁGICA ACONTECE AQUI
            // Quando a imagem muda, notificamos o widget pai (e o Cubit)
            // com o item atualizado, contendo o novo ImageModel.
            if (newImage == null) {
              widget.onUpdate(widget.item.copyWith(forceImageToNull: true));
            } else {
              widget.onUpdate(widget.item.copyWith(image: newImage));
            }
          },
        ),
        const SizedBox(height: 6),
        Text(
          "Imagem do Tamanho",
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Nome do Tamanho'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Ex: Pequena, Média, Grande...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          onChanged: (value) => widget.onUpdate(widget.item.copyWith(name: value)),
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Preço (R\$)'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter()],

          decoration: InputDecoration(

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),

          onChanged: (value) {
            final priceInCents = ((double.tryParse(value.replaceAll(',', '.')) ?? 0) * 100).round();
            widget.onUpdate(widget.item.copyWith(price: priceInCents));
          },
        ),
      ],
    );
  }

  Widget _buildSlicesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Qtd. de Pedaços'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _slicesController,
          decoration: InputDecoration(
            hintText: 'Ex: 4, 6, 8...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => widget.onUpdate(widget.item.copyWith(slices: int.tryParse(value) ?? 0)),
        ),
      ],
    );
  }

  Widget _buildFlavorsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Quantidade de Sabores'),
        const SizedBox(height: 8),
        Container(
        //  padding: const EdgeInsets.all(4),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [1, 2, 3, 4].map((flavorCount) {
              final isSelected = widget.item.maxFlavors == flavorCount;
              return GestureDetector(
                onTap: () => widget.onUpdate(widget.item.copyWith(maxFlavors: flavorCount)),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      flavorCount.toString(),
                      style: TextStyle(
                        color: isSelected ? Colors.blue : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPdvField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Código PDV'),
        const SizedBox(height: 6),
        TextFormField(
          controller: _pdvController,
          decoration: InputDecoration(
            hintText: 'Código do sistema',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          onChanged: (value) => widget.onUpdate(widget.item.copyWith(externalCode: value)),
        ),
      ],
    );
  }

  Widget _buildStatusSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Status do Tamanho",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Switch(
            value: widget.item.isActive,

            onChanged: (value) => widget.onUpdate(widget.item.copyWith(isActive: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
      ),
    );
  }
}