import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ✅ PASSO 1: Importe o que precisamos
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/widgets/base_dialog.dart';

/// Exibe um diálogo padrão informando o usuário que ele precisa fazer upgrade.
Future<void> showUpgradeDialog(BuildContext context, String featureName) {

  return showDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true, // Permite fechar clicando fora
    builder: (BuildContext context) {
      return BaseDialog(
        title: 'Funcionalidade Premium',
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                'O recurso "$featureName" não está incluso no seu plano atual.',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Faça um upgrade para ter acesso a esta e outras funcionalidades incríveis para impulsionar seu negócio!',
              ),
            ],
          ),
        ),
        onSave: () {
          // ✅ PASSO 2: Obtenha o ID da loja a partir do Cubit
          final storesManagerCubit = getIt<StoresManagerCubit>();
          final currentState = storesManagerCubit.state;

          // Verifica se o estado atual está carregado e tem os dados da loja
          if (currentState is StoresManagerLoaded) {
            final activeStoreId = currentState.activeStoreId;

            // Fecha o diálogo antes de navegar
            Navigator.of(context).pop();

            // ✅ PASSO 3: Use o ID obtido para navegar
            context.go('/stores/$activeStoreId/plans');
          } else {
            // Caso de segurança: se o estado não estiver carregado, apenas fecha o diálogo.
            // Você pode adicionar um toast de erro aqui se quiser.
            Navigator.of(context).pop();
          }
        },
        saveText: 'Ver planos',
      );
    },
  );
}