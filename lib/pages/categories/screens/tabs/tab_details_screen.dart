import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/widgets/tab_header.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

import '../../../../core/enums/cashback_type.dart';
import '../../../../core/enums/form_status.dart';
import '../../../../core/responsive_builder.dart';
import '../../cubit/category_wizard_cubit.dart';
import '../../widgets/category_type.dart';



class TabDetailsScreen extends StatelessWidget {
  const TabDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryWizardCubit, CategoryWizardState>(
      builder: (context, state) {
        final cubit = context.read<CategoryWizardCubit>();
        final isLoading = state.status == FormStatus.loading;

        // Verifica se está em modo de edição
        final bool isEditMode = state.editingCategoryId != null;

        // Define os textos com base no modo
        final String title = isEditMode ? 'Editar Categoria' : 'Nova Categoria';
        final String subtitle = isEditMode
            ? 'Altere as informações da sua categoria.'
            : 'Preencha as informações da nova categoria.';



        return SingleChildScrollView(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            //  const SizedBox(height: 24),
              _buildHeader(context, state),
              // ✅ 2. SUBSTITUA O TEXTO ANTIGO PELO NOVO WIDGET
            TabHeader(
                title: title,
                subtitle:  subtitle,

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
              const SizedBox(height: 24),

              const SizedBox(height: 24),
           //   _buildStatusSwitch(context, state, isLoading),
            //  const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }


  // ✅ 1. CABEÇALHO AGORA É DINÂMICO
  Widget _buildHeader(BuildContext context, CategoryWizardState state) {
    // Verifica se está em modo de edição
    final bool isEditMode = state.editingCategoryId != null;

    // Define os textos com base no modo
    final String title = isEditMode ? 'Editar Categoria' : 'Nova Categoria';
    final String subtitle = isEditMode
        ? 'Altere as informações da sua categoria.'
        : 'Preencha as informações da nova categoria.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          title, // Usa a variável de título
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          subtitle, // Usa a variável de subtítulo
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
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

  Widget _buildStatusSwitch(BuildContext context, CategoryWizardState state, bool isLoading) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        title: Text(
          "Status da Categoria",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          state.isActive ? "Visível para os clientes" : "Oculta do cardápio",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        value: state.isActive,
        onChanged: isLoading ? null : context.read<CategoryWizardCubit>().isActiveChanged,
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: state.isActive ? Colors.green.shade50 : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            state.isActive ? Icons.visibility : Icons.visibility_off,
            color: state.isActive ? Colors.green : Colors.grey,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
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
              label: 'Cancelar',
              style: DsButtonStyle.secondary,
              onPressed: isLoading ? null : () => context.read<CategoryWizardCubit>().cancelWizard(),

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