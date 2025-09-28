// lib/features/chat/widgets/pdf_thumbnail.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import para baixar os dados
import 'package:pdfx/pdfx.dart';

class PdfThumbnail extends StatefulWidget {
  final String pdfUrl;
  const PdfThumbnail({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  State<PdfThumbnail> createState() => _PdfThumbnailState();
}

class _PdfThumbnailState extends State<PdfThumbnail> {
  // O estado agora guarda apenas a imagem da página, que é o que precisamos.
  PdfPageImage? _pageImage;

  @override
  void initState() {
    super.initState();
    _loadPdfThumbnail();
  }

  Future<void> _loadPdfThumbnail() async {
    try {
      // 1. Baixa os dados do PDF da URL
      final pdfData = await http.readBytes(Uri.parse(widget.pdfUrl));

      // 2. Abre o documento a partir dos dados em memória (assíncrono)
      final document = await PdfDocument.openData(pdfData);

      // 3. Pega a primeira página
      final page = await document.getPage(1);

      // 4. Renderiza a página como uma imagem
      // Usamos uma largura fixa para a miniatura e calculamos a altura para manter a proporção
      final image = await page.render(
        width: 250, // Largura da miniatura
        height: (250 * page.height) / page.width, // Altura proporcional
      );

      // 5. Fecha os recursos e atualiza a tela
      await page.close();
      if (mounted) setState(() => _pageImage = image);

    } catch (e) {
      debugPrint("Erro ao carregar miniatura do PDF: $e");
      // Opcional: mostrar um ícone de erro se a miniatura falhar
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enquanto a imagem da página não estiver pronta, mostra um loading.
    if (_pageImage == null) {
      return const SizedBox(
        width: 150,
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Quando a imagem estiver pronta, exibe-a.
    // O erro 'toDouble' é resolvido pois agora temos certeza que as dimensões não são nulas.
    return Image.memory(
      _pageImage!.bytes,
      fit: BoxFit.contain, // Contain é melhor para não cortar o documento
    );
  }
}