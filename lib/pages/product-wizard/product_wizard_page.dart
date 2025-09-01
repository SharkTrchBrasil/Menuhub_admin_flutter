import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/product-wizard/steps/step1_product_type.dart';
import 'package:totem_pro_admin/pages/product-wizard/steps/step2_product_details.dart';
import 'package:totem_pro_admin/pages/product-wizard/steps/step3_complements.dart';
import 'package:totem_pro_admin/pages/product-wizard/steps/step4_categories.dart';

import '../../core/enums/form_status.dart';
import '../../core/enums/product_type.dart';
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
          // Anima a transição da página quando o passo muda no Cubit
          if (state.currentStep - 1 != _pageController.page?.round()) {
            _pageController.animateToPage(
              state.currentStep - 1,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
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



                return Column(
                  children: [
                    // Passamos a contagem total de passos para o header.
                    _buildWizardHeader(context, state, steps.length),

                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        // 2. Usa a lista de etapas dinâmica.
                        children: steps,
                      ),
                    ),
                  ],
                );
              },
            ),
            bottomNavigationBar: _buildBottomActionBar(),
          ),
        ),
      ),
    );
  }

// ✅ MÉTODO DO CABEÇALHO ATUALIZADO
  Widget _buildWizardHeader(BuildContext context, ProductWizardState state, int totalSteps) {
    // ✅ 1. LÓGICA PARA O TÍTULO DINÂMICO
    String titleText = 'Criar produto';
    if (state.productType == ProductType.PREPARED) {
      titleText = 'Criar produto preparado';
    } else if (state.productType == ProductType.INDUSTRIALIZED) {
      titleText = 'Criar produto industrializado';
    }

    // ✅ LÓGICA PARA CORRIGIR O NÚMERO DO PASSO ATUAL
    int visualStep = state.currentStep;
    // Se o produto é industrializado e o passo lógico é 4, o passo visual é 3.
    if (state.productType == ProductType.INDUSTRIALIZED && state.currentStep == 4) {
      visualStep = 3;
    }


    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- PARTE 1: BREADCRUMBS ---
          Row(
            children: [
              InkWell(
                onTap: () => context.pop(), // Volta para a lista de produtos
                child: Text(
                  'Cardápio',
                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade600),
              ),
              Text(
                'Criar produto',
                style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),



          // --- TÍTULO E BOTÃO FECHAR (com alterações) ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título agora é expandido para empurrar o botão para a direita
              Expanded(
                child: Text(
                  titleText, // ✅ Usa o texto dinâmico
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              // ✅ 2. BOTÃO FECHAR AGORA É SÓ UM ÍCONE
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Fechar',
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- BARRA DE PROGRESSO DINÂMICA ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                // Usa o `totalSteps` dinâmico para gerar as barrinhas
                children: List.generate(totalSteps, (index) {
                  // A lógica de ativação agora compara com o `visualStep`
                  final bool isActive = (index + 1) <= visualStep;
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
              // Usa o `visualStep` e o `totalSteps` para o texto
              Text(
                'Passo $visualStep de $totalSteps',
                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 12),
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
                  onPressed: () => context.read<ProductWizardCubit>().previousStep(),
                  child: const Text('Voltar'),
                )
              else
                const SizedBox(), // Para manter o alinhamento

              // Botão Continuar/Finalizar
              ElevatedButton(
                onPressed: state.submissionStatus == FormStatus.loading
                    ? null // Desabilita o botão enquanto salva
                    : () async {
                  // ✅ CORREÇÃO: Verifica se é o último passo
                  if (state.currentStep < 4) {
                    // Se não for o último passo, apenas avança
                    context.read<ProductWizardCubit>().nextStep();
                  } else {
                    // Se for o último passo, salva o produto
                    await context.read<ProductWizardCubit>().saveProduct();

                    // Ouve o resultado para fechar a tela ou mostrar erro
                    final finalState = context.read<ProductWizardCubit>().state;
                    if (finalState.submissionStatus == FormStatus.success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Produto criado com sucesso!"),
                              backgroundColor: Colors.green
                          )
                      );
                      context.pop(); // Volta para a tela anterior após salvar
                    } else if (finalState.submissionStatus == FormStatus.error && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Erro: ${finalState.errorMessage}"),
                              backgroundColor: Colors.red
                          )
                      );
                    }
                  }
                },
                child: state.submissionStatus == FormStatus.loading
                    ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2
                    )
                )
                    : Text(state.currentStep < 4 ? 'Continuar' : 'Criar Produto'),
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
      builder: (context) => AlertDialog(
        title: const Text('Sair da página'),
        content: const Text('Ao sair da página, este produto não será criado. Ele e as informações cadastradas serão perdidas.'),
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