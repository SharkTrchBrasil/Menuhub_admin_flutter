// lib/pages/performance/cubit/performance_state.dart

part of 'performance_cubit.dart';

// ✅ Crie este enum no topo do arquivo
enum ChartMetric { sales, value, ticket, newCustomers }


abstract class PerformanceState extends Equatable {
  const PerformanceState();
  @override
  List<Object?> get props => [];
}

class PerformanceInitial extends PerformanceState {}

class PerformanceLoading extends PerformanceState {}

class PerformanceLoaded extends PerformanceState {
  /// Todos os dados de analytics (resumos, gráficos, etc.).
  final StorePerformance performanceData;

  /// A lista de pedidos para a página atual.
  final List<OrderDetails> orders;

  /// Informações de paginação para a lista de pedidos.
  final int currentPage;
  final int totalPages;

  /// O período de filtro que está ativo.
  final DateTime startDate;
  final DateTime endDate;

  /// Um indicador de loading *apenas* para a lista de pedidos,
  /// usado ao paginar ou filtrar, para não recarregar a tela toda.
  final bool isLoadingOrders;
  // Ele é nullable pois pode ser atualizado separadamente.
  final TodaySummary? todaySummary;
// ✅ Adicione a métrica selecionada ao estado
  final ChartMetric selectedChartMetric;


  const PerformanceLoaded({
    required this.performanceData,
    required this.orders,
    required this.currentPage,
    required this.totalPages,
    required this.startDate,
    required this.endDate,
    this.isLoadingOrders = false,
    this.todaySummary,
    this.selectedChartMetric = ChartMetric.sales,
  });

  @override
  List<Object?> get props => [
    performanceData,
    orders,
    currentPage,
    totalPages,
    startDate,
    endDate,
    isLoadingOrders,
    todaySummary,
    selectedChartMetric
  ];

  PerformanceLoaded copyWith({
    StorePerformance? performanceData,
    List<OrderDetails>? orders,
    int? currentPage,
    int? totalPages,
    DateTime? startDate,
    DateTime? endDate,
    bool? isLoadingOrders,
    TodaySummary? todaySummary,
    ChartMetric? selectedChartMetric

  }) {
    return PerformanceLoaded(
      performanceData: performanceData ?? this.performanceData,
      orders: orders ?? this.orders,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isLoadingOrders: isLoadingOrders ?? this.isLoadingOrders,
      todaySummary: todaySummary ?? this.todaySummary,
      selectedChartMetric: selectedChartMetric ?? this.selectedChartMetric
    );
  }
}

class PerformanceError extends PerformanceState {
  final String message;
  const PerformanceError(this.message);
  @override
  List<Object?> get props => [message];
}