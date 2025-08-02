import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import '../../cubit/create_complement_cbit.dart';
import '../../cubit/create_complement_state.dart';
import 'create_group_panel.dart';
import 'create_group_panel_step1.dart' hide GroupType;
import 'create_group_panel_step2.dart';
import 'create_group_panel_step3.dart';
/// Este widget agora ouve o Cubit para decidir qual passo mostrar.
class MultiStepPanelContainer extends StatelessWidget {
  const MultiStepPanelContainer({super.key});

  @override
  Widget build(BuildContext context) {
    // O BlocBuilder se reconstrói automaticamente sempre que o estado do Cubit muda.
    return BlocBuilder<CreateComplementGroupCubit, CreateComplementGroupState>(
      builder: (context, state) {
        // Usamos o 'state.step' para decidir qual widget mostrar.
        // O IndexedStack é ótimo para isso, pois mantém o estado dos painéis anteriores.
        return IndexedStack(
          index: state.step.index, // O índice é controlado pelo enum do estado
          children: [
            // Passo 0: Painel de escolha inicial (Criar ou Copiar)
            AddGroupPanel(),

            // Passo 1: Painel de seleção de tipo
            CreateGroupStep1Panel(),

            // Passo 2: Painel de detalhes do grupo
            CreateGroupStep2Panel(
              // Passamos o tipo de grupo que está salvo no estado do Cubit
              groupType: state.groupType ?? GroupType.ingredients,
            ),

            // Passo 3: Painel para adicionar os complementos
            CreateGroupStep3Panel(
              groupType: state.groupType ?? GroupType.ingredients,
              groupName: state.groupName, // Passa o nome salvo no estado
            ),
          ],
        );
      },
    );
  }
}