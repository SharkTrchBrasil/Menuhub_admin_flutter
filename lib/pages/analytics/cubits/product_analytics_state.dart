// lib/pages/analytics/product_analytics/cubit/product_analytics_state.dart

part of 'product_analytics_cubit.dart';

abstract class ProductAnalyticsState extends Equatable {
  const ProductAnalyticsState();

  @override
  List<Object> get props => [];
}

// Estado inicial, antes de qualquer dado ser processado.
class ProductAnalyticsInitial extends ProductAnalyticsState {}

// Estado de sucesso, quando temos os dados prontos para exibir.
class ProductAnalyticsLoaded extends ProductAnalyticsState {
  final ProductAnalyticsResponse analyticsData;

  const ProductAnalyticsLoaded(this.analyticsData);

  @override
  List<Object> get props => [analyticsData];
}

// Estado de erro, caso os dados não sejam encontrados por algum motivo.
class ProductAnalyticsError extends ProductAnalyticsState {
  final String message;

  const ProductAnalyticsError(this.message);

  @override
  List<Object> get props => [message];
}