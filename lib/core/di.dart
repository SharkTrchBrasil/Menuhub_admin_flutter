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


// Cubits
import 'package:totem_pro_admin/cubits/active_store_cubit.dart';
import 'package:totem_pro_admin/cubits/auth_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup_cubit.dart';
import 'package:totem_pro_admin/pages/orders/cubit/order_page_cubit.dart';
import 'package:totem_pro_admin/pages/splash/splash_page_cubit.dart';

import '../pages/clone_store_wizard/cubit/new_store_cubit.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/chat_repository.dart';
import '../repositories/table_repository.dart';
import '../services/chat_visibility_service.dart';
import '../services/connectivity_service.dart';
import '../services/preference_service.dart';


final getIt = GetIt.instance;
final apiUrl = dotenv.env['API_URL'];

// ✨ NOVO: Função para registrar dependências do escopo do usuário
void registerUserScopeSingletons() {
  if (!getIt.isRegistered<RealtimeRepository>()) {
    getIt.registerSingleton<RealtimeRepository>(RealtimeRepository());
  }

  // ✅ StoresManagerCubit é registrado em configureDependencies agora.
  // Apenas garantimos que ele existe aqui, se necessário.
  if (!getIt.isRegistered<StoresManagerCubit>()) {
    getIt.registerLazySingleton<StoresManagerCubit>(
          () => StoresManagerCubit(
        paymentRepository: getIt<PaymentMethodRepository>(),
        productRepository: getIt<ProductRepository>(),
        storeRepository: getIt<StoreRepository>(),
        realtimeRepository: getIt<RealtimeRepository>(),
        storeOperationConfigRepository: getIt<StoreOperationConfigRepository>(),
      ),
    );
  }

  if (!getIt.isRegistered<ActiveStoreCubit>()) {
    getIt.registerSingleton<ActiveStoreCubit>(
        ActiveStoreCubit(realtimeRepository: getIt<RealtimeRepository>()));
  }

  if (!getIt.isRegistered<PrintingService>()) {
    getIt.registerSingleton<PrintingService>(
      PrintingService(
        realtimeRepo: getIt<RealtimeRepository>(),
        printManager: getIt<PrintManager>(),
        storesManagerCubit: getIt<StoresManagerCubit>(),
      ),
    );
  }
}

// ✨ NOVO: Função para desregistrar dependências do escopo do usuário
Future<void> unregisterUserScopeSingletons() async {
  // O desregistro deve ocorrer na ordem inversa da dependência para evitar erros
  if (getIt.isRegistered<PrintingService>()) {
    await getIt.get<PrintingService>().dispose();
    await getIt.unregister<PrintingService>();
  }

  if (getIt.isRegistered<ActiveStoreCubit>()) {
    await getIt.get<ActiveStoreCubit>().close();
    await getIt.unregister<ActiveStoreCubit>();
  }

  if (getIt.isRegistered<StoresManagerCubit>()) {
    // O método close() do StoresManagerCubit já chama o dispose() do RealtimeRepository
    await getIt.get<StoresManagerCubit>().close();
    await getIt.unregister<StoresManagerCubit>();
  }

  // O RealtimeRepository é descartado pelo StoresManagerCubit, mas removemos o registro aqui
  if (getIt.isRegistered<RealtimeRepository>()) {
    // Garantia extra de que o dispose foi chamado, caso o StoresManagerCubit não exista.
    if(!getIt.get<RealtimeRepository>().isDisposed){
      getIt.get<RealtimeRepository>().dispose();
    }
    await getIt.unregister<RealtimeRepository>();
  }
}


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
  getIt.registerLazySingleton<RealtimeRepository>(() => RealtimeRepository());

  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton(() => PreferenceService());
  getIt.registerLazySingleton(() => ChatVisibilityService());
  getIt.registerLazySingleton<TableRepository>(() => TableRepository());
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
  // ✅ ADICIONE ESTE REGISTRO PARA O NOVO CUBIT
  getIt.registerFactory<NewStoreCubit>(
        () => NewStoreCubit(
      getIt<StoreRepository>(),
    ),
  );

  // --- 3. SERVIÇOS (Dependem dos Repositórios) ---
  getIt.registerSingleton<AuthService>(
    AuthService(
      authRepository: getIt<AuthRepository>(),
      storeRepository: getIt<StoreRepository>(),
    ),
  );

  // --- 4. CUBITS (Dependem dos Repositórios e Serviços) ---
  getIt.registerSingleton<AuthCubit>(AuthCubit(authService: getIt<AuthService>()));
  getIt.registerSingleton<SplashPageCubit>(SplashPageCubit());


  getIt.registerLazySingleton<StoresManagerCubit>(
        () => StoresManagerCubit(
      paymentRepository: getIt<PaymentMethodRepository>(),
      productRepository: getIt<ProductRepository>(),
      storeRepository: getIt<StoreRepository>(),
      realtimeRepository: getIt<RealtimeRepository>(), storeOperationConfigRepository: getIt<StoreOperationConfigRepository>(),
    ),
  );


  // --- 5. SISTEMA DE IMPRESSÃO (Ordem correta) ---
  getIt.registerSingleton<DeviceSettingsService>(DeviceSettingsService(getIt<SharedPreferences>()));
  getIt.registerSingleton<PrinterMappingService>(PrinterMappingService(getIt<SharedPreferences>()));
  getIt.registerSingleton<PrintLayoutService>(PrintLayoutService());
  getIt.registerSingleton<PrintManager>(PrintManager(getIt(), getIt()));

  getIt.registerLazySingleton<OrderCubit>(() => OrderCubit(
    realtimeRepository: getIt<RealtimeRepository>(),
    storesManagerCubit: getIt<StoresManagerCubit>(),
    printManager: getIt<PrintManager>(),
  ));


  // Adicione o registro do seu cubit
  getIt.registerFactory<CreateStoreCubit>(
        () => CreateStoreCubit(
      getIt<StoreRepository>(),
      getIt<SegmentRepository>(),
      getIt<UserRepository>(),
      getIt<AuthCubit>(),
      getIt<StoresManagerCubit>(),
    ),
  );

  // 1. Crie a instância do AppRouter, injetando os Cubits que acabamos de registrar.
  final appRouter = AppRouter(
      authCubit: getIt<AuthCubit>(),
      // Agora é seguro pegar o StoresManagerCubit aqui
      storesManagerCubit: getIt<StoresManagerCubit>()
  );

  getIt.registerLazySingleton<GoRouter>(() => appRouter.router);

}