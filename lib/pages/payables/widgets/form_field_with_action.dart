import 'package:flutter/material.dart';

// Um widget genérico para um Dropdown com um botão de ação (ex: "Adicionar Novo")
class FormFieldWithAction<T> extends StatelessWidget {
  final String labelText;
  final T? value;
  final List<T> items;
  final String Function(T item) itemToString;
  final void Function(T? newValue) onChanged;
  final VoidCallback onActionPressed;
  final String actionLabel;
  final IconData actionIcon;

  const FormFieldWithAction({
    super.key,
    required this.labelText,
    this.value,
    required this.items,
    required this.itemToString,
    required this.onChanged,
    required this.onActionPressed,
    this.actionLabel = 'Novo',
    this.actionIcon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: items.map<DropdownMenuItem<T>>((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemToString(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onActionPressed,
            icon: Icon(actionIcon, size: 16),
            label: Text(actionLabel),
          ),
        ),
      ],
    );
  }
}