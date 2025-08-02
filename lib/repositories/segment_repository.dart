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
      // Faz a chamada GET para o endpoint que criamos no backend.
      final response = await _dio.get('/segments/');

      // Converte a lista de JSONs em uma lista de objetos Segment.
      final segments = (response.data as List)
          .map((json) => Segment.fromJson(json))
          .toList();

      // Retorna o resultado com sucesso (Right).
      return Right(segments);

    } on DioException catch (e) {
      // Em caso de erro na chamada, retorna uma falha (Left).
      print('Erro ao buscar segmentos: $e');
      return Left(Failure('Não foi possível buscar as especialidades. Tente novamente.'));
    }
  }
}