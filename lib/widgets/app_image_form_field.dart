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
  final double? size;
  final bool showTitle;

  const AppImageFormField({
    super.key,
    required this.title,
    this.initialValue,
    required this.onChanged,
    this.size,
    this.showTitle = true,
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

  double get _imageSize {
    // Tamanho responsivo baseado na largura da tela
    final screenWidth = MediaQuery.of(context).size.width;

    if (widget.size != null) return widget.size!;

    if (screenWidth < 480) { // Mobile pequeno
      return 80.0;
    } else if (screenWidth < 768) { // Mobile grande/Tablet pequeno
      return 90.0;
    } else { // Desktop
      return 100.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // IMPORTANTE: Evita overflow
      children: [
        if (widget.showTitle) ...[
          Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: _imageSize,
          height: _imageSize,
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
    return SizedBox(
      width: _imageSize,
      height: _imageSize,
      child: InkWell(
        onTap: _pickAndCropImage,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          ),
          child: Icon(
              Icons.add_a_photo_outlined,
              size: _imageSize * 0.4, // Ícone proporcional
              color: Colors.grey
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail() {
    return SizedBox(
      width: _imageSize,
      height: _imageSize,
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
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: _imageSize * 0.16, // Ícone proporcional
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(ImageModel image) {
    if (image.file != null) {
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
        try {
          if (File(image.file!.path).existsSync()) {
            return Image.file(
              File(image.file!.path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
            );
          } else {
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

    return _buildErrorPlaceholder();
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: SizedBox(
          width: _imageSize * 0.3,
          height: _imageSize * 0.3,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: _imageSize * 0.4,
      ),
    );
  }
}