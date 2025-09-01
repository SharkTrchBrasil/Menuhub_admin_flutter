
enum SearchStatus { initial, loading, success, failure }



// lib/core/utils/enums/product_type.dart

enum ProductType {
  PREPARED,
  INDUSTRIALIZED,
  INDIVIDUAL, // Adicionei este com base no seu schema Pydantic
  KIT,        // Adicionei este com base no seu schema Pydantic
  UNKNOWN;

  /// Converte uma String da API para o enum ProductType.
  static ProductType fromString(String? typeStr) {
    switch (typeStr) {
      case 'Preparado':
      case 'PREPARED':
        return ProductType.PREPARED;
      case 'Industrializado':
      case 'INDUSTRIALIZED':
        return ProductType.INDUSTRIALIZED;
      case 'Individual':
      case 'INDIVIDUAL':
        return ProductType.INDIVIDUAL;
      case 'Kit':
      case 'KIT':
        return ProductType.KIT;
      default:
        return ProductType.UNKNOWN;
    }
  }

  // DENTRO DO ENUM `ProductType`

  /// Converte o enum para a String que a API espera.
  String toApiString() {
    // A propriedade .name já retorna a string em MAIÚSCULO, exatamente como a API espera.
    // Ex: ProductType.INDIVIDUAL.name se torna "INDIVIDUAL"
    return name;
  }
}