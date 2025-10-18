// lib/repositories/segment_repository.dart

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';

import '../core/failures.dart';
import '../models/segment.dart';

class SegmentRepository {
  final Dio _dio;
  SegmentRepository(this._dio);

  /// Busca a lista de especialidades ativas na API.
  Future<Either<Failure, List<Segment>>> getSegments() async {
    try {
      final response = await _dio.get('/segments/');

      final segments = (response.data as List)
          .map((json) => Segment.fromJson(json))
          .toList();

      return Right(segments);
    } on DioException catch (e) {
      print('Erro ao buscar segmentos: $e');
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Não foi possível buscar as especialidades. Tente novamente',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      print('Erro inesperado em getSegments: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }
}