// lib/pages/commands/widgets/create_command_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/repositories/table_repository.dart';

class CreateCommandDialog extends StatefulWidget {
  final int storeId;
  final int? preselectedTableId;

  const CreateCommandDialog({
    super.key,
    required this.storeId,
    this.preselectedTableId,
  });

  @override
  State<CreateCommandDialog> createState() => _CreateCommandDialogState();
}

class _CreateCommandDialogState extends State<CreateCommandDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tableRepository = GetIt.I<TableRepository>();

  late TextEditingController _customerNameController;
  late TextEditingController _customerContactController;
  late TextEditingController _notesController;

  bool _isLoading = false;
  bool _linkToTable = false;
  int? _selectedTableId;

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController();
    _customerContactController = TextEditingController();
    _notesController = TextEditingController();
    _selectedTableId = widget.preselectedTableId;
    _linkToTable = widget.preselectedTableId != null;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerContactController.dispose();
    _notesController.dispose();
    super.dispose();
  }



  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _tableRepository.openTable(
        storeId: widget.storeId,
        tableId: _linkToTable ? _selectedTableId : null, // ✅ MUDOU: null em vez de 0
        customerName: _customerNameController.text.isEmpty
            ? null
            : _customerNameController.text,
        customerContact: _customerContactController.text.isEmpty
            ? null
            : _customerContactController.text,
        attendantId: null,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        if (result.isRight) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comanda criada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.left),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }




  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.receipt_long, color: Colors.orange),
          SizedBox(width: 8),
          Text('Nova Comanda'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nome do Cliente
              TextFormField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Cliente',
                  hintText: 'Ex: João Silva',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Insira o nome do cliente';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contato (opcional)
              TextFormField(
                controller: _customerContactController,
                decoration: const InputDecoration(
                  labelText: 'Telefone (Opcional)',
                  hintText: 'Ex: (11) 98765-4321',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Toggle: Vincular à mesa
              SwitchListTile(
                title: const Text('Vincular a uma mesa'),
                subtitle: const Text('Se marcado, escolha a mesa abaixo'),
                value: _linkToTable,
                onChanged: widget.preselectedTableId == null
                    ? (value) => setState(() => _linkToTable = value)
                    : null,
                activeColor: Colors.orange,
              ),

              // Dropdown de mesas (se vincular)
              if (_linkToTable) ...[
                const SizedBox(height: 8),
                BlocBuilder<StoresManagerCubit, StoresManagerState>(
                  builder: (context, state) {
                    if (state is! StoresManagerLoaded) {
                      return const CircularProgressIndicator();
                    }

                    final availableTables = state
                        .activeStoreWithRole!.store.relations.saloons
                        .expand((s) => s.tables)
                        .where((t) => t.isAvailable)
                        .toList();

                    return DropdownButtonFormField<int>(
                      value: _selectedTableId,
                      decoration: const InputDecoration(
                        labelText: 'Selecione a Mesa',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.table_restaurant),
                      ),
                      items: availableTables.map((table) {
                        return DropdownMenuItem<int>(
                          value: table.id,
                          child: Text(table.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTableId = value;
                        });
                      },
                      validator: (value) {
                        if (_linkToTable && value == null) {
                          return 'Selecione uma mesa';
                        }
                        return null;
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),

              // Observações
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Observações (Opcional)',
                  hintText: 'Ex: Cliente frequente, evento especial...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text('Criar Comanda'),
        ),
      ],
    );
  }
}