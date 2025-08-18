enum CashbackType {
  none,
  fixed,
  percentage;

  /// Converte uma string vinda da API para o nosso Enum.
  static CashbackType fromString(String? value) {
    switch (value) {
      case 'fixed':
        return CashbackType.fixed;
      case 'percentage':
        return CashbackType.percentage;
      default:
        return CashbackType.none;
    }
  }

  /// Retorna um nome amigável para exibição na UI.
  String get displayName {
    switch (this) {
      case CashbackType.none:
        return 'Nenhum';
      case CashbackType.fixed:
        return 'Valor Fixo (R\$)';
      case CashbackType.percentage:
        return 'Porcentagem (%)';
    }
  }
}

// Lembre-se de ter este enum definido no seu projeto
enum DateFilterRange { today, last7Days, last30Days }
