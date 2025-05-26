import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';

class AppColorFormField extends StatelessWidget {
  const AppColorFormField(
      {super.key,
        this.initialValue,
        required this.title,
        required this.onChanged});

  final String title;
  final Color? initialValue;
  final Function(Color) onChanged;

  @override
  Widget build(BuildContext context) {
    return FormField<Color>(
      initialValue: initialValue,
      validator: (value) {
        if (value == null) {
          return 'Campo obrigatório';
        }
        return null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              height: 40,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final color = await showDialog(
                  context: context,
                  builder: (_) {
                    return ColorPickerDialog(
                      color: state.value ?? Colors.white,
                    );
                  },
                );

                if (color != null) {
                  state.didChange(color);
                  onChanged(color);
                }
              },
              child: Container(
                width: 100,
                height: 50,
                decoration: BoxDecoration(
                    color: state.value,
                    border: Border.all(
                      color: Colors.grey[300]!,
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

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key, required this.color});

  final Color color;

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color color = widget.color;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      title: const Text('Escolha uma cor'),
      content: SingleChildScrollView(
        child: ColorPicker(
          hexInputBar: true,
          pickerColor: color,
          onColorChanged: (c) {
            setState(() {
              color = c;
            });
          },
        ),
      ),
      actions: <Widget>[
        AppPrimaryButton(
          label: 'Pronto',
          onPressed: () {
            context.pop(color);
          },
        ),
      ],
    );
  }
}
