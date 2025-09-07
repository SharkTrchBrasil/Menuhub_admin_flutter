import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/categories/screens/category_type_choice_widget.dart';
import 'package:totem_pro_admin/pages/categories/screens/customizable_category_details_screen.dart';
import 'package:totem_pro_admin/pages/categories/screens/general_category_details_screen.dart';

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
            context.pop();
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




// lib/pages/categories/create_category_page.dart

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
                if (state.step == WizardStep.details) {
                  cubit.goToTypeSelection();
                } else {
                  context.pop();
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

          // // ✅ --- A CORREÇÃO ESTÁ AQUI --- ✅
          // // O rodapé agora só é construído se o passo for 'details'
          // bottomNavigationBar: state.step == WizardStep.details
          //     ? _buildFooterButtons( // MOSTRA o rodapé na tela de detalhes
          //   context: context,
          //   cubit: cubit,
          //   isFormValid: isDetailsValid,
          //   isLoading: isLoading,
          //   isEditing: state.editingCategoryId != null,
          // )
          //     : null, // ESCONDE o rodapé na tela de seleção de tipo
        );
      },
    );
  }

  // O _buildStep continua igual
  Widget _buildStep(BuildContext context, CategoryWizardState state) {
    switch (state.step) {
      case WizardStep.typeSelection:
        return const CategoryTypeSelectionScreen(key: ValueKey('type_selection'));
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