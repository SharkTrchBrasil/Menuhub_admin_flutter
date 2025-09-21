// lib/widgets/app_image_form_field.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/widgets/app_crop_dialog.dart';

class AppImageFormField extends StatefulWidget {
  final String title;
  final ImageModel? initialValue;
  final ValueChanged<ImageModel?> onChanged;

  const AppImageFormField({
    super.key,
    required this.title,
    this.initialValue,
    required this.onChanged,
  });

  @override
  State<AppImageFormField> createState() => _AppImageFormFieldState();
}

class _AppImageFormFieldState extends State<AppImageFormField> {
  ImageModel? _currentImage;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.initialValue;
  }

  Future<void> _pickAndCropImage() async {
    try {
      final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 1200,
          imageQuality: 85
      );
      if (picked == null || !mounted) return;

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
      setState(() => _currentImage = newImage);
      widget.onChanged(newImage);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar imagem: ${e.toString()}')),
        );
      }
    }
  }

  void _removeImage() {
    setState(() => _currentImage = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          height: 100,
          child: _currentImage == null ||
              (_currentImage!.file == null &&
                  (_currentImage!.url == null || _currentImage!.url!.isEmpty))
              ? _buildAddButton()
              : _buildImageThumbnail(),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    const double size = 100.0;
    return SizedBox(
      width: size,
      height: size,
      child: InkWell(
        onTap: _pickAndCropImage,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          ),
          child: const Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail() {
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
              child: _buildImageWidget(_currentImage!),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: _removeImage,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
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