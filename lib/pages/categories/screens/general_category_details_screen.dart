import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/widgets/tab_header.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import '../../../core/enums/cashback_type.dart';
import '../../../core/enums/form_status.dart';
import '../../../core/responsive_builder.dart';
import '../cubit/category_wizard_cubit.dart';
import '../widgets/category_type.dart';

class GeneralCategoryDetailsScreen extends StatelessWidget {
  const GeneralCategoryDetailsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return
      BlocBuilder<CategoryWizardCubit, CategoryWizardState>(
      builder: (context, state) {
        final cubit = context.read<CategoryWizardCubit>();
        final isLoading = state.status == FormStatus.loading;
        final isMobile = ResponsiveBuilder.isMobile(context);
        // Verifica se está em modo de edição
        final bool isEditMode = state.editingCategoryId != null;

        // Define os textos com base no modo
        final String title = isEditMode ? 'Editar Categoria' : 'Nova Categoria';
        final String subtitle = isEditMode
            ? 'Altere as informações da sua categoria.'
            : 'Preencha as informações da nova categoria.';

        return Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [


                        TabHeader(
                          title: title,
                          subtitle:  subtitle,
                         // icon: Icons.straighten_outlined, // Exemplo com ícone opcional
                        ),

                        const SizedBox(height: 24),
                        // ✅ SUBSTITUA O MÉTODO ANTIGO PELO NOVO WIDGET
                        CategoryTypeInfoCard(
                          categoryType: state.categoryType,
                          onPressed: cubit.goToTypeSelection,
                          isEditMode: state.editingCategoryId != null,
                        ),

                        const SizedBox(height: 24),
                        _buildNameField(context, state, cubit),
                        const SizedBox(height: 34),
                        // ✅ AQUI: Substituímos os widgets individuais pela nova linha responsiva
                     //   _buildSettingsRow(context, state, cubit),

                        const SizedBox(height: 24), // Espaço extra no final do scroll
                    //  _buildStatusSwitch(context, state, isLoading),


                     //   const SizedBox(height: 44),
                      ],
                    ),
                  ),
                ),

                // O Spacer foi removido.

                // ✨ 2. O RODAPÉ AGORA FICA FORA DA ÁREA DE SCROLL, FIXO NA BASE ✨
                _buildFooterButtons(context, state, isLoading, isMobile),
              ],
            ),
          ),
        );
      },
    );
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




  Widget _buildNameField(BuildContext context, CategoryWizardState state, CategoryWizardCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nome da categoria',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: state.categoryName,
          autofocus: true,
          onChanged: cubit.updateCategoryName,
          decoration: InputDecoration(
            hintText: 'Ex: Lanches, Bebidas, Sobremesas',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            counterText: '${state.categoryName.length}/40',
            suffixIcon: state.categoryName.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () => cubit.updateCategoryName(''),
            )
                : null,
          ),
          maxLength: 40,
        ),
      ],
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

  Widget _buildFooterButtons(BuildContext context, CategoryWizardState state, bool isLoading, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        //border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.end,
        children: [
          if (!isMobile) const Spacer(),
          Expanded(
            flex: isMobile ? 1 : 0,
            child: DsButton(
              requiresConnection: false,
              label: 'Cancelar',
              style: DsButtonStyle.secondary,
              onPressed: (){
                context.pop();
              }

            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: isMobile ? 1 : 0,
            child: DsButton(
              isLoading: isLoading,
              label: state.editingCategoryId !=null ? 'Salvar Alterações' : 'Criar Categoria',
              onPressed: state.categoryName.trim().isNotEmpty && !isLoading
                  ? () async {
                await context.read<CategoryWizardCubit>().submitCategory();
              }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}