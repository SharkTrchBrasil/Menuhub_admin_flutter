import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../models/payment_method.dart';

class StorePaymentMethodRepository {
  StorePaymentMethodRepository(this._dio);
  final Dio _dio;

  /*────────────────────────────── LIST ALL ─────────────────────────────*/
  Future<Either<void, List<StorePaymentMethod>>> getPaymentMethods(
      int storeId) async {
    try {
      final response =
      await _dio.get('/stores/$storeId/payment-methods');

      return Right(
        (response.data as List)
            .map<StorePaymentMethod>(
                (e) => StorePaymentMethod.fromJson(e))
            .toList(),
      );
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  /*────────────────────────────── GET ONE ──────────────────────────────*/
  Future<Either<void, StorePaymentMethod>> getPaymentMethod(
      int storeId, int id) async {
    try {
      final resp =
      await _dio.get('/stores/$storeId/payment-methods/$id');
      return Right(StorePaymentMethod.fromJson(resp.data));
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  /*────────────────────────────── CREATE / UPDATE ──────────────────────*/
  Future<Either<void, StorePaymentMethod>> savePaymentMethod(
      int storeId, StorePaymentMethod pm) async {
    try {
      if (pm.id != null) {
        // PATCH – atualização parcial
        final resp = await _dio.patch(
          '/stores/$storeId/payment-methods/${pm.id}',
          data: await pm.toFormData(),
        );
        return Right(StorePaymentMethod.fromJson(resp.data));
      } else {
        // POST – criação
        final resp = await _dio.post(
          '/stores/$storeId/payment-methods',
          data: await pm.toFormData(),
        );
        return Right(StorePaymentMethod.fromJson(resp.data));
      }
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  /*────────────────────────────── DELETE (opcional) ────────────────────*/
  Future<Either<void, void>> deletePaymentMethod(
      int storeId, int id) async {
    try {
      await _dio.delete('/stores/$storeId/payment-methods/$id');
      return const Right(null);
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }
}
