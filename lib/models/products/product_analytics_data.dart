// lib/models/product_analytics_data.dart

import 'package:equatable/equatable.dart';

// ===================================================================
// MODELO PRINCIPAL DA RESPOSTA
// ===================================================================
class ProductAnalyticsResponse extends Equatable {
  final List<TopProductItem> topProducts;
  final List<LowTurnoverItem> lowTurnoverItems;
  final List<LowStockItem> lowStockItems;
  final AbcAnalysis abcAnalysis;

  const ProductAnalyticsResponse({
    required this.topProducts,
    required this.lowTurnoverItems,
    required this.lowStockItems,
    required this.abcAnalysis,
  });

  factory ProductAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return ProductAnalyticsResponse(
      topProducts: (json['top_products'] as List)
          .map((item) => TopProductItem.fromJson(item))
          .toList(),
      lowTurnoverItems: (json['low_turnover_items'] as List)
          .map((item) => LowTurnoverItem.fromJson(item))
          .toList(),
      lowStockItems: (json['low_stock_items'] as List)
          .map((item) => LowStockItem.fromJson(item))
          .toList(),
      abcAnalysis: AbcAnalysis.fromJson(json['abc_analysis']),
    );
  }

  @override
  List<Object?> get props => [topProducts, lowTurnoverItems, lowStockItems, abcAnalysis];
}

// ===================================================================
// MODELOS DE ITEM INDIVIDUAL
// ===================================================================

class TopProductItem extends Equatable {
  final int productId;
  final String name;
  final String? imageUrl;
  final double revenue;
  final int unitsSold;
  final double profit;

  const TopProductItem({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.revenue,
    required this.unitsSold,
    required this.profit
  });

  factory TopProductItem.fromJson(Map<String, dynamic> json) {
    return TopProductItem(
      productId: json['product_id'],
      name: json['name'],
      imageUrl: json['image_url'],
      revenue: (json['revenue'] as num).toDouble(),
      unitsSold: json['units_sold'],
      profit: (json['profit'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [productId, name, imageUrl, revenue, unitsSold,  profit];
}

class LowTurnoverItem extends Equatable {
  final int productId;
  final String name;
  final String? imageUrl;
  final int stockQuantity;
  final int daysSinceLastSale;
  final double profit;

  const LowTurnoverItem({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.stockQuantity,
    required this.daysSinceLastSale,
    required this.profit
  });

  factory LowTurnoverItem.fromJson(Map<String, dynamic> json) {
    return LowTurnoverItem(
      productId: json['product_id'],
      name: json['name'],
      imageUrl: json['image_url'],
      stockQuantity: json['stock_quantity'],
      daysSinceLastSale: json['days_since_last_sale'],
      profit: (json['profit'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [productId, name, imageUrl, stockQuantity, daysSinceLastSale];
}

class LowStockItem extends Equatable {
  final int productId;
  final String name;
  final String? imageUrl;
  final int stockQuantity;
  final int minimumStockLevel;

  const LowStockItem({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.stockQuantity,
    required this.minimumStockLevel,
  });

  factory LowStockItem.fromJson(Map<String, dynamic> json) {
    return LowStockItem(
      productId: json['product_id'],
      name: json['name'],
      imageUrl: json['image_url'],
      stockQuantity: json['stock_quantity'],
      minimumStockLevel: json['minimum_stock_level'],
    );
  }

  @override
  List<Object?> get props => [productId, name, imageUrl, stockQuantity, minimumStockLevel];
}

class AbcItem extends Equatable {
  final int productId;
  final String name;
  final double revenue;
  final double contributionPercentage;
  final double profit;

  const AbcItem({
    required this.productId,
    required this.name,
    required this.revenue,
    required this.contributionPercentage,
    required this.profit
  });

  factory AbcItem.fromJson(Map<String, dynamic> json) {
    return AbcItem(
      productId: json['product_id'],
      name: json['name'],
      revenue: (json['revenue'] as num).toDouble(),
      contributionPercentage: (json['contribution_percentage'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [productId, name, revenue, contributionPercentage];
}

// ===================================================================
// MODELO DA SEÇÃO DE ANÁLISE ABC
// ===================================================================

class AbcAnalysis extends Equatable {
  final List<AbcItem> classAItems;
  final List<AbcItem> classBItems;
  final List<AbcItem> classCItems;

  const AbcAnalysis({
    required this.classAItems,
    required this.classBItems,
    required this.classCItems,
  });

  factory AbcAnalysis.fromJson(Map<String, dynamic> json) {
    return AbcAnalysis(
      classAItems: (json['class_a_items'] as List)
          .map((item) => AbcItem.fromJson(item))
          .toList(),
      classBItems: (json['class_b_items'] as List)
          .map((item) => AbcItem.fromJson(item))
          .toList(),
      classCItems: (json['class_c_items'] as List)
          .map((item) => AbcItem.fromJson(item))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [classAItems, classBItems, classCItems];
}