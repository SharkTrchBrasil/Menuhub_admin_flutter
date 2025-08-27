import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/cubits/auth_cubit.dart';
import 'package:totem_pro_admin/cubits/auth_state.dart';
import 'package:totem_pro_admin/widgets/app_logo.dart'; // Supondo que seu logo esteja aqui

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      // O listener que vai "despachar" o usuário para a rota correta
      listener: (context, state) {
        // Usamos um pequeno delay para garantir que a transição seja suave
        // e não aconteça no mesmo frame da construção da splash.
        Future.delayed(const Duration(milliseconds: 200), () {
          if (!context.mounted) return;

          // Cenário 1: Autenticado com sucesso
          if (state is AuthAuthenticated) {
            final stores = state.data.stores;
            if (stores.isNotEmpty) {
              // Se tiver lojas, vai para a primeira loja da lista
              final firstStoreId = stores.first.store.core.id;
              context.go('/stores/$firstStoreId/dashboard');
            } else {
              // Se não tiver lojas, vai para a tela de criação de loja
              context.go('/stores/new');
            }
          }
          // Cenário 2: Não autenticado ou erro no login
          else if (state is AuthUnauthenticated || state is AuthError) {
            context.go('/sign-in');
          }
          // Cenário 3: Precisa verificar o e-mail
          else if (state is AuthNeedsVerification) {
            final email = Uri.encodeComponent(state.email);
            context.go('/verify-email?email=$email');
          }
        });
      },
      // A UI da splash page é simples: apenas o logo e um indicador
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLogo(size: 80), // Um pouco maior para destaque
              SizedBox(height: 32),

            ],
          ),
        ),
      ),
    );
  }
}