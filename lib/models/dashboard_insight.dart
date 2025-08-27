import 'package:equatable/equatable.dart';

// ✅ Enum para segurança de tipo, muito melhor que usar Strings puras.
enum InsightType {
  upcomingHoliday,
  lowStock,
  lowMoverItem,
  unknown; // Um valor padrão para evitar erros

  static InsightType fromString(String? type) {
    switch (type) {
      case 'UPCOMING_HOLIDAY':
        return InsightType.upcomingHoliday;
      case 'LOW_STOCK':
        return InsightType.lowStock;
      case 'LOW_MOVER_ITEM':
        return InsightType.lowMoverItem;
      default:
        return InsightType.unknown;
    }
  }
}

// ✅ Classe base abstrata para os detalhes de cada insight.
abstract class InsightDetails extends Equatable {
  const InsightDetails();
}

// --- Implementações Concretas para Cada Tipo de Detalhe ---

class HolidayInsightDetails extends InsightDetails {
  final String holidayName;
  final DateTime holidayDate;

  const HolidayInsightDetails({required this.holidayName, required this.holidayDate});

  factory HolidayInsightDetails.fromJson(Map<String, dynamic> json) {
    return HolidayInsightDetails(
      holidayName: json['holiday_name'],
      holidayDate: DateTime.parse(json['holiday_date']),
    );
  }

  @override
  List<Object?> get props => [holidayName, holidayDate];
}

class LowStockInsightDetails extends InsightDetails {
  final int productId;
  final String productName;
  final int currentStock;
  final int minStock;
  final bool isTopSeller;

  const LowStockInsightDetails({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.minStock,
    required this.isTopSeller,
  });

  factory LowStockInsightDetails.fromJson(Map<String, dynamic> json) {
    return LowStockInsightDetails(
      productId: json['product_id'],
      productName: json['product_name'],
      currentStock: json['current_stock'],
      minStock: json['min_stock'],
      isTopSeller: json['is_top_seller'],
    );
  }

  @override
  List<Object?> get props => [productId, productName, currentStock, minStock, isTopSeller];
}

class LowMoverInsightDetails extends InsightDetails {
  final int productId;
  final String productName;
  final int daysSinceLastSale;

  const LowMoverInsightDetails({
    required this.productId,
    required this.productName,
    required this.daysSinceLastSale,
  });

  factory LowMoverInsightDetails.fromJson(Map<String, dynamic> json) {
    return LowMoverInsightDetails(
      productId: json['product_id'],
      productName: json['product_name'],
      daysSinceLastSale: json['days_since_last_sale'],
    );
  }

  @override
  List<Object?> get props => [productId, productName, daysSinceLastSale];
}

class UnknownInsightDetails extends InsightDetails {
  const UnknownInsightDetails();
  @override
  List<Object?> get props => [];
}


// --- O Modelo Principal do Insight ---

class DashboardInsight extends Equatable {
  final InsightType insightType;
  final String title;
  final String message;
  final InsightDetails details;

  const DashboardInsight({
    required this.insightType,
    required this.title,
    required this.message,
    required this.details,
  });

  factory DashboardInsight.fromJson(Map<String, dynamic> json) {
    final type = InsightType.fromString(json['insight_type']);
    InsightDetails details;

    // ✅ Lógica para desserializar o tipo correto de "details"
    switch (type) {
      case InsightType.upcomingHoliday:
        details = HolidayInsightDetails.fromJson(json['details']);
        break;
      case InsightType.lowStock:
        details = LowStockInsightDetails.fromJson(json['details']);
        break;
      case InsightType.lowMoverItem:
        details = LowMoverInsightDetails.fromJson(json['details']);
        break;
      case InsightType.unknown:
        details = const UnknownInsightDetails();
        break;
    }

    return DashboardInsight(
      insightType: type,
      title: json['title'],
      message: json['message'],
      details: details,
    );
  }

  @override
  List<Object?> get props => [insightType, title, message, details];
}