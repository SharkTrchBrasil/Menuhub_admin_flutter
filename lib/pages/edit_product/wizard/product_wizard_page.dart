import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/edit_product/wizard/steps/step1_product_type.dart';
import 'package:totem_pro_admin/pages/edit_product/wizard/steps/step2_product_details.dart';
import 'package:totem_pro_admin/pages/edit_product/wizard/steps/step3_complements.dart';
import 'package:totem_pro_admin/pages/edit_product/wizard/steps/step4_categories.dart';

import '../cubit/product_wizard_cubit.dart';

import '../groups/cubit/create_complement_cubit.dart';


class ProductWizardPage extends StatefulWidget {
  const ProductWizardPage({super.key, required this.storeId});

  final int storeId;
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
      create: (context) => ProductWizardCubit(storeId: widget.storeId),
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
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: _buildAppBarTitle(),
            automaticallyImplyLeading: false, // Remove o botão de voltar padrão
          ),
          body: BlocBuilder<ProductWizardCubit, ProductWizardState>(
            builder: (context, state) {
              return PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  const Step1ProductType(),
                  Step2ProductDetails(),
                  Step3Complements(),
                  // ✅ SUBSTITUA O PLACEHOLDER PELA TELA REAL
                  Step4Categories(),
                ],
              );
            },
          ),
          bottomNavigationBar: _buildBottomActionBar(),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Criar produto',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Barra de progresso
                Row(
                  children: List.generate(4, (index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      height: 4,
                      width: 40,
                      color: (index + 1) <= state.currentStep
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    );
                  }),
                ),
              ],
            ),
            Text(
              'Passo ${state.currentStep} de 4',
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
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
              // Em product_wizard_page.dart, no _buildBottomActionBar

              ElevatedButton(
                onPressed: state.submissionStatus == FormStatus.loading
                    ? null // Desabilita o botão enquanto salva
                    : () async {
                  // A chamada é a mesma, mas agora o Cubit tem a lógica real
                  await context.read<ProductWizardCubit>().saveProduct();

                  // Ouve o resultado no BlocListener para fechar a tela ou mostrar erro
                  final finalState = context.read<ProductWizardCubit>().state;
                  if (finalState.submissionStatus == FormStatus.success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Produto criado com sucesso!"), backgroundColor: Colors.green)
                    );
                    context.pop(); // Volta para a tela anterior após salvar
                  } else if (finalState.submissionStatus == FormStatus.error && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Erro: ${finalState.errorMessage}"), backgroundColor: Colors.red)
                    );
                  }
                },
                child: state.submissionStatus == FormStatus.loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(state.currentStep < 4 ? 'Continuar' : 'Criar Produto'),
              ),
            ],
          ),
        );
      },
    );
  }
}