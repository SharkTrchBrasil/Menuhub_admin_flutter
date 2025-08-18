// lib/pages/opening_hours/widgets/add_shift_dialog.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'shift_row.dart'; // Reutilizaremos o TimeInput

// Classe para retornar os dados do diálogo (sem alterações)
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
  // Estado local do diálogo (sem alterações)
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

  void _confirm() {
    // Validações (sem alterações)
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 550;

    return Dialog(
      // ✅ 1. LÓGICA PARA TELA CHEIA NO MOBILE
      // Remove o padding e as bordas arredondadas no mobile
      insetPadding: isMobile ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      shape: isMobile
          ? const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: Container(
        // Define a altura máxima para o modo desktop
        width: 500,
        height: isMobile ? double.infinity : null,
        child: isMobile ? _buildMobileFullScreen() : _buildDesktopDialog(),
      ),
    );
  }

  // ✅ 2. LAYOUT PARA DESKTOP (O DIÁLOGO PADRÃO)
  Widget _buildDesktopDialog() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _buildFormContent(),
      ),
    );
  }

  // ✅ 3. LAYOUT PARA MOBILE (TELA CHEIA COM APPBAR)
  Widget _buildMobileFullScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Novo Horário'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _confirm,
              child: const Text('SALVAR'),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildFormContent(),
        ),
      ),
    );
  }

  // ✅ 4. CONTEÚDO DO FORMULÁRIO REUTILIZÁVEL
  // Para não repetir código entre os layouts mobile e desktop
  Widget _buildFormContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seletor de Dias da Semana
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

        // Os botões no desktop são renderizados separadamente no AppBar do mobile
        if (MediaQuery.of(context).size.width >= 550) ...[
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              DsButton(
                label: 'Confirmar horários',
                onPressed: _confirm,
              ),
            ],
          ),
        ]
      ],
    );
  }
}