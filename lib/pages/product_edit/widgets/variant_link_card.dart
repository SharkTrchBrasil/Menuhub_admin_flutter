import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/enums/variant_type.dart';
import 'package:totem_pro_admin/models/products/product_variant_link.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/variant_callbacks.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/variant_option_list.dart';

/// Este widget agora é TOTALMENTE AGNÓSTICO.
/// Ele não sabe qual Cubit o controla, apenas recebe dados e funções (callbacks).
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
    // Chama o callback recebido pelo construtor
    widget.onLinkRulesChanged(
        widget.link.copyWith(minSelectedOptions: newMin, maxSelectedOptions: newMax));
  }

  @override
  Widget build(BuildContext context) {
    // O layout permanece o mesmo, pois ele já usava os callbacks do widget.
    // Apenas garantimos que não há `context.read` ou `BlocBuilder` aqui.
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  // Todos os seus métodos de build (_buildDesktopLayout, _buildMobileLayout, etc.)
  // permanecem os mesmos, pois eles já chamam funções como `widget.onAddOption`
  // ou `_updateRules`, que são agnósticas.
  // Vou colar o resto do seu código aqui para garantir a completude.

  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDesktopHeader(),
          const SizedBox(height: 24),
          _buildDesktopRulesSection(),
          const SizedBox(height: 24),
          VariantOptionsList(
            options: widget.link.variant.options,
            onAddOption: widget.onAddOption,
            onOptionUpdated: widget.onOptionUpdated,
            onOptionRemoved: widget.onOptionRemoved,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVariantTypeBadge(),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildEditableTitle(),
                      _buildDesktopActions(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Contém ${widget.link.variant.options.length} complemento(s)",
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildDesktopActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 32,
          child: ElevatedButton(
            onPressed: widget.onAddOption,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0083CC),
              side: const BorderSide(color: Color(0xFF0083CC)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Row(children: [Icon(Icons.add, size: 16), SizedBox(width: 6), Text("Complementos", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))]),
          ),
        ),
        const SizedBox(width: 16),
        _buildActionIcon(
          icon: widget.link.available ? Icons.pause : Icons.play_arrow,
          tooltip: widget.link.available ? "Pausar grupo" : "Ativar grupo",
          onTap: widget.onToggleAvailability,
          color: widget.link.available ? const Color(0xFF666666) : const Color(0xFF0083CC),
        ),
        _buildActionIcon(
          icon: Icons.delete_outline,
          tooltip: "Remover grupo",
          onTap: _showRemoveGroupDialog,
          color: const Color(0xFFC00),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMobileHeader(),
          const SizedBox(height: 16),
          _buildMobileRulesSection(),
          const SizedBox(height: 16),
          VariantOptionsList(
            options: widget.link.variant.options,
            onAddOption: widget.onAddOption,
            onOptionUpdated: widget.onOptionUpdated,
            onOptionRemoved: widget.onOptionRemoved,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVariantTypeBadge(),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildEditableTitle(),
            _buildMobileActions(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Contém ${widget.link.variant.options.length} complemento(s)",
          style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  Widget _buildMobileActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 32,
          child: ElevatedButton(
            onPressed: widget.onAddOption,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0083CC),
              side: const BorderSide(color: Color(0xFF0083CC)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Row(children: [Icon(Icons.add, size: 16), SizedBox(width: 4), Text("Complementos", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))]),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xFF666666)),
          onSelected: (value) {
            if (value == 'pause') widget.onToggleAvailability();
            if (value == 'delete') _showRemoveGroupDialog();
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'pause', child: Row(children: [Icon(widget.link.available ? Icons.pause : Icons.play_arrow, size: 20, color: const Color(0xFF666666)), const SizedBox(width: 8), Text(widget.link.available ? "Pausar grupo" : "Ativar grupo")])),
            PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete_outline, size: 20, color: Color(0xFFC00)), const SizedBox(width: 8), const Text("Remover grupo", style: TextStyle(color: Color(0xFFC00)))]))
          ],
        ),
      ],
    );
  }

  // --- O restante dos seus métodos de build (que já são agnósticos) ---
  // (Cole o resto dos métodos _buildActionIcon, _buildDesktopRulesSection, etc. aqui)
  Widget _buildActionIcon({required IconData icon, required String tooltip, required VoidCallback onTap, Color? color}) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Tooltip(message: tooltip, child: MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: onTap, child: Icon(icon, size: 20, color: color ?? const Color(0xFF666666))))));
  Widget _buildDesktopRulesSection() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(flex: 2, child: _buildRequiredDropdown()), const SizedBox(width: 24), Expanded(child: _buildCounter(label: "Qtd. mínima", value: widget.link.minSelectedOptions, onChanged: (newValue) => _updateRules(min: newValue), min: 0, max: widget.link.maxSelectedOptions)), const SizedBox(width: 24), Expanded(child: _buildCounter(label: "Qtd. máxima", value: widget.link.maxSelectedOptions, onChanged: (newValue) => _updateRules(max: newValue), min: widget.link.minSelectedOptions, max: 99))]);
  Widget _buildMobileRulesSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildRequiredDropdown(), const SizedBox(height: 16), Row(children: [Expanded(child: _buildCounter(label: "Qtd. mínima", value: widget.link.minSelectedOptions, onChanged: (newValue) => _updateRules(min: newValue), min: 0, max: widget.link.maxSelectedOptions)), const SizedBox(width: 16), Expanded(child: _buildCounter(label: "Qtd. máxima", value: widget.link.maxSelectedOptions, onChanged: (newValue) => _updateRules(max: newValue), min: widget.link.minSelectedOptions, max: 99))])]);
  Widget _buildVariantTypeBadge() => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _getColorForVariantType(widget.link.variant.type).withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(_getIconForVariantType(widget.link.variant.type), color: _getColorForVariantType(widget.link.variant.type), size: 16), const SizedBox(width: 6), Text(_getVariantTypeName(widget.link.variant.type), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _getColorForVariantType(widget.link.variant.type)))]));
  Widget _buildEditableTitle() { if (_isEditingName) { return IntrinsicWidth(child: TextField(controller: _nameController, focusNode: _nameFocusNode, autofocus: true, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF151515)), decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none, hintText: "Nome do grupo"), onSubmitted: (newValue) { if (newValue.trim().isNotEmpty) { widget.onLinkNameChanged(newValue.trim()); } setState(() => _isEditingName = false); }, onEditingComplete: () { if (_nameController.text.trim().isNotEmpty) { widget.onLinkNameChanged(_nameController.text.trim()); } setState(() => _isEditingName = false); })); } else { return GestureDetector(onTap: () => setState(() { _isEditingName = true; WidgetsBinding.instance.addPostFrameCallback((_) => _nameFocusNode.requestFocus()); }), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(widget.link.variant.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF151515)), overflow: TextOverflow.ellipsis), const SizedBox(width: 8), const Icon(Icons.edit, size: 16, color: Color(0xFF666666))])); } }
  Widget _buildRequiredDropdown() { final isRequired = widget.link.minSelectedOptions > 0; return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Este grupo é obrigatório ou opcional?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF151515))), const SizedBox(height: 4), DropdownButtonFormField<bool>(value: isRequired, items: const [DropdownMenuItem(value: true, child: Text("Obrigatório")), DropdownMenuItem(value: false, child: Text("Opcional"))], onChanged: (value) { if (value != null) _updateRules(min: value ? 1 : 0); }, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEBEBEB))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFEBEBEB))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0083CC))), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), filled: true, fillColor: Colors.white))]); }
  Widget _buildCounter({required String label, required int value, required ValueChanged<int> onChanged, required int min, required int max}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF151515))), const SizedBox(height: 4), Container(decoration: BoxDecoration(border: Border.all(color: const Color(0xFFEBEBEB)), borderRadius: BorderRadius.circular(8)), child: Row(children: [IconButton(icon: const Icon(Icons.remove, size: 18), onPressed: value > min ? () => onChanged(value - 1) : null, color: value > min ? const Color(0xFF151515) : const Color(0xFFA3A3A3), padding: const EdgeInsets.all(8)), Expanded(child: Text(value.toString(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF151515)))), IconButton(icon: const Icon(Icons.add, size: 18), onPressed: value < max ? () => onChanged(value + 1) : null, color: value < max ? const Color(0xFF151515) : const Color(0xFFA3A3A3), padding: const EdgeInsets.all(8))]))]);
  void _showRemoveGroupDialog() => showDialog(context: context, builder: (context) => AlertDialog(title: const Text("Remover grupo"), content: const Text("Tem certeza que deseja remover o grupo deste produto?"), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")), TextButton(onPressed: () { Navigator.pop(context); widget.onRemoveLink(); }, child: const Text("Confirmar", style: TextStyle(color: Colors.red)))]));
  String _getVariantTypeName(VariantType type) { switch(type) { case VariantType.INGREDIENTS: return "Ingredientes"; case VariantType.SPECIFICATIONS: return "Especificações"; case VariantType.CROSS_SELL: return "Venda Cruzada"; case VariantType.DISPOSABLES: return "Descartáveis"; default: return "Grupo"; } }
  IconData _getIconForVariantType(VariantType type) { switch(type) { case VariantType.INGREDIENTS: return Icons.fastfood_outlined; case VariantType.SPECIFICATIONS: return Icons.rule_sharp; case VariantType.CROSS_SELL: return Icons.shopping_bag_outlined; case VariantType.DISPOSABLES: return Icons.local_cafe_outlined; default: return Icons.category_outlined; } }
  Color _getColorForVariantType(VariantType type) { switch(type) { case VariantType.INGREDIENTS: return const Color(0xFF00753D); case VariantType.SPECIFICATIONS: return const Color(0xFF0083CC); case VariantType.CROSS_SELL: return const Color(0xFF7B00A3); case VariantType.DISPOSABLES: return const Color(0xFFC75200); default: return const Color(0xFF666666); } }
}