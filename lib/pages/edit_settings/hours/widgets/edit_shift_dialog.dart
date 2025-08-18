// lib/pages/opening_hours/widgets/edit_shift_dialog.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/store_hour.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'shift_row.dart'; // Reutilizaremos o TimeInput

// This class remains the same
class EditShiftResult {
  final TimeOfDay? openingTime;
  final TimeOfDay? closingTime;
  final bool deleted;

  EditShiftResult({this.openingTime, this.closingTime, this.deleted = false});
}

class EditShiftDialog extends StatefulWidget {
  final StoreHour initialShift;
  final String dayName;

  const EditShiftDialog({
    super.key,
    required this.initialShift,
    required this.dayName,
  });

  @override
  State<EditShiftDialog> createState() => _EditShiftDialogState();
}

class _EditShiftDialogState extends State<EditShiftDialog> {
  late TimeOfDay _openingTime;
  late TimeOfDay _closingTime;

  @override
  void initState() {
    super.initState();
    _openingTime = widget.initialShift.openingTime ?? const TimeOfDay(hour: 9, minute: 0);
    _closingTime = widget.initialShift.closingTime ?? const TimeOfDay(hour: 18, minute: 0);
  }

  void _confirm() {
    if (_openingTime.hour * 60 + _openingTime.minute >=
        _closingTime.hour * 60 + _closingTime.minute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O horário de abertura deve ser antes do fechamento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      EditShiftResult(openingTime: _openingTime, closingTime: _closingTime),
    );
  }

  void _delete() {
    Navigator.of(context).pop(EditShiftResult(deleted: true));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 550;

    return Dialog(
      // ✅ 1. Makes the dialog full-screen on mobile
      insetPadding: isMobile ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      shape: isMobile
          ? const RoundedRectangleBorder(borderRadius: BorderRadius.zero)
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        height: isMobile ? double.infinity : null,
        child: isMobile ? _buildMobileFullScreen() : _buildDesktopDialog(),
      ),
    );
  }

  // ✅ 2. Standard dialog layout for desktop
  Widget _buildDesktopDialog() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _buildFormContent(),
      ),
    );
  }

  // ✅ 3. Full-screen Scaffold layout for mobile
  Widget _buildMobileFullScreen() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Horário'),
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

  // ✅ 4. Reusable form content for both layouts
  Widget _buildFormContent() {
    final isMobile = MediaQuery.of(context).size.width < 550;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title is in the AppBar on mobile, so we only show it here for desktop
        if (!isMobile)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Edite o horário de ${widget.dayName}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        if (!isMobile) const SizedBox(height: 24),

        Text('Selecione o horário em que a loja ficará aberta:', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        _buildTimePickers(isMobile: isMobile),
        const SizedBox(height: 24),

        // Action buttons are part of the form content now
        _buildActionButtons(isMobile: isMobile),
      ],
    );
  }

  Widget _buildTimePickers({required bool isMobile}) {
    final pickers = [
      Flexible(
        child: TimeInput(
          time: _openingTime,
          onChanged: (newTime) => setState(() => _openingTime = newTime),
          label: 'Das',
        ),
      ),
      SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
      Flexible(
        child: TimeInput(
          time: _closingTime,
          onChanged: (newTime) => setState(() => _closingTime = newTime),
          label: 'Até',
        ),
      ),
    ];

    return isMobile
        ? Column(mainAxisSize: MainAxisSize.min, children: pickers)
        : Row(crossAxisAlignment: CrossAxisAlignment.center, children: pickers);
  }

  Widget _buildActionButtons({required bool isMobile}) {
    // On mobile, the main actions are in the AppBar. We only show the delete button.
    if (isMobile) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: TextButton.icon(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remover este horário'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ),
      );
    } else {
      // Desktop layout remains the same
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remover'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              DsButton(
                label: 'Confirmar',
                onPressed: _confirm,
              ),
            ],
          ),
        ],
      );
    }
  }
}