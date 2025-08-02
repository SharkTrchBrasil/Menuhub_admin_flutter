import 'package:equatable/equatable.dart';

sealed class PageStatus extends Equatable {
  // ✅ Adicionado const ao construtor da classe base
  const PageStatus();

  @override
  List<Object?> get props => [];
}

class PageStatusIdle extends PageStatus {
  // ✅ Adicionado const ao construtor
  const PageStatusIdle();
}

class PageStatusLoading extends PageStatus {
  // ✅ Adicionado const ao construtor
  const PageStatusLoading();
}

class PageStatusError extends PageStatus {
  // ✅ Adicionado 'final' ao campo
  final String message;

  // ✅ Adicionado const ao construtor
  const PageStatusError(this.message);

  @override
  List<Object?> get props => [message];
}

class PageStatusEmpty extends PageStatus {
  // ✅ Adicionado 'final' ao campo
  final String message;

  // ✅ Adicionado const ao construtor
  const PageStatusEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

class PageStatusSuccess<T> extends PageStatus {
  // ✅ Adicionado 'final' ao campo
  final T data;

  // ✅ Adicionado const ao construtor
  const PageStatusSuccess(this.data);

  @override
  List<Object?> get props => [data];
}