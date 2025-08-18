// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:totem_pro_admin/core/theme/theme_provider.dart';
import 'package:totem_pro_admin/repositories/chatbot_repository.dart';
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DrawerControllerProvider()),
        ChangeNotifierProvider(create: (_) => ColorNotifire()),

        ChangeNotifierProvider(
          create: (_) => ChatBotConfigController(getIt<ChatBotConfigRepository>()),
        ),
      ],
      // E então os providers de lógica (Bloc/Cubit)
      child: MultiBlocProvider(
        providers: [
          // Todos os create agora simplesmente buscam a instância Singleton do GetIt
          BlocProvider(create: (context) => getIt<StoresManagerCubit>()),
          BlocProvider(create: (context) => getIt<AuthCubit>()),
          BlocProvider(create: (context) => getIt<OrderCubit>()),
          BlocProvider(create: (context) => getIt<ActiveStoreCubit>()),
          BlocProvider(create: (context) => getIt<StoreSetupCubit>()),
        ],
        // O filho final é o widget que constrói o MaterialApp
        child: const MyApp(),
      ),
    );
  }
}

/// ✅ Este widget agora constrói o MaterialApp e tem acesso a todos os providers.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final themeProvider = context.watch<ThemeProvider>();



    return MaterialApp.router(
      title: 'PDVix - Admin',
      scrollBehavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerConfig: AppRouter.router,

      // ✅ CORREÇÃO APLICADA AQUI
      // O builder recebe o 'context' e o 'child' (que é o seu app roteado).
      builder: (context, child) {
        // Primeiro, chamamos o builder do BotToast, passando o child do nosso app para ele.
        final botToastBuilder = BotToastInit();
        final appWithToasts = botToastBuilder(context, child);

        // Agora, envolvemos o resultado em nossa própria Stack para adicionar o toast persistente.
        return Stack(
          children: [
            // O app principal, já com a inicialização do BotToast.
            appWithToasts,

            // Nosso toast posicionado sobre todo o conteúdo.
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