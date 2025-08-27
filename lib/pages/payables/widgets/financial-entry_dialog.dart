import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import '../../../models/payable_category.dart';
import '../../../models/supplier.dart';
import '../payables_page.dart';
import 'form_field_with_action.dart';


class FinancialEntryDialog extends StatefulWidget {
  final int storeId;
  final FinancialEntryType type;
  final dynamic itemToEdit;

  const FinancialEntryDialog({super.key,
    required this.storeId,
    required this.type,
    this.itemToEdit,
  });

  @override
  State<FinancialEntryDialog> createState() => FinancialEntryDialogState();
}

class FinancialEntryDialogState extends State<FinancialEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para os campos
  final _titleController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _documentController = TextEditingController();

  // Variáveis de estado para os dropdowns
  Supplier? _selectedSupplier;
  PayableCategory? _selectedPayableCategory;
  // TODO: Adicionar variáveis para os dropdowns de Contas a Receber

  @override
  void initState() {
    super.initState();
    // TODO: Preencher os campos se for uma edição (widget.itemToEdit != null)
  }

  @override
  void dispose() {
    _titleController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _documentController.dispose();
    super.dispose();
  }

  String _getTitle() {
    bool isEditing = widget.itemToEdit != null;
    switch (widget.type) {
      case FinancialEntryType.payable: return isEditing ? 'Editar Conta a Pagar' : 'Nova Conta a Pagar';
      case FinancialEntryType.receivable: return isEditing ? 'Editar Conta a Receber' : 'Nova Conta a Receber';
      case FinancialEntryType.supplier: return isEditing ? 'Editar Fornecedor' : 'Novo Fornecedor';
      case FinancialEntryType.payableCategory: return 'Nova Categoria (Pagar)';
      case FinancialEntryType.receivableCategory: return 'Nova Categoria (Receber)';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // O backend enviará o evento de socket e a UI principal se atualizará sozinha.
      switch (widget.type) {
        case FinancialEntryType.payable:
        // TODO: Chamar o repositório para criar/atualizar a conta a pagar
        // await getIt<StoreRepository>().createPayable(...);
          break;
        case FinancialEntryType.receivable:
        // TODO: Chamar o repositório para criar/atualizar a conta a receber
          break;
        case FinancialEntryType.supplier:
        // TODO: Chamar o repositório para criar/atualizar o fornecedor
          break;
        case FinancialEntryType.payableCategory:
        // TODO: Chamar o repositório para criar a categoria
          break;
        case FinancialEntryType.receivableCategory:
        // TODO: Chamar o repositório para criar a categoria
          break;
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      // TODO: Mostrar um toast de erro
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_getTitle()),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 450, // Largura máxima para o dialog
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: _buildFormFields(),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Salvar'),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    final state = context.watch<StoresManagerCubit>().state;
    if (state is! StoresManagerLoaded) return const Center(child: CircularProgressIndicator());

    final relations = state.activeStore!.relations;

    switch (widget.type) {
      case FinancialEntryType.payable:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Título')),
            const SizedBox(height: 16),
            TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixText: "R\$ ")),
            const SizedBox(height: 16),
            // TODO: Adicionar campo de data (DatePicker)
            FormFieldWithAction<Supplier>(
              labelText: 'Fornecedor',
              value: _selectedSupplier,
              items: relations.suppliers,
              itemToString: (supplier) => supplier.name,
              onChanged: (newValue) => setState(() => _selectedSupplier = newValue),
              onActionPressed: () {
                // Abre outro dialog por cima para criar um novo fornecedor
              // widget.parentState._showFinancialEntryDialog(type: FinancialEntryType.supplier);
              },
            ),
          ],
        );

      case FinancialEntryType.supplier:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome do Fornecedor')),
            const SizedBox(height: 16),
            TextFormField(controller: _documentController, decoration: const InputDecoration(labelText: 'CNPJ/CPF (Opcional)')),
          ],
        );

      case FinancialEntryType.receivable:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Título do Recebível')),
            const SizedBox(height: 16),
            TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: 'Valor (R\$)', prefixText: "R\$ ")),
            // TODO: Adicionar campo de data e dropdown de cliente/categoria
          ],
        );

    // ... adicione os outros cases para as categorias
      default:
        return const Text('Tipo de formulário não implementado.');
    }
  }
}