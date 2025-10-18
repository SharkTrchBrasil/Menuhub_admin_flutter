import 'package:equatable/equatable.dart';

/// Representa uma falha genérica na camada de dados.
class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({
    required this.message,
    this.statusCode,
  });

  /// Construtor de conveniência para criar Failure apenas com mensagem
  const Failure.fromMessage(String message) : this(message: message);

  /// Verifica se é erro de autenticação (401)
  bool get isUnauthorized => statusCode == 401;

  /// Verifica se é erro de acesso negado (403)
  bool get isForbidden => statusCode == 403;

  /// Verifica se é erro de recurso não encontrado (404)
  bool get isNotFound => statusCode == 404;

  /// Verifica se é erro de validação (400, 422)
  bool get isValidationError => statusCode == 400 || statusCode == 422;

  /// Verifica se é erro do servidor (500+)
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Verifica se é erro de conexão/rede
  bool get isNetworkError => statusCode == null;

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() => statusCode != null
      ? 'Failure($statusCode): $message'
      : 'Failure: $message';
}