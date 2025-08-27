// lib/pages/opening_hours/widgets/scheduled_pauses_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/scheduled_pause.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import '../../../../widgets/app_toasts.dart' as AppToasts;
import 'pause_list_item_card.dart';

class ScheduledPausesView extends StatelessWidget {
  final VoidCallback onAddPause;

  const ScheduledPausesView({super.key, required this.onAddPause});

  // ✅ WIDGET PARA O ESTADO VAZIO (CORRIGIDO CONFORME A REFERÊNCIA)
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          children: [
            Text(
              'Você pode cadastrar aqui os momentos em que a loja estará fechada.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            DsButton(
              label: 'Nova pausa programada',
              onPressed: onAddPause,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded || state.activeStore == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final pauses = state.activeStore!.relations.scheduledPauses;
        pauses.sort((a, b) => a.startTime.compareTo(b.startTime)); // Ordena por data

        if (pauses.isEmpty) {
          return _buildEmptyState(context);
        }

        // ✅ LÓGICA PARA AGRUPAR AS PAUSAS POR MÊS
        final Map<String, List<ScheduledPause>> pausesByMonth = {};
        for (var pause in pauses) {
          final monthKey = DateFormat('MMMM yyyy', 'pt_BR').format(pause.startTime.toLocal());
          if (pausesByMonth[monthKey] == null) {
            pausesByMonth[monthKey] = [];
          }
          pausesByMonth[monthKey]!.add(pause);
        }

        // ✅ A ESTRUTURA PRINCIPAL AGORA É UMA COLUMN COM A LISTA
        return Column(
          children: [
            // ✅ O CABEÇALHO RESPONSIVO É CHAMADO AQUI
            _buildHeader(context),
            const SizedBox(height: 34),

            // ListView para os meses
            ListView.separated(
              primary: false,
              shrinkWrap: true,
              itemCount: pausesByMonth.keys.length,
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(),
              ),
              itemBuilder: (context, index) {
                final monthAndYearKey = pausesByMonth.keys.elementAt(index);
                final monthPauses = pausesByMonth[monthAndYearKey]!;

                // ✅ PEGA APENAS O NOME DO MÊS PARA EXIBIR
                final monthName = DateFormat('MMMM', 'pt_BR').format(monthPauses.first.startTime.toLocal());



                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0,),
                      child: Text(
                        monthName[0].toUpperCase() + monthName.substring(1),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Column para os cards de pausa daquele mês
                    Column(
                      children: monthPauses.map((pause) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: PauseListItemCard(
                                pause: pause,
                                onEdit: () {
                                  // TODO: Chamar o diálogo de edição de pausa aqui
                                },
                                onDelete: () async {
                                  // Lógica de deleção com confirmação
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Confirmar Exclusão'),
                                      content: const Text('Tem certeza que deseja remover esta pausa?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Remover', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final success = await context.read<StoresManagerCubit>().deletePause(pauseId: pause.id);
                                    if (success && context.mounted) {
                                      AppToasts.showSuccess('Pausa removida com sucesso!');
                                    }
                                  }
                                },
                              ),
                            ),
                            Divider(height: 1, color: Colors.grey[300]),
                          ],
                        );




                      }).toList(),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
  // ✅ NOVO WIDGET DE CABEÇALHO RESPONSIVO
  Widget _buildHeader(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 720;

    final textWidget = Text(
      'Você pode cadastrar aqui os momentos em que a loja estará fechada.',
      // Definimos um máximo de 2 linhas para o texto
      maxLines: 2,
      overflow: TextOverflow.ellipsis,

      style: Theme.of(context)
          .textTheme
          .bodyMedium
          ?.copyWith(fontWeight: FontWeight.w500),
    );

    final buttonWidget = DsButton(
      onPressed: onAddPause,
      label: 'Nova pausa programada',
      icon: Icons.add,
    );

    if (isMobile) {
      // Layout em Coluna para mobile
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textWidget,
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: buttonWidget,
          ),
        ],
      );
    } else {
      // Layout em Linha para desktop
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Alinha verticalmente
        children: [
          Expanded(child: textWidget), // Força o texto a quebrar a linha
          const SizedBox(width: 24),
          buttonWidget,
        ],
      );
    }
  }
}