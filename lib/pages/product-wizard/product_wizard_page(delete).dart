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
import '../../models/products/prodcut_category_links.dart';
import '../../widgets/ds_primary_button.dart';
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
        // 1. Criamos a instância do Cubit primeiro.
        final cubit = ProductWizardCubit(storeId: widget.storeId);

        // 2. Verificamos se uma categoria foi passada para a página.
        if (widget.category != null) {

          // ✅ 3. A MÁGICA: Criamos o objeto 'ProductCategoryLink' que o CUBIT espera.
          final initialLink = ProductCategoryLink(
            category: widget.category!,
            categoryId: widget.category!.id!,
            // Pega o preço inicial do produto que está no estado do CUBIT (geralmente 0)
            price: cubit.state.productInCreation.price ?? 0,
            product: cubit.state.productInCreation,
          );

          // ✅ 4. Agora sim, enviamos o objeto 'ProductCategoryLink' completo.
          cubit.addCategoryLink(initialLink);
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
          // ✅ A ESTRUTURA AGORA COMEÇA COM O BLOCBUILDER
          child: BlocBuilder<ProductWizardCubit, ProductWizardState>(
            builder: (context, state) {
              // A lista de steps é calculada aqui dentro, pois depende do estado
              final List<Widget> steps = [
                const Step1ProductType(),
                Step2ProductDetails(),
                if (state.productType != ProductType.INDUSTRIALIZED)
                  const Step3Complements(),
                Step4Categories(),
              ];

              // ✅ O SCAFFOLD É CONSTRUÍDO AQUI DENTRO
              return Scaffold(
                // 1. UMA APPBAR SIMPLES, APENAS PARA DAR ESTRUTURA E COR
                appBar: AppBar(
                  toolbarHeight: 0, // Esconde a barra de ferramentas padrão
                  elevation: 0,
                  backgroundColor: Colors.white,
                  // 2. NOSSO CABEÇALHO CUSTOMIZADO VAI NO 'bottom' DA APPBAR
                  bottom: _buildWizardHeader(context, state, steps.length),
                ),
                // 3. O PAGEVIEW COM OS PASSOS É O 'body' DO SCAFFOLD
                body: Padding(
                  padding:  EdgeInsets.all(ResponsiveBuilder.isMobile(context) ? 14 :24.0),
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: steps,
                  ),
                ),
                // 4. O RODAPÉ COM OS BOTÕES
                bottomNavigationBar: _buildBottomActionBar(),
              );
            },
          ),
        ),
      ),
    );
  }

  // ✅ O MÉTODO DO CABEÇALHO AGORA PRECISA SER UM 'PreferredSizeWidget'
  PreferredSizeWidget _buildWizardHeader(
      BuildContext context,
      ProductWizardState state,
      int totalSteps,
      ) {
    // A lógica interna para definir os textos continua a mesma
    String titleText = 'Criar produto';
    if (state.productType == ProductType.PREPARED) {
      titleText = 'Criar produto preparado';
    } else if (state.productType == ProductType.INDUSTRIALIZED) {
      titleText = 'Criar produto industrializado';
    }

    // Envolvemos nosso Column em um PreferredSize para que ele possa ser usado no 'bottom' da AppBar
    return PreferredSize(
      preferredSize: const Size.fromHeight(120.0), // Altura do nosso cabeçalho
      child: Container(
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
            // A barra de progresso
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
          //  border: Border(top: BorderSide(color: Colors.grey.shade200)),
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


              DsButton(
                onPressed: (state.submissionStatus == FormStatus.loading || (state.currentStep == 2 && !state.isStep2Valid))
                    ? null
                    : () {

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








