// lib/pages/edit_product/widgets/groups/multi_step_panel_container.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/pages/edit_product/groups/steps/step0_initial_choice.dart';
import 'package:totem_pro_admin/pages/edit_product/groups/steps/step1_group_type.dart';
import 'package:totem_pro_admin/pages/edit_product/groups/steps/step1_select_group.dart';
import 'package:totem_pro_admin/pages/edit_product/groups/steps/step2_group_details.dart';
import 'package:totem_pro_admin/pages/edit_product/groups/steps/step2_set_rules.dart';
import 'package:totem_pro_admin/pages/edit_product/groups/steps/step3_add_complements.dart';

import 'cubit/create_complement_cubit.dart';




/// Este widget é o ponto de entrada do side panel.
/// Ele escuta o [CreateComplementGroupCubit] e renderiza o passo (tela) correto do wizard.
class MultiStepPanelContainer extends StatelessWidget {
  const MultiStepPanelContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // O BlocBuilder se reconstrói automaticamente sempre que o estado do Cubit muda.
    return BlocBuilder<CreateComplementGroupCubit, CreateComplementGroupState>(
      builder: (context, state) {
        // Usamos o AnimatedSwitcher para uma transição suave entre as telas
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            // Efeito de Fade (aparecer e desaparecer)
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildStepWidget(state), // Decide qual tela/passo mostrar
        );
      },
    );
  }

  /// Helper que mapeia cada valor do enum [CreateComplementStep] para seu respectivo widget de UI.
  Widget _buildStepWidget(CreateComplementGroupState state) {
    // A Key garante que o Flutter entenda que estamos trocando de widget,
    // o que é importante para o AnimatedSwitcher e para o estado dos widgets internos.
    final key = ValueKey(state.step);

    switch (state.step) {
      case CreateComplementStep.initial:
        return Step0InitialChoice(key: key);

    // Fluxo de Criação
      case CreateComplementStep.selectType:
        return Step1GroupType(key: key);
      case CreateComplementStep.groupDetails:
        return Step2GroupDetails(key: key, groupType: state.groupType!);
      case CreateComplementStep.addComplements:
        return Step3AddComplements(key: key);

    // Fluxo de Cópia
      case CreateComplementStep.copyGroup_SelectGroup:
        return Step1SelectGroup(key: key);
      case CreateComplementStep.copyGroup_SetRules:
        return Step2SetRules(key: key);

      default:
        return Center(key: key, child: const Text("Passo não implementado."));
    }
  }
}