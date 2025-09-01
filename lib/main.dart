// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bot_toast/bot_toast.dart';

// Seus imports
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/auth_cubit.dart';
import 'package:totem_pro_admin/cubits/active_store_cubit.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup_cubit.dart';
import 'package:totem_pro_admin/pages/orders/order_page_cubit.dart';

import 'package:totem_pro_admin/constdata/colorprovider.dart';
import 'package:totem_pro_admin/core/chatbot_config_provider.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/menu_app_controller.dart';
import 'package:totem_pro_admin/core/router.dart';
import 'package:totem_pro_admin/core/theme/app_theme.dart';

import 'package:totem_pro_admin/repositories/chatbot_repository.dart';
import 'package:totem_pro_admin/themes/ds_theme.dart';
import 'package:totem_pro_admin/themes/ds_theme_switcher.dart';
import 'package:totem_pro_admin/widgets/persistent_notification_toast..dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/env');

  await configureDependencies();
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
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DrawerControllerProvider()),
        ChangeNotifierProvider(create: (_) => ColorNotifire()),
        ChangeNotifierProvider(create: (_) => DsThemeSwitcher()),
        // Removido o ProxyProvider pois não é mais necessário
        ChangeNotifierProvider(
          create: (_) => ChatBotConfigController(getIt<ChatBotConfigRepository>()),
        ),
      ],
      // E então os providers de lógica (Bloc/Cubit)
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => getIt<StoresManagerCubit>()),
          BlocProvider(create: (context) => getIt<AuthCubit>()),
          BlocProvider(create: (context) => getIt<OrderCubit>()),
          BlocProvider(create: (context) => getIt<ActiveStoreCubit>()),
          BlocProvider(create: (context) => getIt<StoreSetupCubit>()),
        ],
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenha o DsThemeSwitcher do provider
    final themeSwitcher = Provider.of<DsThemeSwitcher>(context);
    final colorNotifire = Provider.of<ColorNotifire>(context);

    return MaterialApp.router(
      title: 'PDVix - Admin',
      scrollBehavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      debugShowCheckedModeBanner: false,

      // Use o tema convertido do DsTheme
      theme: AppTheme.fromDsTheme(themeSwitcher.theme),

      // Para dark theme, você pode criar um DsTheme específico ou usar o mesmo
      darkTheme: AppTheme.fromDsTheme(
        DsTheme(
          primaryColor: themeSwitcher.theme.primaryColor,
          mode: DsThemeMode.dark, // Força modo escuro
          fontFamily: themeSwitcher.theme.fontFamily,
          themeName: themeSwitcher.theme.themeName,
        ),
      ),

      // Use o themeMode baseado no DsTheme
      themeMode: themeSwitcher.theme.mode == DsThemeMode.light
          ? ThemeMode.light
          : ThemeMode.dark,

      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerConfig: getIt<GoRouter>(),

      builder: (context, child) {
        final botToastBuilder = BotToastInit();
        final appWithToasts = botToastBuilder(context, child);

        return Stack(
          children: [
            appWithToasts,
            const Positioned(
              bottom: 20,
              right: 20,
              child: PersistentNotificationToast(),
            ),
          ],
        );
      },
    );
  }
}