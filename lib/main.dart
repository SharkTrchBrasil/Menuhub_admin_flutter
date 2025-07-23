// Em: main.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:totem_pro_admin/pages/orders/order_page_cubit.dart';
import 'package:totem_pro_admin/pages/orders/service/printer_manager.dart';
import 'package:totem_pro_admin/repositories/chatbot_repository.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/services/auth_service.dart';
import 'package:totem_pro_admin/services/cubits/auth_cubit.dart';
import 'package:totem_pro_admin/services/cubits/auth_state.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/widgets/persistent_notification_toast..dart';


import 'constdata/colorprovider.dart';
import 'core/chatbot_config_provider.dart';
import 'core/di.dart';
import 'core/menu_app_controller.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'cubits/active_store_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/env');

  if (kIsWeb) {
    // usePathUrlStrategy();
  }

  configureDependencies();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('pt', 'BR'),
        Locale('es', 'ES'),
      ],
      path: 'assets/langs',
      fallbackLocale: const Locale('pt', 'BR'),
      child: const AppProviders(),
    ),
  );
}

class AppProviders extends StatelessWidget {
  const AppProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              ChatBotConfigController(getIt<ChatBotConfigRepository>()),
        ),
        ChangeNotifierProvider(create: (_) => DrawerControllerProvider()),
        ChangeNotifierProvider(create: (_) => ColorNotifire()),
      ],
      child: const AppBlocs(),
    );
  }
}

class AppBlocs extends StatelessWidget {
  const AppBlocs({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StoresManagerCubit>(
          create: (context) => StoresManagerCubit(
            storeRepository: getIt<StoreRepository>(),
            realtimeRepository: getIt<RealtimeRepository>(),
          ),
        ),
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(
            authService: getIt<AuthService>(),
            realtimeRepository: getIt<RealtimeRepository>(),
          ),
        ),
        BlocProvider<OrderCubit>(
          create: (context) => OrderCubit(
            realtimeRepository: getIt<RealtimeRepository>(),
            storesManagerCubit: context.read<StoresManagerCubit>(),
            printManager: getIt<PrintManager>(),
          ),
        ),
        BlocProvider<ActiveStoreCubit>(
          create: (context) => ActiveStoreCubit(
            realtimeRepository: getIt<RealtimeRepository>(),
          ),
        ),
      ],
      child: const AppInitializer(),
    );
  }
}

// ✨ SIMPLIFICADO PARA STATELESSWIDGET ✨
// Não precisamos mais de initState ou dispose aqui.
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final storesManagerCubit = context.read<StoresManagerCubit>();
    final themeProvider = context.watch<ThemeProvider>();

    final router = createRouter(
      authCubit: authCubit,
      storesManagerCubit: storesManagerCubit,
    );

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          print('[main.dart BlocListener] Authenticated com sucesso');
        } else if (authState is AuthUnauthenticated) {
          print('[main.dart BlocListener] Usuário deslogado');
        }
      },
      child: MaterialApp.router(
        title: 'PDVix - Admin',
        scrollBehavior:
        ScrollConfiguration.of(context).copyWith(scrollbars: false),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        locale: context.locale,
        supportedLocales: context.supportedLocales,
        localizationsDelegates: context.localizationDelegates,
        routerConfig: router,
        builder: (context, child) {
          return Stack(
            children: [
              // O BotToastInit precisa estar dentro do Stack, mas envolvendo o child.
              BotToastInit()(
                context,
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: child!,
                ),
              ),
              // Nosso toast posicionado sobre todo o conteúdo.
              const Positioned(
                bottom: 20,
                right: 20,
                child: PersistentNotificationToast(),
              ),
            ],
          );
        },
      ),
    );
  }
}