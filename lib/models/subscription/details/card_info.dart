import 'package:equatable/equatable.dart';

/// Informações do cartão cadastrado (mascaradas)
class CardInfo extends Equatable {
  final String maskedNumber;
  final String brand;
  final String status;

  const CardInfo({
    required this.maskedNumber,
    required this.brand,
    required this.status,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    return CardInfo(
      maskedNumber: json['masked_number'] as String,
      brand: json['brand'] as String,
      status: json['status'] as String,
    );
  }

  /// Ícone da bandeira
  String get brandIcon {
    switch (brand.toLowerCase()) {
      case 'visa':
        return '💳';
      case 'mastercard':
        return '💳';
      case 'elo':
        return '💳';
      case 'amex':
        return '💳';
      default:
        return '💳';
    }
  }

  /// Se o cartão está ativo
  bool get isActive => status.toLowerCase() == 'active';

  @override
  List<Object?> get props => [maskedNumber, brand, status];
}