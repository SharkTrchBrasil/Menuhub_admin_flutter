// lib/pages/commands/widgets/command_card.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/tables/command.dart';


class CommandCard extends StatelessWidget {
  final Command command;
  final int storeId;
  final VoidCallback onTap;

  const CommandCard({
    super.key,
    required this.command,
    required this.storeId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasTable = command.tableId != null;
   // final timeAgo = timeago.format(command.createdAt, locale: 'pt_BR');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ícone
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: hasTable ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hasTable ? Icons.table_restaurant : Icons.receipt_long,
                      color: hasTable ? Colors.blue : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Informações principais
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Comanda #${command.id}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (hasTable)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Mesa',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          command.customerName ?? 'Sem nome',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Total (placeholder, seria calculado dos orders)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'R\$ 0,00',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      // Text(
                      //   timeAgo,
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     color: Colors.grey[500],
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
              if (command.notes?.isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          command.notes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}