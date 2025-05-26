import 'package:flutter/material.dart';

class AppCounterFormField extends StatelessWidget {
  const AppCounterFormField({super.key, required this.title, this.validator, required this.minValue, required this.maxValue, required this.initialValue, required this.onChanged});

  final int initialValue;
  final String title;
  final String? Function(int?)? validator;
  final int minValue;
  final int maxValue;
  final Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return FormField<int>(
      initialValue: initialValue,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: state.value! > minValue ? () async {
                    onChanged(state.value! - 1);
                    state.didChange(state.value! - 1);
                  } : null,
                  color: Colors.blue,
                  icon: Icon(Icons.remove),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    state.value.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                IconButton(
                  onPressed: state.value! < maxValue ? () async {
                    onChanged(state.value! + 1);
                    state.didChange(state.value! + 1);
                  } : null,
                  color: Colors.blue,
                  icon: Icon(Icons.add),
                ),
              ],
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
