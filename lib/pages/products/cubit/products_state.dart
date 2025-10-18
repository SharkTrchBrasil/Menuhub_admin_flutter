part of 'products_cubit.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {}

class ProductsActionInProgress extends ProductsState {}

class ProductsActionSuccess extends ProductsState {
  final String message;
  const ProductsActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ProductsActionFailure extends ProductsState {
  final String error;
  const ProductsActionFailure(this.error);

  @override
  List<Object> get props => [error];
}