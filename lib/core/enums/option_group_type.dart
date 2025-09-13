/// Define o comportamento especial de um grupo de opções.
enum OptionGroupType {
  /// Um grupo especial para Tamanhos, usado em categorias onde o preço varia por tamanho.
  /// A UI pode usar este tipo para mostrar campos específicos (ex: fatias, sabores máx).
  size,

  /// Um grupo genérico de opções, onde cada item pode ter um preço aditivo.
  /// Usado para a maioria dos casos (ex: Massas, Bordas, Frutas, Caldas).
  generic,
}