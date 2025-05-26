import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:totem_pro_admin/models/totem.dart';

class TotemsRepository {
  TotemsRepository(this._dio);

  final Dio _dio;

  Future<Either<void, List<Totem>>> getTotems(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/totems');
      final totems =
          response.data.map<Totem>((e) => Totem.fromJson(e)).toList();
      return Right(totems);
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, void>> authorizeTotem(
    int storeId,
    String publicKey,
  ) async {
    try {
      await _dio.post(
        '/stores/$storeId/authorize-totem',
        queryParameters: {'public_key': publicKey},
      );
      return const Right(null);
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, void>> revokeTotem(int storeId, int totemId) async {
    try {
      await _dio.delete('/stores/$storeId/totems/$totemId');
      return const Right(null);
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }
}
