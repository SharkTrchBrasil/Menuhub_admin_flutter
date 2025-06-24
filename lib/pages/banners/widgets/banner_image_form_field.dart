import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/widgets/app_crop_dialog.dart';

import 'banner_crop_dialog.dart';



class BannerImageFormField extends StatelessWidget {
  const BannerImageFormField({
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
          final maxWidth = constraints.maxWidth;
          final imageWidth = maxWidth.clamp(200.0, 600.0); // ajuste como quiser
          final imageHeight = imageWidth * 9 / 16; // ou qualquer outra proporção





          return Center(
            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,
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
                            final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (picked == null || !context.mounted) return;

                            final cropResult = await showDialog<Uint8List>(
                              context: context,
                              builder: (_) => BannerCropDialog(
                                image: picked,

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
                          child:  Container(
                    width: imageWidth,
                    height: imageHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: state.value == null
                          ? const Icon(Icons.photo_camera, size: 48)
                          : _buildImage(state.value!),
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

                SizedBox(height: 10,)
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildImage(ImageModel model) {
    if (model.file != null) {
      if (kIsWeb) {
        return FutureBuilder<Uint8List>(
          future: model.file!.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Image.memory(snapshot.data!, fit: BoxFit.cover);
            } else if (snapshot.hasError) {
              return const Icon(Icons.error_outline, size: 48, color: Colors.red);
            }
            return const CircularProgressIndicator();
          },
        );
      } else {
        return Image.file(File(model.file!.path), fit: BoxFit.cover);
      }
    } else if (model.url != null && model.url!.isNotEmpty && Uri.tryParse(model.url!)?.hasAbsolutePath == true) {
      return Image.network(model.url!, fit: BoxFit.cover);
    }

    // Caso não tenha imagem válida, retorna o ícone da câmera
    return const Icon(Icons.photo_camera, size: 48);
  }

}
