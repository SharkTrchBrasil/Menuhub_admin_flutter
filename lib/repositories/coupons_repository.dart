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
      Response response;
      if (coupon.id != null) {
        response = await _dio.patch(
          '/stores/$storeId/coupons/${coupon.id}',
          data: coupon.toJson(),
        );
      } else {
        response = await _dio.post(
          '/stores/$storeId/coupons',
          data: coupon.toJson(),
        );
      }
      return Right(Coupon.fromJson(response.data));

    } on DioException catch (e) {
      // ✅ INÍCIO DA CORREÇÃO
      debugPrint("Erro no saveCoupon. Resposta do servidor: ${e.response?.data}");

      // Verifica se a resposta e o corpo da resposta existem e são um Mapa
      if (e.response?.data is Map<String, dynamic>) {
        final responseData = e.response!.data as Map<String, dynamic>;
        final detail = responseData['detail'];

        // Verifica se o 'detail' é um Mapa e contém o nosso código de erro específico
        if (detail is Map<String, dynamic> && detail['code'] == 'CODE_ALREADY_EXISTS') {
          debugPrint("Erro detectado: Código de cupom já existe.");
          return const Left(CouponError.codeAlreadyExists);
        }
      }

      // Para todos os outros casos de erro (500, 422 com lista, etc.), retorna 'unknown'
      debugPrint("Erro não específico ou em formato inesperado. Retornando 'unknown'.");
      return const Left(CouponError.unknown);
      // ✅ FIM DA CORREÇÃO
    }
  }
}
