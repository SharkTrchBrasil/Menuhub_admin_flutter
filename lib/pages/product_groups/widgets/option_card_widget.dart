import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OptionGroupCard extends StatefulWidget {
  final String groupName;
  final String groupType;
  final int complementCount;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final VoidCallback onAddComplement;
  final VoidCallback onPauseGroup;
  final VoidCallback onDeleteGroup;
  final bool isRequired;
  final ValueChanged<bool> onRequiredChanged;
  final int minQuantity;
  final int maxQuantity;
  final ValueChanged<int> onMinQuantityChanged;
  final ValueChanged<int> onMaxQuantityChanged;
  final List<ComplementItem> complements;

  const OptionGroupCard({
    super.key,
    required this.groupName,
    required this.groupType,
    required this.complementCount,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onAddComplement,
    required this.onPauseGroup,
    required this.onDeleteGroup,
    required this.isRequired,
    required this.onRequiredChanged,
    required this.minQuantity,
    required this.maxQuantity,
    required this.onMinQuantityChanged,
    required this.onMaxQuantityChanged,
    required this.complements,
  });

  @override
  State<OptionGroupCard> createState() => _OptionGroupCardState();
}

class ComplementItem {
  final String id; // ✅ Adicione um ID único
  final String name;
  final String imageUrl;
  final double price;
  final String? pdvCode;
  final bool isActive;

  ComplementItem({
    required this.id, // ✅ ID único obrigatório
    required this.name,
    required this.imageUrl,
    required this.price,
    this.pdvCode,
    this.isActive = true,
  });

  // Método para gerar uma chave única baseada no ID
  Key get key => Key(id);
}

class _OptionGroupCardState extends State<OptionGroupCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do card
          _buildHeader(),

          // Conteúdo expandido
          if (widget.isExpanded) _buildExpandedContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag do tipo de grupo
          _buildGroupTypeTag(),
          const SizedBox(height: 12),

          // Linha principal com título e ações
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informações do grupo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.groupName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF151515),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Contém ${widget.complementCount} complemento${widget.complementCount != 1 ? 's' : ''}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),

              // Botões de ação
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botão Adicionar Complementos
                  _buildAddButton(),
                  const SizedBox(width: 8),

                  // Botão Expandir/Recolher
                  IconButton(
                    icon: Icon(
                      widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: const Color(0xFF666666),
                      size: 20,
                    ),
                    onPressed: widget.onToggleExpand,
                    splashRadius: 20,
                  ),

                  // Botão Pausar/Ativar
                  _buildIconButton(
                    icon: Icons.pause,
                    tooltip: 'Pausar grupo',
                    onPressed: widget.onPauseGroup,
                  ),

                  // Botão Remover
                  _buildIconButton(
                    icon: Icons.delete_outline,
                    tooltip: 'Remover grupo',
                    onPressed: widget.onDeleteGroup,
                    color: const Color(0xFFDC3545),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTypeTag() {
    Color tagColor;
    IconData tagIcon;

    switch (widget.groupType) {
      case 'Ingredientes':
        tagColor = const Color(0xFF00753D);
        tagIcon = Icons.restaurant;
        break;
      case 'Especificações':
        tagColor = const Color(0xFF0066A3);
        tagIcon = Icons.tune;
        break;
      case 'Venda Cruzada':
        tagColor = const Color(0xFF7B00A3);
        tagIcon = Icons.shopping_bag;
        break;
      default:
        tagColor = const Color(0xFF666666);
        tagIcon = Icons.category;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tagColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tagIcon, size: 14, color: tagColor),
          const SizedBox(width: 4),
          Text(
            widget.groupType,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: tagColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: widget.onAddComplement,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEB0033),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 16),
          SizedBox(width: 4),
          Text("Complementos"),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20, color: color ?? const Color(0xFF666666)),
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 20,
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Configurações do grupo
          _buildGroupSettings(),
          const SizedBox(height: 24),

          // Tabela de complementos
          _buildComplementsTable(),
        ],
      ),
    );
  }

  Widget _buildGroupSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Configurações do grupo",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF151515),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            // Tipo de grupo (Obrigatório/Opcional)
            Expanded(
              child: _buildRequiredDropdown(),
            ),
            const SizedBox(width: 16),

            // Quantidade mínima
            _buildQuantityStepper(
              "Qtd. mínima",
              widget.minQuantity,
              widget.onMinQuantityChanged,
            ),
            const SizedBox(width: 16),

            // Quantidade máxima
            _buildQuantityStepper(
              "Qtd. máxima",
              widget.maxQuantity,
              widget.onMaxQuantityChanged,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRequiredDropdown() {
    return DropdownButtonFormField<bool>(
      value: widget.isRequired,
      items: const [
        DropdownMenuItem(
          value: false,
          child: Text("Opcional"),
        ),
        DropdownMenuItem(
          value: true,
          child: Text("Obrigatório"),
        ),
      ],
      onChanged: (value) => widget.onRequiredChanged(value ?? false),
      decoration: const InputDecoration(
        labelText: "Este grupo é obrigatório ou opcional?",
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildQuantityStepper(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF666666),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 120,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEBEBEB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                onPressed: () => onChanged(value - 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => onChanged(value + 1),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComplementsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Complementos",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF151515),
          ),
        ),
        const SizedBox(height: 16),

        if (widget.complements.isEmpty)
          _buildEmptyState()
        else
          _buildTable(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEBEBEB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFF666666)),
          const SizedBox(height: 16),
          const Text(
            "Nenhum complemento adicionado",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF151515),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Adicione complementos para que os clientes possam personalizar seus pedidos",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF666666)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onAddComplement,
            child: const Text("Adicionar primeiro complemento"),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        columns: const [
          DataColumn(label: SizedBox(width: 40)),
          DataColumn(label: Text("Imagem")),
          DataColumn(label: Text("Produto")),
          DataColumn(label: Text("Preço")),
          DataColumn(label: Text("Código PDV")),
          DataColumn(label: Text("Ações")),
        ],
        rows: widget.complements.map((complement) => _buildTableRow(complement)).toList(),
      ),
    );
  }

  DataRow _buildTableRow(ComplementItem complement) {
    return DataRow(
      cells: [
        // Ícone de arrastar
        const DataCell(
          Icon(Icons.drag_indicator, size: 16, color: Color(0xFF666666)),
        ),
        // Imagem
        DataCell(
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: NetworkImage(complement.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Nome do produto
        DataCell(Text(complement.name)),
        // Preço
        DataCell(Text("R\$ ${complement.price.toStringAsFixed(2)}")),
        // Código PDV
        DataCell(Text(complement.pdvCode ?? "-")),
        // Ações
        DataCell(
          Row(
            children: [
              _buildTableActionButton(
                icon: complement.isActive ? Icons.pause : Icons.play_arrow,
                tooltip: complement.isActive ? 'Pausar' : 'Ativar',
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              _buildTableActionButton(
                icon: Icons.more_vert,
                tooltip: 'Opções',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 16),
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 16,
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
    );
  }
}