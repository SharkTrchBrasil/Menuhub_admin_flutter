import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/core/enums/wizard_step.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/pages/categories/cubit/category_wizard_cubit.dart';
import 'package:totem_pro_admin/pages/categories/screens/category_template_selection_screen.dart';
import 'package:totem_pro_admin/pages/categories/screens/category_type_choice_widget.dart';
import 'package:totem_pro_admin/pages/categories/screens/customizable_category_details_screen.dart';
import 'package:totem_pro_admin/pages/categories/screens/general_category_details_screen.dart';
import 'package:totem_pro_admin/pages/categories/screens/pricing_model_selection_screen.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';

import '../../core/enums/category_type.dart';

// O conteúdo que antes era `CreateCategoryPage` agora é um widget reutilizável.
class CategoryPanel extends StatelessWidget {
  final int storeId;
  final Category? category; // Nulo para criar, preenchido para editar
 // Callback para fechar o painel
  final VoidCallback onSaveSuccess; // Callback para fechar e atualizar

  const CategoryPanel({
    super.key,
    required this.storeId,
    this.category,

    required this.onSaveSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryWizardCubit(
        categoryRepository: getIt<CategoryRepository>(),
        storeId: storeId,
        editingCategory: category,
      ),
      child: BlocListener<CategoryWizardCubit, CategoryWizardState>(
        listener: (context, state) {
          if (state.status == FormStatus.success) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text("Categoria salva com sucesso!"),
                  backgroundColor: Colors.green,
                ),
              );
         //   onSaveSuccess(); // Notifica o pai para fechar e atualizar
          } else if (state.status == FormStatus.error) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? "Ocorreu um erro."),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        child: const _CategoryPanelView(),
      ),
    );
  }
}

// A UI que antes era `_CreateCategoryView`
class _CategoryPanelView extends StatelessWidget {
  const _CategoryPanelView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryWizardCubit, CategoryWizardState>(
      builder: (context, state) {
        final cubit = context.read<CategoryWizardCubit>();
        final parentWidget = context.findAncestorWidgetOfExactType<CategoryPanel>()!;
        final title = state.editingCategoryId != null ? 'Editar Categoria' : 'Nova Categoria';

        return Column(

          children: [

            // Corpo do Wizard (conteúdo que troca)
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buildStep(context, state),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep(BuildContext context, CategoryWizardState state) {
    // Esta função é exatamente a mesma que você já tinha em `_CreateCategoryView`
    switch (state.step) {
      case WizardStep.typeSelection:
        return const CategoryTypeSelectionScreen(key: ValueKey('type_selection'));
      case WizardStep.pricingModelSelection:
        return const PricingModelSelectionScreen(key: ValueKey('pricing_model_selection'));
      case WizardStep.templateSelection:
        return const CategoryTemplateSelectionScreen(key: ValueKey('template_selection'));
      case WizardStep.details:
        if (state.categoryType == CategoryType.GENERAL) {
          return const GeneralCategoryDetailsScreen(key: ValueKey('general_details'));
        } else if (state.categoryType == CategoryType.CUSTOMIZABLE) {
          return const CustomizableCategoryDetailsScreen(key: ValueKey('customizable_details'));
        }
        return const Center(child: Text("Tipo de categoria inválido."));
    }
  }
}