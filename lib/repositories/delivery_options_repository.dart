import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../models/delivery_options.dart';



class DeliveryOptionRepository {
  final Dio _dio;

  DeliveryOptionRepository(this._dio);

  Future<Either<void, DeliveryOptionsModel?>> getStoreDeliveryConfig(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/delivery-config');
      return Right(
        response.data != null ? DeliveryOptionsModel.fromJson(response.data) : null,
      );
    } catch (e) {
      debugPrint('Erro ao buscar delivery config: $e');
      return const Left(null);
    }
  }

  Future<Either<void, DeliveryOptionsModel>> updateStoreDeliveryConfig(
      int storeId, DeliveryOptionsModel config) async {
    try {
      final response = await _dio.put(
        '/stores/$storeId/delivery-config',
        data: await config.toFormData(),
      );
      return Right(DeliveryOptionsModel.fromJson(response.data));
    } catch (e) {
      debugPrint('Erro ao atualizar delivery config: $e');
      return const Left(null);
    }
  }
}
