import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/cubits/auth_cubit.dart';
import 'package:totem_pro_admin/cubits/auth_state.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/services/preference_service.dart'; // Importar
import 'package:totem_pro_admin/core/di.dart'; // Importar getIt


class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, authState) {
            if (authState is AuthUnauthenticated || authState is AuthError) {
              context.go('/sign-in');
            }
          },
        ),
        BlocListener<StoresManagerCubit, StoresManagerState>(
          listener: (context, storesState) async { // Tornar async
            final authState = context.read<AuthCubit>().state;

            if (authState is AuthAuthenticated && storesState is StoresManagerLoaded) {
              final preferenceService = getIt<PreferenceService>();
              final skipHub = await preferenceService.getSkipHubPreference();
              final lastStoreId = storesState.activeStore?.core.id;

              // ✅ LÓGICA CORRIGIDA:
              // Se o usuário quer pular a seleção E temos uma loja ativa...
              if (skipHub && lastStoreId != null) {
                // ...navegue para a ROTA BASE da loja.
                // O GoRouter.redirect vai interceptar isso e decidir o destino final (hub, wizard, etc).
                final destination = '/stores/$lastStoreId';
                print("🚀 SPLASH: Lojas carregadas. Navegando para a rota base da loja: $destination");
                context.go(destination);
              } else {
                // Se não for para pular, ou não houver loja ativa,
                // vá para a página de seleção de lojas (o antigo Hub).
                print("🚀 SPLASH: Lojas carregadas. Navegando para a seleção de lojas (/hub-selector)...");
                // Supondo que você tenha uma rota para a tela que lista as lojas.
                // Vamos chamar de '/hub-selector' por clareza.
                context.go('/hub'); // Ajuste se o nome da sua rota de seleção for outro.
              }
            }

            if (authState is AuthAuthenticated && storesState is StoresManagerEmpty) {
              print("🚀 SPLASH: Autenticado mas sem lojas. Navegando para /stores/new/wizard...");
              context.go('/stores/new/wizard');
            }
          },
        ),
      ],
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}