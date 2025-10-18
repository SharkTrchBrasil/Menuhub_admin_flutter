import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/core/enums/product_type.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/products/prodcut_category_links.dart';
import 'package:totem_pro_admin/pages/product-wizard/steps/step1_product_type.dart';
import 'package:totem_pro_admin/pages/product-wizard/steps/step2_product_details.dart';
import 'package:totem_pro_admin/pages/product-wizard/steps/step3_complements.dart';

import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

import '../product_edit/tabs/product_availability_tab.dart';
import '../product_edit/tabs/product_pricing_tab.dart';
import 'cubit/product_wizard_cubit.dart';
import 'cubit/product_wizard_state.dart';

class ProductCreationPanel extends StatelessWidget {
  final int storeId;
  final Category? category;
  final VoidCallback onSaveSuccess;
  final VoidCallback onCancel;

  const ProductCreationPanel({
    super.key,
    required this.storeId,
    this.category,
    required this.onSaveSuccess,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ProductWizardCubit(storeId: storeId)..startFlow();
        // Se uma categoria inicial for fornecida, já a adiciona aos links do produto.
        if (category != null) {
          final initialLink = ProductCategoryLink(
            category: category!,
            categoryId: category!.id!,
            price: cubit.state.productInCreation.price!,
          );
          cubit.addCategoryLink(initialLink);
        }
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
        child: const _ProductWizardView(),
      ),
    );
  }
}

class _ProductWizardView extends StatelessWidget {
  const _ProductWizardView();

  Widget _buildStepWidget(int step, ProductType type) {
    switch (step) {
      case 1:
        return const Step1ProductType();
      case 2:
        return const Step2ProductDetails();
      case 3:
      // O passo 3 é omitido para produtos INDUSTRIALIZED
        return type == ProductType.PREPARED ? const Step3Complements() : const ProductPricingTab();
      case 4:
        return const ProductPricingTab();
      default:
        return const Step1ProductType();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      builder: (context, state) {
        final cubit = context.read<ProductWizardCubit>();
        final totalSteps = state.productType == ProductType.INDUSTRIALIZED ? 3 : 4;
        final isLastStep = state.currentStep == totalSteps;
        final bool canContinue = state.currentStep != 2 || state.productInCreation.name.trim().isNotEmpty;

        return Column(
          children: [
            // 1. Cabeçalho com indicador de progresso
            _WizardHeader(
              productType: state.productType,
              currentStep: state.currentStep,
              totalSteps: totalSteps,
            ),

            // 2. Corpo do Wizard com transição
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Padding(
                  key: ValueKey<int>(state.currentStep), // Garante a troca do widget
                  padding: const EdgeInsets.all(24.0),
                  child: _buildStepWidget(state.currentStep, state.productType),
                ),
              ),
            ),

            // 3. Rodapé com botões de ação
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  // Botão Voltar (aparece a partir do passo 2)
                  if (state.currentStep > 1)
                    Expanded(
                      child: DsButton(
                        style: DsButtonStyle.secondary,
                        onPressed: cubit.previousStep,
                        label: 'Voltar',
                      ),
                    ),
                  if (state.currentStep > 1) const SizedBox(width: 16),

                  // Botão Continuar/Salvar
                  Expanded(
                    child: DsButton(
                      onPressed: (state.submissionStatus == FormStatus.loading || !canContinue)
                          ? null
                          : () {
                        if (isLastStep) {
                          cubit.saveProduct();
                        } else {
                          cubit.nextStep();
                        }
                      },
                      isLoading: state.submissionStatus == FormStatus.loading,
                      label: isLastStep ? 'Criar Produto' : 'Continuar',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WizardHeader extends StatelessWidget {
  final ProductType productType;
  final int currentStep;
  final int totalSteps;

  const _WizardHeader({
    required this.productType,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    String titleText = 'Criar novo produto';
    if (productType == ProductType.PREPARED) {
      titleText = 'Criar produto de produção própria';
    } else if (productType == ProductType.INDUSTRIALIZED) {
      titleText = 'Criar produto de revenda';
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titleText,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(totalSteps, (index) {
              final step = index + 1;
              final bool isActive = step <= currentStep;
              return Expanded(
                child: Container(
                  margin: step == totalSteps ? EdgeInsets.zero : const EdgeInsets.only(right: 4),
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}