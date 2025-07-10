import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:provider/provider.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:bot_toast/bot_toast.dart';

import 'package:totem_pro_admin/repositories/chatbot_repository.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';

import 'constdata/colorprovider.dart';
import 'core/chatbot_config_provider.dart';
import 'core/di.dart';
import 'core/menu_app_controller.dart';
import 'core/router.dart';
import 'core/store_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'cubits/store_manager_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/env'); // carrega o env

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
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),

          ChangeNotifierProvider(
            create:
                (_) =>
                    ChatBotConfigController(getIt<ChatBotConfigRepository>()),
          ),

          //   ChangeNotifierProvider(create: (_) =>  StoreProvider()),
          ChangeNotifierProvider(create: (_) => DrawerControllerProvider()),

          ChangeNotifierProvider(create: (context) => ColorNotifire()),

          BlocProvider<StoresManagerCubit>(
            create:
                (_) => StoresManagerCubit(
                  storeRepository: getIt<StoreRepository>(),
                    realtimeRepository: getIt<RealtimeRepository>()
                ), // ou com injeção de dependência
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyCustomScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'PDVix - Admin',

      scrollBehavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: false),
      debugShowCheckedModeBanner: false,
      builder: BotToastInit(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerConfig: router,
    );
  }
}

class CleanScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
  };
}
