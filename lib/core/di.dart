import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totem_pro_admin/core/router.dart';
import 'package:totem_pro_admin/core/token_interceptor.dart';

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

// Serviços
import 'package:totem_pro_admin/services/auth_service.dart';
import 'package:totem_pro_admin/services/print/device_settings_service.dart';
import 'package:totem_pro_admin/services/print/print_layout_service.dart';
import 'package:totem_pro_admin/services/print/printing_service.dart';
import 'package:totem_pro_admin/services/print/print_manager.dart';
import 'package:totem_pro_admin/services/print/printer_mapping_service.dart';
import 'package:totem_pro_admin/services/subscription/subscription_service.dart';

// Cubits
import 'package:totem_pro_admin/cubits/active_store_cubit.dart';
import 'package:totem_pro_admin/cubits/auth_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup_cubit.dart';
import 'package:totem_pro_admin/pages/orders/cubit/order_page_cubit.dart';
import 'package:totem_pro_admin/pages/splash/splash_page_cubit.dart';

import '../repositories/analytics_repository.dart';
import '../repositories/table_repository.dart';
import '../services/connectivity_service.dart';


final getIt = GetIt.instance;
final apiUrl = dotenv.env['API_URL'];

Future<void> configureDependencies() async {
  // --- 1. DEPENDÊNCIAS EXTERNAS E CONFIGURAÇÕES ---
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  final dio = Dio(BaseOptions(baseUrl: '$apiUrl/admin'))
    ..interceptors.addAll([
      TokenInterceptor(),
      PrettyDioLogger(requestBody: true, requestHeader: true),
    ]);
  getIt.registerSingleton(dio);
  getIt.registerSingleton(const FlutterSecureStorage());

  // --- 2. REPOSITÓRIOS ---
  // Singletons (compartilhados e vivem para sempre)
  getIt.registerSingleton(AuthRepository(getIt(), getIt()));
  getIt.registerSingleton(StoreRepository(getIt()));

  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  getIt.registerLazySingleton<RealtimeRepository>(
        () => RealtimeRepository(),
  );

  getIt.registerLazySingleton<TableRepository>(
        () => TableRepository(),
  );


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


  // --- 3. SERVIÇOS (Dependem dos Repositórios) ---
  getIt.registerSingleton<AuthService>(
    AuthService(
      authRepository: getIt<AuthRepository>(),
      storeRepository: getIt<StoreRepository>(),

    ),
  );

  // --- 4. CUBITS (Dependem dos Repositórios e Serviços) ---


  getIt.registerSingleton<StoresManagerCubit>(
    StoresManagerCubit(
      paymentRepository:getIt<PaymentMethodRepository>(),
      productRepository:getIt<ProductRepository>(),
      storeRepository: getIt<StoreRepository>(),
      realtimeRepository: getIt<RealtimeRepository>(),

    ),
  );


  getIt.registerSingleton<AuthCubit>(AuthCubit(authService: getIt<AuthService>(),
    storesManagerCubit: getIt<StoresManagerCubit>(),));


  getIt.registerSingleton<ActiveStoreCubit>(ActiveStoreCubit(realtimeRepository: getIt<RealtimeRepository>()));
  getIt.registerSingleton<SplashPageCubit>(SplashPageCubit());

  // --- 5. SERVIÇOS QUE DEPENDEM DE CUBITS ---
  // Agora registramos o AccessControlService, pois o StoresManagerCubit já existe.
  getIt.registerSingleton<AccessControlService>(
    AccessControlService(getIt<StoresManagerCubit>()),
  );

  // --- 6. SISTEMA DE IMPRESSÃO (Ordem correta) ---
  getIt.registerSingleton<DeviceSettingsService>(DeviceSettingsService(getIt<SharedPreferences>()));
  getIt.registerSingleton<PrinterMappingService>(PrinterMappingService(getIt<SharedPreferences>()));
  getIt.registerSingleton<PrintLayoutService>(PrintLayoutService());
  getIt.registerSingleton<PrintManager>(PrintManager(getIt(), getIt()));

  getIt.registerLazySingleton<OrderCubit>(() => OrderCubit(
    realtimeRepository: getIt<RealtimeRepository>(),
    storesManagerCubit: getIt<StoresManagerCubit>(),
    printManager: getIt<PrintManager>(),
  ));

  // Serviços que dependem dos Cubits e precisam ser inicializados.
  getIt.registerSingleton<PrintingService>(
    PrintingService(
      // ✅ Usa o getter do AuthService para pegar a instância ATIVA
      realtimeRepo:getIt<RealtimeRepository>(),
      printManager: getIt<PrintManager>(),
      storesManagerCubit: getIt<StoresManagerCubit>(),
    ),
  );


  // Adicione o registro do seu cubit
  getIt.registerFactory<StoreSetupCubit>(
        () => StoreSetupCubit(
      getIt<StoreRepository>(),
      getIt<SegmentRepository>(),
      getIt<UserRepository>(),
      getIt<AuthCubit>(),
      getIt<AuthService>(),
    ),
  );

  // 1. Crie a instância do AppRouter, injetando os Cubits que acabamos de registrar.
  final appRouter = AppRouter(
    authCubit: getIt<AuthCubit>(),
    storesManagerCubit: getIt<StoresManagerCubit>(),
  );

  getIt.registerLazySingleton<GoRouter>(() => appRouter.router);

}