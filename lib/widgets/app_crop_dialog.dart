import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

class AppCropDialog extends StatefulWidget {
  const AppCropDialog(
      {super.key, required this.image, required this.aspectRatio});

  final XFile image;
  final double aspectRatio;

  @override
  State<AppCropDialog> createState() => _AppCropDialogState();
}

class _AppCropDialogState extends State<AppCropDialog> {
  final CropController controller = CropController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double dialogWidth = size.width * 0.9 > 600 ? 600 : size.width * 0.9;
    final double dialogHeight = size.height * 0.7;

    return Dialog(
      insetPadding: const EdgeInsets.all(16), // margem ao redor do diálogo
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: FutureBuilder(
          future: widget.image.readAsBytes(),
          builder: (_, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: SpinKitCubeGrid(color: Colors.blue),
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
                      if (cropped is CropFailure) {
                        showError('Não foi possível cortar a imagem.');
                      } else {
                        context.pop((cropped as CropSuccess).croppedImage);
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: AppPrimaryButton(
                      label: 'Salvar',
                      onPressed: () => controller.crop(),
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