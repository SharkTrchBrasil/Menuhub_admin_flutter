import 'dart:async';

import 'package:boleto_utils/boleto_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({Key? key}) : super(key: key);

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  late BoletoUtils boletoUtils;
  BoletoValidado? boletoValidado; // corrigido: apenas 1 variável

  @override
  void initState() {
    super.initState();
    boletoUtils = BoletoUtils();
  }

  Future<void> startBarcodeScanStream() async {
    String barcode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );

    if (barcode.length == 44) {
      setState(() {
        boletoValidado = boletoUtils.validarBoleto(barcode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de Boleto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: startBarcodeScanStream,
              child: const Text('Escanear boleto'),
            ),
            const SizedBox(height: 20),
            if (boletoValidado != null) ...[
              infoText('Sucesso', '${boletoValidado!.sucesso}'),
              infoText('Mensagem', '${boletoValidado!.mensagem}'),
              infoText('Código de Entrada', '${boletoValidado!.codigoInput}'),
              infoText('Tipo Código Entrada', '${boletoValidado!.tipoCodigoInput}'),
              infoText('Tipo Boleto', '${boletoValidado!.tipoBoleto}'),
              infoText('Código de Barras', '${boletoValidado!.codigoBarras}'),
              infoText('Linha Digitável', '${boletoValidado!.linhaDigitavel}'),
              infoText('Banco Emissor', '${boletoValidado!.bancoEmissor?.codigo}'),
              infoText('Vencimento', '${boletoValidado!.vencimento}'),
              infoText('Valor', '${boletoValidado!.valor}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget infoText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SelectableText(
        '$title: $value',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
