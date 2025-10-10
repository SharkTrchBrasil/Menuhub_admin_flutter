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

  Widget _buildDesktopHeaderRow(BuildContext context) {
    final headerTextStyle = TextStyle(
      color: Colors.grey.shade600,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white
      ),
      child: Row(
        children: [
          // Checkbox de seleção - MESMA LARGURA DO CARD
          SizedBox(
            width: 30, // ✅ MESMO VALOR DO CARD
            child: Checkbox(
              value: isAllSelected,
              onChanged: (_) => onSelectAll(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 16), // ✅ MESMO ESPAÇAMENTO DO CARD

          // Coluna "Produto" - MESMO FLEX DO CARD
          Expanded(
            flex: 3, // ✅ ALTERADO DE 2 PARA 3 (igual ao card)
            child: Text('PRODUTO', style: headerTextStyle),
          ),

          // Coluna "Categoria" - MESMO FLEX DO CARD
          Expanded(
            flex: 1, // ✅ MANTIDO 1 (igual ao card)
            child: Text('CATEGORIA', style: headerTextStyle),
          ),

          // Coluna "Visualizações" - MESMO FLEX DO CARD
          Expanded(
            flex: 1, // ✅ MANTIDO 1 (igual ao card)
            child: Text(
              'ESTOQUE',
              style: headerTextStyle,
              textAlign: TextAlign.center,
            ),
          ),

          // Coluna "Vendas" - MESMO FLEX DO CARD
          Expanded(
            flex: 1, // ✅ MANTIDO 1 (igual ao card)
            child: Text(
              'VENDAS',
              style: headerTextStyle,
              textAlign: TextAlign.center,
            ),
          ),

          // Coluna "Ações" - MESMA LARGURA DO CARD
          SizedBox(
            width: 140, // ✅ MESMA LARGURA DO CARD
            child: Text(
              'AÇÕES',
              style: headerTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ BARRA DE AÇÕES RESPONSIVA (MOBILE E DESKTOP)
  Widget _buildSelectionActionsBar(BuildContext context) {
    final bool isMobile = ResponsiveBuilder.isMobile(context);
   // final bool isTablet = ResponsiveBuilder.isTablet(context);

    return Container(
      padding: EdgeInsets.symmetric(
     //   horizontal: isMobile ? 6 : 16,
        vertical: isMobile ? 2 : 12,
      ),
      color: Colors.white,
      child: Row(
        children: [
          // Checkbox e contador
          Row(
            children: [
              SizedBox(
                width: 30,
                child: Checkbox(
                  value: isAllSelected,
                  onChanged: (_) => onSelectAll(),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 8),
                Text(
                  '$selectedCount ${selectedCount == 1 ? 'selecionado' : 'selecionados'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),

       //   const Spacer(),

          // Ações - Layout responsivo
          if (isMobile) _buildMobileActions(context) else _buildDesktopActions(context),
        ],
      ),
    );
  }

  // ✅ AÇÕES PARA MOBILE (Ícones com tooltip)
  Widget _buildMobileActions(BuildContext context) {
    return Row(
      children: [
        // Adicionar à categoria
        _MobileActionButton(
          icon: Icons.drive_file_move_outline,
          tooltip: 'Adicionar à categoria',
          onPressed: onAddToCategory,
          color: Colors.blue,
        ),

        const SizedBox(width: 8),

        // Pausar
        _MobileActionButton(
          icon: Icons.pause_circle_outline,
          tooltip: 'Pausar produtos',
          onPressed: onPause,
          color: Colors.orange,
        ),

        const SizedBox(width: 8),

        // Ativar
        _MobileActionButton(
          icon: Icons.play_circle_outline,
          tooltip: 'Ativar produtos',
          onPressed: onActivate,
          color: Colors.green,
        ),

        const SizedBox(width: 8),

        // Remover
        _MobileActionButton(
          icon: Icons.delete_outline,
          tooltip: 'Remover produtos',
          onPressed: onRemove,
          color: Colors.red,
        ),
      ],
    );
  }

  // ✅ AÇÕES PARA DESKTOP (Botões com texto)
  Widget _buildDesktopActions(BuildContext context) {
    return Row(
      children: [
        // Adicionar à categoria
        _DesktopActionButton(
          icon: Icons.drive_file_move_outline,
          label: 'Adicionar à categoria',
          onPressed: onAddToCategory,
        ),

        const SizedBox(width: 12),

        // Pausar
        _DesktopActionButton(
          icon: Icons.pause_circle_outline,
          label: 'Pausar',
          onPressed: onPause,
          color: Colors.orange,
        ),

        const SizedBox(width: 12),

        // Ativar
        _DesktopActionButton(
          icon: Icons.play_circle_outline,
          label: 'Ativar',
          onPressed: onActivate,
          color: Colors.green,
        ),

        const SizedBox(width: 12),

        // Remover
        _DesktopActionButton(
          icon: Icons.delete_outline,
          label: 'Remover',
          onPressed: onRemove,
          color: Colors.red,
        ),
      ],
    );
  }
}

// ✅ BOTÃO DE AÇÃO PARA MOBILE
class _MobileActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;

  const _MobileActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: color ?? Theme.of(context).primaryColor),
        iconSize: 22,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}

// ✅ BOTÃO DE AÇÃO PARA DESKTOP
class _DesktopActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _DesktopActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 18,
        color: color ?? Theme.of(context).primaryColor,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: color ?? Theme.of(context).primaryColor,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        backgroundColor: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}