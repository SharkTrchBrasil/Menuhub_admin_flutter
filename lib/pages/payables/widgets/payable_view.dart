import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:totem_pro_admin/pages/payables/widgets/payable_card.dart';

import '../../../models/store/store_payable.dart';

// Enum para controlar o estado do filtro
enum PayableFilterStatus { all, pending, paid, overdue }

class PayablesView extends StatefulWidget {
  final List<StorePayable> payables;
  final int storeId;
  // Suas funções de callback para adicionar, editar e deletar
  final VoidCallback onAddPayable;
  final Function(StorePayable) onEditPayable;
  final Function(StorePayable) onDeletePayable;

  const PayablesView({
    super.key,
    required this.payables,
    required this.storeId,
    required this.onAddPayable,
    required this.onEditPayable,
    required this.onDeletePayable,
  });

  @override
  State<PayablesView> createState() => _PayablesViewState();
}

class _PayablesViewState extends State<PayablesView> {
  // ✅ 1. CONTROLA O FILTRO ATUALMENTE SELECIONADO
  PayableFilterStatus _selectedStatus = PayableFilterStatus.all;

  @override
  Widget build(BuildContext context) {
    // ✅ 2. FILTRA A LISTA ANTES DE CONSTRUIR QUALQUER COISA
    final filteredPayables = _getFilteredPayables();

    // A estrutura principal é uma coluna que pode rolar
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ 3. SEÇÃO DE RESUMO (KPIs)
          _buildSummarySection(filteredPayables),
          const SizedBox(height: 24),

          // ✅ 4. SEÇÃO DE FILTROS
          _buildFilterSection(),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // ✅ 5. CONTEÚDO PRINCIPAL (LISTA RESPONSIVA)
          _buildContentSection(context, filteredPayables),
        ],
      ),
    );
  }

  /// Filtra a lista principal de contas com base no status selecionado.
  List<StorePayable> _getFilteredPayables() {
    switch (_selectedStatus) {
      case PayableFilterStatus.pending:
        return widget.payables.where((p) => p.status == 'pending').toList();
      case PayableFilterStatus.paid:
        return widget.payables.where((p) => p.status == 'paid').toList();
      case PayableFilterStatus.overdue:
        return widget.payables.where((p) => p.status == 'overdue').toList();
      case PayableFilterStatus.all:
      default:
        return widget.payables;
    }
  }

  /// Constrói a linha de resumo no topo.
  Widget _buildSummarySection(List<StorePayable> items) {
    final totalValue = items.fold<int>(0, (sum, item) => sum + item.amount);

    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: [
        _KpiCard(
          title: 'Valor Total (Filtro)',
          value: _formatCurrency(totalValue),
          subtitle: '${items.length} conta(s) encontrada(s)',
          color: Theme.of(context).colorScheme.primary,
          icon: Icons.functions,
        ),
      ],
    );
  }

  /// Constrói os chips de filtro.
  Widget _buildFilterSection() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        ChoiceChip(
          label: const Text('Todas'),
          selected: _selectedStatus == PayableFilterStatus.all,
          onSelected: (selected) {
            if (selected) setState(() => _selectedStatus = PayableFilterStatus.all);
          },
        ),
        ChoiceChip(
          label: const Text('Pendentes'),
          selected: _selectedStatus == PayableFilterStatus.pending,
          onSelected: (selected) {
            if (selected) setState(() => _selectedStatus = PayableFilterStatus.pending);
          },
        ),
        ChoiceChip(
          label: const Text('Pagas'),
          selected: _selectedStatus == PayableFilterStatus.paid,
          onSelected: (selected) {
            if (selected) setState(() => _selectedStatus = PayableFilterStatus.paid);
          },
        ),
        ChoiceChip(
          label: const Text('Vencidas'),
          selected: _selectedStatus == PayableFilterStatus.overdue,
          onSelected: (selected) {
            if (selected) setState(() => _selectedStatus = PayableFilterStatus.overdue);
          },
        ),
      ],
    );
  }

  /// Constrói a lista responsiva (GridView para desktop, ListView para mobile).
  Widget _buildContentSection(BuildContext context, List<StorePayable> items) {
    if (items.isEmpty) {
      return const Center(
        heightFactor: 5, // Empurra o texto para baixo
        child: Text('Nenhuma conta encontrada para este filtro.'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const double mobileBreakpoint = 768;
        if (constraints.maxWidth < mobileBreakpoint) {
          // --- MOBILE: Uma coluna de cards ---
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: PayableCard(
                  payable: items[index],
                  storeId: widget.storeId,
                 // onEdit: () => widget.onEditPayable(items[index]),
                  onDelete: () => widget.onDeletePayable(items[index]),
                ),
              );
            },
          );
        } else {
          // --- DESKTOP: Um grid de cards ("row" com quebra de linha) ---
          int crossAxisCount = (constraints.maxWidth >= 1200) ? 3 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: 180,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              return PayableCard(
                payable: items[index],
                storeId: widget.storeId,
               // onEdit: () => widget.onEditPayable(items[index]),
                onDelete: () => widget.onDeletePayable(items[index]),
              );
            },
          );
        }
      },
    );
  }
}


/// ✅ NOVO WIDGET AUXILIAR PARA OS CARDS DE KPI
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ConstrainedBox(
      // Garante uma largura mínima para cada card, ajudando o Wrap a se organizar
      constraints: const BoxConstraints(minWidth: 250),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: textTheme.titleMedium),
                  Text(
                    value,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(subtitle, style: textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper para formatar moeda
String _formatCurrency(int cents) {
  return NumberFormat.simpleCurrency(locale: 'pt_BR').format(cents / 100);
}