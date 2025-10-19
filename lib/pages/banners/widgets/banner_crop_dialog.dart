import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

class BannerCropDialog extends StatefulWidget {
  const BannerCropDialog(
      {super.key, required this.image,});

  final XFile image;


  @override
  State<BannerCropDialog> createState() => _BannerCropDialogState();
}

class _BannerCropDialogState extends State<BannerCropDialog> {
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
                child: DotLoading(),
              );
            }


            return Column(
              children: [
                Expanded(
                  child: Crop(
                    controller: controller,
                    image: snapshot.data!,

                    onCropped: (CropResult cropped) {
                      if (cropped is CropFailure) {
                        showError('Não foi possível cortar a imagem.');
                      } else {
                        context.pop((cropped as CropSuccess).croppedImage);
                      }
                    },

                      initialRectBuilder: InitialRectBuilder.withBuilder((viewportRect, imageRect) {
                        return imageRect;
                      })
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