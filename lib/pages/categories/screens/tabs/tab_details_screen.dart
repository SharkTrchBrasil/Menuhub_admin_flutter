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




}