import 'package:flutter/material.dart';

import '../../../core/enums/variant_type.dart';
import '../../../models/product_variant_link.dart';
import '../../../models/variant.dart';
import '../../../models/variant_option.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/product_variant_link.dart';
import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/pages/edit_product/cubit/product_wizard_cubit.dart'; // Importe o CUBIT do WIZARD

class VariantLinkCard extends StatefulWidget {
  final ProductVariantLink link;
  final VoidCallback onRemove; // ✅ Parâmetro para a função de remover

  const VariantLinkCard({
    super.key,
    required this.link,
    required this.onRemove,
  });

  @override
  State<VariantLinkCard> createState() => _VariantLinkCardState();
}

class _VariantLinkCardState extends State<VariantLinkCard> {
  // Estado local para gerenciar as regras do grupo
  late bool _isRequired;
  late int _minQty;
  late int _maxQty;

  @override
  void initState() {
    super.initState();
    // Inicia o estado local com os valores do link
    _isRequired = widget.link.isRequired;
    _minQty = widget.link.minSelectedOptions;
    _maxQty = widget.link.maxSelectedOptions;
  }

  // Função para notificar o Cubit sobre mudanças nas regras
  void _updateLinkRulesInCubit() {
    // Monta um novo objeto com os valores atualizados
    final updatedLink = widget.link.copyWith(
      minSelectedOptions: _minQty,
      maxSelectedOptions: _maxQty,
      // A UI não muda o uiDisplayMode diretamente, mas podemos inferir
    );
    // TODO: Chamar um método no Cubit para atualizar este link específico na lista
    context.read<ProductWizardCubit>().updateVariantLink(updatedLink);
    print("Regras atualizadas para o grupo: ${widget.link.variant.name}");
  }


  // Helper para formatar o nome do Enum
  String _formatVariantType(VariantType type) {
    switch(type) {
      case VariantType.INGREDIENTS: return "Ingredientes";
      case VariantType.SPECIFICATIONS: return "Especificações";
      case VariantType.CROSS_SELL: return "Venda Cruzada";
      default: return "Outro";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1, margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        title: _buildCollapsedHeader(),
        trailing: const Icon(Icons.expand_more), // Ícone para indicar que é expansível
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.all(16),
        backgroundColor: Colors.grey[50],
        children: [_buildExpandedContent()],
      ),
    );
  }

  Widget _buildCollapsedHeader() {
    // ✅ Usa os dados de 'link' e 'link.variant'
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Row(
            children: [
              Icon(Icons.category_outlined, color: Colors.blue[800], size: 14),
              const SizedBox(width: 4),
              Text(_formatVariantType(widget.link.variant.type), style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.link.variant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 2),
              Text("Contém ${widget.link.variant.options.length} complementos", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            Tooltip(
              message: "Editar grupo",
              child: IconButton(
                onPressed: () { /* TODO: Abrir painel de edição */ },
                icon: Icon(Icons.edit_outlined, color: Colors.grey[600]),
              ),
            ),
            Tooltip(
              message: "Remover grupo",
              // ✅ CORREÇÃO: Conecta a função onRemove ao botão
              child: IconButton(
                onPressed: widget.onRemove,
                icon: Icon(Icons.delete_outline, color: Colors.red[400]),
              ),
            ),
          ],
        )
      ],
    );
  }


  Widget _buildExpandedContent() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdown("Este grupo é:", _isRequired, (newValue) {
                setState(() {
                  _isRequired = newValue;
                  if (_isRequired && _minQty < 1) _minQty = 1;
                  if (_maxQty < _minQty) _maxQty = _minQty;
                });
                _updateLinkRulesInCubit();
              }),
            ),
            const SizedBox(width: 16),
            _buildQuantityStepper("Qtd. Mínima", _minQty, (newValue) {
              if (newValue <= _maxQty && newValue >= (_isRequired ? 1 : 0)) {
                setState(() => _minQty = newValue);
                _updateLinkRulesInCubit();
              }
            }),
            const SizedBox(width: 16),
            _buildQuantityStepper("Qtd. Máxima", _maxQty, (newValue) {
              if (newValue >= _minQty) {
                setState(() => _maxQty = newValue);
                _updateLinkRulesInCubit();
              }
            }),
          ],
        ),
        const SizedBox(height: 24),
        _buildComplementTable(),
      ],
    );
  }

  Widget _buildDropdown(String label, bool isRequired, ValueChanged<bool> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        DropdownButtonFormField<bool>(
          value: isRequired,
          items: const [
            DropdownMenuItem(value: true, child: Text("Obrigatório")),
            DropdownMenuItem(value: false, child: Text("Opcional")),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityStepper(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          width: 100,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300)
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.remove, size: 20), onPressed: () => onChanged(value - 1)),
              Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(icon: const Icon(Icons.add, size: 20), onPressed: () => onChanged(value + 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComplementTable() {
    // ✅ Itera sobre 'link.variant.options'
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            SizedBox(width: 40),
            Expanded(flex: 3, child: Text("Complemento", style: TextStyle(color: Colors.grey, fontSize: 12))),
            Expanded(flex: 2, child: Text("Preço", style: TextStyle(color: Colors.grey, fontSize: 12))),
            SizedBox(width: 80),
          ],
        ),
        const Divider(),
        ListView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.link.variant.options.length,
          itemBuilder: (context, index) {
            final option = widget.link.variant.options[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.drag_indicator, color: Colors.grey),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: option.imagePath != null && option.imagePath!.isNotEmpty
                        ? Image.network(option.imagePath!, width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported))
                        : Container(width: 40, height: 40, color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(flex: 3, child: Text(option.resolvedName, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Expanded(flex: 2, child: Text("R\$ ${(option.resolvedPrice / 100).toStringAsFixed(2)}")),
                  SizedBox(
                    width: 80,
                    child: Row(
                      children: [
                        IconButton(onPressed: () {}, icon: const Icon(Icons.pause, size: 20, color: Colors.grey)),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey)),
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        )
      ],
    );
  }
}



