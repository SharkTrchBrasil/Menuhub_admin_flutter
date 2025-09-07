import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/products/steps_bulk_category/step1.dart';
import 'package:totem_pro_admin/pages/products/steps_bulk_category/step2.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import '../../repositories/product_repository.dart';
import 'cubit/bulk_category_cubit.dart';
import 'cubit/bulk_category_state.dart';

class BulkAddToCategoryWizard extends StatefulWidget {
  final int storeId;
  final List<Product> selectedProducts;
  final List<Category> allCategories;

  const BulkAddToCategoryWizard({
    super.key,
    required this.storeId,
    required this.selectedProducts,
    required this.allCategories,
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
    return BlocProvider(
      create: (_) => BulkAddToCategoryCubit(
        productRepository: getIt<ProductRepository>(),
        storeId: widget.storeId,
        selectedProducts: widget.selectedProducts,
      ),
      child: BlocListener<BulkAddToCategoryCubit, BulkAddToCategoryState>(
        listener: (context, state) {
          if (state.status == FormStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produtos atualizados com sucesso!"), backgroundColor: Colors.green));
            context.pop(); // Fecha o side-panel
          } else if (state.status == FormStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? "Ocorreu um erro."), backgroundColor: Colors.red));
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // Header personalizado no estilo iFood
              _buildWizardHeader(context),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Step1SelectCategory(allCategories: widget.allCategories),
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
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        SizedBox(height: 24,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Adicionar a uma categoria existente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.pop(),
                child: Icon(
                  Icons.close,
                  color: Colors.grey[700],
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

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
              style: TextStyle(
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
// Em _BulkAddToCategoryWizardState

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
            mainAxisAlignment: MainAxisAlignment.end, // Alinhado à direita para consistência
            children: [
              // Botão Voltar (só aparece a partir do passo 2)
              if (_currentStep == 2)
                TextButton(
                  // Desabilita o botão se estiver carregando
                  onPressed: isLoading ? null : _previousStep,
                  child: const Text('Voltar'),
                )
              else
              // Usamos um Spacer para empurrar o botão 'Continuar' para a direita no passo 1
                const Spacer(),

              // Botão Continuar/Concluir
              DsButton(
                isLoading: isLoading,
                label: _currentStep == 1 ? "Continuar" : "Concluir",
                // Habilita o botão com base na validação de cada passo
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



