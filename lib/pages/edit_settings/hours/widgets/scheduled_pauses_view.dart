// lib/pages/opening_hours/widgets/scheduled_pauses_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/calendar.svg',
              height: 150,
              colorFilter: ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma pausa programada',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crie pausas para eventos, feriados ou manutenções.\nSua loja não receberá pedidos durante estes períodos.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            DsButton(
              label: 'Criar primeira pausa',
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

        final pauses = state.activeStore!.scheduledPauses;
        pauses.sort((a, b) => a.startTime.compareTo(b.startTime));

        // ✅ A LÓGICA AGORA FICA DENTRO DO BUILDER
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabeçalho com título e botão de adicionar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                if (pauses.isNotEmpty)
                  Flexible(
                    child: DsButton(
                      onPressed: onAddPause,

                      label: 'Nova pausa programada',
                    ),
                  ),
              ],
            ),


            SizedBox(height: 18,),
            // 2. Lógica condicional que mostra o estado vazio ou a lista
            if (pauses.isEmpty)
              _buildEmptyState(context)
            else
            // ✅ LISTVIEW.BUILDER CORRIGIDO, SEM EXPANDED
              ListView.builder(
                // Diz para a ListView se encolher para caber no seu conteúdo.
                shrinkWrap: true,
                // Delega a rolagem para o SingleChildScrollView da página pai.
                primary: false,
                itemCount: pauses.length,
                itemBuilder: (context, index) {
                  final pause = pauses[index];
                  return PauseListItemCard(
                    pause: pause,
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmar Exclusão'),
                          content: const Text('Tem certeza que deseja remover esta pausa programada?'),
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
                  );
                },
              ),
          ],
        );
      },
    );
  }
}