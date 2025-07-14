import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/widgets/app_crop_dialog.dart';

class AppImageFormField extends StatelessWidget {
  const AppImageFormField({
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

  @override
  Widget build(BuildContext context) {
    return FormField<ImageModel>(
      initialValue: initialValue,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: aspectRatio,
              child: InkWell(
                onTap: () async {
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image == null || !context.mounted) return;
                  final cropResult = await showDialog(
                    context: context,
                    builder:
                        (_) => AppCropDialog(
                          image: image,
                          aspectRatio: aspectRatio,
                        ),
                  );
                  if (cropResult == null) return;
                  final model = ImageModel(file: XFile.fromData(cropResult));
                  state.didChange(model);
                  onChanged(model);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(80),
                    border:
                        state.hasError
                            ? Border.all(
                              color: Theme.of(context).colorScheme.error,
                            )
                            : null,
                  ),
                  child:
                      state.value == null
                          ? Icon(Icons.photo_camera)
                          : state.value!.file != null
                          ? Image.network(
                            state.value!.file!.path,
                            fit: BoxFit.cover,
                          )
                          : Image.network(state.value!.url!, fit: BoxFit.cover),
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
      },
    );
  }
}
