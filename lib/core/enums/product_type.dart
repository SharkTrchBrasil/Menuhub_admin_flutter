// lib/core/utils/enums/product_type.dart

enum ProductType {
  INDIVIDUAL,
  KIT,
  PREPARED,
  INDUSTRIALIZED; // Removido FLAVOR e UNKNOWN

  /// Converte uma String da API para o enum ProductType.
  static ProductType fromString(String? typeStr) {
    switch (typeStr) {
      case 'INDIVIDUAL':
        return ProductType.INDIVIDUAL;
      case 'KIT':
        return ProductType.KIT;
      case 'PREPARED':
        return ProductType.PREPARED;
      case 'INDUSTRIALIZED':
        return ProductType.INDUSTRIALIZED;
      default:
      // Se um tipo desconhecido vier da API, é melhor tratar como um erro
      // ou ter um tipo padrão seguro, como INDIVIDUAL.
      // Lançar um erro é mais seguro para encontrar bugs.
        throw ArgumentError('Tipo de produto desconhecido: $typeStr');
    }
  }

  /// Converte o enum para a String que a API espera.
  String toApiString() {
    return name; // Ex: ProductType.INDIVIDUAL.name se torna "INDIVIDUAL"
  }
}