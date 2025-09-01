import 'package:flutter/material.dart';

import '../../../core/enums/variant_type.dart';

import '../../../models/product_variant_link.dart';

import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:totem_pro_admin/models/variant_option.dart';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';

// ✅ --- INTERFACES DE CALLBACK ---
// Para manter o código limpo, definimos os tipos de função que o widget vai usar para se comunicar com a tela pai.
typedef OnLinkRulesChanged = void Function(ProductVariantLink updatedLink);
typedef OnOptionUpdated = void Function(VariantOption updatedOption);
typedef OnOptionRemoved = void Function(VariantOption optionToRemove);
typedef OnOptionPausable = void Function(VariantOption option, bool isPausable);
typedef OnToggleAvailability = void Function(); // ✅ NOVO TIPO DE CALLBACK

// ✅ Defina o tipo do novo callback no topo do arquivo
typedef OnLinkNameChanged = void Function(String newName);

class VariantLinkCard extends StatefulWidget {
  final ProductVariantLink link;
  final VoidCallback onRemoveLink;
  final OnLinkRulesChanged onLinkRulesChanged;
  final OnOptionUpdated onOptionUpdated;
  final OnOptionRemoved onOptionRemoved;
  final OnLinkNameChanged onLinkNameChanged;
  final OnToggleAvailability onToggleAvailability;
  final VoidCallback onAddOption;

  const VariantLinkCard({
    super.key,
    required this.link,
    required this.onRemoveLink,
    required this.onLinkRulesChanged,
    required this.onOptionUpdated,
    required this.onOptionRemoved,
    required this.onLinkNameChanged,
    required this.onToggleAvailability,
  required this.onAddOption,
  });

  @override
  State<VariantLinkCard> createState() => _VariantLinkCardState();
}

class _VariantLinkCardState extends State<VariantLinkCard> {
  bool _isExpanded = false;
  // ✅ 3. ADICIONE ESTADO PARA O NOME
  bool _isEditingName = false;
  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.link.variant.name);

    // ✅ 2. INICIALIZE O FOCUSNODE E ADICIONE O LISTENER
    _nameFocusNode = FocusNode();
    _nameFocusNode.addListener(_onNameFocusChange);
  }

  @override
  void dispose() {
    _nameController.dispose();
    // ✅ 3. FAÇA O DISPOSE DO FOCUSNODE E REMOVA O LISTENER
    _nameFocusNode.removeListener(_onNameFocusChange);
    _nameFocusNode.dispose();
    super.dispose();
  }

// ✅ NOVO MÉTODO PARA LIDAR COM A PERDA DE FOCO
  void _onNameFocusChange() {
    // Se o campo de texto NÃO tem mais o foco E ainda estamos no modo de edição...
    if (!_nameFocusNode.hasFocus && _isEditingName) {
      print('Campo de nome perdeu o foco, salvando...');
      // ...chama o callback para salvar o novo nome...
      widget.onLinkNameChanged(_nameController.text);
      // ...e sai do modo de edição.
      setState(() {
        _isEditingName = false;
      });
    }
  }

  // Garante que o controller seja atualizado se o widget mudar
  @override
  void didUpdateWidget(covariant VariantLinkCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.link.variant.name != oldWidget.link.variant.name) {
      _nameController.text = widget.link.variant.name;
    }
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


  Widget _buildEditableTitle() {
    if (_isEditingName) {
      // --- MODO DE EDIÇÃO (SEM BOTÕES) ---
      return TextField(
        controller: _nameController,
        focusNode: _nameFocusNode, // ✅ Conecta o FocusNode
        autofocus: true,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero, // Remove padding extra
          border: InputBorder.none,      // Deixa sem linha embaixo
        ),
        // Salva também quando o usuário pressiona "Enter"
        onSubmitted: (newValue) {
          widget.onLinkNameChanged(newValue);
          setState(() {
            _isEditingName = false;
          });
        },
      );
    } else {
      // --- MODO DE VISUALIZAÇÃO ---
      // Usamos um GestureDetector para tornar toda a área clicável
      return GestureDetector(
        onTap: () {
          setState(() {
            _isEditingName = true;
            // Pede o foco para o TextField assim que ele for construído
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _nameFocusNode.requestFocus();
            });
          });
        },
        child: Row(
          children: [
            Text(
              widget.link.variant.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit, size: 16, color: Colors.grey),
          ],
        ),
      );
    }
  }

  // Helper para atualizar as regras e notificar o cubit
  void _updateRules({int? min, int? max}) {
    final newMin = min ?? widget.link.minSelectedOptions;
    final newMax = max ?? widget.link.maxSelectedOptions;

    // Garante que max >= min
    if (newMax < newMin) return;

    final updatedLink = widget.link.copyWith(
      minSelectedOptions: newMin,
      maxSelectedOptions: newMax,
    );
    widget.onLinkRulesChanged(updatedLink);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // --- TAG DO TIPO DE GRUPO ---
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    // Use uma cor baseada no tipo do grupo para um visual mais rico
                    color: _getColorForVariantType(widget.link.variant.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                          _getIconForVariantType(widget.link.variant.type),
                          color: _getColorForVariantType(widget.link.variant.type),
                          size: 14
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatVariantType(widget.link.variant.type),
                        style: TextStyle(
                            color: _getColorForVariantType(widget.link.variant.type),
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
       //   const SizedBox(width: 16),


          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: _buildCollapsedHeader(),
          ),

          // Conteúdo que só aparece quando expandido
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }



// ✅ SUBSTITUA O MÉTODO INTEIRO POR ESTE
  Widget _buildCollapsedHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [


          // --- NOME E SUBTÍTULO (EXPANSÍVEL) ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEditableTitle(),
                const SizedBox(height: 4),
                Text(
                  "Contém ${widget.link.variant.options.length} complemento(s)",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // --- BOTÕES DE AÇÃO ---
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [

              OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Complementos"),
                // ✅ AÇÃO CONECTADA: Chama a mesma função de edição que o lápis chamaria.
                onPressed: widget.onAddOption,
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(fontSize: 13)
                ),
              ),
              const SizedBox(width: 8),
              // Ícones de ação para o GRUPO (pausar, remover)
              IconButton(
                icon: Icon(widget.link.available ? Icons.pause : Icons.play_arrow, color: Colors.orange.shade700),
                tooltip: "Pausar/Ativar grupo neste produto",
                onPressed: widget.onToggleAvailability,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: "Remover grupo deste produto",
                onPressed: widget.onRemoveLink,
              ),
            ],
          )
        ],
      ),
    );
  }

// ✅ ADICIONE ESTES MÉTODOS HELPER DENTRO DA SUA CLASSE TAMBÉM
// Eles ajudam a deixar o código do cabeçalho mais limpo e dinâmico

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



  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Seção de Regras (Min/Max)
          _buildRulesSection(),
       SizedBox(height: 16,),
          // Tabela de Opções
          _buildOptionsTable(),
        ],
      ),
    );
  }

  Widget _buildRulesSection() {
    final isRequired = widget.link.minSelectedOptions > 0;

    return Row(
      children: [
        // Dropdown Obrigatório/Opcional
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<bool>(
            elevation: 0,
            padding: EdgeInsetsGeometry.zero,
            value: isRequired,
            items: const [
              DropdownMenuItem(value: true, child: Text("Obrigatório")),
              DropdownMenuItem(value: false, child: Text("Opcional")),
            ],
            onChanged: (value) {
              if (value == null) return;
              // Se virar obrigatório, o mínimo é 1. Se virar opcional, o mínimo é 0.
              _updateRules(min: value ? 1 : 0);
            },
            decoration: const InputDecoration(labelText: "Este grupo é", border: OutlineInputBorder()),
          ),
        ),
        const SizedBox(width: 16),
        // Stepper Mínimo
        _buildQuantityStepper(
           "Qtd. Mínima",
          widget.link.minSelectedOptions,
           (newValue) => _updateRules(min: newValue),
        ),
        const SizedBox(width: 16),
        // Stepper Máximo
        _buildQuantityStepper(
           "Qtd. Máxima",
           widget.link.maxSelectedOptions,
           (newValue) => _updateRules(max: newValue),
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


  Widget _buildOptionsTable() {
    return Column(
      children: [
        // Cabeçalho da tabela
        Row(
          children: const [
            SizedBox(width: 40), // Espaço para o drag handle
            Expanded(flex: 3, child: Text("Complemento", style: TextStyle(color: Colors.grey, fontSize: 12))),
            Expanded(flex: 2, child: Text("Preço", style: TextStyle(color: Colors.grey, fontSize: 12))),
            SizedBox(width: 48), // Espaço para ações
          ],
        ),
        const Divider(),
        // Corpo da tabela
        if (widget.link.variant.options.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Text("Nenhum complemento adicionado a este grupo ainda."),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.link.variant.options.length,
            itemBuilder: (context, index) {
              final option = widget.link.variant.options[index];
              // Cada linha da tabela pode ser um widget separado para gerenciar a edição inline,
              // ou podemos simplificar por enquanto.
              return _buildOptionRow(option);
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
          ),
      ],
    );
  }

  // Widget para cada linha da tabela de opções
  Widget _buildOptionRow(VariantOption option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(option.resolvedName, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 2,
            child: Text(UtilBrasilFields.obterReal(option.resolvedPrice / 100)),
          ),
          // Menu de Ações para a opção
          SizedBox(
            width: 48,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  // TODO: Abrir um dialog para editar os detalhes da OPÇÃO
                } else if (value == 'remove') {
                  widget.onOptionRemoved(option);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'remove', child: Text('Remover do Grupo')),
              ],
              icon: const Icon(Icons.more_vert, color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}




