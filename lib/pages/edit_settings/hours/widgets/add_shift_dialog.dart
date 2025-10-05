import 'package:flutter/material.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'shift_row.dart'; // Reutilizaremos o TimeInput

// A classe de resultado permanece a mesma
class AddShiftResult {
  final Set<int> selectedDays;
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;

  AddShiftResult({
    required this.selectedDays,
    required this.openingTime,
    required this.closingTime,
  });
}

// O nome "Dialog" foi mantido, mas agora é efetivamente uma "Página" de painel.
class AddShiftDialog extends StatefulWidget {
  final int initialDay;
  final TimeOfDay initialTime;
  final Map<int, String> dayNames;
  final List<int> displayOrder;

  const AddShiftDialog({
    super.key,
    required this.initialDay,
    required this.initialTime,
    required this.dayNames,
    required this.displayOrder,
  });

  @override
  State<AddShiftDialog> createState() => _AddShiftDialogState();
}

class _AddShiftDialogState extends State<AddShiftDialog> {
  // A lógica de estado e inicialização permanece a mesma
  late Set<int> _selectedDays;
  late TimeOfDay _openingTime;
  late TimeOfDay _closingTime;

  @override
  void initState() {
    super.initState();
    _selectedDays = {widget.initialDay};
    int roundedMinutes = (widget.initialTime.minute / 15).round() * 15;
    if (roundedMinutes >= 60) {
      _openingTime = TimeOfDay(hour: widget.initialTime.hour + 1, minute: 0);
    } else {
      _openingTime = TimeOfDay(hour: widget.initialTime.hour, minute: roundedMinutes);
    }
    _closingTime = TimeOfDay(hour: _openingTime.hour + 2, minute: _openingTime.minute);
  }

  // A lógica de confirmação e validação permanece a mesma
  void _confirm() {
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecione pelo menos um dia da semana.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    if (_openingTime.hour * 60 + _openingTime.minute >=
        _closingTime.hour * 60 + _closingTime.minute) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('O horário de abertura deve ser antes do fechamento.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    Navigator.of(context).pop(AddShiftResult(
      selectedDays: _selectedDays,
      openingTime: _openingTime,
      closingTime: _closingTime,
    ));
  }

  // ✅✅✅ BUILD SIMPLIFICADO ✅✅✅
  @override
  Widget build(BuildContext context) {
    // O widget agora é sempre um Scaffold, que funciona perfeitamente no Side Panel.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novo Horário'),
        // Botão para fechar o painel
        automaticallyImplyLeading: false,


      ),
      // O corpo agora tem rolagem para evitar overflow
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: _buildFormContent(), // O conteúdo do formulário é reutilizado
      ),
      // Botões ficam em um rodapé fixo para melhor UX
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: DsButton(
                style: DsButtonStyle.secondary,
                onPressed: () => Navigator.of(context).pop(),
                label: 'Cancelar',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DsButton(
                label: 'Salvar Horários',
                onPressed: _confirm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅✅✅ CONTEÚDO DO FORMULÁRIO SIMPLIFICADO ✅✅✅
  // Não precisa mais de lógica para mostrar/esconder botões.
  Widget _buildFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),

        const Text('Escolha os dias da semana:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: widget.displayOrder.map((dayIndex) {
            final dayName = widget.dayNames[dayIndex]!;
            final isSelected = _selectedDays.contains(dayIndex);
            return FilterChip(
              label: Text(dayName.substring(0, 3)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDays.add(dayIndex);
                  } else {
                    _selectedDays.remove(dayIndex);
                  }
                });
              },
              selectedColor: Theme.of(context).primaryColor,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Seletor de Horário
        const Text('Selecione o horário:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: TimeInput(time: _openingTime, onChanged: (t) => setState(() => _openingTime = t), label: 'Das')),
            const SizedBox(width: 16),
            Expanded(child: TimeInput(time: _closingTime, onChanged: (t) => setState(() => _closingTime = t), label: 'Até')),
          ],
        ),
      ],
    );
  }
}