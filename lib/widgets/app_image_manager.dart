// lib/widgets/app_image_manager.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:totem_pro_admin/widgets/app_crop_dialog.dart';
import 'package:totem_pro_admin/widgets/video_player_dialog.dart';

import '../models/image_model.dart';

// Regras de negócio centralizadas para fácil manutenção
const double kImageMaxWidth = 1080;
const int kImageQuality = 80;
const int kMaxVideoSizeInMB = 50;
const int kMaxVideoSizeInBytes = kMaxVideoSizeInMB * 1024 * 1024;
const Duration kMaxVideoDuration = Duration(seconds: 60);

class AppImageManager extends StatelessWidget {
  const AppImageManager({
    super.key,
    // --- Parâmetros para Imagens ---
    required this.imageTitle,
    this.images = const [],
    required this.onImagesChanged,
    this.imageLimit = 5,
    // --- Parâmetros para Vídeo ---
    required this.videoTitle,
    this.video,
    required this.onVideoChanged,
    // ✅ NOVO PARÂMETRO PARA CONTROLAR A LÓGICA DE IMPORTAÇÃO
    this.isImported = false,
  });

  // Imagens
  final String imageTitle;
  final List<ImageModel> images;
  final ValueChanged<List<ImageModel>> onImagesChanged;
  final int imageLimit;

  // Vídeo
  final String videoTitle;
  final ImageModel? video;
  final ValueChanged<ImageModel?> onVideoChanged;

  // Lógica de produto importado
  final bool isImported;

  // --- MÉTODOS DE AÇÃO (sem alteração de lógica interna) ---
  Future<void> _pickAndCropImage(BuildContext context) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: kImageMaxWidth,
      maxHeight: kImageMaxWidth,
      imageQuality: kImageQuality,
    );
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
    onImagesChanged([...images, newImage]);
  }

  void _removeImage(ImageModel imageToRemove) {
    onImagesChanged(List<ImageModel>.from(images)..remove(imageToRemove));
  }

  Future<void> _pickVideo(BuildContext context) async {
    final picked = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
      maxDuration: kMaxVideoDuration,
    );
    if (picked == null || !context.mounted) return;

    final fileSize = await picked.length();
    if (fileSize > kMaxVideoSizeInBytes) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vídeo muito grande! O limite é de $kMaxVideoSizeInMB MB.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final newVideo = ImageModel(file: picked, isVideo: true);
    onVideoChanged(newVideo);
  }

  void _removeVideo() {
    onVideoChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- SEÇÃO DE IMAGENS ---
        Text(imageTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _buildImageGallery(context),

        // ✅ A SEÇÃO DE VÍDEO INTEIRA SÓ APARECE SE O PRODUTO NÃO FOR IMPORTADO
        if (!isImported) ...[
          const SizedBox(height: 24),
          Text(videoTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _buildVideoSelector(context),
        ],
      ],
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...images.map((image) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildImageThumbnail(image, isCover: images.first == image),
            )),

            // ✅ O BOTÃO DE ADICIONAR SÓ APARECE SE NÃO FOR IMPORTADO
            if (images.length < imageLimit && !isImported)
              _buildAddButton(context, isVideo: false),
          ],
        ),
      ),
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

          // ✅ O BOTÃO DE REMOVER SÓ APARECE SE NÃO FOR IMPORTADO
          if (!isImported)
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

          if (isCover)
            Positioned(
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                child: const Text("CAPA", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoSelector(BuildContext context) {
    if (video == null && !isImported) {
      return _buildAddButton(context, isVideo: true);
    }
    if (video != null) {
      return _buildVideoThumbnail(context);
    }
    return const SizedBox.shrink();
  }

  Widget _buildVideoThumbnail(BuildContext context) {
    const double size = 100.0;
    final bool isLocalFile = video?.file != null;
    final bool hasRemoteUrl = video?.url != null && video!.url!.isNotEmpty;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.videocam, color: Colors.white, size: 40),
            ),
          ),
          if (hasRemoteUrl)
            Center(
              child: InkWell(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => VideoPlayerDialog(videoUrl: video!.url!),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                ),
              ),
            ),

          // ✅ O BOTÃO DE REMOVER SÓ APARECE SE NÃO FOR IMPORTADO
          if (!isImported)
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: _removeVideo,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),

          if (isLocalFile)
            Positioned(
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                child: Text(
                  video?.file?.name ?? "Vídeo",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, {required bool isVideo}) {
    const double size = 100.0;
    return SizedBox(
      width: size,
      height: size,
      child: InkWell(
        onTap: () => isVideo ? _pickVideo(context) : _pickAndCropImage(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(
            isVideo ? Icons.video_call_outlined : Icons.add_a_photo_outlined,
            size: 40,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  // ✅ CORREÇÃO FINAL PARA EXIBIÇÃO DE IMAGEM LOCAL (CORTADA)
  Widget _buildImageWidget(ImageModel image) {
    // 1. Se for um arquivo local (novo ou cortado), use Image.memory
    if (image.file != null) {
      return FutureBuilder<Uint8List>(
        future: image.file!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!, fit: BoxFit.cover);
          }
          return _buildLoadingPlaceholder();
        },
      );
    }
    // 2. Se for uma URL da internet, use CachedNetworkImage
    if (image.url != null && image.url!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: image.url!,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
      );
    }
    // 3. Se não tiver nenhum dos dois, mostre o placeholder de erro
    return _buildErrorPlaceholder();
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}