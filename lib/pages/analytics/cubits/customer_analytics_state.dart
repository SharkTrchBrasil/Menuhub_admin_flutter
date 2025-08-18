// lib/pages/analytics/customer_analytics/cubit/customer_analytics_state.dart

part of 'customer_analytics_cubit.dart';


abstract class CustomerAnalyticsState extends Equatable {
  const CustomerAnalyticsState();

  @override
  List<Object> get props => [];
}

// Estado inicial
class CustomerAnalyticsInitial extends CustomerAnalyticsState {}

// Estado de sucesso com os dados de análise de clientes
class CustomerAnalyticsLoaded extends CustomerAnalyticsState {
  final CustomerAnalyticsResponse analyticsData;

  const CustomerAnalyticsLoaded(this.analyticsData);

  @override
  List<Object> get props => [analyticsData];
}

// Estado de erro
class CustomerAnalyticsError extends CustomerAnalyticsState {
  final String message;

  const CustomerAnalyticsError(this.message);

  @override
  List<Object> get props => [message];
}