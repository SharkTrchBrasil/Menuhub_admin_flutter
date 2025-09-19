// lib/pages/orders/widgets/create_table_dialog.dart

import 'package:flutter/material.dart';

class CreateTableDialog extends StatefulWidget {
  const CreateTableDialog({super.key});

  @override
  State<CreateTableDialog> createState() => _CreateTableDialogState();
}

class _CreateTableDialogState extends State<CreateTableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController(text: '4'); // Valor padrão

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final capacity = int.tryParse(_capacityController.text) ?? 4;

      // TODO: Chamar o método do seu cubit para criar a mesa no backend
      // Ex: context.read<TablesCubit>().createTable(name: name, capacity: capacity);

      print('Criando mesa: $name com capacidade $capacity');
      Navigator.of(context).pop(); // Fecha o dialog após submeter
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Criar Nova Mesa'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Mesa',
                hintText: 'Ex: Mesa 01, Varanda 2',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, insira um nome para a mesa.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacidade Máxima',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                  return 'Insira um número válido.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Criar'),
        ),
      ],
    );
  }
}