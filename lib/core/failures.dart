/// Representa uma falha genérica na camada de dados.
class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}