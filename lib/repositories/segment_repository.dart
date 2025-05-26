import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/segment.dart';

class SegmentRepository {
  SegmentRepository(this._dio);

  final Dio _dio;

  Future<Either<void, List<Segment>>> getSegments() async {
    try {
      final response = await _dio.get('/stores/segments');
      return Right(
        response.data.map<Segment>((c) => Segment.fromJson(c)).toList(),
      );
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, Segment>> getSegment(int storeId, int id) async {
    try {
      final response = await _dio.get('/stores/$storeId/segments/$id');
      return Right(Segment.fromJson(response.data));
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, Segment>> saveSegment(
    int storeId,
    Segment category,
  ) async {
    try {
      if (category.id != null) {
        final response = await _dio.patch(
          '/stores/$storeId/segments/${category.id}',
          data: await category.toFormData(),
        );
        return Right(Segment.fromJson(response.data));
      } else {
        final response = await _dio.post(
          '/stores/$storeId/segments',
          data: await category.toFormData(),
        );
        return Right(Segment.fromJson(response.data));
      }
    } catch (e) {
      debugPrint('$e');
      return Left(null);
    }
  }
}
