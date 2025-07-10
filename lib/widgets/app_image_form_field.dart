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
        return LayoutBuilder(builder: (context, constraints) {
          // Tamanhos conforme padrão iFood para produtos
          const double idealProductImageSize = 1200.0;
          const double minProductImageSize = 800.0;

          // Tamanho de exibição no formulário
          final double displaySize = constraints.maxWidth.clamp(200.0, 300.0);

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
                      // Área de upload
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          final picked = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            maxWidth: idealProductImageSize,
                            maxHeight: idealProductImageSize,
                            imageQuality: 85,
                          );
                          if (picked == null || !context.mounted) return;

                          // Força crop 1:1
                          final cropResult = await showDialog<Uint8List>(
                            context: context,
                            builder: (_) => AppCropDialog(
                              image: picked,
                              aspectRatio: 1.0,

                            ),
                          );

                          if (cropResult == null) return;

                          ImageModel model;
                          if (kIsWeb) {
                            model = ImageModel(file: XFile.fromData(cropResult));
                          } else {
                            final xfile = await _saveTempFile(
                                cropResult,
                                'product_image_${DateTime.now().millisecondsSinceEpoch}.jpg'
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
                            color: Colors.grey[100],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (state.value != null)
                                  _buildImage(state.value!, displaySize),
                                if (state.value == null)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.fastfood, size: 48, color: Colors.grey),
                                      const SizedBox(height: 8),
                                      Text(
                                        title,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Recomendado: 1200x1200px',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                // Overlay para feedback visual
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Dicas de qualidade
                      if (state.value == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Use fundo branco e boa iluminação',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Mensagem de erro
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

  Widget _buildImage(ImageModel model, double displaySize) {
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
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.red[50],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red),
          SizedBox(height: 8),
          Text('Erro ao carregar', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  Widget _buildPlaceholderWidget(double size) {
    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_camera, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Adicionar imagem', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}