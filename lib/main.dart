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
import 'package:totem_pro_admin/pages/chatpanel/widgets/chat_pop/chat_popup_manager.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup_cubit.dart';
import 'package:totem_pro_admin/pages/orders/cubit/order_page_cubit.dart';
import 'package:totem_pro_admin/constdata/colorprovider.dart';

import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/menu_app_controller.dart';
import 'package:totem_pro_admin/core/router.dart';
import 'package:totem_pro_admin/core/theme/app_theme.dart';
import 'package:totem_pro_admin/pages/table/cubits/tables_cubit.dart';
import 'package:totem_pro_admin/repositories/chatbot_repository.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/repositories/table_repository.dart';
import 'package:totem_pro_admin/services/notification_service.dart';
import 'package:totem_pro_admin/themes/ds_theme.dart';
import 'package:totem_pro_admin/themes/ds_theme_switcher.dart';

import 'core/utils/platform_utils.dart';
import 'core/utils/sounds/sound_util.dart';

// Removemos os imports de conectividade que não são mais necessários aqui

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/env');
  await configureDependencies();
  await EasyLocalization.ensureInitialized();
  await SoundAlertUtil.initialize();
  // ✅ 2. Execute a inicialização APENAS se for um dispositivo móvel
  if (isMobileDevice) {
    await NotificationService().initialize();
  }
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'), Locale('pt', 'BR'), Locale('es', 'ES'),
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

      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => getIt<StoresManagerCubit>()),
          BlocProvider(create: (context) => getIt<AuthCubit>()),
          BlocProvider(create: (context) => getIt<OrderCubit>()),
          BlocProvider(create: (context) => getIt<ActiveStoreCubit>()),
          BlocProvider(create: (context) => getIt<CreateStoreCubit>()),
          BlocProvider(
            create: (context) => TablesCubit(realtimeRepository: getIt<RealtimeRepository>()),),



        ],
        child: const MyApp(),
      ),
    );
  }
}

// No arquivo main.dart - ATUALIZAR a classe MyApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeSwitcher = Provider.of<DsThemeSwitcher>(context);

    return MaterialApp.router(
      title: 'Parceiros',
      scrollBehavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.fromDsTheme(themeSwitcher.theme),
      darkTheme: AppTheme.fromDsTheme(
        DsTheme(
          primaryColor: themeSwitcher.theme.primaryColor,
          mode: DsThemeMode.dark,
          fontFamily: themeSwitcher.theme.fontFamily,
          themeName: themeSwitcher.theme.themeName,
        ),
      ),
      themeMode: themeSwitcher.theme.mode == DsThemeMode.light
          ? ThemeMode.light
          : ThemeMode.dark,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerConfig: getIt<GoRouter>(),
      builder: (context, child) {
        return ChatPopupManager(
          child: BotToastInit()(context, child),
        );
      },
    );
  }
}