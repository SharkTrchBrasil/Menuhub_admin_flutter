// lib/pages/products/widgets/filter_height_calculator.dart

class FilterHeightCalculator {
  /// Calcula a altura do header de filtros baseado no contexto
  static double calculate({
    required bool isMobile,
    required bool hasSelection,
  }) {
    if (!hasSelection) {
      // Apenas filtros
      return isMobile ? 74.0 : 74.0;
    } else {
      // Filtros + barra de ações
      return isMobile ? 148.0 : 148.0;
    }
  }
}