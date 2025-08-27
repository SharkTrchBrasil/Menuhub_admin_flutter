// lib/pages/reports/tabs/sales_report_tab.dart (Crie este novo arquivo)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/repositories/analytics_repository.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart'; // Para pegar o storeId

class SalesReportTab extends StatefulWidget {
  const SalesReportTab({super.key});

  @override
  State<SalesReportTab> createState() => _SalesReportTabState();
}

class _SalesReportTabState extends State<SalesReportTab> {
  // Estado para guardar as datas do filtro
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _endDate = DateTime.now();

  // Helper para formatar a data para exibição
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Função para abrir o seletor de período
  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pegamos o ID da loja ativa do Cubit
    final storeId = context.watch<StoresManagerCubit>().state.activeStore!.core.id;

    // Se não houver loja ativa, mostramos uma mensagem
    if (storeId == null) {
      return const Center(child: Text("Selecione uma loja para gerar relatórios."));
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500), // Limita a largura no desktop
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Relatório de Vendas',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecione um período para gerar o relatório de desempenho consolidado.',
                style: TextStyle(color: Colors.grey),
              ),
              const Divider(height: 48),

              // --- SELETOR DE PERÍODO ---
              Text('Período do Relatório', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDateRange,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Text('${_formatDate(_startDate)} - ${_formatDate(_endDate)}'),
                ),
              ),
              const SizedBox(height: 32),

              // --- BOTÕES DE EXPORTAÇÃO ---
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Gerar Relatório em PDF'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {
                  // Chama o método do repositório para baixar o PDF
                  // context.read<AnalyticsRepository>().downloadReport(
                  //   storeId: storeId,
                  //   startDate: _startDate,
                  //   endDate: _endDate,
                  //   format: 'pdf',
                  // )


                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.table_chart),
                label: const Text('Gerar Planilha Excel (XLSX)'),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {
                  // Chama o método do repositório para baixar o Excel
                  // context.read<AnalyticsRepository>().downloadReport(
                  //   storeId: storeId,
                  //   startDate: _startDate,
                  //   endDate: _endDate,
                  //   format: 'xlsx',
                  // );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}