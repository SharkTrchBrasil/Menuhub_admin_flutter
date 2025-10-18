// lib/pages/tables/widgets/manage_table_dialog.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/repositories/table_repository.dart'; // ✅ MUDOU
import 'package:totem_pro_admin/models/tables/table.dart';

class ManageTableDialog extends StatefulWidget {
  final int storeId;
  final int saloonId;
  final TableModel? table;

  const ManageTableDialog({
    super.key,
    required this.storeId,
    required this.saloonId,
    this.table,
  });

  @override
  State<ManageTableDialog> createState() => _ManageTableDialogState();
}

class _ManageTableDialogState extends State<ManageTableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tableRepository = GetIt.I<TableRepository>(); // ✅ MUDOU

  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  late TextEditingController _locationController;

  bool _isLoading = false;
  bool get isEditing => widget.table != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.table?.name ?? '');
    _capacityController = TextEditingController(
      text: widget.table?.maxCapacity.toString() ?? '4',
    );
    _locationController = TextEditingController(
      text: widget.table?.locationDescription ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (isEditing) {
        await _tableRepository.updateTable( // ✅ MUDOU
          storeId: widget.storeId,
          tableId: widget.table!.id,
          name: _nameController.text,
          maxCapacity: int.parse(_capacityController.text),
          locationDescription: _locationController.text.isEmpty
              ? null
              : _locationController.text,
        );
      } else {
        await _tableRepository.createTable( // ✅ MUDOU
          storeId: widget.storeId,
          saloonId: widget.saloonId,
          name: _nameController.text,
          maxCapacity: int.parse(_capacityController.text),
          locationDescription: _locationController.text.isEmpty
              ? null
              : _locationController.text,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mesa ${isEditing ? 'atualizada' : 'criada'} com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
      title: Text(isEditing ? 'Editar Mesa' : 'Criar Nova Mesa'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Mesa *',
                  hintText: 'Ex: Mesa 01, Varanda 2',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Insira um nome para a mesa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacidade Máxima *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Insira um número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Localização (Opcional)',
                  hintText: 'Ex: Próximo à janela',
                  border: OutlineInputBorder(),
                ),
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
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Text(isEditing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }
}