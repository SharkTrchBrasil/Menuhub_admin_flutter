import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:totem_pro_admin/core/token_interceptor.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';
import 'package:totem_pro_admin/repositories/coupons_repository.dart';
import 'package:totem_pro_admin/repositories/payment_method_repository.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/repositories/segment_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';


import '../repositories/chatbot_repository.dart';
import '../repositories/delivery_options_repository.dart';

import '../repositories/totems_repository.dart';
import '../repositories/user_repository.dart';

final getIt = GetIt.I;

void configureDependencies() {
  final dio = Dio(BaseOptions(baseUrl: 'https://api-pdvix.onrender.com/admin'))
    ..interceptors.addAll([
      TokenInterceptor(),
      PrettyDioLogger(requestBody: true, requestHeader: true),
    ]);

  getIt.registerSingleton(dio);
  getIt.registerSingleton(FlutterSecureStorage());
  getIt.registerSingleton(AuthRepository(getIt(), getIt()));
  getIt.registerSingleton(StoreRepository(getIt()));
  getIt.registerFactory(() => CategoryRepository(getIt()));
  getIt.registerFactory(() => ProductRepository(getIt()));
  getIt.registerFactory(() => TotemsRepository(getIt()));
  getIt.registerFactory(() => CouponRepository(getIt()));

  // minhas features


  getIt.registerFactory(() => StorePaymentMethodRepository(getIt()));
  getIt.registerFactory(() => SegmentRepository(getIt()));
  getIt.registerFactory(() => UserRepository(getIt()));
  getIt.registerFactory(() => ChatBotConfigRepository(getIt()));
  getIt.registerFactory(() => DeliveryOptionRepository(getIt()));



}
