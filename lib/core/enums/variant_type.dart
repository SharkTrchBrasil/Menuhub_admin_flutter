// lib/core/utils/enums/variant_type.dart

enum VariantType {
  INGREDIENTS,
  SPECIFICATIONS,
  CROSS_SELL,
  DISPOSABLES,
  UNKNOWN;

  /// Converte uma String da API para o enum VariantType.
  static VariantType fromString(String? typeStr) {
    switch (typeStr) {
      case "Ingredientes":
        return VariantType.INGREDIENTS;
      case "Especificações":
        return VariantType.SPECIFICATIONS;
      case "Cross-sell":
        return VariantType.CROSS_SELL;
      case "Descartáveis":
        return VariantType.DISPOSABLES;
      default:
        return VariantType.UNKNOWN;
    }
  }

  /// Converte o enum para a String que a API espera.
  String toApiString() {
    switch (this) {
      case VariantType.INGREDIENTS:
        return "Ingredientes";
      case VariantType.SPECIFICATIONS:
        return "Especificações";
      case VariantType.CROSS_SELL:
        return "Cross-sell";
      case VariantType.DISPOSABLES:
        return "Descartáveis";
      case VariantType.UNKNOWN:
        return ""; // Retorna vazio para o tipo desconhecido
    }
  }
}