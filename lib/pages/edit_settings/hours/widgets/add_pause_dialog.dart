// lib/pages/opening_hours/widgets/add_pause_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import '../../../../models/holiday.dart';
import '../../../../models/scheduled_pause.dart';
import 'shift_row.dart'; // Assuming TimeInput is in here
// ✅ CLASSE ADICIONADA AQUI
// Esta classe define a "forma" dos dados que o diálogo vai retornar.
class AddPauseResult {
  final String? reason;
  final DateTime startTime;
  final DateTime endTime;

  AddPauseResult({
    this.reason,
    required this.startTime,
    required this.endTime,
  });
}

class AddPauseDialog extends StatefulWidget {
  // ✅ ADICIONA PARÂMETROS OPCIONAIS
  final Holiday? holiday;
  final ScheduledPause? existingPause;

  const AddPauseDialog({
    super.key,
    this.holiday,
    this.existingPause,
  });

  @override
  State<AddPauseDialog> createState() => _AddPauseDialogState();
}

class _AddPauseDialogState extends State<AddPauseDialog> {
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();

    // ✅ LÓGICA DE INICIALIZAÇÃO INTELIGENTE
    // Se estamos editando uma pausa existente (vinda de um feriado)
    if (widget.existingPause != null) {
      final pause = widget.existingPause!;
      _reasonController.text = pause.reason ?? widget.holiday?.name ?? '';
      _startDate = pause.startTime.toLocal();
      _startTime = TimeOfDay.fromDateTime(pause.startTime.toLocal());
      _endDate = pause.endTime.toLocal();
      _endTime = TimeOfDay.fromDateTime(pause.endTime.toLocal());
    }
    // Se estamos configurando um novo feriado
    else if (widget.holiday != null) {
      _reasonController.text = widget.holiday!.name;
      _startDate = widget.holiday!.date;
      _endDate = widget.holiday!.date;
      // Define horários padrão para o dia todo
      _startTime = const TimeOfDay(hour: 0, minute: 0);
      _endTime = const TimeOfDay(hour: 23, minute: 59);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _confirm() {
    if (_startDate == null ||
        _startTime == null ||
        _endDate == null ||
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, preencha todas as datas e horários.'),
        backgroundColor: Colors.red,
      ));
      return;
    }
    final startDateTime = _combineDateTime(_startDate!, _startTime!);
    final endDateTime = _combineDateTime(_endDate!, _endTime!);

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('A data/hora de término deve ser posterior à de início.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    Navigator.of(context).pop(
      AddPauseResult(
        reason: _reasonController.text.trim(),
        startTime: startDateTime,
        endTime: endDateTime,
      ),
    );
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
        title: const Text('Criar Pausa'),
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
          ),
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
        if (!isMobile) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text('Criar pausa programada', overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        const Text('A loja ficará indisponível nesta data, mesmo que esteja dentro do horário de funcionamento.'),
        const SizedBox(height: 24),
        const Text('Título da pausa programada', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Ex: Manutenção da Cozinha',
          ),
        ),
        const SizedBox(height: 24),
        isMobile ? _buildMobilePickers() : _buildDesktopPickers(),

        // Buttons are only shown here on desktop
        if (!isMobile) ...[
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              DsButton(
                style: DsButtonStyle.secondary,
                label: 'Cancelar',
                onPressed: () => Navigator.of(context).pop(),
              ),
              DsButton(
                label: 'Salvar pausa programada',
                onPressed: _confirm,
              ),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildDesktopPickers() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildDateTimePicker('Começa em', _startDate, _startTime, (date) => setState(() => _startDate = date), (time) => setState(() => _startTime = time))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 40),
          child: Icon(Icons.arrow_forward),
        ),
        Expanded(child: _buildDateTimePicker('Termina em', _endDate, _endTime, (date) => setState(() => _endDate = date), (time) => setState(() => _endTime = time))),
      ],
    );
  }

  Widget _buildMobilePickers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateTimePicker('Começa em', _startDate, _startTime, (date) => setState(() => _startDate = date), (time) => setState(() => _startTime = time)),
        const SizedBox(height: 16),
        _buildDateTimePicker('Termina em', _endDate, _endTime, (date) => setState(() => _endDate = date), (time) => setState(() => _endTime = time)),
      ],
    );
  }

  Widget _buildDateTimePicker(String label, DateTime? date, TimeOfDay? time,
      Function(DateTime) onDateChanged, Function(TimeOfDay) onTimeChanged) {
    Future<void> pickDate() async {
      final selectedDate = await showDatePicker(
        context: context,
        initialDate: date ?? DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (selectedDate != null) {
        onDateChanged(selectedDate);
      }
    }

    Future<void> pickTime() async {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: time ?? TimeOfDay.now(),
      );
      if (selectedTime != null) {
        onTimeChanged(selectedTime);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: pickDate,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Selecione a data', overflow: TextOverflow.ellipsis,)),
                const Icon(Icons.calendar_month, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: pickTime,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(time != null ? time.format(context) : 'Selecione a hora')),
                const Icon(Icons.access_time, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}