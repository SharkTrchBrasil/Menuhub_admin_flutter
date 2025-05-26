import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDateTimeFormField extends StatelessWidget {
  const AppDateTimeFormField({super.key, required this.title, required this.onChanged, this.initialValue, this.validator});

  final String title;
  final Function(DateTime?) onChanged;
  final DateTime? initialValue;
  final String? Function(DateTime?)? validator;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: initialValue,
      validator: validator,
      builder: (state) {
        Future<void> showDateTimePickers() async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );

          if(date == null || !context.mounted) return;

          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if(time == null || !context.mounted) return;

          final dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );

          state.didChange(dateTime);
          onChanged(dateTime);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              width: 300,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                border: state.hasError
                    ? Border.all(
                  color: Theme.of(context).colorScheme.error,
                  width: 1,
                )
                    : null,
              ),
              child: InkWell(
                onTap: showDateTimePickers,
                child: state.value == null
                    ? const Center(
                  child: Text(
                    'Selecionar Data',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(state.value!),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        state.didChange(null);
                        onChanged(null);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
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
