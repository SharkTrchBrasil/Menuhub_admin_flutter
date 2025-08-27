// lib/pages/performance/cubit/performance_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';

import 'package:totem_pro_admin/core/failures.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/paginated_response.dart';
import 'package:totem_pro_admin/models/performance_data.dart';
import 'package:totem_pro_admin/repositories/analytics_repository.dart';
import 'package:equatable/equatable.dart';

import '../../../models/today_summary.dart';

part 'performance_state.dart';

class PerformanceCubit extends Cubit<PerformanceState> {
  final AnalyticsRepository _analyticsRepository;
  final int storeId;

  PerformanceCubit(this._analyticsRepository, this.storeId) : super(PerformanceInitial());

  /// Método principal para carregar TODOS os dados da tela para um novo período.
  /// Usado no `initState` e ao aplicar um novo filtro de data.
  Future<void> loadDataForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    emit(PerformanceLoading());


    // ✅ Executa as TRÊS chamadas de API em paralelo.
    final results = await Future.wait([
      _analyticsRepository.getStorePerformance(
        storeId: storeId,
        startDate: startDate,
        endDate: endDate,
      ),
      _analyticsRepository.getOrdersByDate(
        storeId: storeId,
        startDate: startDate,
        endDate: endDate,
        page: 1,
      ),
      // ✅ ADICIONADO: Chamada para o resumo do dia.
      _analyticsRepository.getTodaySummary(storeId: storeId),
    ]);

    final summaryResult = results[0] as Either<Failure, StorePerformance>;
    final ordersResult = results[1] as Either<Failure, PaginatedResponse<OrderDetails>>;
    final todaySummaryResult = results[2] as Either<Failure, TodaySummary>; // ✅ ADICIONADO

    // Processa os resultados.
    summaryResult.fold(
          (failure) => emit(PerformanceError(failure.message)),
          (summaryData) {
        ordersResult.fold(
              (failure) => emit(PerformanceError(failure.message)),
              (paginatedOrders) {
            todaySummaryResult.fold(
              // Se o resumo do dia falhar, não quebramos a tela, apenas emitimos sem ele.
                  (failure) => emit(PerformanceLoaded(
                performanceData: summaryData,
                orders: paginatedOrders.items,
                currentPage: paginatedOrders.page,
                totalPages: paginatedOrders.totalPages,
                startDate: startDate,
                endDate: endDate,
                todaySummary: null, // ✅ Emite nulo em caso de falha
              )),
                  (todayData) {
                // ✅ Emite o estado final com TODOS os dados.
                emit(PerformanceLoaded(
                  performanceData: summaryData,
                  orders: paginatedOrders.items,
                  currentPage: paginatedOrders.page,
                  totalPages: paginatedOrders.totalPages,
                  startDate: startDate,
                  endDate: endDate,
                  todaySummary: todayData,
                ));
              },
            );
          },
        );
      },
    );
  }

  /// Busca APENAS a lista de pedidos.
  /// Usado para paginação e filtros (busca por texto, status).
  Future<void> fetchOrders({
    int page = 1,
    String? search,
    String? status,
  }) async {
    // Só funciona se os dados já estiverem carregados.
    if (state is! PerformanceLoaded) return;
    final currentState = state as PerformanceLoaded;

    // Mostra um loading apenas na lista de pedidos.
    emit(currentState.copyWith(isLoadingOrders: true));

    final result = await _analyticsRepository.getOrdersByDate(
      storeId: storeId,
      // Usa as datas que já estão salvas no estado.
      startDate: currentState.startDate,
      endDate: currentState.endDate,
      page: page,
      search: search,
      status: status,
    );

    result.fold(
      // Em caso de erro, voltamos ao estado anterior sem o loading de pedidos.
          (failure) => emit(currentState.copyWith(isLoadingOrders: false)),
          (paginatedData) {
        // Atualiza o estado apenas com a nova lista de pedidos e dados de paginação.
        emit(currentState.copyWith(
          orders: paginatedData.items,
          currentPage: paginatedData.page,
          totalPages: paginatedData.totalPages,
          isLoadingOrders: false,
        ));
      },
    );
  }
  
// Dentro de PerformanceCubit
  void changeChartMetric(ChartMetric metric) {
    if (state is! PerformanceLoaded) return;
    final currentState = state as PerformanceLoaded;
    emit(currentState.copyWith(selectedChartMetric: metric));
  }

  // ✅ ADICIONADO: Método para atualizar APENAS o resumo do dia.
  /// Usado pelo botão "Atualizar" do card de vendas do dia.
  Future<void> fetchTodaySummary() async {
    if (state is! PerformanceLoaded) return;
    final currentState = state as PerformanceLoaded;

    final result = await _analyticsRepository.getTodaySummary(storeId: storeId);

    result.fold(
          (failure) { /* Opcional: mostrar um toast de erro */ },
          (todayData) {
        // Atualiza o estado apenas com o novo resumo do dia.
        emit(currentState.copyWith(todaySummary: todayData));
      },
    );
  }
}
