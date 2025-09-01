// No arquivo do seu enum UIDisplayMode no Flutter

enum UIDisplayMode { SINGLE, MULTIPLE, QUANTITY, UNKNOWN }

extension UIDisplayModeExtension on UIDisplayMode {
  String toApiString() {
    // Agora, mapeamos cada caso para a string exata em português
    switch (this) {
      case UIDisplayMode.SINGLE:
        return 'Seleção Única';
      case UIDisplayMode.MULTIPLE:
        return 'Seleção Múltipla';
      case UIDisplayMode.QUANTITY:
        return 'Seleção com Quantidade';
      case UIDisplayMode.UNKNOWN:
      // Defina um padrão ou lance um erro se preferir
        return 'Seleção Única';
    }
  }

  // Você pode ajustar o 'fromString' também se precisar
  static UIDisplayMode fromString(String? value) {
    switch (value) {
      case 'Seleção Única':
        return UIDisplayMode.SINGLE;
      case 'Seleção Múltipla':
        return UIDisplayMode.MULTIPLE;
      case 'Seleção com Quantidade':
        return UIDisplayMode.QUANTITY;
      default:
        return UIDisplayMode.UNKNOWN;
    }
  }
}