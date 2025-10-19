import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

import 'ds_primary_button.dart';

class AppCropDialog extends StatefulWidget {
  const AppCropDialog({
    super.key,
    required this.image,
    required this.aspectRatio,
  });

  final XFile image;
  final double aspectRatio;

  @override
  State<AppCropDialog> createState() => _AppCropDialogState();
}

class _AppCropDialogState extends State<AppCropDialog> {
  final CropController controller = CropController();
  bool _isCropping = false;

  @override
  void dispose() {
    // CropController doesn't have a dispose method, so we just call super.dispose()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double dialogWidth = size.width * 0.9 > 600 ? 600 : size.width * 0.9;
    final double dialogHeight = size.height * 0.7;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: FutureBuilder(
          future: widget.image.readAsBytes(),
          builder: (_, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: DotLoading(),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: Crop(
                    controller: controller,
                    image: snapshot.data!,
                    aspectRatio: widget.aspectRatio,
                    onCropped: (CropResult cropped) {
                      // Check if widget is still mounted before calling context.pop()
                      if (!mounted) return;

                      setState(() {
                        _isCropping = false;
                      });

                      if (cropped is CropFailure) {
                        showError('Não foi possível cortar a imagem.');
                      } else {
                        // Use Navigator.of(context) instead of context.pop() for better safety
                        Navigator.of(context).pop((cropped as CropSuccess).croppedImage);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _isCropping
                        ? const CircularProgressIndicator()
                        : DsButton(
                      label: 'Salvar',
                      onPressed: () {
                        setState(() {
                          _isCropping = true;
                        });
                        controller.crop();
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}