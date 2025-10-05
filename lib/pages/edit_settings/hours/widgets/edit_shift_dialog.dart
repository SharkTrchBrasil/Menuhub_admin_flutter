import 'package:flutter/material.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import '../../../../models/store/store_hour.dart';
import 'shift_row.dart'; // Reutiliza o TimeInput

// A classe de resultado permanece a mesma
class EditShiftResult {
  final TimeOfDay? openingTime;
  final TimeOfDay? closingTime;
  final bool deleted;

  EditShiftResult({this.openingTime, this.closingTime, this.deleted = false});
}

// O nome "Dialog" foi mantido, mas agora é uma "Página" de painel.
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
  // Lógica de estado e inicialização (sem alterações)
  late TimeOfDay _openingTime;
  late TimeOfDay _closingTime;

  @override
  void initState() {
    super.initState();
    _openingTime = widget.initialShift.openingTime ?? const TimeOfDay(hour: 9, minute: 0);
    _closingTime = widget.initialShift.closingTime ?? const TimeOfDay(hour: 18, minute: 0);
  }

  // Lógica de confirmação e validação (sem alterações)
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

  // Lógica de deleção (sem alterações)
  void _delete() {
    Navigator.of(context).pop(EditShiftResult(deleted: true));
  }

  // ✅✅✅ BUILD SIMPLIFICADO ✅✅✅
  @override
  Widget build(BuildContext context) {
    // O widget agora é sempre um Scaffold, que funciona perfeitamente no Side Panel.
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Horário'),
        // Botão para fechar o painel
      automaticallyImplyLeading: false,
      ),
      // O corpo agora tem rolagem para evitar overflow
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: _buildFormContent(),
      ),
      // Botões ficam em um rodapé fixo para melhor UX
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botão de remover à esquerda
            TextButton.icon(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remover'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
            // Botões de cancelar e salvar à direita
            Row(
              children: [

                const SizedBox(width: 8),
                DsButton(
                  label: 'Salvar',
                  onPressed: _confirm,
                ),
              ],
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

        // Título que antes era condicional, agora é fixo
        Text(
          'Edite o horário de ${widget.dayName}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        Text('Selecione o horário em que a loja ficará aberta:', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),

        // Seletores de tempo
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TimeInput(
                time: _openingTime,
                onChanged: (newTime) => setState(() => _openingTime = newTime),
                label: 'Das',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TimeInput(
                time: _closingTime,
                onChanged: (newTime) => setState(() => _closingTime = newTime),
                label: 'Até',
              ),
            ),
          ],
        ),
      ],
    );
  }
}