import 'package:flutter/material.dart';

import '../../../models/supplier.dart';


// --- ABA 2: FORNECEDORES ---
class SuppliersView extends StatelessWidget {
  final List<Supplier> suppliers; // Supondo que seu modelo se chama Supplier
  const SuppliersView({super.key, required this.suppliers});

  @override
  Widget build(BuildContext context) {
    if (suppliers.isEmpty) {
      return const Center(child: Text('Nenhum fornecedor cadastrado.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(28),
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const Icon(Icons.business),
            title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(supplier.document ?? 'Documento não informado'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Abrir diálogo para editar o fornecedor
            },
          ),
        );
      },
    );
  }
}
