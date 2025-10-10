// Em lib/pages/table/tables.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import 'package:totem_pro_admin/widgets/dot_loading.dart';
import '../../models/tables/saloon.dart';
import '../../models/tables/table.dart';
import 'widgets/create_table_dialog.dart';

class SaloonsAndTablesPanel extends StatefulWidget {
  const SaloonsAndTablesPanel({super.key});

  @override
  State<SaloonsAndTablesPanel> createState() => _SaloonsAndTablesPanelState();
}

class _SaloonsAndTablesPanelState extends State<SaloonsAndTablesPanel> {
  int _selectedSaloonIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded || state.activeStoreWithRole == null) {
          return const Center(child: DotLoading());
        }

        final saloons = state.activeStoreWithRole!.store.relations.saloons;

        if (saloons.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Nenhum salão encontrado.',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCreateTableDialog(context),
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

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // HEADER COM LEGENDAS E TOTAL
              _buildHeader(context, selectedSaloon),

              // LISTA DE SALÕES (AMBIENTES)
              _buildSaloonList(saloons),

              // ÁREA DAS MESAS
              Expanded(
                child: _buildTablesArea(selectedSaloon),
              ),
            ],
          ),
        );
      },
    );
  }

  // HEADER COM LEGENDAS E TOTAL (igual ao HTML)
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
          // LEGENDAS DOS TIPOS DE MESA
          Row(
            children: [
              _buildTableTypeLegend(
                color: const Color(0xFF082610),
                iconColor: const Color(0xFF5A6472),
                count: _countTablesByStatus(selectedSaloon, 'FREE'),
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

          // TOTAL (R$ 0,00 + ÍCONE DE VISIBILIDADE)
          Row(
            children: [
              Text(
                'R\$ 0,00',
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

  // LEGENDA DO TIPO DE MESA
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

  // CONTAR MESAS POR STATUS
  int _countTablesByStatus(Saloon saloon, String status) {
    return saloon.tables.where((table) => table.status.toUpperCase() == status).length;
  }

  // LISTA DE SALÕES (AMBIENTES) - estilo do HTML
  Widget _buildSaloonList(List<Saloon> saloons) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // LISTA DE SALÕES
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
                        // CONTADORES
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
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected ? Colors.white : Colors.white,
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
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected ? Colors.white : Colors.white,
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

          // BOTÃO "NOVO AMBIENTE"
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _showCreateTableDialog(context),
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

  void _showCreateTableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateTableDialog(),
    );
  }

  Widget _buildTablesArea(Saloon saloon) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grid de mesas
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
          itemCount: tables.length + 1, // +1 para o botão "Nova mesa"
          itemBuilder: (context, index) {
            if (index == tables.length) {
              // BOTÃO "NOVA MESA"
              return _buildNewTableButton();
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

  // BOTÃO "NOVA MESA"
  Widget _buildNewTableButton() {
    return ElevatedButton(
      onPressed: () => _showCreateTableDialog(context),
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

  // ITEM DE MESA (estilo do HTML)
  Widget _buildTableItem(TableModel table) {
    final bool isOccupied = table.status.toUpperCase() == 'OCCUPIED';
    final bool isReserved = table.status.toUpperCase() == 'RESERVED';

    Color backgroundColor;
    Color textColor;

    if (isOccupied) {
      backgroundColor = const Color(0xFF613400);
      textColor = Colors.white;
    } else if (isReserved) {
      backgroundColor = const Color(0xFF0047A3);
      textColor = Colors.white;
    } else {
      backgroundColor = const Color(0xFF082610);
      textColor = Colors.white;
    }

    return ElevatedButton(
      onPressed: () {
        // Ação ao clicar na mesa
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
          // STATUS DA MESA (vazio por enquanto)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: double.infinity,
                // Espaço para status futuro
              ),
              const SizedBox(height: 4),
              // Nome do cliente (vazio por enquanto)
              const SizedBox(
                height: 16,
                child: Text(
                  '',
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // NÚMERO DA MESA (centralizado)
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

          // GARÇOM/ATENDENTE (vazio por enquanto)
          const SizedBox(
            height: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Espaço para informações do garçom futuro
              ],
            ),
          ),
        ],
      ),
    );
  }
}