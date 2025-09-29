import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show debugPrint;


import '../models/store/store_operation_config.dart';





class StoreOperationConfigRepository {
  final Dio _dio;

  StoreOperationConfigRepository(this._dio);

  // ✅ MÉTODO ÚNICO PARA SALVAR A CONFIGURAÇÃO
  Future<Either<String, void>> updateConfiguration(int storeId, StoreOperationConfig config) async {
    try {
      // ✅ Envia o objeto como JSON, não mais como FormData
      await _dio.put('/stores/$storeId/configuration', data: config.toJson());
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
