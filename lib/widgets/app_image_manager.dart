// lib/widgets/app_image_manager.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/widgets/app_crop_dialog.dart';

class AppImageManager extends StatelessWidget {
  const AppImageManager({
    super.key,
    required this.title,
    this.images = const [],
    // ✅ ALTERADO: Callback para a lista inteira
    required this.onChanged,
    this.imageLimit = 5,
  });

  final String title;
  final List<ImageModel> images;
  // ✅ ALTERADO: Callback para a lista inteira
  final ValueChanged<List<ImageModel>> onChanged;
  final int imageLimit;

  Future<void> _pickAndCropImage(BuildContext context) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (picked == null || !context.mounted) return;

    final cropResult = await showDialog<Uint8List>(
      context: context,
      builder: (_) => AppCropDialog(image: picked, aspectRatio: 1.0),
    );
    if (cropResult == null) return;


    final tempFile = XFile.fromData(
      cropResult,
      name: 'cropped_${DateTime.now().millisecondsSinceEpoch}.jpg',
      mimeType: 'image/jpeg',
    );


    final newImage = ImageModel(file: tempFile);

    final updatedList = [...images, newImage];
    onChanged(updatedList);


  }

  void _removeImage(ImageModel imageToRemove) {

    final updatedList = List<ImageModel>.from(images)..remove(imageToRemove);
    onChanged(updatedList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Renderiza as miniaturas das imagens existentes
                ...List.generate(images.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildImageThumbnail(images[index], isCover: index == 0),
                  );
                }),

                // Mostra o botão de adicionar se o limite não foi atingido
                if (images.length < imageLimit)
                  _buildAddButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(ImageModel image, {bool isCover = false}) {
    const double size = 100.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImageWidget(image),
            ),
          ),
          // Botão de remover
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: () => _removeImage(image),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
          // Badge "CAPA"
          if (isCover)
            Positioned(
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text("CAPA", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    const double size = 100.0;
    return SizedBox(
      width: size,
      height: size,
      child: InkWell(
        onTap: () => _pickAndCropImage(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          ),
          child: Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[600]),
        ),
      ),
    );
  }

  Widget _buildImageWidget(ImageModel image) {
    // ✅ CORREÇÃO PRINCIPAL: Verificar se o XFile contém dados em memória
    if (image.file != null) {
      // Se for web, usar Image.network com dados base64
      if (kIsWeb) {
        return FutureBuilder<Uint8List>(
          future: image.file!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
              );
            }
            return _buildLoadingPlaceholder();
          },
        );
      } else {
        // Para mobile/desktop, verificar se é um arquivo temporário em memória
        try {
          // Tenta ler como arquivo primeiro
          if (File(image.file!.path).existsSync()) {
            return Image.file(
              File(image.file!.path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
            );
          } else {
            // Se o caminho não existe, pode ser um arquivo em memória
            return FutureBuilder<Uint8List>(
              future: image.file!.readAsBytes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
                  );
                }
                return _buildLoadingPlaceholder();
              },
            );
          }
        } catch (e) {
          // Fallback: tentar ler como bytes
          return FutureBuilder<Uint8List>(
            future: image.file!.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
                );
              }
              return _buildLoadingPlaceholder();
            },
          );
        }
      }
    }

    // 2. Se não houver arquivo local, tenta a URL da internet
    if (image.url != null && image.url!.isNotEmpty) {
      return Image.network(
        image.url!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _buildLoadingPlaceholder();
        },
      );
    }

    // 3. Fallback: placeholder de erro/vazio
    return _buildErrorPlaceholder();
  }

  // ✅ Widgets auxiliares para estados de carregamento e erro
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}