import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppFileFormField extends StatelessWidget {
  const AppFileFormField({
    super.key,
    required this.title,
    this.initialValue,
    required this.onChanged,
  });

  final String title;
  final FileModel? initialValue;
  final Function(FileModel?) onChanged;

  @override
  Widget build(BuildContext context) {
    return FormField<FileModel>(
      initialValue: initialValue,
      validator: (value) {
        if (value == null) {
          return 'Campo obrigatório';
        }
        return null;
      },
      builder: (state) {
        Future<void> selectFile() async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            allowMultiple: false,
            type: FileType.custom,
            allowedExtensions: ['pem'],
          );
          if (result != null && result.xFiles.isNotEmpty) {
            final value = FileModel(file: result.xFiles.first);
            onChanged(value);
            state.didChange(value);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(70),
                border: state.hasError
                    ? Border.all(
                    color: Theme.of(context).colorScheme.error, width: 1)
                    : null,
              ),
              child: InkWell(
                onTap: selectFile,
                child: Center(
                  child: Text(
                    state.value == null ? 'Selecionar arquivo' : 'Arquivo selecionado!',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
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

class FileModel {
  FileModel({this.url, this.file});

  final String? url;
  final XFile? file;
}
