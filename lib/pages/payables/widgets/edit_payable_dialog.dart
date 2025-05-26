// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Mantenha se ainda usa Provider em outras partes
import 'package:get/get.dart';         // Mantenha se ainda usa GetX
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // <--- Importe este pacote AGORA!

import '../../../core/app_edit_controller.dart';
import '../../../core/di.dart';
import '../../../models/page_status.dart';
import '../../../models/store_payable.dart';
import '../../../repositories/store_repository.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/base_dialog.dart';
import '../../../widgets/app_page_status_builder.dart';
import '../../../pages/base/BasePage.dart';

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
    save: (product) => repository.savePayable(widget.storeId, product),
    empty: () => StorePayable(title: '', value: 0, dueDate: '', status: ''),
  );

  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  // MobileScanner não usa GlobalKey para o controlador da mesma forma que QRView.
  // Você controlará a câmera com o MobileScannerController.
  MobileScannerController mobileScannerController = MobileScannerController();


  Map<String, dynamic> lerBoleto(String codigo) {
    codigo = codigo.replaceAll(RegExp(r'[^0-9]'), '');
    if (codigo.length != 47 && codigo.length != 48) {
      throw FormatException('Código de barras inválido');
    }
    String barra;
    if (codigo.length == 47) {
      barra = codigo.substring(0, 4) +
          codigo.substring(32, 33) +
          codigo.substring(33, 47) +
          codigo.substring(4, 9) +
          codigo.substring(10, 20) +
          codigo.substring(21, 31);
    } else {
      barra = codigo;
    }

    String fatorVencimento = barra.substring(5, 9);
    String valor = barra.substring(9, 19);
    DateTime base = DateTime(1997, 10, 7);
    int dias = int.tryParse(fatorVencimento) ?? 0;
    DateTime vencimento = base.add(Duration(days: dias));
    double valorFinal = double.parse(valor) / 100;

    return {
      'valor': valorFinal.toStringAsFixed(2),
      'vencimento': vencimento.toIso8601String().substring(0, 10),
      'codigoBarras': barra,
    };
  }

  void onBarcodeScanned(String code) {
    try {
      final data = lerBoleto(code);
      barcodeController.text = data['codigoBarras'];
      valueController.text = data['valor'];
      dueDateController.text = data['vencimento'];

      if (controller.status is PageStatusSuccess<StorePayable>) {
        final currentProduct = (controller.status as PageStatusSuccess<StorePayable>).data;
        controller.onChanged(
          currentProduct.copyWith(
            barcode: data['codigoBarras'],
            value: (double.parse(data['valor']) * 100).toInt(),
            dueDate: data['vencimento'],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: O estado do formulário não está pronto para atualização.')),
        );
        return;
      }

      // 'MobileScannerController' tem métodos para parar/pausar a câmera
      mobileScannerController.stop(); // Ou .stop() para parar completamente
      Navigator.of(context).pop();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao ler boleto')),
      );
    }
  }

  void openQRScanner() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Escanear boleto'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: MobileScanner(
            // key: qrKey, // MobileScanner não precisa de GlobalKey aqui para o controller
            controller: mobileScannerController, // Atribui o controller instanciado
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              // final MobileScannerController cameraController = capture.controller; // Se precisar do controller da câmera

              // Processa o primeiro código de barras detectado
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                onBarcodeScanned(barcodes.first.rawValue!);
              }
            },
            // Você pode adicionar um overlay personalizado aqui se precisar
            // Por padrão, mobile_scanner não tem um overlay como qr_code_scanner
            // Se precisar de um, você pode empilhar um Container com bordas transparentes e um recorte no meio.
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              mobileScannerController.dispose(); // Dispose do controller ao fechar
              Navigator.of(context).pop();
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return AppPageStatusBuilder<StorePayable>(
          status: controller.status,
          successBuilder: (product) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              barcodeController.text = product.barcode ?? '';
              valueController.text = (product.value / 100).toStringAsFixed(2);
              dueDateController.text = product.dueDate ?? '';
            });

            return Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: BaseDialog(
                title: widget.id == null ? 'Novo Pagamento' : 'Editar Pagamento', // Título dinâmico
                saveText: 'Salvar',
                onSave: () async {
                  if (formKey.currentState!.validate()) {
                    final result = await controller.saveData();
                    if (result.isRight && context.mounted) {
                      widget.onSaved?.call(result.right);
                      context.pop();
                    }
                  }
                },
                content: SizedBox(
                  width: MediaQuery.of(context).size.width < 600
                      ? MediaQuery.of(context).size.width
                      : MediaQuery.of(context).size.width * 0.5,
                  height: 450,
                  child: BasePage(
                    mobileBuilder: (context) => _buildForm(product),
                    desktopBuilder: (context) => _buildForm(product),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildForm(StorePayable product) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppTextField(
          initialValue: product.title,
          title: 'Nome',
          hint: 'Ex: Conta de Luz',
          validator: (title) {
            if (title == null || title.isEmpty) return 'Campo obrigatório';
            if (title.length < 3) return 'Nome muito curto';
            return null;
          },
          onChanged: (value) => controller.onChanged(product.copyWith(title: value)),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: barcodeController,
                title: 'Código de barras',
                hint: '00000000000000000000000000000000000000000000000',
                onChanged: (value) => controller.onChanged(product.copyWith(barcode: value)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:18.0),
              child: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: openQRScanner,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: valueController,
          title: 'Valor',
          hint: 'Ex: 125.50',
          keyboardType: TextInputType.number,
          formatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
            CentavosInputFormatter(moeda: true),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) return 'Informe o valor';
            final cleanValue = value.replaceAll(RegExp(r'[R$,.]'), '').replaceAll(',', '.');
            if (double.tryParse(cleanValue) == null) return 'Valor inválido';
            return null;
          },
          onChanged: (value) {
            final cleanValue = value?.replaceAll(RegExp(r'[R$,.]'), '').replaceAll(',', '.');
            controller.onChanged(
              product.copyWith(value: ((double.tryParse(cleanValue!) ?? 0) * 100).toInt()),
            );
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: dueDateController,
          title: 'Vencimento',
          hint: 'Ex: 2025-06-15',
          keyboardType: TextInputType.datetime,
          formatters:[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
            DataInputFormatter(),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) return 'Informe a data';
            return null;
          },
          onChanged: (value) => controller.onChanged(product.copyWith(dueDate: value)),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: product.status.isNotEmpty ? product.status : 'open',
          decoration: const InputDecoration(labelText: 'Status'),
          items: const [
            DropdownMenuItem(value: 'open', child: Text('Aberto')),
            DropdownMenuItem(value: 'paid', child: Text('Pago')),
            DropdownMenuItem(value: 'cancelled', child: Text('Cancelado')),
          ],
          onChanged: (status) => controller.onChanged(product.copyWith(status: status ?? 'open')),
        ),
      ],
    );
  }

  @override
  void dispose() {
    mobileScannerController.dispose(); // Dispose do mobileScannerController
    barcodeController.dispose();
    valueController.dispose();
    dueDateController.dispose();
    super.dispose();
  }
}