import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';



enum PeriodOption { last7Days, last30Days }

class FilterSidePanel extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final Function(DateTime, DateTime) onApply;

  const FilterSidePanel({
    super.key,
    required this.initialStartDate,
    required this.initialEndDate,
    required this.onApply,
  });

  @override
  State<FilterSidePanel> createState() => _FilterSidePanelState();
}

class _FilterSidePanelState extends State<FilterSidePanel> {
  late DateTime _startDate;
  late DateTime _endDate;
  PeriodOption _selectedPeriodOption = PeriodOption.last7Days;
  String _selectedPeriodType = 'CURRENT'; // 'CURRENT', 'MONTH', 'CUSTOM'
  String _selectedPlatform = 'CARDAPY';

  // ✅ NOVO ESTADO: Guarda o mês selecionado (ex: 7 para Julho)
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _updateUiStateFromDates();
  }

  // Lógica para determinar o estado inicial da UI a partir das datas
  void _updateUiStateFromDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day);

    if (start == today.subtract(const Duration(days: 6)) && end == today) {
      _selectedPeriodType = 'CURRENT';
      _selectedPeriodOption = PeriodOption.last7Days;
    } else
    if (start == today.subtract(const Duration(days: 29)) && end == today) {
      _selectedPeriodType = 'CURRENT';
      _selectedPeriodOption = PeriodOption.last30Days;
    } else if (start.day == 1 &&
        end.day == DateUtils.getDaysInMonth(end.year, end.month)) {
      _selectedPeriodType = 'MONTH';
      _selectedMonth = start.month;
    } else {
      _selectedPeriodType = 'CUSTOM';
    }
  }

  // Define um período pré-definido (7 ou 30 dias)
  void _setPeriodOption(PeriodOption option) {
    setState(() {
      _selectedPeriodOption = option;
      _selectedPeriodType = 'CURRENT';
      _selectedMonth = null;
      final now = DateTime.now();
      if (option == PeriodOption.last7Days) {
        _startDate = now.subtract(const Duration(days: 6));
        _endDate = now;
      } else if (option == PeriodOption.last30Days) {
        _startDate = now.subtract(const Duration(days: 29));
        _endDate = now;
      }
    });
  }

  // ✅ NOVA FUNÇÃO: Define o período para um mês fechado
  void _setMonthOption(int month, int year) {
    setState(() {
      _selectedPeriodType = 'MONTH';
      _selectedMonth = month;
      _startDate = DateTime(year, month, 1);
      _endDate = DateTime(year, month + 1,
          0); // O dia 0 do mês seguinte é o último dia do mês atual
    });
  }

  // Abre o seletor de período personalizado
  Future<void> _selectCustomDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),

      // ✅ ALTERAÇÃO: Define o estilo do seletor.
      // Em telas grandes, isso pode abrir um dialog em vez de tela cheia.
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            child: child,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriodType = 'CUSTOM';
        _selectedMonth = null;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedPeriodType = 'CURRENT';
      _selectedPlatform = 'CARDAPY';
      _selectedMonth = null;
      _setPeriodOption(PeriodOption.last7Days);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos um Scaffold para ter uma estrutura de página completa dentro do Drawer/BottomSheet
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Todos os filtros'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        // Remove o botão de voltar padrão
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildPeriodFilter(),
                  const SizedBox(height: 24),
                  _buildPlatformFilter(),
                  const SizedBox(height: 24),

                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // --- SEÇÕES DO BUILD ---

  Widget _buildPeriodFilter() {
    final now = DateTime.now();
    // Gera a lista dos últimos 3 meses para os chips
    final last3Months = List.generate(3, (index) {
      final date = DateTime(now.year, now.month - index, 1);
      return {
        'month': date.month,
        'year': date.year,
        'name': DateFormat.MMMM('pt_BR').format(date)
      };
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filtro de período', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Tipos de filtro', style: TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 12),
        _buildRadioOption(
          value: 'CURRENT',
          groupValue: _selectedPeriodType,
          label: 'Período corrente',
          onChanged: (value) => setState(() => _selectedPeriodType = value!),
        ),
        _buildRadioOption(
          value: 'MONTH',
          groupValue: _selectedPeriodType,
          label: 'Mês fechado',
          onChanged: (value) => setState(() => _selectedPeriodType = value!),
        ),
        _buildRadioOption(
          value: 'CUSTOM',
          groupValue: _selectedPeriodType,
          label: 'Personalizado',
          onChanged: (value) {
            setState(() => _selectedPeriodType = value!);
            if (value == 'CUSTOM') _selectCustomDateRange(context);
          },
        ),
        const SizedBox(height: 16),

        // ✅ LÓGICA ATUALIZADA PARA MOSTRAR OS CHIPS CORRETOS
        if (_selectedPeriodType == 'CURRENT')
          Wrap(
            spacing: 8,
            children: [
              _buildChipOption(
                label: 'Últ. 7 dias',
                selected: _selectedPeriodOption == PeriodOption.last7Days,
                onSelected: (_) => _setPeriodOption(PeriodOption.last7Days),
              ),
              _buildChipOption(
                label: 'Últ. 30 dias',
                selected: _selectedPeriodOption == PeriodOption.last30Days,
                onSelected: (_) => _setPeriodOption(PeriodOption.last30Days),
              ),
            ],
          ),
        if (_selectedPeriodType == 'MONTH')
          Wrap(
            spacing: 8,
            children: last3Months.map((monthData) {
              final monthName = monthData['name'] as String;
              final month = monthData['month'] as int;
              final year = monthData['year'] as int;
              return _buildChipOption(
                label: monthName.substring(0, 1).toUpperCase() +
                    monthName.substring(1), // Capitaliza o nome
                selected: _selectedMonth == month,
                onSelected: (_) => _setMonthOption(month, year),
              );
            }).toList(),
          ),
        if (_selectedPeriodType == 'CUSTOM')
          OutlinedButton.icon(
            onPressed: () => _selectCustomDateRange(context),
            icon: const Icon(Icons.calendar_today),
            label: Text(
                "${DateFormat('dd/MM/yy').format(_startDate)} - ${DateFormat(
                    'dd/MM/yy').format(_endDate)}"),
          ),
      ],
    );
  }





  Widget _buildPlatformFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filtro de canal ou serviço', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            _buildChipOption(
              label: 'App e Site', // Simplificado
              selected: _selectedPlatform == 'CARDAPY',
              onSelected: (_) => setState(() => _selectedPlatform = 'CARDAPY'),
            ),

          ],
        ),
      ],
    );
  }



  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearFilters,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              child: const Text('Limpar filtros', style: TextStyle(color: Colors.black)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => widget.onApply(_startDate, _endDate),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEB0033),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Aplicar'),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS HELPERS (Copiados da sua UI) ---

  Widget _buildRadioOption({
    required String value,
    required String groupValue,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            activeColor: const Color(0xFFEB0033),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildChipOption({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black)),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFEB0033),
      side: BorderSide(color: selected ? const Color(0xFFEB0033) : Colors.grey.shade400),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}