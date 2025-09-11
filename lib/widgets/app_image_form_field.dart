


import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/widgets/app_crop_dialog.dart';



class AppProductImageFormField extends StatelessWidget {
  const AppProductImageFormField({
    super.key,
    required this.title,
    this.initialValue,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  });

  final String title;
  final ImageModel? initialValue;
  final String? Function(ImageModel?)? validator;
  final Function(ImageModel?) onChanged;
  final bool enabled;

  // ✅ Lógica de seleção de imagem extraída para uma função reutilizável
  Future<void> _pickAndCropImage(BuildContext context, FormFieldState<ImageModel> state) async {
    const double idealProductImageSize = 1200.0;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: idealProductImageSize,
      maxHeight: idealProductImageSize,
      imageQuality: 85,
    );
    if (picked == null || !context.mounted) return;

    final cropResult = await showDialog<Uint8List>(
      context: context,
      builder: (_) => AppCropDialog(image: picked, aspectRatio: 1.0),
    );

    if (cropResult == null) return;

    ImageModel model;
    if (kIsWeb) {
      model = ImageModel(file: XFile.fromData(cropResult, name: picked.name));
    } else {
      final tempFile = await _saveTempFile(cropResult, 'product_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      if (tempFile == null) return;
      model = ImageModel(file: tempFile);
    }

    // Atualiza o estado do formulário e chama o callback
    state.didChange(model);
    onChanged(model);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<ImageModel>(
      initialValue: initialValue,
      validator: validator,
      builder: (state) {
        final double displaySize = MediaQuery.of(context).size.width.clamp(200.0, 300.0);

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),

        // ✅ LÓGICA CORRIGIDA:
        // Verifica se há uma imagem (seja URL ou arquivo local)
        if (state.value?.file != null || (state.value?.url != null && state.value!.url!.isNotEmpty))
        // Se tiver, mostra a pré-visualização horizontal
        _buildImagePreviewHorizontal(context, state)
        else
        // Se não tiver, mostra o seletor horizontal
        _buildImagePickerHorizontal(context, state),

        if (state.hasError)
        Padding(
        padding: const EdgeInsets.only(left: 12, top: 6),
        child: Text(
        state.errorText!,
        style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
        ),
        ),
        ]);
      },
    );
  }

  // --- Widgets de Construção ---
  /// ✅ WIDGET ATUALIZADO para o placeholder HORIZONTAL
  Widget _buildImagePickerHorizontal(BuildContext context, FormFieldState<ImageModel> state) {
    const double imagePreviewSize = 80.0;

    return InkWell(
      onTap: enabled ? () => _pickAndCropImage(context, state) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Placeholder da imagem à esquerda
            Container(
              width: imagePreviewSize,
              height: imagePreviewSize,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[600]),
            ),
            const SizedBox(width: 16),

            // 2. Textos de instrução à direita
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Adicionar Imagem',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Recomendado: 1200x1200px',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreviewHorizontal(BuildContext context, FormFieldState<ImageModel> state) {
    final imageModel = state.value!;
    const double imagePreviewSize = 80.0; // Tamanho menor para a prévia na linha

    return Container(

      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Imagem à esquerda
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildImage(imageModel),
          ),
          const SizedBox(width: 16),

          // 2. Spacer para empurrar os botões para a direita
          const Spacer(),

     if(enabled)
          IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
            tooltip: 'Alterar foto',
            onPressed: enabled ? () => _pickAndCropImage(context, state) : null,
          ),

          if(enabled)
          IconButton(
            icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            tooltip: 'Remover foto',
            onPressed: enabled ? () {
              state.didChange(null);
              onChanged(null);
            } : null,
          ),
        ],
      ),
    );
  }




  Future<XFile?> _saveTempFile(Uint8List data, String filename) async {
    if (kIsWeb) return null;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(data);
    return XFile(file.path);
  }


  Widget _buildImage(ImageModel model) {
    const double displaySize = 80.0;

    if (model.file != null) {
      if (kIsWeb) {
        return FutureBuilder<Uint8List>(
          future: model.file!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                width: displaySize,
                height: displaySize,
                fit: BoxFit.cover,
              );
            } else if (snapshot.hasError) {
              return _buildErrorWidget(displaySize);
            }
            return _buildLoadingWidget(displaySize);
          },
        );
      } else {
        return Image.file(
          File(model.file!.path),
          width: displaySize,
          height: displaySize,
          fit: BoxFit.cover,
        );
      }
    } else if (model.url != null && model.url!.isNotEmpty &&
        Uri.tryParse(model.url!)?.hasAbsolutePath == true) {
      return Image.network(
        model.url!,
        width: displaySize,
        height: displaySize,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingWidget(displaySize);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget(displaySize);
        },
      );
    }

    return _buildPlaceholderWidget(displaySize);
  }

  Widget _buildLoadingWidget(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorWidget(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.red[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // ✅ IMPORTANTE: Evita overflow
          children: [
            const Icon(Icons.error_outline, size: 24, color: Colors.red), // ✅ Tamanho reduzido
            const SizedBox(height: 4),
            Text(
              'Erro',
              style: TextStyle(
                color: Colors.red,
                fontSize: 10, // ✅ Fonte menor
                height: 1.0, // ✅ Altura de linha reduzida
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // ✅ Máximo de linhas
              overflow: TextOverflow.ellipsis, // ✅ Overflow controlado
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderWidget(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // ✅ IMPORTANTE: Evita overflow
          children: [
            const Icon(Icons.photo_camera, size: 24, color: Colors.grey), // ✅ Tamanho reduzido
            const SizedBox(height: 4),
            Text(
              'Adicionar',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10, // ✅ Fonte menor
                height: 1.0, // ✅ Altura de linha reduzida
              ),
              textAlign: TextAlign.center,
              maxLines: 1, // ✅ Máximo de linhas
              overflow: TextOverflow.ellipsis, // ✅ Overflow controlado
            ),
          ],
        ),
      ),
    );
  }




}





