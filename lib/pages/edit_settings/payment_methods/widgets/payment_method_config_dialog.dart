import 'package:brasil_fields/brasil_fields.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart'; // ✅ 1. Importe o pacote
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/models/payment_method.dart';

import '../../../../core/formatters/value_range_formatter.dart';

enum PixKeyType { email, phone, cpfCnpj, random }

class PaymentMethodConfigDialog extends StatefulWidget {
  final PlatformPaymentMethod method;
  final int storeId;

  const PaymentMethodConfigDialog({
    super.key,
    required this.method,
    required this.storeId,
  });

  @override
  State<PaymentMethodConfigDialog> createState() => _PaymentMethodConfigDialogState();
}

class _PaymentMethodConfigDialogState extends State<PaymentMethodConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _feeController;
  late final TextEditingController _pixKeyController;
  PixKeyType _selectedPixKeyType = PixKeyType.email;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    final activation = widget.method.activation;

    _feeController = TextEditingController(
        text: (activation?.feePercentage ?? 0).toString());
    _pixKeyController =
        TextEditingController(text: activation?.details?['pix_key'] ?? '');

    final keyTypeString = activation?.details?['pix_key_type'];
    _selectedPixKeyType = PixKeyType.values.firstWhere(
          (e) => e.name == keyTypeString,
      orElse: () => PixKeyType.email,
    );
  }

  @override
  void dispose() {
    _feeController.dispose();
    _pixKeyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    final currentActivation = widget.method.activation ?? StorePaymentMethodActivation.empty();

    final newDetails = Map<String, dynamic>.from(currentActivation.details ?? {});
    if (widget.method.methodType == 'MANUAL_PIX') {
      final unmaskedPixKey = UtilBrasilFields.removeCaracteres(_pixKeyController.text);
      newDetails['pix_key'] = unmaskedPixKey;
      newDetails['pix_key_type'] = _selectedPixKeyType.name;
    }

    final updatedActivation = currentActivation.copyWith(
      // ✅ O valor do controller já virá como '4.99', então o parse funciona perfeitamente
      feePercentage: double.tryParse(_feeController.text.replaceAll(',', '.')) ?? 0.0,
      details: newDetails,
    );

    // ✅ 1. CAPTURE O RESULTADO DO CUBIT
    final success = await context.read<StoresManagerCubit>().updatePaymentMethodActivation(
      storeId: widget.storeId,
      platformMethodId: widget.method.id,
      activation: updatedActivation,
    );

    // Garante que o widget ainda está na árvore de widgets antes de usar o context
    if (!mounted) return;

    setState(() { _isLoading = false; });

    // ✅ 2. MOSTRE O SNACKBAR CORRETO E DECIDA SE DEVE FECHAR O DIÁLOGO

    if (success) {
      // Em caso de sucesso, fecha o diálogo e mostra o SnackBar verde.
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuração salva com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Em caso de erro, NÃO fecha o diálogo e mostra o SnackBar vermelho.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao salvar. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Configurar ${widget.method.name}'),
      scrollable: true, // Adiciona rolagem ao diálogo
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildFormFields(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Salvar'),
        ),
      ],
    );
  }

  List<Widget> _buildFormFields() {
    switch (widget.method.methodType) {
      case 'MANUAL_PIX':
        return [
          _buildPixKeyTypeDropdown(),
          const SizedBox(height: 16),
          _buildPixKeyField(),
        ];
      case 'OFFLINE_CARD':
        return [_buildFeeField()];
      default:
        return [
          const Text(
              'Este método de pagamento não possui configurações editáveis.')
        ];
    }
  }

  // ✅ 3. MÉTODO PARA DEIXAR OS NOMES DO DROPDOWN MAIS AMIGÁVEIS
  String _getPixKeyTypeDisplayName(PixKeyType type) {
    switch (type) {
      case PixKeyType.email:
        return 'E-mail';
      case PixKeyType.phone:
        return 'Celular';
      case PixKeyType.cpfCnpj:
        return 'CPF/CNPJ';
      case PixKeyType.random:
        return 'Chave Aleatória';
    }
  }

  // ✅ 4. HELPER PARA O TIPO DE TECLADO
  TextInputType _getPixKeyKeyboardType() {
    switch (_selectedPixKeyType) {
      case PixKeyType.phone:
      case PixKeyType.cpfCnpj:
        return TextInputType.number;
      case PixKeyType.email:
        return TextInputType.emailAddress;
      case PixKeyType.random:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getPixKeyFormatters() {
    switch(_selectedPixKeyType) {
      case PixKeyType.phone:
        return [FilteringTextInputFormatter.digitsOnly, TelefoneInputFormatter()];
      case PixKeyType.cpfCnpj:
        return [FilteringTextInputFormatter.digitsOnly, CpfOuCnpjFormatter()];
      default:
        return [];
    }
  }

  String? _getPixKeyValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira a chave PIX.';
    }

    final unmaskedValue = UtilBrasilFields.removeCaracteres(value);

    switch(_selectedPixKeyType) {
      case PixKeyType.phone:
        if (unmaskedValue.length < 10) return 'Número de celular inválido.';
        break;
      case PixKeyType.cpfCnpj:
        if (!UtilBrasilFields.isCPFValido(value) && !UtilBrasilFields.isCNPJValido(value)) {
          return 'CPF ou CNPJ inválido.';
        }
        break;
      case PixKeyType.email:
        if (!RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$').hasMatch(value)) {
          return 'E-mail inválido.';
        }
        break;
      case PixKeyType.random:
        if (value.length < 10) return 'Chave aleatória muito curta.'; // Exemplo de validação
        break;
    }
    return null;
  }


  Widget _buildPixKeyTypeDropdown() {
    return DropdownButtonFormField<PixKeyType>(
      value: _selectedPixKeyType,
      decoration: const InputDecoration(
        labelText: 'Tipo de Chave PIX',
        border: OutlineInputBorder(),
      ),
      items: PixKeyType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(_getPixKeyTypeDisplayName(type)), // Usa o nome amigável
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPixKeyType = value;
            _pixKeyController.clear(); // Limpa o campo ao trocar o tipo
            _formKey.currentState?.validate(); // Revalida o formulário
          });
        }
      },
    );
  }

  Widget _buildPixKeyField() {
    return TextFormField(
      controller: _pixKeyController,
      decoration: const InputDecoration(
        labelText: 'Chave PIX',
        border: OutlineInputBorder(),
      ),
      // ✅ USA OS HELPERS PARA TORNAR O CAMPO DINÂMICO
      keyboardType: _getPixKeyKeyboardType(),
      inputFormatters: _getPixKeyFormatters(),
      validator: _getPixKeyValidator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }


  Widget _buildFeeField() {
    return TextFormField(
      controller: _feeController,
      decoration: const InputDecoration(
        labelText: 'Taxa (%)',
        hintText: 'Ex: 4,99',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.percent),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),

      // ✅ 2. ADICIONE O NOVO FORMATADOR À LISTA
      // A ordem é importante: primeiro formata como moeda, depois valida o intervalo.
      inputFormatters: [
        CurrencyTextInputFormatter.currency(
          locale: 'pt-BR',
          symbol: '',
          decimalDigits: 2,
          turnOffGrouping: true,
        ),
        ValueRangeTextInputFormatter(min: 0.00, max: 99.99), // Nosso novo formatador!
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira uma taxa.';
        }
        // A validação de intervalo aqui ainda é uma boa prática como uma última barreira
        final fee = double.tryParse(value.replaceAll(',', '.'));
        if (fee == null) {
          return 'Número inválido.';
        }
        if (fee < 0 || fee >= 100) {
          return 'A taxa deve ser entre 0,00 e 99,99';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}