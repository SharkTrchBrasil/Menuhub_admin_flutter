import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PrinterService {
  // Configurações para impressora de 58mm
  static const double _printer58mmWidth = 58 * PdfPageFormat.mm;
  static const double _printer80mmWidth = 80 * PdfPageFormat.mm;

  // Imprime um recibo simples
  Future<void> printReceipt({
    required String title,
    required List<Map<String, String>> items,
    required double total,
    String? footer,
    bool is58mm = true, // Padrão para 58mm
  }) async {
    try {
      final pdf = pw.Document();
      final double pageWidth = is58mm ? _printer58mmWidth : _printer80mmWidth;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(pageWidth, double.infinity,
              marginAll: 2 * PdfPageFormat.mm),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                pw.Center(
                  child: pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: is58mm ? 10 : 12,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 8),

                // Itens
                for (var item in items)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        item['name'] ?? '',
                        style: pw.TextStyle(
                          fontSize: is58mm ? 8 : 10,
                        ),
                      ),
                      pw.Text(
                        item['value'] ?? '',
                        style: pw.TextStyle(
                          fontSize: is58mm ? 8 : 10,
                        ),
                      ),
                    ],
                  ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 1),
                pw.SizedBox(height: 4),

                // Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: is58mm ? 9 : 11,
                      ),
                    ),
                    pw.Text(
                      'R\$ ${total.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: is58mm ? 9 : 11,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),

                // Rodapé
                if (footer != null)
                  pw.Center(
                    child: pw.Text(
                      footer,
                      style: pw.TextStyle(
                        fontSize: is58mm ? 7 : 9,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
              ],
            );
          },
        ),
      );

      // Imprime o documento
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint('Erro ao imprimir: $e');
      rethrow;
    }
  }

  // Imprime um texto simples
  Future<void> printRawText(String text, {bool is58mm = true}) async {
    try {
      final pdf = pw.Document();
      final double pageWidth = is58mm ? _printer58mmWidth : _printer80mmWidth;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(pageWidth, double.infinity,
              marginAll: 2 * PdfPageFormat.mm),
          build: (pw.Context context) {
            return pw.Text(
              text,
              style: pw.TextStyle(fontSize: is58mm ? 9 : 11),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      debugPrint('Erro ao imprimir texto: $e');
      rethrow;
    }
  }

  // Verifica se a impressão é suportada
  static Future<bool> isPrintingSupported() async {
    return await Printing.info().then((info) => info.canPrint);
  }
}