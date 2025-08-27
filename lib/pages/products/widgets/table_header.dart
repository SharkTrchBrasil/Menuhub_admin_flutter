import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';

class TableHeader extends StatelessWidget {
  final int selectedCount;
  final bool isAllSelected;
  final VoidCallback onSelectAll;
  final VoidCallback onAddToCategory;
  final VoidCallback onPause;
  final VoidCallback onActivate;
  final VoidCallback onRemove;

  const TableHeader({
    super.key,
    required this.selectedCount,
    required this.isAllSelected,
    required this.onSelectAll,
    required this.onAddToCategory,
    required this.onPause,
    required this.onActivate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ LÓGICA PRINCIPAL: Decide o que mostrar com base na seleção e na plataforma.
    if (selectedCount > 0) {
      // Se há itens selecionados, mostra a barra de ações em QUALQUER plataforma.
      return _buildSelectionActionsBar(context);
    } else {
      // Se NENHUM item está selecionado...
      return ResponsiveBuilder(
        // ...não mostra nada no mobile.
        mobileBuilder: (context, constraints) => const SizedBox.shrink(),
        // ...mostra o cabeçalho estático da tabela no desktop.
        desktopBuilder: (context, constraints) => _buildDesktopHeaderRow(context),
      );
    }
  }

  // ✅ NOVO WIDGET: O cabeçalho da tabela para desktop quando NADA está selecionado.
  Widget _buildDesktopHeaderRow(BuildContext context) {
    final headerTextStyle = TextStyle(
      color: Colors.grey.shade600,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Adiciona uma borda inferior para separar do conteúdo
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        children: [
          Checkbox(

          value: isAllSelected,
          onChanged: (_) => onSelectAll(),
        ),
        const SizedBox(width: 12),
        // Coluna "Produto" - flex: 4 (mais espaço)
        Expanded(
          flex: 4,
          child: Text('PRODUTO', style: headerTextStyle),
        ),
        // Coluna "Categoria" - flex: 2
        Expanded(
          flex: 2,
          child: Text('CATEGORIA', style: headerTextStyle),
        ),
        // Coluna "Visualizações" - flex: 1
        Expanded(
          flex: 1,
          child: Text('VISUALIZAÇÕES', style: headerTextStyle, textAlign: TextAlign.center),
        ),
        // Coluna "Vendas" - flex: 1
        Expanded(
          flex: 1,
          child: Text('VENDAS', style: headerTextStyle, textAlign: TextAlign.center),
        ),
        // Coluna "Ações" - Largura fixa
        SizedBox(
          width: 120,
          child: Text('AÇÕES', style: headerTextStyle, textAlign: TextAlign.center),
        ),

        ],
      ),
    );
  }

  // ✅ WIDGET ATUALIZADO: Barra de ações que aparece quando HÁ seleção.
  Widget _buildSelectionActionsBar(BuildContext context) {
    final bool isMobile = !ResponsiveBuilder.isDesktop(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).primaryColor.withOpacity(0.08),
      child: Row(
        children: [
          // Checkbox para selecionar/desselecionar todos
          Checkbox(
            value: isAllSelected,
            onChanged: (_) => onSelectAll(),
          ),
          const SizedBox(width: 16),
          // Texto com a contagem de itens
          Text(
            '$selectedCount selecionado(s)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(), // Empurra as ações para a direita

          // Ações
          _actionButton(
            context,
            label: 'Alterar categoria',
            icon: Icons.drive_file_move_outline,
            onPressed: onAddToCategory,
            isMobile: isMobile,
            forceTextOnMobile: true,
          ),
          if (!isMobile) const VerticalDivider(width: 24, indent: 8, endIndent: 8),
          _actionButton(context, label: 'Pausar', icon: Icons.pause_circle_outline, onPressed: onPause, isMobile: isMobile, color: Colors.orange),
          _actionButton(context, label: 'Ativar', icon: Icons.play_circle_outline, onPressed: onActivate, isMobile: isMobile, color: Colors.green),
          _actionButton(context, label: 'Remover', icon: Icons.delete_outline, onPressed: onRemove,  isMobile: isMobile, color: Colors.red),
        ],
      ),
    );
  }

  Widget _actionButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required VoidCallback onPressed,
        Color? color,
        required bool isMobile,
        bool forceTextOnMobile = false,
      }) {
    final effectiveColor = color ?? Theme.of(context).primaryColor;

    if (isMobile && !forceTextOnMobile) {
      return IconButton(
        icon: Icon(icon, color: effectiveColor),
        tooltip: label,
        onPressed: onPressed,
      );
    }

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: effectiveColor, size: 20),
      label: Text(
        label,
        style: TextStyle(color: effectiveColor, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}