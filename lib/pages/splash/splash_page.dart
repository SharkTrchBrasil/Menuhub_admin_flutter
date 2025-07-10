import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/pages/splash/splash_page_cubit.dart';
import 'package:totem_pro_admin/services/auth_service.dart';
import 'package:totem_pro_admin/widgets/app_logo.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

import '../../repositories/auth_repository.dart';
import '../../repositories/store_repository.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key, required this.redirectTo});

  final String? redirectTo;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final AuthService _authService;
  late final SplashPageCubit _cubit;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    _cubit = getIt<SplashPageCubit>();
    _initializeApp();
  }
  Future<void> _initializeApp() async {
    final authService = getIt<AuthService>();

    final result = await authService.initializeApp();

    if (!mounted) return;

    result.fold(
          (error) => _handleAuthError(error),
          (totemAuth) async {
        // Busca as lojas novamente para garantir consistência
        final storesResult = await getIt<StoreRepository>().getStores();

        if (!mounted) return;

        storesResult.fold(
              (_) => showError('Não foi possível buscar suas lojas.'),
              (stores) {
            if (stores.isNotEmpty) {
              context.go(widget.redirectTo ?? '/stores/${stores.first.store.id}/orders');
            } else {
              context.go('/stores/new');
            }
          },
        );
      },
    );
  }


  void _handleAuthError(SignInError error) {
    switch (error) {
      case SignInError.notLoggedIn:
      case SignInError.invalidCredentials:
      case SignInError.sessionExpired:
        context.go('/sign-in');
        break;
      case SignInError.inactiveAccount:
        showError('Conta inativa. Entre em contato com o suporte.');
        break;
      case SignInError.noStoresAvailable:
        context.go('/stores/new');
        break;
      case SignInError.networkError:
        showError('Sem conexão com a internet. Tente novamente.');
        break;
      case SignInError.emailNotVerified:
        context.go('/verify-email');
        break;
      default:
        showError('Erro inesperado. Tente novamente.');
        context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: AppLogo(size: 50),
      ),
    );
  }
}