// lib/repositories/analytics_repository.dart

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/core/failures.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/paginated_response.dart';
import 'package:totem_pro_admin/models/performance_data.dart';
import '../models/today_summary.dart';

class AnalyticsRepository {
  final Dio _dio;

  AnalyticsRepository(this._dio);

  /// Busca os dados de analytics agregados para um período.
  Future<Either<Failure, StorePerformance>> getStorePerformance({
    required int storeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      final response = await _dio.get(
        '/stores/$storeId/performance',
        queryParameters: {
          'start_date': formattedStartDate,
          'end_date': formattedEndDate,
        },
      );

      return Right(StorePerformance.fromJson(response.data));
    } on DioException catch (e) {
      print('DioException em getStorePerformance: ${e.response?.data}');
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Não foi possível carregar os dados de desempenho',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      print('Erro inesperado em getStorePerformance: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  /// Busca a lista de pedidos paginada para um período.
  Future<Either<Failure, PaginatedResponse<OrderDetails>>> getOrdersByDate({
    required int storeId,
    required DateTime startDate,
    required DateTime endDate,
    String? search,
    String? status,
    int page = 1,
    int size = 10,
  }) async {
    try {
      final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      final queryParameters = <String, dynamic>{
        'start_date': formattedStartDate,
        'end_date': formattedEndDate,
        'page': page,
        'size': size,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
      if (status != null && status.isNotEmpty) {
        queryParameters['status'] = status;
      }

      final response = await _dio.get(
        '/stores/$storeId/performance/list-by-date',
        queryParameters: queryParameters,
      );

      return Right(PaginatedResponse.fromJson(
        response.data,
            (json) => OrderDetails.fromJson(json as Map<String, dynamic>),
      ));
    } on DioException catch (e) {
      print('DioException em getOrdersByDate: ${e.response?.data}');
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Não foi possível carregar os pedidos',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      print('Erro inesperado em getOrdersByDate: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, TodaySummary>> getTodaySummary({
    required int storeId,
  }) async {
    try {
      final response = await _dio.get(
        '/stores/$storeId/performance/today-summary',
      );
      return Right(TodaySummary.fromJson(response.data));
    } on DioException catch (e) {
      print('DioException em getTodaySummary: ${e.response?.data}');
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Não foi possível carregar o resumo do dia. Tente novamente',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      print('Erro inesperado em getTodaySummary: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }
}