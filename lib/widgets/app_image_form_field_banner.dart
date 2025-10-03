import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/widgets/app_crop_dialog.dart';

class AppImageFormFieldBanner extends StatelessWidget {
  const AppImageFormFieldBanner({
    super.key,
    required this.title,
    required this.aspectRatio,
    this.initialValue,
    required this.onChanged,
    required this.validator,
  });

  final String title;
  final double aspectRatio;
  final ImageModel? initialValue;
  final String? Function(ImageModel?) validator;
  final Function(ImageModel?) onChanged;

  Future<XFile?> _saveTempFile(Uint8List data, String filename) async {
    if (kIsWeb) return null;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(data);
    return XFile(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<ImageModel>(
      initialValue: initialValue,
      validator: validator,
      builder: (state) {
        return LayoutBuilder(builder: (context, constraints) {
          // Definimos as dimensões desejadas
          const double desiredWidth = 1920;
          const double desiredHeight = 375;
          const double desiredAspectRatio = desiredWidth / desiredHeight;

          // Calculamos a largura máxima disponível
          final double maxAvailableWidth = constraints.maxWidth;

          // Definimos a altura baseada na proporção
          final double effectiveHeight = maxAvailableWidth / desiredAspectRatio;

          // Altura mínima quando não há imagem (reduzida para evitar overflow)
          final double emptyStateHeight = 120.0; // Altura fixa mínima

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
                child: InkWell(
                  onTap: () async {
                    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (picked == null || !context.mounted) return;

                    final cropResult = await showDialog<Uint8List>(
                      context: context,
                      builder: (_) => AppCropDialog(
                        image: picked,
                        aspectRatio: aspectRatio,
                      ),
                    );

                    if (cropResult == null) return;

                    ImageModel model;
                    if (kIsWeb) {
                      model = ImageModel(file: XFile.fromData(cropResult));
                    } else {
                      final xfile = await _saveTempFile(cropResult, 'cropped_image.jpg');
                      if (xfile != null) {
                        model = ImageModel(file: xfile);
                      } else {
                        return;
                      }
                    }

                    state.didChange(model);
                    onChanged(model);
                  },
                  child: SizedBox(
                    width: maxAvailableWidth,
                    height: state.value == null ? emptyStateHeight : effectiveHeight,
                    child: state.value == null
                        ? _buildEmptyState(context, emptyStateHeight)
                        : _buildImage(state.value!, maxAvailableWidth, effectiveHeight, context),
                  ),
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 6),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        });
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, double containerHeight) {
    return Container(
      height: containerHeight,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Importante: tamanho mínimo
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo, size: 32), // Ícone menor
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 14, // Texto menor
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Limita a 2 linhas
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ImageModel model, double width, double height, BuildContext context) {
    if (model.file != null) {
      if (kIsWeb) {
        return FutureBuilder<Uint8List>(
          future: model.file!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  snapshot.data!,
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                ),
              );
            } else if (snapshot.hasError) {
              return _buildErrorState(context, height);
            }
            return _buildLoadingState(height);
          },
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(model.file!.path),
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildErrorState(context, height),
          ),
        );
      }
    } else if (model.url != null && model.url!.isNotEmpty && Uri.tryParse(model.url!)?.hasAbsolutePath == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          model.url!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildLoadingState(height);
          },
          errorBuilder: (context, error, stackTrace) => _buildErrorState(context, height),
        ),
      );
    }

    return _buildEmptyState(context, height);
  }

  Widget _buildLoadingState(double height) {
    return Container(
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, double height) {
    return Container(
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 32, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              'Erro ao carregar imagem',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}