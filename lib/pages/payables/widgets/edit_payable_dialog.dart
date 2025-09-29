

import 'package:brasil_fields/brasil_fields.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';


import '../../../core/app_edit_controller.dart';
import '../../../core/di.dart';
import '../../../core/helpers/mask.dart';

// Seu modelo de conta a pagar
import '../../../models/store/store_payable.dart';
import '../../../repositories/store_repository.dart'; // Seu repositório de dados
import '../../../widgets/app_text_field.dart'; // Seu widget de campo de texto
import '../../../widgets/base_dialog.dart'; // Seu widget de diálogo base
import '../../../widgets/app_page_status_builder.dart'; // Seu construtor de status de página
import '../../../pages/base/BasePage.dart'; // Seu widget BasePage para responsividade




class EditPayableDialog extends StatefulWidget {
  const EditPayableDialog({
    super.key,
    required this.storeId,
    this.id,
    this.onSaved,
  });

  final int storeId;
  final int? id;
  final void Function(StorePayable)? onSaved;

  @override
  State<EditPayableDialog> createState() => _EditPayableDialogState();
}

class _EditPayableDialogState extends State<EditPayableDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final StoreRepository repository = getIt();

  late final AppEditController<void, StorePayable> controller =
  AppEditController(
    id: widget.id,
    fetch: (id) => repository.getPayable(widget.storeId, id),
    save: (payable) => repository.savePayable(widget.storeId, payable),
    empty: () => StorePayable(
      title: '',
      amount: 0,
      dueDate: '',
      status: 'pending', // Define um status padrão
      description: null, // Inicializa como nulo
      barcode: null,     // Inicializa como nulo
    ),
  );




  @override
  void initState() {
    super.initState();
    // O AppEditController.load() é gerenciado internamente pelo AppPageStatusBuilder
    // e acionado quando o status é PageStatusLoading.
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return AppPageStatusBuilder<StorePayable>(
          status: controller.status,

          successBuilder: (payable) {

            return Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: BaseDialog(
                title: widget.id == null ? 'Nova Conta a Pagar' : 'Editar Conta a Pagar',
                saveText: 'Salvar',
                onSave: () async {
                  if (formKey.currentState!.validate()) {

                    final result = await controller.saveData();
                    if (result.isRight && context.mounted) {
                      widget.onSaved?.call(result.right);
                      context.pop();
                    } else if (result.isLeft) {

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro ao salvar: ${''}')),
                      );
                    }
                  }
                },
                content: SizedBox(
                  width: MediaQuery.of(context).size.width < 600
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width * 0.35, // Largura ajustada para desktop
                  height: 550, // Altura fixa para o conteúdo do diálogo
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500), // Max width para desktop
                    child: BasePage(
                      mobileBuilder: (BuildContext context) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.all(16.0), // Adiciona padding
                          child: Column( // Usar Column para arranjar verticalmente no mobile
                            children: [
                              _buildFormFields(payable), // Chama o método que constrói os campos
                            ],
                          ),
                        );
                      },
                      desktopBuilder: (BuildContext context) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          padding: const EdgeInsets.all(24.0), // Adiciona padding maior para desktop
                          child: Column( // Usar Column para desktop, pois os campos já serão dispostos em Rows
                            children: [
                              _buildFormFields(payable), // Chama o método que constrói os campos
                            ],
                          ),
                        );
                      },
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

  // Método auxiliar para construir os campos do formulário, reutilizável para mobile e desktop
  Widget _buildFormFields(StorePayable payable) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome (Título)
        AppTextField(
          initialValue: payable.title, // Usa initialValue diretamente do objeto
          title: 'Nome',
          hint: 'Ex: Conta de Luz',
          validator: (title) {
            if (title == null || title.isEmpty) return 'Campo obrigatório';
            if (title.length < 3) return 'Nome muito curto';
            return null;
          },
          onChanged: (name) {
            controller.onChanged(
              payable.copyWith(title: name), // Atualiza o nome no controller
            );
          },
        ),
        const SizedBox(height: 20),

        // Valor
        AppTextField(
          initialValue:

             UtilBrasilFields.obterReal(
            payable.amount /
                100,
          ),

          title: 'Preço',
          hint: 'Ex: R\$ 5,00',
          formatters: [
            FilteringTextInputFormatter
                .digitsOnly,
            CentavosInputFormatter(
              moeda: true,
            ),
          ],
          onChanged: (value) {
            final money =
            UtilBrasilFields.converterMoedaParaDouble(
              value ?? '',
            );

            controller.onChanged(
              payable.copyWith(
                amount:
                (money * 100)
                    .floor(),
              ),
            );
          },
          validator: (value) {
            if (value == null ||
                value.length < 7) {
              return 'Campo obrigatório';
            }

            return null;
          },
        ),
        const SizedBox(height: 20),

        // Vencimento
        // Vencimento
        DatePickerField(
          title: 'Vencimento',
          initialValue: formatForDisplay(payable.dueDate),
          onChanged: (value) {
            final formatted = formatForSaving(value);
            if (formatted != null) {
              controller.onChanged(payable.copyWith(dueDate: formatted));
            }
          },
        ),

        const SizedBox(height: 20),

        // Observação (Opcional)
        AppTextField(
          initialValue: payable.description, // Usa initialValue diretamente do objeto
          title: 'Observação (Opcional)',
          hint: 'Ex: Detalhes adicionais sobre a conta',

          keyboardType: TextInputType.multiline,
          onChanged: (value) => controller.onChanged(payable.copyWith(description: value!.isEmpty ? null : value)),
        ),
        const SizedBox(height: 20),

        // Código de Barras (Opcional)
        AppTextField(
          initialValue: payable.barcode, // Usa initialValue diretamente do objeto
          title: 'Código de Barras (Opcional)',
          hint: 'Ex: 00099.99999 99999.999999 99999.999999 9 99999999999999',
          keyboardType: TextInputType.number,
          onChanged: (value) => controller.onChanged(payable.copyWith(barcode: value!.isEmpty ? null : value)),
        ),
        const SizedBox(height: 20),

        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            DropdownButtonFormField<String>(
              value: payable.status.isNotEmpty ? payable.status : 'pending',
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Aberto')),
                DropdownMenuItem(value: 'paid', child: Text('Pago')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelado')),
              ],
              onChanged: (status) {
                controller.onChanged(payable.copyWith(status: status ?? 'pending'));
              },
            ),

            const SizedBox(height: 16),

            // Campo visível somente se status == 'paid'
            if (payable.status == 'paid')
            // Data de Pagamento
              DatePickerField(
                title: 'Data de Pagamento',
                initialValue: formatForDisplay(payable.paymentDate),
                onChanged: (value) {
                  final formatted = formatForSaving(value);
                  controller.onChanged(payable.copyWith(paymentDate: formatted));
                },
              ),
          ],
        ),

        const SizedBox(height: 20), // Espaçamento extra no final





      ],
    );
  }

  // Função auxiliar para converter de yyyy-MM-dd para dd/MM/yyyy
  String formatForDisplay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return '';
    }
  }

// Função auxiliar para converter de dd/MM/yyyy para yyyy-MM-dd
  String? formatForSaving(String? input) {
    if (input == null || input.isEmpty) return null;
    try {
      final date = DateFormat('dd/MM/yyyy').parse(input);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return null;
    }
  }


  @override
  void dispose() {

    controller.dispose(); // Descarte o AppEditController
    super.dispose();
  }
}
