import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:totem_pro_admin/core/token_interceptor.dart';

import 'package:totem_pro_admin/pages/orders/order_page_cubit.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';
import 'package:totem_pro_admin/repositories/coupons_repository.dart';
import 'package:totem_pro_admin/repositories/payment_method_repository.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/repositories/segment_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/pages/splash/splash_page_cubit.dart';
import 'package:totem_pro_admin/repositories/banner_repository.dart';
import 'package:totem_pro_admin/repositories/chatbot_repository.dart';
import 'package:totem_pro_admin/repositories/delivery_options_repository.dart';
import 'package:totem_pro_admin/repositories/order_repository.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/repositories/totems_repository.dart';
import 'package:totem_pro_admin/repositories/user_repository.dart';
import 'package:totem_pro_admin/services/auth_service.dart';


import '../pages/orders/service/print.dart';
import '../pages/orders/service/printer_manager.dart';
import '../services/cubits/auth_cubit.dart';

final getIt = GetIt.instance;
final apiUrl = dotenv.env['API_URL'];

// ✅ Agora async para poder usar `await`
Future<void> configureDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  // --- PASSO 1: Dependências básicas ---
  final dio = Dio(BaseOptions(baseUrl: '$apiUrl/admin'))
    ..interceptors.addAll([
      TokenInterceptor(),
      PrettyDioLogger(requestBody: true, requestHeader: true),
    ]);

  getIt.registerSingleton(dio);
  getIt.registerSingleton(const FlutterSecureStorage());
  getIt.registerSingleton(sharedPreferences);

  // Repositórios simples
  getIt.registerSingleton(AuthRepository(getIt(), getIt()));
  getIt.registerSingleton(StoreRepository(getIt()));
  getIt.registerLazySingleton(() => PrinterService());

  // Realtime e StoreManager (devem ser Singletons)
  getIt.registerSingleton<RealtimeRepository>(RealtimeRepository());

  getIt.registerSingleton<StoresManagerCubit>(
    StoresManagerCubit(
      storeRepository: getIt<StoreRepository>(),
      realtimeRepository: getIt<RealtimeRepository>(),
    ),
  );

  // É crucial que o RealtimeRepository receba a instância do StoresManagerCubit
  // DEPOIS que ambos já foram registrados no GetIt.
//  getIt<RealtimeRepository>().setStoresManagerCubit(getIt<StoresManagerCubit>());

  // ✅ PrintManager com async factory
  final printManager = await PrintManager.create(

    prefs: sharedPreferences,
    printerService: getIt<PrinterService>(),
  );
  getIt.registerSingleton<PrintManager>(printManager);

  // Repositórios com factory (podem ser criados sob demanda)
  getIt.registerFactory(() => CategoryRepository(getIt()));
  getIt.registerFactory(() => ProductRepository(getIt()));
  getIt.registerFactory(() => TotemsRepository(getIt()));
  getIt.registerFactory(() => CouponRepository(getIt()));
  getIt.registerFactory(() => StorePaymentMethodRepository(getIt()));
  getIt.registerFactory(() => SegmentRepository(getIt()));
  getIt.registerFactory(() => UserRepository(getIt()));
  getIt.registerFactory(() => ChatBotConfigRepository(getIt()));
  getIt.registerFactory(() => DeliveryOptionRepository(getIt()));
  getIt.registerFactory(() => BannerRepository(getIt()));
  getIt.registerFactory(() => OrderRepository(getIt()));

  // Serviços (AuthService precisa do AuthRepository, StoreRepository e RealtimeRepository)
// Em configureDependencies()
  getIt.registerSingleton<AuthService>(
    AuthService(
      authRepository: getIt<AuthRepository>(),
      storeRepository: getIt<StoreRepository>(),
      realtimeRepository: getIt<RealtimeRepository>(),
     // storesManagerCubit: getIt<StoresManagerCubit>(), // <--- Adicione isto!
    ),
  );


  // Outros Cubits
  getIt.registerLazySingleton<OrderCubit>(() => OrderCubit(
    realtimeRepository: getIt<RealtimeRepository>(),
    storesManagerCubit: getIt<StoresManagerCubit>(),
    printManager: getIt<PrintManager>(),
  ));

  getIt.registerSingleton<SplashPageCubit>(SplashPageCubit());


  // ✅ ADICIONE ESTA LINHA AQUI, NO FINAL DE configureDependencies()
  getIt.registerSingleton<bool>(true, instanceName: 'isInitialized');

}