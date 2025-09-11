part of 'products_cubit.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object> get props => [];
}

// Estado inicial, nada acontecendo.
class ProductsInitial extends ProductsState {}

// Estado para quando uma ação está em andamento (ex: salvando, deletando).
class ProductsActionInProgress extends ProductsState {}

// Estado para quando uma ação foi concluída com sucesso.
class ProductsActionSuccess extends ProductsState {
  final String message;
  const ProductsActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

// Estado para quando uma ação falhou.
class ProductsActionFailure extends ProductsState {
  final String error;
  const ProductsActionFailure(this.error);

  @override
  List<Object> get props => [error];
}