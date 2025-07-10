import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
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

final getIt = GetIt.instance;

final apiUrl = dotenv.env['API_URL'];

// core/di.dart
void configureDependencies() {
  // --- PASSO 1: Dependências básicas e repositórios sem dependências complexas ---
  final dio = Dio(BaseOptions(baseUrl: '$apiUrl/admin'))
    ..interceptors.addAll([
      TokenInterceptor(),
      PrettyDioLogger(requestBody: true, requestHeader: true),
    ]);

  getIt.registerSingleton(dio);
  getIt.registerSingleton(const FlutterSecureStorage());

  getIt.registerSingleton(AuthRepository(getIt(), getIt()));
  getIt.registerSingleton(StoreRepository(getIt()));

  // Registre os repositórios que são registerFactory ou não têm dependências circulares com Cubits
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


  // --- PASSO 2: Lidar com a dependência circular entre RealtimeRepository e StoresManagerCubit ---

  // Opção A: RealtimeRepository não depende de StoresManagerCubit no construtor
  // Se o construtor de RealtimeRepository não precisa do StoresManagerCubit, registre-o primeiro.
  // getIt.registerSingleton<RealtimeRepository>(RealtimeRepository());

  // Opção B: RealtimeRepository depende de StoresManagerCubit no construtor
  // e StoresManagerCubit depende de RealtimeRepository no construtor.
  // Esta é a dependência circular. Vamos resolvê-la usando `late final` e um método de inicialização no RealtimeRepository.

  // 2a. Registre RealtimeRepository *sem* o StoresManagerCubit no construtor, mas com um método `init`
  // Para isso, você precisará ajustar a classe RealtimeRepository para ter um construtor sem argumentos
  // e um método `initialize` ou `setStoresManagerCubit`.
  getIt.registerSingleton<RealtimeRepository>(RealtimeRepository()); // Construtor sem StoreManagerCubit

  // 2b. Registre StoresManagerCubit, passando RealtimeRepository (que já está registrado)
  getIt.registerSingleton<StoresManagerCubit>(
    StoresManagerCubit(
      storeRepository: getIt<StoreRepository>(),
      realtimeRepository: getIt<RealtimeRepository>(),
    ),
  );

  // 2c. Agora, chame um método de inicialização no RealtimeRepository para injetar o StoresManagerCubit
  // Isso requer que você adicione um método `setStoresManagerCubit` (ou similar) no RealtimeRepository.
  getIt<RealtimeRepository>().setStoresManagerCubit(getIt<StoresManagerCubit>());


  // --- PASSO 3: Registre os demais serviços/cubits que dependem dos já registrados ---

  getIt.registerSingleton<AuthService>(
    AuthService(
      authRepository: getIt<AuthRepository>(),
      storeRepository: getIt<StoreRepository>(),
      realtimeRepository: getIt<RealtimeRepository>(),
    ),
  );

  getIt.registerLazySingleton<OrderCubit>(() => OrderCubit(
    realtimeRepository: getIt<RealtimeRepository>(),
    storesManagerCubit: getIt<StoresManagerCubit>(),
  ));

  getIt.registerSingleton<SplashPageCubit>(SplashPageCubit());
}








// import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:get_it/get_it.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// import 'package:totem_pro_admin/core/token_interceptor.dart';
//
// import 'package:totem_pro_admin/pages/orders/order_page_cubit.dart';
// import 'package:totem_pro_admin/repositories/auth_repository.dart';
// import 'package:totem_pro_admin/repositories/category_repository.dart';
// import 'package:totem_pro_admin/repositories/coupons_repository.dart';
// import 'package:totem_pro_admin/repositories/payment_method_repository.dart';
// import 'package:totem_pro_admin/repositories/product_repository.dart';
// import 'package:totem_pro_admin/repositories/segment_repository.dart';
// import 'package:totem_pro_admin/repositories/store_repository.dart';
// import '../cubits/store_manager_cubit.dart';
// import '../pages/splash/splash_page_cubit.dart';
// import '../repositories/banner_repository.dart';
// import '../repositories/chatbot_repository.dart';
// import '../repositories/delivery_options_repository.dart';
// import '../repositories/order_repository.dart';
// import '../repositories/realtime_repository.dart';
// import '../repositories/totems_repository.dart';
// import '../repositories/user_repository.dart';
// import '../services/auth_service.dart';
//
// final getIt = GetIt.instance; // Use .instance em vez de .I para clareza
//
// final apiUrl = dotenv.env['API_URL'];
//
// void configureDependencies() {
//   // 1. Primeiro registre as dependências básicas
//   final dio = Dio(BaseOptions(baseUrl: '$apiUrl/admin'))
//     ..interceptors.addAll([
//       TokenInterceptor(),
//       PrettyDioLogger(requestBody: true, requestHeader: true),
//     ]);
//
//   getIt.registerSingleton(dio);
//   getIt.registerSingleton(const FlutterSecureStorage());
//
//   // 2. Registre o RealtimeRepository ANTES do AuthService
//   getIt.registerSingleton(RealtimeRepository(getIt<StoresManagerCubit>()));
//
//   // 3. Registre os repositórios que dependem apenas de dio/secureStorage
//   getIt.registerSingleton(AuthRepository(getIt(), getIt()));
//   getIt.registerSingleton(StoreRepository(getIt()));
//   getIt.registerSingleton<StoresManagerCubit>(
//     StoresManagerCubit(storeRepository:getIt<StoreRepository>(), realtimeRepository:getIt<RealtimeRepository>() ),
//   );
//
//   // 4. Agora registre o AuthService que depende dos repositórios
//   getIt.registerSingleton<AuthService>(
//     AuthService(
//       authRepository: getIt<AuthRepository>(),
//       storeRepository: getIt<StoreRepository>(),
//       realtimeRepository: getIt<RealtimeRepository>(),
//     ),
//   );
//
//   // 5. Registre os demais repositórios
//   getIt.registerFactory(() => CategoryRepository(getIt()));
//   getIt.registerFactory(() => ProductRepository(getIt()));
//   getIt.registerFactory(() => TotemsRepository(getIt()));
//   getIt.registerFactory(() => CouponRepository(getIt()));
//   getIt.registerFactory(() => StorePaymentMethodRepository(getIt()));
//   getIt.registerFactory(() => SegmentRepository(getIt()));
//   getIt.registerFactory(() => UserRepository(getIt()));
//   getIt.registerFactory(() => ChatBotConfigRepository(getIt()));
//   getIt.registerFactory(() => DeliveryOptionRepository(getIt()));
//   getIt.registerFactory(() => BannerRepository(getIt()));
//   getIt.registerFactory(() => OrderRepository(getIt()));
//
//   // 6. Registre os cubits/controllers
//   getIt.registerLazySingleton<OrderCubit>(() => OrderCubit(
//     realtimeRepository: getIt<RealtimeRepository>(), // Pede do get_it
//     storesManagerCubit: getIt<StoresManagerCubit>(), // <--- AQUI ESTÁ O SEGREDO!
//   ));
//   // 6. Registre os cubits/controllers
//   getIt.registerSingleton<SplashPageCubit>(SplashPageCubit());
//
//   // 6. Registre os cubits/controllers
//   getIt.registerSingleton<StoresManagerCubit>(StoresManagerCubit(storeRepository: null,bit(ltimeRepository: null));
//
// }
