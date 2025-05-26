import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:totem_pro_admin/models/coupon.dart';

import '../core/helpers/app_error.dart';
import '../pages/edit_coupon/edit_coupon_page.dart';


typedef CouponListResult = Either<AppError, List<Coupon>>;
typedef CouponResult = Either<AppError, Coupon>;

class CouponRepository {
  CouponRepository(this._dio);

  final Dio _dio;

  CouponListResult _mapListResponse(Response response) {
    try {
      final data = response.data;
      if (data is List) {
        final coupons = data.map<Coupon>((c) => Coupon.fromJson(c)).toList();
        return Right(coupons);
      } else {
        return Left(AppError('Formato de resposta inválido'));
      }
    } catch (e) {
      return Left(AppError('Erro ao converter dados'));
    }
  }

  CouponResult _mapItemResponse(Response response) {
    try {
      final data = response.data;
      return Right(Coupon.fromJson(data));
    } catch (e) {
      return Left(AppError('Erro ao converter cupom'));
    }
  }

  CouponListResult _handleError(dynamic e) {
    if (e is DioException) {
      debugPrint('Erro Dio: ${e.message}');
      return Left(AppError(e.message ?? 'Erro desconhecido', statusCode: e.response?.statusCode));
    } else {
      debugPrint('Erro: $e');
      return Left(AppError('Erro inesperado'));
    }
  }

  CouponResult _handleErrorItem(dynamic e) {
    if (e is DioException) {
      debugPrint('Erro Dio: ${e.message}');
      return Left(AppError(e.message ?? 'Erro desconhecido', statusCode: e.response?.statusCode));
    } else {
      debugPrint('Erro: $e');
      return Left(AppError('Erro inesperado'));
    }
  }

  Future<CouponListResult> getCoupons(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/coupons');
      return _mapListResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Either<CouponError, Coupon>> getCoupon(int storeId, int id) async {
    try {
      final response = await _dio.get('/stores/$storeId/coupons/$id');
      return Right(Coupon.fromJson(response.data));
    } catch (e) {
      debugPrint('$e');
      return const Left(CouponError.unknown);
    }
  }

  Future<Either<CouponError, Coupon>> saveCoupon(
      int storeId,
      Coupon coupon,
      ) async {
    try {
      if (coupon.id != null) {
        final response = await _dio.patch(
          '/stores/$storeId/coupons/${coupon.id}',
          data: coupon.toJson(),
        );
        return Right(Coupon.fromJson(response.data));
      } else {
        final response = await _dio.post(
          '/stores/$storeId/coupons',
          data: coupon.toJson(),
        );
        return Right(Coupon.fromJson(response.data));
      }
    } on DioException catch (e) {
      debugPrint('$e');
      if(e.response?.data?['detail']?['code'] == 'CODE_ALREADY_EXISTS') {
        return const Left(CouponError.codeAlreadyExists);
      }
      return Left(CouponError.unknown);
    }
  }
}
