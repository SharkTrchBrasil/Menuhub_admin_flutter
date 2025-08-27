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
        '/stores/$storeId/performance', // A barra no final é importante
        queryParameters: {
          'start_date': formattedStartDate,
          'end_date': formattedEndDate,
        },
      );

      return Right(StorePerformance.fromJson(response.data));
    } on DioException catch (e) {
      print('DioException em getStorePerformance: ${e.response?.data}');
      return Left(Failure('Não foi possível carregar os dados de desempenho.'));
    } catch (e) {
      print('Erro inesperado em getStorePerformance: $e');
      return Left(Failure('Ocorreu um erro inesperado.'));
    }
  }

  /// Busca a lista de pedidos paginada para um período.
  Future<Either<Failure, PaginatedResponse<OrderDetails>>> getOrdersByDate({
    required int storeId,
    // ✅ ALTERADO: Recebe um período, não mais um único dia.
    required DateTime startDate,
    required DateTime endDate,
    String? search,
    String? status,
    int page = 1,
    int size = 10,
  }) async {
    try {
      // ✅ ALTERADO: Formata ambas as datas.
      final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
      final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

      final queryParameters = <String, dynamic>{ // ✅ Definindo o tipo explicitamente
        // ✅ ALTERADO: Usa os parâmetros de período.
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
        '/stores/$storeId/performance/list-by-date', // A barra no final é importante
        queryParameters: queryParameters,
      );

      return Right(PaginatedResponse.fromJson(
        response.data,
            (json) => OrderDetails.fromJson(json as Map<String, dynamic>),
      ));
    } on DioException catch (e) {
      print('DioException em getOrdersByDate: ${e.response?.data}');
      return Left(Failure('Não foi possível carregar os pedidos.'));
    } catch (e) {
      print('Erro inesperado em getOrdersByDate: $e');
      return Left(Failure('Ocorreu um erro inesperado.'));
    }
  }


  Future<Either<Failure, TodaySummary>> getTodaySummary({required int storeId}) async {
    try {
      final response = await _dio.get('/stores/$storeId/performance/today-summary');
      return Right(TodaySummary.fromJson(response.data));
    } on DioException catch (e) {
      // Para erros de rede ou respostas com status de erro (4xx, 5xx)
      print('DioException em getTodaySummary: ${e.response?.data}');
      return Left(Failure('Não foi possível carregar o resumo do dia. Tente novamente.'));
    } catch (e) {
      // Para qualquer outro erro inesperado (ex: falha no parsing do JSON)
      print('Erro inesperado em getTodaySummary: $e');
      return Left(Failure('Ocorreu um erro inesperado.'));
    }
  }


  //
  //
  // // ✅ NOVO MÉTODO
  // Future<void> downloadReport({
  // required int storeId,
  // required DateTime startDate,
  // required DateTime endDate,
  // required String format, // 'pdf' ou 'xlsx'
  // }) async {
  // final authService = GetIt.instance<AuthService>();
  // final token = authService.token; // Pega o token atual
  //
  // if (token == null) {
  // // Lidar com o caso de não ter token
  // return;
  // }
  //
  // final formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
  // final formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);
  //
  // // ATENÇÃO: Substitua 'https://sua-api.com/admin' pela base da sua API
  // final String baseUrl = "https://api-pdvix-production.up.railway.app/admin";
  //
  // final url = "$baseUrl/stores/$storeId/performance/export/$format"
  // "?start_date=$formattedStartDate"
  // "&end_date=$formattedEndDate";
  //
  // // Para web, apenas lançar a URL funciona. Para mobile,
  // // pode ser necessário adicionar o token nos headers, o que requer
  // // uma abordagem mais complexa com download via Dio e salvamento local.
  // // Vamos começar com a abordagem mais simples via url_launcher.
  // if (!await launchUrl(Uri.parse(url), webOnlyWindowName: '_blank')) {
  // throw 'Não foi possível abrir a URL: $url';
  // }
  // }
  //
  //
  //
  //






























}