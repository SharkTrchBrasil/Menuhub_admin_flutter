import 'package:equatable/equatable.dart';
// CORREÇÃO: Importando o modelo que contém os dados das lojas e autenticação.
// O caminho pode precisar de ajuste dependendo da estrutura do seu projeto.
import 'package:totem_pro_admin/models/totem_auth_and_stores.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';

// CORREÇÃO: Adicionado 'extends Equatable' para otimizar reconstruções de UI.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// CORREÇÃO: O estado agora carrega os dados de autenticação e das lojas.
// Isso resolve a condição de corrida, disponibilizando os dados imediatamente para o roteador.
class AuthAuthenticated extends AuthState {
  final TotemAuthAndStores data;

  const AuthAuthenticated(this.data);

  @override
  List<Object> get props => [data];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final SignInError error;

  const AuthError(this.error);

  @override
  List<Object> get props => [error];
}

// CORREÇÃO: Renomeado para seguir o padrão e evitar confusão.
class AuthSignUpError extends AuthState {
  final SignUpError error;

  const AuthSignUpError(this.error);

  @override
  List<Object> get props => [error];
}

// NOVO ESTADO!
class AuthNeedsVerification extends AuthState {
  final String email;
  final String password; // <-- ADICIONE ESTE CAMPO

  const AuthNeedsVerification({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}