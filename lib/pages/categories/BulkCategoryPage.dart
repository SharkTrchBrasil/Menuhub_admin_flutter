import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';

import 'package:totem_pro_admin/pages/categories/steps_bulk_category/step1.dart';
import 'package:totem_pro_admin/pages/categories/steps_bulk_category/step2.dart';

import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import '../../core/enums/bulk_action_type.dart';
import '../../core/enums/category_type.dart';
import '../../models/products/product.dart';
import '../../repositories/product_repository.dart';
import 'cubit/bulk_category_cubit.dart';
import 'cubit/bulk_category_state.dart';

class BulkAddToCategoryWizard extends StatefulWidget {
  final int storeId;
  final List<Product> selectedProducts;
  final List<Category> allCategories;
  final BulkActionType actionType;

  const BulkAddToCategoryWizard({
    super.key,
    required this.storeId,
    required this.selectedProducts,
    required this.allCategories,
    required this.actionType,
  });

  @override
  State<BulkAddToCategoryWizard> createState() => _BulkAddToCategoryWizardState();
}

class _BulkAddToCategoryWizardState extends State<BulkAddToCategoryWizard> {
  final _pageController = PageController();
  int _currentStep = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() => _currentStep = 2);
    _pageController.animateToPage(1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _previousStep() {
    setState(() => _currentStep = 1);
    _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {

// ===================================================================
    // ✅ LÓGICA DE FILTRO DEFINITIVA (Aplicada aqui)
    // ===================================================================

    // 1. Pega todas as categorias que podem ser selecionadas (regra de negócio)
    List<Category> filteredCategories = widget.allCategories
        .where((cat) => cat.type == CategoryType.GENERAL)
        .toList();

    // 2. Pega os IDs de TODAS as categorias às quais os produtos selecionados
    //    JÁ estão vinculados (seja um produto novo em memória ou um existente).
    final Set<int?> existingCategoryIds = widget.selectedProducts
        .expand((product) => product.categoryLinks) // Junta todos os links
        .map((link) => link.categoryId)           // Pega os IDs
        .toSet();                                  // Cria um conjunto sem duplicatas

    // 3. Remove da lista de seleção as categorias que já estão vinculadas.
    filteredCategories.removeWhere((cat) => existingCategoryIds.contains(cat.id));

    // ===================================================================


    return BlocProvider(
      create: (_) => BulkAddToCategoryCubit(
        productRepository: getIt<ProductRepository>(),
        storeId: widget.storeId,
        selectedProducts: widget.selectedProducts,
        actionType: widget.actionType,
      ),
      child: BlocListener<BulkAddToCategoryCubit, BulkAddToCategoryState>(
        listener: (context, state) {
          // ✅ LÓGICA ATUALIZADA DO LISTENER
          // Se a ação for MOVER e der sucesso, fecha a tela
          if (widget.actionType == BulkActionType.move && state.status == FormStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produtos movidos com sucesso!"), backgroundColor: Colors.green));
            context.pop(true); // Retorna 'true' para indicar sucesso
          }
          // Se a ação for ADICIONAR e o resultado estiver pronto, fecha e retorna os dados
          else if (widget.actionType == BulkActionType.add && state.addResult != null) {
            context.pop(state.addResult); // Retorna a lista de links para a tela de edição
          }
          // Tratamento de erro (funciona para ambos os casos)
          else if (state.status == FormStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? "Ocorreu um erro."), backgroundColor: Colors.red));
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false, // Remove o botão de voltar padrão
            title: const Text(
              'Adicionar à Categoria',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey[700]),
                onPressed: () => context.pop(),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0), // Altura do header do wizard
              child: _buildWizardHeader(context),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // ✅ PASSA A LISTA JÁ FILTRADA PARA O PASSO 1
                    Step1SelectCategory(allCategories: filteredCategories),
                    const Step2SetPrices(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomActionBar(context),
        ),
      ),
    );
  }

  Widget _buildWizardHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // Ajuste do padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de progresso
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentStep >= 1 ? const Color(0xFFEA1D2C) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentStep >= 2 ? const Color(0xFFEA1D2C) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Texto "Passo X de 2" alinhado à direita
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Passo $_currentStep de 2',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return BlocBuilder<BulkAddToCategoryCubit, BulkAddToCategoryState>(
      builder: (context, state) {
        final cubit = context.read<BulkAddToCategoryCubit>();
        final bool isStep1Valid = state.targetCategory != null;
        final bool isLoading = state.status == FormStatus.loading;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              DsButton(
                isLoading: isLoading,
                label: _currentStep == 1 ? "Continuar" : "Concluir",
                onPressed: (isLoading || (_currentStep == 1 && !isStep1Valid))
                    ? null
                    : () {
                  if (_currentStep == 1) {
                    _nextStep();
                  } else {
                    cubit.submit();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}