// lib/pages/commands/commands_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/tables/command.dart';
import 'package:totem_pro_admin/pages/commands/widgets/command_details_panel.dart';

import 'package:totem_pro_admin/widgets/dot_loading.dart';

import 'widgets/create_command_dialog.dart';
import 'widgets/command_card.dart';

class CommandsPage extends StatefulWidget {
  const CommandsPage({super.key});

  @override
  State<CommandsPage> createState() => _CommandsPageState();
}

class _CommandsPageState extends State<CommandsPage> {
  final _searchController = TextEditingController();
  String _filterType = 'all';


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        print('🔥🔥🔥 [COMMANDS_PAGE] Estado atual: ${state.runtimeType}');

        if (state is StoresManagerLoading || state is StoresManagerInitial) {
          print('🔥🔥🔥 [COMMANDS_PAGE] Mostrando loading...');
          return const Center(child: DotLoading());
        }

        if (state is StoresManagerError) {
          print('🔥🔥🔥 [COMMANDS_PAGE] Erro: ${state.message}');
          return Center(child: Text('Erro: ${state.message}'));
        }

        if (state is! StoresManagerLoaded) {
          print('🔥🔥🔥 [COMMANDS_PAGE] Estado não é Loaded!');
          return const SizedBox.shrink();
        }

        final commands = state.standaloneCommands;
        print('🔥🔥🔥 [COMMANDS_PAGE] Comandas no estado: ${commands.length}');
        for (var cmd in commands) {
          print('  - Comanda: ${cmd.customerName}');
        }

        final filteredCommands = _applyFilters(commands);
        print('🔥🔥🔥 [COMMANDS_PAGE] Comandas filtradas: ${filteredCommands.length}');

        return Scaffold(
          body: Column(
            children: [
              _buildHeader(context, state.activeStoreId),
              _buildSearchBar(),
              Expanded(
                child: filteredCommands.isEmpty
                    ? _buildEmptyState()
                    : _buildCommandsList(filteredCommands, state.activeStoreId),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateCommandDialog(context, state.activeStoreId),
            backgroundColor: Colors.orange,
            icon: const Icon(Icons.add),
            label: const Text('Nova Comanda'),
          ),
        );
      },
    );
  }


  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por nome ou número...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchController.clear();
              });
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  List<Command> _applyFilters(List<Command> commands) {
    // ✅ CORREÇÃO CRÍTICA: Cria uma CÓPIA mutável da lista
    var filtered = List<Command>.from(commands);

    // Filtro por tipo
    switch (_filterType) {
      case 'with_table':
        filtered = filtered.where((cmd) => cmd.tableId != null).toList();
        break;
      case 'without_table':
        filtered = filtered.where((cmd) => cmd.tableId == null).toList();
        break;
    }

    // Filtro por busca
    if (_searchController.text.isNotEmpty) {
      final searchText = _searchController.text.toLowerCase();
      filtered = filtered.where((cmd) {
        final name = cmd.customerName?.toLowerCase() ?? '';
        final id = cmd.id.toString();
        return name.contains(searchText) || id.contains(searchText);
      }).toList();
    }

    // ✅ Agora pode ordenar porque é uma cópia mutável
    filtered.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    return filtered;
  }
  Widget _buildHeader(BuildContext context, int storeId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comandas',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gerencie todas as comandas ativas',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateCommandDialog(context, storeId),
                icon: const Icon(Icons.add),
                label: const Text('Nova Comanda'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildCommandsList(List<Command> commands, int storeId) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: commands.length,
      itemBuilder: (context, index) {
        final command = commands[index];
        return CommandCard(
          command: command,
          storeId: storeId,
          onTap: () => _openCommandDetails(command),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Nenhuma comanda ativa'
                : 'Nenhuma comanda encontrada',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Crie uma nova comanda para começar'
                : 'Tente ajustar sua busca',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }


  void _openCommandDetails(Command command) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Align(
        alignment: Alignment.centerRight,
        child: CommandDetailsPanel(
          command: command,
          onClose: () => Navigator.pop(ctx),
          onAddItems: () {
            Navigator.pop(ctx);
            _showAddItemsDialog(command);
          },
        ),
      ),
    );
  }


  void _showAddItemsDialog(Command command) {
    // TODO: Implementar dialog de adicionar itens
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adicionar Itens'),
        content: const Text('Dialog será implementado na próxima etapa'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
  void _showCreateCommandDialog(BuildContext context, int storeId) {
    showDialog(
      context: context,
      builder: (ctx) => CreateCommandDialog(storeId: storeId),
    );
  }


}