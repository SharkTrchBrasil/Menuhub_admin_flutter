import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/store/store.dart'; // Adapte o import

// Usar uma classe de estado torna mais fácil lidar com carregamento, erros, etc.
abstract class ActiveStoreState extends Equatable {
  const ActiveStoreState();

  @override
  List<Object?> get props => [];
}

class ActiveStoreInitial extends ActiveStoreState {}

class ActiveStoreLoading extends ActiveStoreState {}

class ActiveStoreLoaded extends ActiveStoreState {
  final Store store;
  const ActiveStoreLoaded(this.store);

  @override
  List<Object?> get props => [store];
}

class ActiveStoreError extends ActiveStoreState {
  final String message;
  const ActiveStoreError(this.message);

  @override
  List<Object?> get props => [message];
}