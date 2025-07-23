import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubits/active_store_cubit.dart';
import '../cubits/active_store_state.dart';


/// Um widget que exibe o status da assinatura de forma concisa,
/// ideal para ser usado em uma AppBar.
class AppBarSubscriptionInfo extends StatelessWidget {
  const AppBarSubscriptionInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos o BlocBuilder para ouvir as mudanças no ActiveStoreCubit
    return BlocBuilder<ActiveStoreCubit, ActiveStoreState>(
      builder: (context, state) {
        // Só mostramos algo se o estado for 'Loaded' e tiver dados
        if (state is ActiveStoreLoaded) {
          final subscription = state.store.subscription;

          // Retorna um widget vazio se não houver assinatura ou dados essenciais
          if (subscription == null ||
              subscription.planName == null ||
              subscription.currentPeriodEnd == null) {
            return const SizedBox.shrink(); // Não mostra nada
          }

          // Formata a data para dd/MM/yyyy
          final formattedDate =
          DateFormat('dd/MM/yyyy').format(subscription.currentPeriodEnd!);

          final status = subscription.status;
          Color statusColor = Colors.grey;

          switch (status) {
            case 'active':
              statusColor = Colors.green.shade400;
              break;
            case 'grace_period':
              statusColor = Colors.orange.shade400;
              break;
            case 'expired':
              statusColor = Colors.red.shade400;
              break;
          }


          // Retorna um widget com um visual limpo para a AppBar
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador visual do status
                Icon(Icons.shield, color: statusColor, size: 18),
                const SizedBox(width: 8),
                // Texto com as informações
                Text(
                  '${subscription.planName} | Vence em: $formattedDate',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        // Para qualquer outro estado (loading, error, initial), não mostramos nada.
        // Isso evita poluir a AppBar com indicadores de carregamento.
        return const SizedBox.shrink();
      },
    );
  }
}