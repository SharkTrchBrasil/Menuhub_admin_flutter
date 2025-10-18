import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import '../core/di.dart';
import '../models/active_session.dart';

class SessionManagerRepository {
  final Dio _dio;

  SessionManagerRepository(this._dio);

  Future<Either<String, List<ActiveSession>>> getActiveSessions() async {
    try {
      // ✅ NOVO: Pega o SID atual do RealtimeRepository
      final currentSid = getIt<RealtimeRepository>().currentSocketId;

      final response = await _dio.get(
        '/sessions/active',
        queryParameters: currentSid != null ? {'current_sid': currentSid} : null,
      );

      final sessions = (response.data as List)
          .map((json) => ActiveSession.fromJson(json))
          .toList();

      return Right(sessions);
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? 'Erro ao buscar sessões');
    } catch (e) {
      return Left('Erro inesperado: $e');
    }
  }

  Future<Either<String, void>> revokeSession(int sessionId) async {
    try {
      await _dio.delete('/sessions/$sessionId');
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? 'Erro ao revogar sessão');
    } catch (e) {
      return Left('Erro inesperado: $e');
    }
  }

  Future<Either<String, void>> revokeAllOtherSessions(String currentSid) async {
    try {
      await _dio.post(
        '/sessions/revoke-all-others',
        data: {'current_sid': currentSid},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? 'Erro ao revogar sessões');
    } catch (e) {
      return Left('Erro inesperado: $e');
    }
  }
}