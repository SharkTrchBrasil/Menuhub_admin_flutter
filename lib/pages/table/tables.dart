// lib/pages/table/tables.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/table/widgets/create_table_dialog.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/models/tables/saloon.dart';
import 'package:totem_pro_admin/models/tables/table.dart';

import 'cubits/tables_cubit.dart';
import 'widgets/table_order_side_panel.dart';

class SaloonsAndTablesPanel extends StatefulWidget {
  const SaloonsAndTablesPanel({super.key});

  @override
  State<SaloonsAndTablesPanel> createState() => _SaloonsAndTablesPanelState();
}

class _SaloonsAndTablesPanelState extends State<SaloonsAndTablesPanel> {
  int _selectedSaloonIndex = 0;

  @override
  void initState() {
    super.initState();
    // ✅ Conecta ao store ativo quando a tela carregar
    final storeManagerState = context.read<StoresManagerCubit>().state;
    if (storeManagerState is StoresManagerLoaded &&
        storeManagerState.activeStoreWithRole != null) {
      context.read<TablesCubit>().connectToStore(
          storeManagerState.activeStoreWithRole!.store.core.id!
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TablesCubit, TablesState>(
      builder: (context, tablesState) {
        // ✅ Mostra loading enquanto carrega
        if (tablesState is TablesLoading || tablesState is TablesInitial) {
          return const Center(child: DotLoading());
        }

        // ✅ Mostra erro se houver
        if (tablesState is TablesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Erro: ${tablesState.message}',
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
            ),
          );
        }

        // ✅ Agora trabalha com TablesLoaded
        final saloons = (tablesState as TablesLoaded).saloons;
        final selectedTable = tablesState.selectedTable;

        if (saloons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Nenhum salão encontrado.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCreateSaloonDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Criar Primeiro Salão'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (_selectedSaloonIndex >= saloons.length) {
          _selectedSaloonIndex = 0;
        }

        final selectedSaloon = saloons[_selectedSaloonIndex];

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHeader(context, selectedSaloon),
                  _buildSaloonList(saloons),
                  Expanded(
                    child: _buildTablesArea(selectedSaloon),
                  ),
                ],
              ),
            ),

            // ✅ SidePanel aparece quando uma mesa está selecionada
            if (selectedTable != null)
              TableOrderSidePanel(
                table: selectedTable,
                onClose: () {
                  context.read<TablesCubit>().clearSelection();
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Saloon selectedSaloon) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildTableTypeLegend(
                color: const Color(0xFF082610),
                iconColor: const Color(0xFF5A6472),
                count: _countTablesByStatus(selectedSaloon, 'AVAILABLE'),
              ),
              const SizedBox(width: 24),
              _buildTableTypeLegend(
                color: const Color(0xFF613400),
                iconColor: const Color(0xFF613400),
                count: _countTablesByStatus(selectedSaloon, 'OCCUPIED'),
              ),
              const SizedBox(width: 24),
              _buildTableTypeLegend(
                color: const Color(0xFF0047A3),
                iconColor: const Color(0xFF0047A3),
                count: _countTablesByStatus(selectedSaloon, 'RESERVED'),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'R\$ ${_calculateTotalRevenue(selectedSaloon).toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.visibility, color: Colors.grey[600], size: 20),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableTypeLegend({
    required Color color,
    required Color iconColor,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Icon(
            Icons.table_restaurant,
            color: iconColor,
            size: 12,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  int _countTablesByStatus(Saloon saloon, String status) {
    return saloon.tables.where((table) => table.status.toUpperCase() == status).length;
  }

  double _calculateTotalRevenue(Saloon saloon) {
    // TODO: Calcular o total de vendas das mesas ocupadas
    return 0.0;
  }

  Widget _buildSaloonList(List<Saloon> saloons) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: saloons.length,
              itemBuilder: (context, index) {
                final saloon = saloons[index];
                final isSelected = index == _selectedSaloonIndex;
                final occupiedCount = _countTablesByStatus(saloon, 'OCCUPIED');
                final reservedCount = _countTablesByStatus(saloon, 'RESERVED');

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedSaloonIndex = index;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? Colors.orange : Colors.white,
                      foregroundColor: isSelected ? Colors.white : Colors.grey[700],
                      elevation: isSelected ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? Colors.orange : Colors.grey[300]!,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          saloon.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            if (occupiedCount > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFF613400),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  occupiedCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                            ],
                            if (reservedCount > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white.withOpacity(0.2) : const Color(0xFF0047A3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  reservedCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _showCreateSaloonDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF5A6472),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 16),
                SizedBox(width: 4),
                Text(
                  'Novo ambiente',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateSaloonDialog(BuildContext context) {
    // TODO: Criar dialog para salão
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Novo Salão'),
        content: const Text('Dialog de criar salão será implementado'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showCreateTableDialog(BuildContext context, int saloonId) {
    final storeId = (context.read<StoresManagerCubit>().state as StoresManagerLoaded)
        .activeStoreWithRole!.store.core.id;

    showDialog(
      context: context,
      builder: (context) => ManageTableDialog(
        storeId: storeId!,
        saloonId: saloonId,
      ),
    );
  }

  Widget _buildTablesArea(Saloon saloon) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildTablesGrid(saloon),
          ),
        ],
      ),
    );
  }

  Widget _buildTablesGrid(Saloon saloon) {
    final tables = saloon.tables;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final crossAxisCount = _calculateCrossAxisCount(availableWidth);

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: tables.length + 1,
          itemBuilder: (context, index) {
            if (index == tables.length) {
              return _buildNewTableButton(saloon.id);
            }

            final table = tables[index];
            return _buildTableItem(table);
          },
        );
      },
    );
  }

  int _calculateCrossAxisCount(double availableWidth) {
    if (availableWidth > 1200) return 6;
    if (availableWidth > 900) return 5;
    if (availableWidth > 700) return 4;
    if (availableWidth > 500) return 3;
    return 2;
  }

  Widget _buildNewTableButton(int saloonId) {
    return ElevatedButton(
      onPressed: () => _showCreateTableDialog(context, saloonId),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4E627E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 32, color: Color(0xFF4E627E)),
          SizedBox(height: 8),
          Text(
            'Nova mesa',
            style: TextStyle(
              color: Color(0xFF4E627E),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableItem(TableModel table) {
    final bool isAvailable = table.isAvailable;
    final bool isOccupied = table.isOccupied;
    final bool isReserved = table.isReserved;

    Color backgroundColor;
    Color textColor = Colors.white;

    if (isOccupied) {
      backgroundColor = const Color(0xFF613400);
    } else if (isReserved) {
      backgroundColor = const Color(0xFF0047A3);
    } else {
      backgroundColor = const Color(0xFF082610);
    }

    // Pega a comanda ativa (se houver)
    final activeCommand = table.activeCommand;

    return ElevatedButton(
      onPressed: () {
        // ✅ Seleciona a mesa no Cubit
        context.read<TablesCubit>().selectTable(table);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
                child: Text(
                  table.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 16,
                child: Text(
                  activeCommand?.customerName ?? '',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Text(
                table.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            height: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (activeCommand != null && activeCommand.attendantId != null)
                  Icon(
                    Icons.person,
                    size: 12,
                    color: textColor.withOpacity(0.7),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}