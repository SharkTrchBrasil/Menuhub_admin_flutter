// lib/features/chat/screens/pdf_viewer_screen.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


// ✅ 2. O widget agora pode ser um StatelessWidget, muito mais simples!
class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String pdfName;

  const PdfViewerScreen({
    Key? key,
    required this.pdfUrl,
    this.pdfName = 'Documento',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pdfName),
      ),
      // ✅ 3. Usa o SfPdfViewer.network diretamente
      body: SfPdfViewer.network(
        pdfUrl,
        // Opcional: Mostra um indicador de progresso enquanto o PDF carrega
        canShowPaginationDialog: false,

        pageLayoutMode: PdfPageLayoutMode.single,
      ),
    );
  }
}