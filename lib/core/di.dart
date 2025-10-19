import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totem_pro_admin/core/router.dart';
import 'package:totem_pro_admin/core/token_interceptor.dart';
import 'package:flutter/material.dart';
// Repositórios
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';
import 'package:totem_pro_admin/repositories/coupons_repository.dart';
import 'package:totem_pro_admin/repositories/payment_method_repository.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/repositories/segment_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/repositories/banner_repository.dart';
import 'package:totem_pro_admin/repositories/chatbot_repository.dart';
import 'package:totem_pro_admin/repositories/store_operation_config_repository.dart';
import 'package:totem_pro_admin/repositories/order_repository.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/repositories/totems_repository.dart';
import 'package:totem_pro_admin/repositories/user_repository.dart';
import 'package:totem_pro_admin/repositories/dashboard_repository.dart';
import 'package:totem_pro_admin/repositories/analytics_repository.dart';
import 'package:totem_pro_admin/repositories/chat_repository.dart';
import 'package:totem_pro_admin/repositories/session_manager_repository.dart';
import 'package:totem_pro_admin/repositories/table_repository.dart';

// Serviços
import 'package:totem_pro_admin/services/auth_service.dart';
import 'package:totem_pro_admin/services/print/device_settings_service.dart';
import 'package:totem_pro_admin/services/print/print_layout_service.dart';
import 'package:totem_pro_admin/services/print/printing_service.dart';
import 'package:totem_pro_admin/services/print/print_manager.dart';
import 'package:totem_pro_admin/services/print/printer_mapping_service.dart';
import 'package:totem_pro_admin/services/chat_visibility_service.dart';
import 'package:totem_pro_admin/services/connectivity_service.dart';
import 'package:totem_pro_admin/services/preference_service.dart';

// Cubits
import 'package:totem_pro_admin/cubits/auth_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup_cubit.dart';
import 'package:totem_pro_admin/pages/orders/cubit/order_page_cubit.dart';
import 'package:totem_pro_admin/pages/splash/splash_page_cubit.dart';
import 'package:totem_pro_admin/pages/clone_store_wizard/cubit/new_store_cubit.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/cubit/opening_hours_cubit.dart';
import 'package:totem_pro_admin/pages/operation_configuration/cubit/operation_config_cubit.dart';
import 'package:totem_pro_admin/pages/products/cubit/products_cubit.dart';
import 'package:totem_pro_admin/pages/sessions/cubit/session_manager_cubit.dart';

import '../pages/commands/cubit/standalone_commands_cubit.dart';

final getIt = GetIt.instance;
final apiUrl = dotenv.env['API_URL'];

// ✅ Função para registrar dependências do escopo do usuário
void registerUserScopeSingletons() {
  // ✅ StoresManagerCubit (depende do RealtimeRepository que já é global)
  if (!getIt.isRegistered<StoresManagerCubit>()) {
    getIt.registerLazySingleton<StoresManagerCubit>(
          () => StoresManagerCubit(
        paymentRepository: getIt<PaymentMethodRepository>(),
        storeRepository: getIt<StoreRepository>(),
        realtimeRepository: getIt<RealtimeRepository>(),
      ),
    );
  }

  // ✅ PrintingService
  if (!getIt.isRegistered<PrintingService>()) {
    getIt.registerSingleton<PrintingService>(
      PrintingService(
        realtimeRepo: getIt<RealtimeRepository>(),
        printManager: getIt<PrintManager>(),
        storesManagerCubit: getIt<StoresManagerCubit>(),
      ),
    );
  }

  // ✅ ADICIONE ESTE BLOCO:
  if (!getIt.isRegistered<StandaloneCommandsCubit>()) {
    getIt.registerLazySingleton<StandaloneCommandsCubit>(
          () => StandaloneCommandsCubit(
        realtimeRepository: getIt<RealtimeRepository>(),
      ),
    );
  }






}

// ✅ Função para desregistrar dependências do escopo do usuário
Future<void> unregisterUserScopeSingletons() async {
  // Ordem inversa de dependência
  if (getIt.isRegistered<PrintingService>()) {
    await getIt.get<PrintingService>().dispose();
    await getIt.unregister<PrintingService>();
  }

  if (getIt.isRegistered<StoresManagerCubit>()) {
    await getIt.get<StoresManagerCubit>().close();
    await getIt.unregister<StoresManagerCubit>();
  }

}

Future<void> configureDependencies() async {
  // --- 1. DEPENDÊNCIAS EXTERNAS E CONFIGURAÇÕES ---
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // ✅ CRIAR INTERCEPTOR ANTES DE ADICIONAR NO DIO
  final tokenInterceptor = TokenInterceptor();

  final dio = Dio(BaseOptions(baseUrl: '$apiUrl'))
    ..interceptors.addAll([
      tokenInterceptor, // ✅ Usar instância criada acima
      PrettyDioLogger(requestBody: true, requestHeader: true),
    ]);
  getIt.registerSingleton(dio);
  getIt.registerSingleton(const FlutterSecureStorage());

  // ✅ REGISTRAR O INTERCEPTOR NO GET_IT (para acessar depois)
  getIt.registerSingleton<TokenInterceptor>(tokenInterceptor);

  // --- 2. REPOSITÓRIOS ---
  getIt.registerSingleton(AuthRepository(getIt(), getIt()));
  getIt.registerSingleton(StoreRepository(getIt()));

  // ✅ CORREÇÃO: RealtimeRepository agora é GLOBAL (não mais de escopo de usuário)
  getIt.registerLazySingleton<RealtimeRepository>(() => RealtimeRepository());

  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton(() => PreferenceService());
  getIt.registerLazySingleton(() => ChatVisibilityService());
  getIt.registerLazySingleton<TableRepository>(() => TableRepository(getIt()));
  getIt.registerLazySingleton<ChatRepository>(() => ChatRepository(getIt()));

  // Factories (criados toda vez que são pedidos)
  getIt.registerFactory(() => CategoryRepository(getIt()));
  getIt.registerFactory(() => ProductRepository(getIt()));
  getIt.registerFactory(() => TotemsRepository(getIt()));
  getIt.registerFactory(() => CouponRepository(getIt()));
  getIt.registerFactory(() => PaymentMethodRepository(getIt()));
  getIt.registerFactory(() => SegmentRepository(getIt()));
  getIt.registerFactory(() => UserRepository(getIt()));
  getIt.registerFactory(() => ChatbotRepository(getIt()));
  getIt.registerFactory(() => DashboardRepository(getIt()));
  getIt.registerFactory(() => StoreOperationConfigRepository(getIt()));
  getIt.registerFactory(() => BannerRepository(getIt()));
  getIt.registerFactory(() => OrderRepository(getIt()));
  getIt.registerFactory(() => AnalyticsRepository(getIt()));
  getIt.registerFactory(() => SessionManagerRepository(getIt()));

  getIt.registerFactory<NewStoreCubit>(
        () => NewStoreCubit(getIt<StoreRepository>()),
  );

  // --- 3. SERVIÇOS ---
  getIt.registerSingleton<AuthService>(
    AuthService(
      authRepository: getIt<AuthRepository>(),
      storeRepository: getIt<StoreRepository>(),
    ),
  );

  // --- 4. CUBITS (Dependem dos Repositórios e Serviços) ---
  getIt.registerSingleton<AuthCubit>(AuthCubit(authService: getIt<AuthService>()));
  getIt.registerSingleton<SplashPageCubit>(SplashPageCubit());

  // ✅ StoresManagerCubit agora é registrado em registerUserScopeSingletons()
  // Mas também pode ser lazy global se preferir (descomente a linha abaixo)
  // getIt.registerLazySingleton<StoresManagerCubit>(
  //   () => StoresManagerCubit(
  //     paymentRepository: getIt<PaymentMethodRepository>(),
  //     storeRepository: getIt<StoreRepository>(),
  //     realtimeRepository: getIt<RealtimeRepository>(),
  //   ),
  // );

  // ✅ CUBITS ESPECÍFICOS (Factories porque são específicos por tela)
  getIt.registerFactory<OpeningHoursCubit>(
        () => OpeningHoursCubit(
      storeRepository: getIt<StoreRepository>(),
    ),
  );

  getIt.registerFactory<OperationConfigCubit>(
        () => OperationConfigCubit(
      storeOperationConfigRepository: getIt<StoreOperationConfigRepository>(),
    ),
  );

  getIt.registerFactory<ProductsCubit>(
        () => ProductsCubit(
      categoryRepository: getIt<CategoryRepository>(),
      productRepository: getIt<ProductRepository>(),
    ),
  );

  getIt.registerFactory<SessionManagerCubit>(
        () => SessionManagerCubit(
      repository: getIt<SessionManagerRepository>(),
    ),
  );

  // --- 5. SISTEMA DE IMPRESSÃO ---
  getIt.registerSingleton<DeviceSettingsService>(
    DeviceSettingsService(getIt<SharedPreferences>()),
  );
  getIt.registerSingleton<PrinterMappingService>(
    PrinterMappingService(getIt<SharedPreferences>()),
  );
  getIt.registerSingleton<PrintLayoutService>(PrintLayoutService());
  getIt.registerSingleton<PrintManager>(PrintManager(getIt(), getIt()));

  getIt.registerLazySingleton<OrderCubit>(
        () => OrderCubit(
      realtimeRepository: getIt<RealtimeRepository>(),
      printManager: getIt<PrintManager>(),
    ),
  );

  getIt.registerFactory<CreateStoreCubit>(
        () => CreateStoreCubit(
      getIt<StoreRepository>(),
      getIt<SegmentRepository>(),
      getIt<UserRepository>(),
      getIt<AuthCubit>(),
      getIt<StoresManagerCubit>(),
    ),
  );

  // --- 6. ROUTER ---
  final appRouter = AppRouter(authCubit: getIt<AuthCubit>());
  getIt.registerLazySingleton<GoRouter>(() => appRouter.router);


  // ✅ CONFIGURAR CALLBACK APÓS CRIAR AUTHCUBIT E ROUTER
  tokenInterceptor.onBothTokensExpired = () {
    // ✅ Mostra notificação de sessão expirada
    final context = globalNavigatorKey.currentContext;
    if (context != null) {
      BotToast.showText(
        text: '⏰ Sua sessão expirou. Faça login novamente.',
        duration: const Duration(seconds: 5),
        contentColor: Colors.orange,
        textStyle: const TextStyle(color: Colors.white, fontSize: 14),
      );
    }
  };
}



