import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/widgets/app_crop_dialog.dart';

class AppImageFormFieldLogo extends StatelessWidget {
  const AppImageFormFieldLogo({
    super.key,
    required this.title,
    this.initialValue,
    required this.onChanged,
    required this.validator,
  });

  final String title;
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
        return LayoutBuilder(
          builder: (context, constraints) {
            // Tamanho fixo para a imagem (500x500)
            const double imageSize = 168.0;

            // Tamanho do container visual (pode ser menor para o placeholder)
            final double displaySize =
                state.value != null
                    ? constraints.maxWidth.clamp(100.0, imageSize)
                    : 160.0; // Tamanho menor quando sem imagem

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            final picked = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              maxWidth: imageSize,
                              maxHeight: imageSize,
                              imageQuality: 90,
                            );
                            if (picked == null || !context.mounted) return;

                            final cropResult = await showDialog<Uint8List>(
                              context: context,
                              builder:
                                  (_) => AppCropDialog(
                                    image: picked,
                                    aspectRatio: 1.0, // Força proporção 1:1
                                  ),
                            );

                            if (cropResult == null) return;

                            ImageModel model;
                            if (kIsWeb) {
                              model = ImageModel(
                                file: XFile.fromData(cropResult),
                              );
                            } else {
                              final xfile = await _saveTempFile(
                                cropResult,
                                'cropped_logo.jpg',
                              );
                              if (xfile != null) {
                                model = ImageModel(file: xfile);
                              } else {
                                return;
                              }
                            }

                            state.didChange(model);
                            onChanged(model);
                          },
                          child: Container(
                            width: displaySize,
                            height: displaySize,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Center(
                                child:
                                    state.value == null
                                        ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.add_a_photo,
                                              size: 48,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              title,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                            ),
                                          ],
                                        )
                                        : _buildImage(
                                          state.value!,
                                          displaySize,
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                const SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildImage(ImageModel model, double size) {
    if (model.file != null) {
      if (kIsWeb) {
        return FutureBuilder<Uint8List>(
          future: model.file!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                width: size,
                height: size,
                fit: BoxFit.cover,
              );
            } else if (snapshot.hasError) {
              return const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              );
            }
            return const CircularProgressIndicator();
          },
        );
      } else {
        return Image.file(
          File(model.file!.path),
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }
    } else if (model.url != null &&
        model.url!.isNotEmpty &&
        Uri.tryParse(model.url!)?.hasAbsolutePath == true) {
      return Image.network(
        model.url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 48);
        },
      );
    }

    return const Icon(Icons.photo_camera, size: 48);
  }
}
