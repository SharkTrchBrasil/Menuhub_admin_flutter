import 'package:flutter/material.dart';
import 'package:totem_pro_admin/widgets/app_switch.dart';

class AppSwitchFormField extends StatelessWidget {
  const AppSwitchFormField({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onChanged,
    this.validator,
  });

  final String title;
  final bool initialValue;
  final Function(bool?) onChanged;
  final String? Function(bool?)? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<bool>(
      initialValue: initialValue,
      validator: validator,
      builder: (state) {
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
            AppSwitch(
              value: state.value!,
              onChanged: (v) {
                state.didChange(v);
                onChanged(v);
              },
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
