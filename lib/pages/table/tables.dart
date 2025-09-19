// Em lib/pages/orders/widgets/tables.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

class TablesGridView extends StatelessWidget {
  const TablesGridView({super.key});

  @override
  Widget build(BuildContext context) {
    // O Cubit agora é o StoresManagerCubit
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          // Se o estado não estiver carregado, mostra um loading.
          return const Center(child: DotLoading());
        }

        // Acessamos as mesas diretamente do estado carregado!
        final tables = state.activeStore?.relations.tables ?? [];

        if (tables.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma mesa encontrada.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220.0,
            mainAxisSpacing: 20.0,
            crossAxisSpacing: 20.0,
            childAspectRatio: 4 / 3,
          ),
          itemCount: tables.length,
          itemBuilder: (context, index) {
            final table = tables[index];
            return Card(
              elevation: 4,
              color: table.status == 'OCCUPIED'
                  ? Colors.orange.shade600
                  : Colors.green.shade600,
              child: InkWell(
                onTap: () {
                  // TODO: Abrir o painel de detalhes da mesa
                  // Você também pode buscar as comandas da mesa aqui, filtrando
                  // final commandsForThisTable = state.activeStore?.relations.commands
                  //    .where((c) => c.tableId == table.id).toList() ?? [];
                  print('Mesa ${table.name} clicada!');
                },
                child: Center(
                  child: Text(
                    table.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}