import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totem_pro_admin/models/variant_option.dart';

import '../../product_edit/widgets/edit_option_form.dart';
import '../../product_edit/widgets/variant_callbacks.dart';
import '../../product_edit/widgets/varion_option_bottom_sheet.dart';



class VariantOptionTile extends StatefulWidget {
  final VariantOption option;
  final OnOptionRemoved onRemove; // ✅ 2. TIPO CORRIGIDO (era VoidCallback)
  final OnOptionUpdated onUpdate;
  final int index;
  final bool isMobile;

  const VariantOptionTile({
    super.key,
    required this.option,
    required this.onRemove,
    required this.onUpdate,
    required this.index,
    this.isMobile = false,
  });

  @override
  State<VariantOptionTile> createState() => _VariantOptionTileState();
}

class _VariantOptionTileState extends State<VariantOptionTile> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _pdvController;
  bool _isMobileEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(covariant VariantOptionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.option != oldWidget.option) {
      _initializeControllers();
    }
  }

  void _initializeControllers() {
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

  void _saveChanges() {
    final priceText = _priceController.text;
    final priceInCents = priceText.isEmpty
        ? widget.option.price_override
        : (UtilBrasilFields.converterMoedaParaDouble(priceText) * 100).toInt();

    final updatedOption = widget.option.copyWith(
      name_override: _nameController.text,
      price_override: priceInCents,
      pos_code: _pdvController.text,
    );
    widget.onUpdate(updatedOption);
  }

  void _updateSingleField({bool? available}) {
    final updatedOption = widget.option.copyWith(available: available);
    widget.onUpdate(updatedOption);
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return OptionActionsBottomSheet(
          option: widget.option,
          onUpdated: widget.onUpdate,
          // Agora os tipos são compatíveis e a função é passada diretamente
          onRemoved: widget.onRemove,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.isMobile || MediaQuery.of(context).size.width < 768;
    return isMobile ? _buildMobileCard() : _buildDesktopRow();
  }

  // =======================================================================
  // ========================== LAYOUT MOBILE ==============================
  // =======================================================================

  Widget _buildMobileCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isMobileEditing
              ? EditOptionForm(
            option: widget.option,
            onConfirm: (updatedOption) {
              widget.onUpdate(updatedOption);
              setState(() => _isMobileEditing = false);
            },
            onCancel: () {
              _initializeControllers();
              setState(() => _isMobileEditing = false);
            },
          )
              : _buildMobileDisplayView(),
        ),
      ),
    );
  }

  Widget _buildMobileDisplayView() {
    return Row(
      key: const ValueKey('display'),
      children: [
        _buildImageSection(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.option.resolvedName, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    UtilBrasilFields.obterReal((widget.option.price_override ?? 0) / 100),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  if(widget.option.pos_code != null && widget.option.pos_code!.isNotEmpty) ...[
                    Text(" • ", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    Text("PDV: ${widget.option.pos_code!}", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  ]
                ],
              ),
            ],
          ),
        ),



    _buildToggleStatusButton(),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onPressed: () => _showActions(context),
        ),
      ],
    );
  }

  // =======================================================================
  // ========================== LAYOUT DESKTOP =============================
  // =======================================================================

  Widget _buildDesktopRow() {
    return Material(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: widget.index,
              child: const MouseRegion(cursor: SystemMouseCursors.grab, child: Icon(Icons.drag_indicator)),
            ),
            const SizedBox(width: 16),
            SizedBox(width: 75, child: _buildImageSection()),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: _buildNameField()),
            const SizedBox(width: 12),
            Expanded(flex: 2, child: Text(widget.option.description ?? 'Sem descrição')),
            const SizedBox(width: 12),
            SizedBox(width: 130, child: _buildPriceField()),
            const SizedBox(width: 12),
            SizedBox(width: 130, child: _buildPdvField()),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildToggleStatusButton(),
                  // ✅ 3. CORREÇÃO DA CHAMADA DE REMOÇÃO NO DESKTOP
                  IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                      onPressed: () => widget.onRemove(widget.option)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey.shade200,
          ),
          child: widget.option.imagePath != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              widget.option.imagePath!,
              width: 60,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderImage(),
            ),
          )
              : _buildPlaceholderImage(),
        ),

      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return const Center(
      child: Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(labelText: 'Nome', isDense: true, border: OutlineInputBorder()),
      onEditingComplete: _saveChanges,
      onTapOutside: (_) => _saveChanges(),
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      textAlign: TextAlign.right,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter(moeda: true)],
      decoration: const InputDecoration(labelText: 'Preço', isDense: true, border: OutlineInputBorder(), prefixText: 'R\$ '),
      onEditingComplete: _saveChanges,
      onTapOutside: (_) => _saveChanges(),
    );
  }

  Widget _buildPdvField() {
    return TextFormField(
      controller: _pdvController,
      decoration: const InputDecoration(labelText: 'Código PDV', isDense: true, border: OutlineInputBorder()),
      onEditingComplete: _saveChanges,
      onTapOutside: (_) => _saveChanges(),
    );
  }

  // ✅ 1. NOVO MÉTODO REUTILIZÁVEL PARA O BOTÃO DE STATUS
  Widget _buildToggleStatusButton() {
    return IconButton(
      tooltip: widget.option.available ? "Pausar complemento" : "Ativar complemento",
      icon: Icon(widget.option.available ? Icons.pause_circle_outline : Icons.play_circle_outline),
      color: widget.option.available ? Colors.orange.shade700 : Colors.green.shade700,
      onPressed: () => _updateSingleField(available: !widget.option.available),
    );
  }
}
