import 'package:equatable/equatable.dart';
// CORREÇÃO: Importando o modelo que contém os dados das lojas e autenticação.
// O caminho pode precisar de ajuste dependendo da estrutura do seu projeto.
import 'package:totem_pro_admin/models/totem_auth_and_stores.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final TotemAuthAndStores data;

  const AuthAuthenticated(this.data);

  @override
  List<Object?> get props => [data];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final SignInError error;

  const AuthError(this.error);

  @override
  List<Object?> get props => [error];
}

class AuthSignUpError extends AuthState {
  final SignUpError error;

  const AuthSignUpError(this.error);

  @override
  List<Object?> get props => [error];
}

class AuthNeedsVerification extends AuthState {
  final String email;
  final String password;
  final String? error; // opcional

  const AuthNeedsVerification({
    required this.email,
    required this.password,
    this.error,
  });

  AuthNeedsVerification copyWith({
    String? email,
    String? password,
    String? error,
  }) {
    return AuthNeedsVerification(
      email: email ?? this.email,
      password: password ?? this.password,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [email, password, error];
}
