import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bot_toast/bot_toast.dart';

// Seus imports
import 'package:totem_pro_admin/cubits/auth_cubit.dart';
import 'package:totem_pro_admin/constdata/colorprovider.dart';
import 'package:totem_pro_admin/core/di.dart';

import 'package:totem_pro_admin/core/theme/app_theme.dart';
import 'package:totem_pro_admin/services/notification_service.dart';
import 'package:totem_pro_admin/themes/ds_theme.dart';
import 'package:totem_pro_admin/themes/ds_theme_switcher.dart';
import 'package:totem_pro_admin/core/utils/platform_utils.dart';
import 'package:totem_pro_admin/core/utils/sounds/sound_util.dart';
import 'package:totem_pro_admin/widgets/device_limit_notification.dart';

import 'core/provider/drawer_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/env');
  await configureDependencies();
  await EasyLocalization.ensureInitialized();
  await SoundAlertUtil.initialize();
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
    // AppRoot provê apenas os providers que são verdadeiramente globais
    // e não dependem do estado de login do usuário.
    return MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (_) => ColorNotifire()),
        ChangeNotifierProvider(create: (_) => DsThemeSwitcher()),
      ],
      child: MultiBlocProvider(
        providers: [

          ChangeNotifierProvider(
            create: (_) => DrawerProvider(),
          ),

          BlocProvider.value(value: getIt<AuthCubit>()),
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
    final themeSwitcher = Provider.of<DsThemeSwitcher>(context);

    // ✅ ENVOLVA O MaterialApp.router com o DeviceLimitListener
    return DeviceLimitListener(
      child: MaterialApp.router(
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
        builder: BotToastInit(),
      ),
    );
  }
}