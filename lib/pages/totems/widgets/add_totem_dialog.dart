import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/repositories/totems_repository.dart';
import 'package:totem_pro_admin/widgets/app_secondary_button.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

class AddTotemDialog extends StatefulWidget {
  const AddTotemDialog({super.key, required this.storeId});

  final int storeId;

  @override
  State<AddTotemDialog> createState() => _AddTotemDialogState();
}

class _AddTotemDialogState extends State<AddTotemDialog> {
  bool loading = false;


  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3)).then((_) async {

      if(loading) return;

      final barcode = '123';
      loading = true;
      final authResult = await getIt<TotemsRepository>().authorizeTotem(widget.storeId, barcode);
      if(authResult.isRight) {
        showSuccess('Totem vinculado com sucesso!');
        if(context.mounted) context.pop();
      } else {
        showError('Falha ao vincular totem!');
      }
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Adicionar Totem',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Escaneie o QR Code do Totem para vinculá-lo a esta loja.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                AspectRatio(
                  aspectRatio: 1,
                  child: MobileScanner(
                    onDetect: (result) async {
                      if(result.barcodes.isEmpty || loading) return;

                      final barcode = result.barcodes.first;
                      loading = true;
                      final authResult = await getIt<TotemsRepository>().authorizeTotem(widget.storeId, barcode.displayValue!);
                      if(authResult.isRight) {
                        showSuccess('Totem vinculado com sucesso!');
                        if(context.mounted) context.pop();
                      } else {
                        showError('Falha ao vincular totem!');
                      }
                      loading = false;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AppSecondaryButton(
                      label: 'Cancelar',
                      onPressed: context.pop,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
