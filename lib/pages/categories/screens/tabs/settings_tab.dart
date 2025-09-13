import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/enums/cashback_type.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/pages/categories/cubit/category_wizard_cubit.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/widgets/tab_header.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryWizardCubit>();
    final state = context.watch<CategoryWizardCubit>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const TabHeader(
            title: 'Configurações da Categoria',
            subtitle: 'Defina regras de cashback, destino de impressão e outras configurações avançadas para esta categoria.',
          ),
          const SizedBox(height: 24),


          // Layout responsivo para os cards de Impressora e Cashback
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) { // Mobile
                return Column(
                  children: [
                    _buildPrinterDropdown(context, state, cubit),
                    const SizedBox(height: 16),
                    _buildCashbackSection(context, state),

                    const SizedBox(height: 16),
                    // Card de Status e Prioridade
                    _buildStatusAndPriorityCard(context, state, cubit),



                  ],
                );
              } else { // Desktop
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPrinterDropdown(context, state, cubit)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCashbackSection(context, state)),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Widgets auxiliares que estavam antes em 'tab_details_screen.dart'

  Widget _buildStatusAndPriorityCard(BuildContext context, CategoryWizardState state, CategoryWizardCubit cubit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text("Categoria Ativa", style: TextStyle(fontWeight: FontWeight.w500)),
              value: state.isActive,
              onChanged: cubit.isActiveChanged,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextFormField(
                initialValue: state.priority.toString(),
                decoration: const InputDecoration(
                  labelText: 'Ordem de Exibição (Prioridade)',
                  hintText: 'Ex: 1, 2, 3...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: cubit.priorityChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCashbackSection(BuildContext context, CategoryWizardState state) {
    final cubit = context.read<CategoryWizardCubit>();
    final isMobile = ResponsiveBuilder.isMobile(context);

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.monetization_on,
                    color: Colors.purple.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Regra de Cashback",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dropdown para tipo de cashback
            DropdownButtonFormField<CashbackType>(
              value: state.cashbackType,
              onChanged: (value) {
                if (value != null) {
                  cubit.cashbackTypeChanged(value);
                }
              },
              decoration: InputDecoration(
                labelText: "Tipo de Cashback",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items: CashbackType.values.map((type) {
                return DropdownMenuItem<CashbackType>(
                  value: type,
                  child: Text(_getCashbackTypeLabel(type)),
                );
              }).toList(),
              isExpanded: true,
            ),

            // Campo de valor apenas se cashback estiver ativo
            if (state.cashbackType != CashbackType.none) ...[
              const SizedBox(height: 16),
              TextFormField(
                initialValue: state.cashbackValue,
                onChanged: cubit.cashbackValueChanged,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Valor do Cashback",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixText: state.cashbackType == CashbackType.fixed ? "R\$ " : null,
                  suffixText: state.cashbackType == CashbackType.percentage ? "%" : null,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  String _getCashbackTypeLabel(CashbackType type) {
    switch (type) {
      case CashbackType.none:
        return "Nenhum cashback";
      case CashbackType.percentage:
        return "Percentual (%)";
      case CashbackType.fixed:
        return "Valor fixo (R\$)";
      default:
        return "Nenhum";
    }
  }


  Widget _buildPrinterDropdown(BuildContext context, CategoryWizardState state, CategoryWizardCubit cubit) {
    // A lógica para definir as opções e o valor atual continua a mesma
    const List<String> printerDestinations = ['', 'cozinha', 'bar', 'balcao'];
    final currentValue = printerDestinations.contains(state.printerDestination)
        ? state.printerDestination
        : null;

    // A mudança é na estrutura do Card
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // ✅ Padding ajustado para 16
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ 1. Header replicado do Cashback, com ícone e cor de Impressão
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50, // Nova cor para diferenciar
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.print_outlined, // Ícone relevante para impressão
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Destino de Impressão", // Novo título
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Espaçador igual

            // ✅ 2. O Dropdown que já funcionava agora é o corpo do card
            DropdownButtonFormField<String>(
              value: currentValue,
              decoration: InputDecoration(
                labelText: "Local de Impressão", // Label ajustado
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items: printerDestinations.map((String destination) {
                return DropdownMenuItem<String>(
                  value: destination,
                  child: Text(destination.isEmpty ? 'Nenhum / Padrão da Loja' : destination),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  cubit.printerDestinationChanged(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow(BuildContext context, CategoryWizardState state, CategoryWizardCubit cubit) {
    final isMobile = ResponsiveBuilder.isMobile(context);

    // Se for mobile, retorna uma Coluna com os widgets empilhados
    if (isMobile) {
      return Column(
        children: [
          _buildPrinterDropdown(context, state, cubit),
          const SizedBox(height: 24),
          _buildCashbackSection(context, state),
        ],
      );
    }
    // Se for desktop, retorna uma Linha com os widgets lado a lado
    else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha os cards pelo topo
        children: [
          // O Expanded faz com que cada widget filho ocupe o espaço disponível igualmente
          Expanded(
            flex: 1, // Ocupa uma fração do espaço
            child: _buildPrinterDropdown(context, state, cubit),
          ),
          const SizedBox(width: 24), // Espaçamento entre os cards
          Expanded(
            flex: 1, // Ocupa a outra fração do espaço
            child: _buildCashbackSection(context, state),
          ),
        ],
      );
    }
  }


}