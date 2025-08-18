import 'package:dio/dio.dart';
import 'package:totem_pro_admin/models/dashboard_data.dart';

class DashboardRepository {
  final Dio _dio;

  DashboardRepository(this._dio);

  /// Busca os dados do dashboard para uma loja, permitindo filtrar por data.
  // ALTERADO: A assinatura do método agora inclui startDate e endDate.
  // Renomeei para getDashboardData para manter a consistência com o Cubit.
  Future<DashboardData> getDashboardData({
    required int storeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // NOVO: Formatamos as datas para o padrão 'YYYY-MM-DD' que a API espera.
      final startDateString = startDate.toIso8601String().split('T').first;
      final endDateString = endDate.toIso8601String().split('T').first;

      // NOVO: Criamos o mapa de parâmetros para a URL.
      final queryParams = {
        'start_date': startDateString,
        'end_date': endDateString,
      };

      // ALTERADO: A chamada `_dio.get` agora inclui os `queryParameters`.
      // O nome do endpoint deve ser exatamente igual ao que você definiu na sua API FastAPI.
      final response = await _dio.get(
        '/admin/stores/$storeId/dashboard/', // Verifique se o endpoint é '/dashboard' ou '/dashboard-summary'
        queryParameters: queryParams,
      );

      // A conversão do JSON para o nosso modelo continua igual.
      return DashboardData.fromJson(response.data);
    } on DioException catch (e) {
      // O tratamento de erro robusto que você já tinha.
      print("Erro ao buscar dados do dashboard: $e");
      // É uma boa prática relançar uma exceção mais específica ou um objeto de erro.
      throw Exception('Falha ao conectar ao servidor. Verifique sua conexão.');
    } catch (e) {
      print("Erro inesperado no repositório do dashboard: $e");
      throw Exception('Ocorreu um erro inesperado ao processar os dados.');
    }
  }
}