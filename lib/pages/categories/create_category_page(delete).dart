import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/categories/screens/category_template_selection_screen.dart';
import 'package:totem_pro_admin/pages/categories/screens/category_type_choice_widget.dart';
import 'package:totem_pro_admin/pages/categories/screens/customizable_category_details_screen.dart';
import 'package:totem_pro_admin/pages/categories/screens/general_category_details_screen.dart';
import 'package:totem_pro_admin/pages/categories/screens/pricing_model_selection_screen.dart';

import '../../core/di.dart';
import '../../core/enums/category_type.dart';
import '../../core/enums/form_status.dart';
import '../../core/enums/wizard_step.dart';
import '../../models/category.dart';
import '../../repositories/category_repository.dart';
import '../../widgets/ds_primary_button.dart';
import 'cubit/category_wizard_cubit.dart';


class CreateCategoryPage extends StatelessWidget {
  const CreateCategoryPage({super.key, required this.storeId, this.category});

  final int storeId;
  final Category? category;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // ✨ A LÓGICA DE INICIALIZAÇÃO FICA TODA AQUI DENTRO ✨
      create: (context) {
        // 1. Criamos a instância do Cubit
        final cubit = CategoryWizardCubit(
          categoryRepository: getIt<CategoryRepository>(),
          storeId: storeId,
          editingCategory: category,
          // Adicione aqui a dependência do StoresManagerCubit, se necessário
        );

        return cubit;
      },
      // ✨ ENVOLVA O SEU _CreateCategoryView COM UM BlocListener
      child: BlocListener<CategoryWizardCubit, CategoryWizardState>(
        listener: (context, state) {
          // Se o status for 'cancelled' OU 'success', fechamos o painel
          if (state.status == FormStatus.cancelled || state.status == FormStatus.success) {
            context.goNamed(
              'products', // O nome da sua tela de lista principal
              pathParameters: {
                'storeId': context.read<CategoryWizardCubit>().storeId.toString(),
              },
            );
          }
          if (state.status == FormStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Categoria salva com sucesso!"), backgroundColor: Colors.green),
            );
          }
        },
        child: const _CreateCategoryView(),
      ),
    );
  }
}






class _CreateCategoryView extends StatelessWidget {
  const _CreateCategoryView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryWizardCubit, CategoryWizardState>(
      builder: (context, state) {
        final cubit = context.read<CategoryWizardCubit>();
        final bool isDetailsValid = state.categoryName.trim().isNotEmpty;
        final bool isLoading = state.status == FormStatus.loading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {

                final cubit = context.read<CategoryWizardCubit>();


                if (cubit.state.editingCategoryId == null && cubit.state.step == WizardStep.details) {
                  cubit.goToTypeSelection();
                }
                // Em todos os outros casos (editando, no primeiro passo, etc.), saia da tela.
                else {
                  // Navega explicitamente para a lista, pois 'pop' não é seguro.
                  context.goNamed(
                    'products',
                    pathParameters: {'storeId': cubit.storeId.toString()},
                  );
                }




              },
            ),
            title: Text(
              state.editingCategoryId != null ? "Editar Categoria" : "Voltar",
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),

          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildStep(context, state),
          ),


        );
      },
    );
  }

  // O _buildStep continua igual
  Widget _buildStep(BuildContext context, CategoryWizardState state) {
    switch (state.step) {
      case WizardStep.typeSelection:
        return const CategoryTypeSelectionScreen(key: ValueKey('type_selection'));
    // ✅ ADICIONE ESTE NOVO CASE
      case WizardStep.pricingModelSelection:
        return const PricingModelSelectionScreen(key: ValueKey('pricing_model_selection'));

      case WizardStep.templateSelection:
        return const CategoryTemplateSelectionScreen(key: ValueKey('template_selection'));

      case WizardStep.details:
        if (state.categoryType == CategoryType.GENERAL) {
          return const GeneralCategoryDetailsScreen(key: ValueKey('general_details'));
        } else if (state.categoryType == CategoryType.CUSTOMIZABLE) {
          return const CustomizableCategoryDetailsScreen(key: ValueKey('customizable_details'));
        } else {
          return const Center(child: Text("Tipo de categoria não selecionado."));
        }
    }
  }


}