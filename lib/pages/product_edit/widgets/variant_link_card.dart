import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/variant_callbacks.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/variant_option_list.dart';

import '../../../core/enums/variant_type.dart';
import '../../../models/product_variant_link.dart';
import 'package:totem_pro_admin/models/variant_option.dart';



class VariantLinkCard extends StatefulWidget {
  final ProductVariantLink link;
  final VoidCallback onRemoveLink;
  final OnLinkRulesChanged onLinkRulesChanged;
  final OnOptionUpdated onOptionUpdated;
  final OnOptionRemoved onOptionRemoved;
  final OnLinkNameChanged onLinkNameChanged;
  final VoidCallback onAddOption;
  final VoidCallback onToggleAvailability;

  const VariantLinkCard({
    super.key,
    required this.link,
    required this.onRemoveLink,
    required this.onLinkRulesChanged,
    required this.onOptionUpdated,
    required this.onOptionRemoved,
    required this.onLinkNameChanged,
    required this.onAddOption,
    required this.onToggleAvailability,
  });

  @override
  State<VariantLinkCard> createState() => _VariantLinkCardState();
}

class _VariantLinkCardState extends State<VariantLinkCard> {
  // O estado agora só se preocupa com o nome e a expansão
  bool _isEditingName = false;
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.link.variant.name);
    _nameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _updateRules({int? min, int? max}) {
    final newMin = min ?? widget.link.minSelectedOptions;
    final newMax = max ?? widget.link.maxSelectedOptions;
    if (newMax < newMin) return;
    widget.onLinkRulesChanged(
        widget.link.copyWith(minSelectedOptions: newMin, maxSelectedOptions: newMax));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),

      child: ExpansionTile(
        dense: true,
        // O cabeçalho continua aqui
        leading: _buildVariantTypeBadge(),
        title:  _buildEditableTitle(),

        subtitle: Text(
          "Contém ${widget.link.variant.options.length} complemento(s)",
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),

        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildRulesSection(),
          ),

          VariantOptionsList(
            options: widget.link.variant.options,
            onAddOption: widget.onAddOption,
            onOptionUpdated: widget.onOptionUpdated,
            onOptionRemoved: widget.onOptionRemoved,
          )
        ],
      ),
    );
  }






  Widget _buildEditableTitle() {
    if (_isEditingName) {
      return TextField(
        controller: _nameController,
        focusNode: _nameFocusNode,
        autofocus: true,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
        onSubmitted: (newValue) {
          widget.onLinkNameChanged(newValue);
          setState(() {
            _isEditingName = false;
          });
        },
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isEditingName = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _nameFocusNode.requestFocus();
            });
          });
        },
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.link.variant.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            _buildTrailingActions()
          ],
        ),
      );
    }
  }

  Widget _buildVariantTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getColorForVariantType(widget.link.variant.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(
        _getIconForVariantType(widget.link.variant.type),
        color: _getColorForVariantType(widget.link.variant.type),
        size: 20,
      ),
    );
  }



  Widget _buildTrailingActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(widget.link.available ? Icons.pause : Icons.play_arrow,
              color: widget.link.available ? Colors.orange :Colors.green, size: 20),
          onPressed: widget.onToggleAvailability,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          onPressed: (){
    showRemoveGroupBottomSheet(
    context,
    onConfirm: () {
    // Sua lógica para remover o grupo aqui
    widget.onRemoveLink();
    },
    );
    }


        ),


      ],
    );
  }

  Widget _buildRulesSection() {
    final isRequired = widget.link.minSelectedOptions > 0;
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text("Este grupo é obrigatório ou opcional?", style: const TextStyle(fontSize: 14,)),
          const SizedBox(height: 4),
          DropdownButtonFormField<bool>(
            value: isRequired,
            items: const [
              DropdownMenuItem(
                value: true,
                child: Text(
                  "Obrigatório",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF151515), // ifdl-text-color-primary
                  ),
                ),
              ),
              DropdownMenuItem(
                value: false,
                child: Text(
                  "Opcional",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF151515), // ifdl-text-color-primary
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              _updateRules(min: value ? 1 : 0);
            },
            decoration: InputDecoration(

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), // ifdl-border-radius-md
                borderSide: const BorderSide(
                  color: Color(0xFFEBEBEB), // ifdl-outline-color-default
                  width: 1, // ifdl-border-width-hairline
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFEBEBEB),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF0083CC), // ifdl-outline-color-focus
                  width: 2, // ifdl-border-width-thin
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              filled: true,
              fillColor: Colors.white, // ifdl-neutral-background-color-primary
            ),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF151515), // ifdl-text-color-primary
            ),
            dropdownColor: Colors.white, // ifdl-neutral-background-color-primary
            icon: const Icon(
              Icons.expand_more,
              color: Color(0xFF666666), // ifdl-text-color-secondary
              size: 24, // ifdl-icon-size-scale-md
            ),
            borderRadius: BorderRadius.circular(8), // ifdl-border-radius-md
            menuMaxHeight: 200,
            isExpanded: true,
          ),
          const SizedBox(height: 16),
          // Steppers em coluna para mobile
          Row(
            children: [
              Expanded(
                child: _buildQuantityStepper(
                  "Mínimo",
                  widget.link.minSelectedOptions,
                      (newValue) => _updateRules(min: newValue),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuantityStepper(
                  "Máximo",
                  widget.link.maxSelectedOptions,
                      (newValue) => _updateRules(max: newValue),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // Layout para desktop
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<bool>(
              value: isRequired,
              items: const [
                DropdownMenuItem(value: true, child: Text("Obrigatório")),
                DropdownMenuItem(value: false, child: Text("Opcional")),
              ],
              onChanged: (value) {
                if (value == null) return;
                _updateRules(min: value ? 1 : 0);
              },
              decoration: const InputDecoration(
                labelText: "Este grupo é",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildQuantityStepper(
              "Qtd. Mínima",
              widget.link.minSelectedOptions,
                  (newValue) => _updateRules(min: newValue),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildQuantityStepper(
              "Qtd. Máxima",
              widget.link.maxSelectedOptions,
                  (newValue) => _updateRules(max: newValue),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildQuantityStepper(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14,)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 20),
                onPressed: () => onChanged(value - 1),
              ),
              Expanded(
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }



  void showRemoveGroupBottomSheet(BuildContext context, {required VoidCallback onConfirm}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: const Text(
                  "Remover grupo",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF151515), // ifdl-text-color-primary

                  ),
                ),
              ),

              // Body
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: const Text(
                  "Tem certeza que deseja remover o grupo deste produto?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF151515), // ifdl-text-color-primary

                    height: 1.5,
                  ),
                ),
              ),

              // Footer - Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide.none,
                        backgroundColor: const Color(0xFFF5F5F5), // ifdl-neutral-background-color-secondary
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF151515), // ifdl-text-color-primary

                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Confirmar",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white, // ifdl-color-neutral-100

                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Espaço extra para evitar que o conteúdo fique muito próximo da borda inferior
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }



  IconData _getIconForVariantType(VariantType type) {
    switch(type) {
      case VariantType.INGREDIENTS: return Icons.fastfood_outlined;
      case VariantType.SPECIFICATIONS: return Icons.rule_sharp;
      case VariantType.CROSS_SELL: return Icons.shopping_bag_outlined;
      default: return Icons.category_outlined;
    }
  }

  Color _getColorForVariantType(VariantType type) {
    switch(type) {
      case VariantType.INGREDIENTS: return Colors.green.shade800;
      case VariantType.SPECIFICATIONS: return Colors.blue.shade800;
      case VariantType.CROSS_SELL: return Colors.purple.shade800;
      default: return Colors.grey.shade800;
    }
  }


}