import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/edit_product/wizard/steps/step1_product_type.dart';
import 'package:totem_pro_admin/pages/edit_product/wizard/steps/step2_product_details.dart';
import 'package:totem_pro_admin/pages/edit_product/wizard/steps/step3_complements.dart';

import '../cubit/product_wizard_cubit.dart';
import '../cubit/product_wizard_state.dart';


class ProductWizardPage extends StatefulWidget {
  const ProductWizardPage({super.key});

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
      create: (context) => ProductWizardCubit(),
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
                  const Center(child: Text('Passo 4: Revisão')),
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
              ElevatedButton(
                onPressed: () {
                  if (state.currentStep < 4) {
                    context.read<ProductWizardCubit>().nextStep();
                  } else {
                    // Lógica para finalizar e salvar
                  //  context.read<ProductWizardCubit>().saveProduct();
                  }
                },
                child: Text(state.currentStep < 4 ? 'Continuar' : 'Finalizar Cadastro'),
              ),
            ],
          ),
        );
      },
    );
  }
}