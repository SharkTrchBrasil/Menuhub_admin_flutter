import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../models/store/store_receivable.dart';


class ReceivableCard extends StatelessWidget {
  final StoreReceivable receivable;
  final int storeId;
  final VoidCallback onDelete;

  const ReceivableCard({required this.receivable, required this.storeId, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Material(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(receivable.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Row(
                children: [
                  Expanded(child: Text(_formatCurrency(receivable.amount), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: _receivableStatusColor(receivable.status).withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
                    child: Text(_receivableStatusLabel(receivable.status), style: TextStyle(color: _receivableStatusColor(receivable.status), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'editar') { /* TODO: DialogService.showReceivableDialog */ }
                  else if (value == 'excluir') { onDelete(); }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'editar', child: ListTile(leading: Icon(Icons.edit), title: Text('Editar'))),
                  const PopupMenuItem(value: 'excluir', child: ListTile(leading: Icon(Icons.delete), title: Text('Excluir'))),
                ],
              ),
            ),
            const Spacer(),
            Row(children: [
              Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text("Vencimento: ${dateFormat.format(receivable.dueDate)}"),
            ]),
            const SizedBox(height: 4),
            if (receivable.receivedDate != null)
              Row(children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text("Recebido em: ${dateFormat.format(receivable.receivedDate!)}"),
              ]),
          ],
        ),
      ),
    );
  }

  String _receivableStatusLabel(String status) => {'received': 'Recebido', 'pending': 'Pendente', 'overdue': 'Vencido'}[status.toLowerCase()] ?? 'Desconhecido';
  Color _receivableStatusColor(String status) => {'received': Colors.green, 'pending': Colors.orange, 'overdue': Colors.red}[status.toLowerCase()] ?? Colors.grey;

  String _formatCurrency(int cents) => NumberFormat.simpleCurrency(locale: 'pt_BR').format(cents / 100);

}
