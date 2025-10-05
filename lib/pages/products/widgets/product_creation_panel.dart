import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/products/prodcut_category_links.dart';
import 'package:totem_pro_admin/pages/product-wizard/cubit/product_wizard_cubit.dart';
import 'package:totem_pro_admin/pages/product-wizard/product_wizard_page(delete).dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

import '../../../core/enums/form_status.dart';
import '../../../core/enums/product_type.dart';
import '../../product-wizard/cubit/product_wizard_state.dart';
import '../../product-wizard/steps/step1_product_type.dart';
import '../../product-wizard/steps/step2_product_details.dart';
import '../../product-wizard/steps/step3_complements.dart';
import '../../product-wizard/steps/step4_categories.dart';


class ProductCreationPanel extends StatelessWidget {
  final int storeId;
  final Category category;
  final VoidCallback onSaveSuccess;
  final VoidCallback onCancel;

  const ProductCreationPanel({
    super.key,
    required this.storeId,
    required this.category,
    required this.onSaveSuccess,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ProductWizardCubit(storeId: storeId);
        final initialLink = ProductCategoryLink(
          category: category,
          categoryId: category.id!,
          price: cubit.state.productInCreation.price ?? 0,
          product: cubit.state.productInCreation,
        );
        cubit.addCategoryLink(initialLink);
        return cubit;
      },
      child: BlocListener<ProductWizardCubit, ProductWizardState>(
        listener: (context, state) {
          if (state.submissionStatus == FormStatus.success) {
            onSaveSuccess();
          } else if (state.submissionStatus == FormStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? "Erro"), backgroundColor: Colors.red),
            );
          }
        },
        child: ProductWizardViewForPanel(onCancel: onCancel),
      ),
    );
  }
}

class ProductWizardViewForPanel extends StatefulWidget {
  final VoidCallback onCancel;
  const ProductWizardViewForPanel({super.key, required this.onCancel});

  @override
  State<ProductWizardViewForPanel> createState() => _ProductWizardViewForPanelState();
}

class _ProductWizardViewForPanelState extends State<ProductWizardViewForPanel> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<ProductWizardCubit>().stream.listen((state) {
      if (mounted) {
        final totalSteps = state.productType == ProductType.INDUSTRIALIZED ? 3 : 4;
        int visualStep = state.currentStep > totalSteps ? totalSteps : state.currentStep;
        if (visualStep - 1 != _pageController.page?.round()) {
          _pageController.animateToPage(
            visualStep - 1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ✅ 1. MÉTODO DO HEADER COPIADO E ADAPTADO
  Widget _buildWizardHeader(BuildContext context, ProductWizardState state, int totalSteps) {
    String titleText = 'Criar produto';
    if (state.productType == ProductType.PREPARED) {
      titleText = 'Criar produto preparado';
    } else if (state.productType == ProductType.INDUSTRIALIZED) {
      titleText = 'Criar produto industrializado';
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  titleText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: List.generate(totalSteps, (index) {
                  final bool isActive = (index + 1) <= state.currentStep;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                'Passo ${state.currentStep} de $totalSteps',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ 2. MÉTODO DO FOOTER COPIADO DIRETAMENTE
  Widget _buildBottomActionBar() {
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      builder: (context, state) {
        final cubit = context.read<ProductWizardCubit>();
        final totalSteps = state.productType == ProductType.INDUSTRIALIZED ? 3 : 4;
        final isLastStep = state.currentStep == totalSteps;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,

          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (state.currentStep > 1)
                Flexible(
                  child: DsButton(
                    style: DsButtonStyle.secondary,
                    onPressed: cubit.previousStep,
                    label: 'Voltar',
                  ),
                ),

                const SizedBox(width: 16,),


              Flexible(
                child: DsButton(
                  onPressed: (state.submissionStatus == FormStatus.loading || (state.currentStep == 2 && !state.isStep2Valid))
                      ? null
                      : () {
                    if (isLastStep) {
                      cubit.saveProduct();
                    } else {
                      cubit.nextStep();
                    }
                  },
                  isLoading: state.submissionStatus == FormStatus.loading,
                 label : (isLastStep ? 'Criar Produto' : 'Continuar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      builder: (context, state) {
        final steps = [
          const Step1ProductType(),
          Step2ProductDetails(),
          if (state.productType != ProductType.INDUSTRIALIZED) const Step3Complements(),
          Step4Categories(),
        ];

        // ✅ 3. UI ATUALIZADA PARA INCLUIR HEADER E FOOTER
        return Column(
          children: [
            // Cabeçalho com progresso
            _buildWizardHeader(context, state, steps.length),

            // Corpo do Wizard
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: steps,
                ),
              ),
            ),
            // Rodapé com botões
            _buildBottomActionBar(),
          ],
        );
      },
    );
  }
}