// lib/pages/product_edit/widgets/groups/multi_step_panel_container.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/enums/create_compement_step.dart';
import '../../../core/responsive_builder.dart';
import '../cubit/create_complement_cubit.dart';
import '../steps/step0_initial_choice.dart';
import '../steps/step1_group_type.dart';
import '../steps/step1_select_group.dart';
import '../steps/step2_group_details.dart';
import '../steps/step2_set_rules.dart';
import '../steps/step3_add_complements.dart';

// ✅ CLASSE DE CONFIGURAÇÃO ATUALIZADA COM `subtitle`
class WizardStepConfig {
  final String title;
  final String? subtitle; // Subtítulo opcional
  final int currentStep;
  final int totalSteps;
  final bool showStepIndicator;

  WizardStepConfig({
    required this.title,
    this.subtitle,
    this.currentStep = 0,
    this.totalSteps = 0,
    this.showStepIndicator = true,
  });
}

class MultiStepPanelContainer extends StatelessWidget {
  const MultiStepPanelContainer({super.key});

  // ✅ FUNÇÃO AUXILIAR ATUALIZADA
  WizardStepConfig _getStepConfig(CreateComplementGroupState state) {
    switch (state.step) {
      case CreateComplementStep.initial:
        return WizardStepConfig(
          title: "Grupo de complementos",
          // Adicionamos o subtítulo específico para o passo 0
          subtitle: "Crie um novo grupo ou copie um que já existe no seu cardápio.",
          showStepIndicator: false,
        );

    // --- Fluxo de Criação ---
      case CreateComplementStep.selectType:
        return WizardStepConfig(title: "Criar novo grupo", currentStep: 1, totalSteps: 3);
      case CreateComplementStep.groupDetails:
        return WizardStepConfig(title: "Criar novo grupo", currentStep: 2, totalSteps: 3);
      case CreateComplementStep.addComplements:
        return WizardStepConfig(title: "Criar novo grupo", currentStep: 3, totalSteps: 3);

    // --- Fluxo de Cópia ---
      case CreateComplementStep.copyGroup_SelectGroup:
        return WizardStepConfig(title: "Copiar grupo", currentStep: 1, totalSteps: 2);
      case CreateComplementStep.copyGroup_SetRules:
        return WizardStepConfig(title: "Copiar grupo", currentStep: 2, totalSteps: 2);

      default:
        return WizardStepConfig(title: "Grupo de complementos", showStepIndicator: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateComplementGroupCubit, CreateComplementGroupState>(
      builder: (context, state) {
        final config = _getStepConfig(state);

        return Scaffold(
          backgroundColor: Colors.white,
          // ✅ APPBAR COM ALTURA DINÂMICA
          appBar: AppBar(
            elevation: 0, // Sem sombra na barra principal
            toolbarHeight: config.subtitle != null ? 100 : 50, // Altura dinâmica baseada no conteúdo
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
           // titleSpacing: 24.0,
          //  actionsPadding: const EdgeInsets.only(right: 16.0),

            // Título principal e subtítulo
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinha à esquerda
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container para título e botão de fechar (alinhados na mesma linha)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        config.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22
                        ),
                      ),
                    ),
                    // Botão de fechar alinhado com o título
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 24),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                if (config.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    config.subtitle!,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.2, // Controla o espaçamento entre linhas
                    ),
                    maxLines: 2, // Permite até 2 linhas
                    overflow: TextOverflow.ellipsis,
                  ),
                ]
              ],
            ),
            // ✅ A MÁGICA ACONTECE AQUI: Usamos a propriedade `bottom` para o indicador de progresso
            bottom: config.showStepIndicator
                ? _WizardProgressIndicator(
              currentStep: config.currentStep,
              totalSteps: config.totalSteps,
            )
                : null,
          ),
          body: _buildCurrentStepWidget(state), // Passa o estado inteiro
        );
      },
    );
  }

  // Widget que retorna a tela correta com base no enum do estado
  Widget _buildCurrentStepWidget(CreateComplementGroupState state) {
    switch (state.step) {
      case CreateComplementStep.initial:
        return const Step0InitialChoice();
      case CreateComplementStep.selectType:
        return const Step1GroupType();
      case CreateComplementStep.groupDetails:
      // Passa o groupType do estado para o widget do passo
        return Step2GroupDetails(groupType: state.groupType!);
      case CreateComplementStep.addComplements:
        return const Step3AddComplements();
      case CreateComplementStep.copyGroup_SelectGroup:
        return const Step1SelectGroup();
      case CreateComplementStep.copyGroup_SetRules:
        return const Step2SetRules();
      default:
        return const Center(child: Text("Passo desconhecido"));
    }
  }
}

// ✅ NOVO WIDGET PRIVADO PARA O INDICADOR DE PROGRESSO
// Ele implementa `PreferredSizeWidget` para ser usado na propriedade `bottom` da AppBar
class _WizardProgressIndicator extends StatelessWidget implements PreferredSizeWidget {
  final int currentStep;
  final int totalSteps;

  const _WizardProgressIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,
          vertical: 14
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              for (int i = 0; i < totalSteps; i++) ...[
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: i < currentStep ? Colors.red : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                if (i < totalSteps - 1) const SizedBox(width: 4),
              ]
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Passo $currentStep de $totalSteps",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Define a altura total do widget, que é necessária para a AppBar
  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}