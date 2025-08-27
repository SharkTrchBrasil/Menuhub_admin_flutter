import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../models/store_payable.dart';
import '../../../services/dialog_service.dart';

// Widget do Card de Contas a Pagar (refatorado do seu código original)
class PayableCard extends StatelessWidget {
  final StorePayable payable;
  final VoidCallback onDelete;
  final int storeId;

  const PayableCard({
    required this.payable,
    required this.onDelete,
    required this.storeId,
  });

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
              title: Text(payable.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Row(
                children: [
                  Expanded(child: Text(_formatCurrency(payable.amount), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: _statusColor(payable.status).withOpacity(0.1), borderRadius: BorderRadius.circular(50)),
                    child: Text(_statusLabel(payable.status), style: TextStyle(color: _statusColor(payable.status), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'editar') {
                    DialogService.showPayableDialog(context, storeId, paymentId: payable.id);
                  } else if (value == 'excluir') {
                    onDelete();
                  }
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
              Text("Vencimento: ${dateFormat.format(DateTime.parse(payable.dueDate))}"),
            ]),
            const SizedBox(height: 4),
            if (payable.paymentDate != null)
              Row(children: [
                Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                const SizedBox(width: 6),
                Text("Pago em: ${dateFormat.format(DateTime.parse(payable.paymentDate!))}"),
              ]),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(int cents) => NumberFormat.simpleCurrency(locale: 'pt_BR').format(cents / 100);

  String _statusLabel(String status) => {'paid': 'Pago', 'pending': 'Pendente', 'overdue': 'Vencido'}[status.toLowerCase()] ?? 'Desconhecido';
  Color _statusColor(String status) => {'paid': Colors.green, 'pending': Colors.orange, 'overdue': Colors.red}[status.toLowerCase()] ?? Colors.grey;

}
