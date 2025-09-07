import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/product-wizard/steps/step1_product_type.dart';
import 'package:totem_pro_admin/pages/product-wizard/steps/step2_product_details.dart';
import 'package:totem_pro_admin/pages/product-wizard/steps/step3_complements.dart';
import 'package:totem_pro_admin/pages/product-wizard/steps/step4_categories.dart';

import '../../core/enums/form_status.dart';
import '../../core/enums/product_type.dart';
import '../../core/responsive_builder.dart';
import '../../models/category.dart';
import 'cubit/product_wizard_cubit.dart';
import 'cubit/product_wizard_state.dart';

class ProductWizardPage extends StatefulWidget {
  const ProductWizardPage({super.key, required this.storeId, this.category});

  final int storeId;
  final Category? category;

  @override
  State<ProductWizardPage> createState() => _ProductWizardPageState();
}

class _ProductWizardPageState extends State<ProductWizardPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ProductWizardCubit(storeId: widget.storeId);

        // ✅ Se a categoria veio pelo construtor, adiciona no Cubit
        if (widget.category != null) {
          cubit.addCategoryLink(widget.category!);
        }

        return cubit;
      },
      child: BlocListener<ProductWizardCubit, ProductWizardState>(
        listener: (context, state) {


          // Lógica de animação da página (continua a mesma)
          final totalSteps = state.productType == ProductType.INDUSTRIALIZED ? 3 : 4;
          int visualStep = state.currentStep > totalSteps ? totalSteps : state.currentStep;
          if (visualStep - 1 != _pageController.page?.round()) {
            _pageController.animateToPage(
              visualStep - 1,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }


          // ✅ LÓGICA DE REAÇÃO ATUALIZADA
          if (state.submissionStatus == FormStatus.success) {
            // Apenas fecha a tela, retornando 'true' para indicar sucesso.
            // O SnackBar será mostrado pela tela anterior.
            context.pop(true);
          }
          else if (state.submissionStatus == FormStatus.error) {
            // Mostra o erro aqui mesmo, pois o usuário ainda está na tela
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Erro: ${state.errorMessage ?? 'Ocorreu uma falha.'}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: PopScope(
          // ✅ 2. `canPop: false` impede que o usuário saia da tela automaticamente
          canPop: false,
          // ✅ 3. `onPopInvoked` é chamado quando o usuário TENTA sair (botão voltar)
          onPopInvoked: (didPop) async {
            // Se o pop já aconteceu por algum motivo, não faz nada.
            if (didPop) return;

            final cubit = context.read<ProductWizardCubit>();

            // Verifica se o estado está "sujo" (se houve alterações)
            if (cubit.state.isDirty) {
              // Se estiver sujo, mostra o dialog de confirmação
              final shouldPop = await _showExitConfirmationDialog(context);
              if (shouldPop ?? false) {
                // Se o usuário confirmar, aí sim nós saímos da tela
                context.pop();
              }
            } else {
              // Se não houver alterações, pode sair da tela sem perguntar
              context.pop();
            }
          },

          child: Scaffold(
            body: BlocBuilder<ProductWizardCubit, ProductWizardState>(
              builder: (context, state) {
                // 1. Cria a lista de etapas dinamicamente.
                //    A etapa 3 só é incluída se o produto não for industrializado.
                final List<Widget> steps = [
                  const Step1ProductType(),
                  Step2ProductDetails(),
                  if (state.productType != ProductType.INDUSTRIALIZED)
                    const Step3Complements(),
                  Step4Categories(),
                ];

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24,
                    vertical: 14,
                  ),
                  child: SingleChildScrollView(
                    // Alterado de ListView para SingleChildScrollView
                    child: Column(
                      children: [
                        _buildWizardHeader(context, state, steps.length),
                        SizedBox(
                          // Adicionado SizedBox com altura fixa
                          height:
                              MediaQuery.of(context).size.height ,
                              // Ajuste conforme necessário
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: steps,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            bottomNavigationBar: _buildBottomActionBar(),
          ),
        ),
      ),
    );
  }



  Widget _buildWizardHeader(
      BuildContext context,
      ProductWizardState state,
      int totalSteps,
      ) {
    String titleText = 'Criar produto';
    if (state.productType == ProductType.PREPARED) {
      titleText = 'Criar produto preparado';
    } else if (state.productType == ProductType.INDUSTRIALIZED) {
      titleText = 'Criar produto industrializado';
    }

    // ✅ A LÓGICA DE 'visualStep' FOI REMOVIDA.
    //    Agora state.currentStep já é o passo visual correto.

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  titleText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Fechar',
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: List.generate(totalSteps, (index) {
                  // A comparação agora é direta com state.currentStep
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
              // O texto também usa os valores diretos
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

  Widget _buildBottomActionBar() {
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      builder: (context, state) {

        final cubit = context.read<ProductWizardCubit>();

        // A contagem de passos e a verificação de último passo agora são dinâmicas
        final totalSteps = state.productType == ProductType.INDUSTRIALIZED ? 3 : 4;
        final isLastStep = state.currentStep == totalSteps;




        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botão Voltar (só aparece a partir do passo 2)
              if (state.currentStep > 1)
                TextButton(
                  onPressed:
                      () => context.read<ProductWizardCubit>().previousStep(),
                  child: const Text('Voltar'),
                )
              else
                const SizedBox(), // Para manter o alinhamento
              // Botão Continuar/Finalizar


              ElevatedButton(
                onPressed: (state.submissionStatus == FormStatus.loading || (state.currentStep == 2 && !state.isStep2Valid))
                    ? null
                    : () {
                  // ✅ LÓGICA SIMPLIFICADA: Apenas manda o comando para o CUBIT.
                  // Sem await, sem SnackBar, sem pop.
                  if (isLastStep) {
                    cubit.saveProduct();
                  } else {
                    cubit.nextStep();
                  }
                },
                child: state.submissionStatus == FormStatus.loading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : Text(isLastStep ? 'Criar Produto' : 'Continuar'),
              ),












            ],
          ),
        );
      },
    );
  }

  // DENTRO DA CLASSE _ProductWizardPageState

  // ✅ ADICIONE ESTA FUNÇÃO AUXILIAR
  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sair da página'),
            content: const Text(
              'Ao sair da página, este produto não será criado. Ele e as informações cadastradas serão perdidas.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Não sair
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true), // Sair
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
  }
}
