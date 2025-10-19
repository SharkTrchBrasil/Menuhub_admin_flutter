import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/totem_auth_and_stores.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';

import '../core/enums/auth_erros.dart';

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

// ✅ CORRIGIDO: Adiciona reason e message
class AuthUnauthenticated extends AuthState {
  final String? message;
  final String? reason; // ✅ NOVO: Para diferenciar tipos de logout

  const AuthUnauthenticated({
    this.message,
    this.reason,
  });

  @override
  List<Object?> get props => [message, reason];
}

class AuthError extends AuthState {
  final SignInError error;

  const AuthError(this.error);

  // ✅ NOVO: Helper para converter enum em mensagem
  String get errorMessage {
    switch (error) {
      case SignInError.emailNotVerified:
        return 'E-mail não verificado. Por favor, verifique sua caixa de entrada.';
      case SignInError.invalidCredentials:
        return 'E-mail ou senha incorretos.';
      case SignInError.networkError:
        return 'Erro de conexão. Verifique sua internet.';
      case SignInError.serverError:
        return 'Erro no servidor. Tente novamente mais tarde.';
      default:
        return 'Erro desconhecido. Tente novamente.';
    }
  }

  @override
  List<Object?> get props => [error];
}

class AuthSignUpError extends AuthState {
  final SignUpError error;

  const AuthSignUpError(this.error);

  // ✅ NOVO: Helper para converter enum em mensagem
  String get errorMessage {
    switch (error) {
      case SignUpError.emailAlreadyExists:
        return 'Este e-mail já está cadastrado.';
      case SignUpError.weakPassword:
        return 'Senha muito fraca. Use no mínimo 8 caracteres.';
      case SignUpError.networkError:
        return 'Erro de conexão. Verifique sua internet.';
      case SignUpError.serverError:
        return 'Erro no servidor. Tente novamente mais tarde.';
      default:
        return 'Erro desconhecido. Tente novamente.';
    }
  }

  @override
  List<Object?> get props => [error];
}

class AuthNeedsVerification extends AuthState {
  final String email;
  final String password;
  final String? error;

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