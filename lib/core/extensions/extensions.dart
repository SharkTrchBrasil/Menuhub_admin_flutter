import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


import '../../models/products/product.dart';
import '../enums/cashback_type.dart';
import '../enums/inventory_stock.dart';



extension BuildContextX on BuildContext {
  bool get isSmallScreen => MediaQuery.sizeOf(this).width < 600;
}

extension IntX on int {
  String toPrice() => NumberFormat.simpleCurrency(locale: 'pt-BR').format(this/100);
}

extension GoRouterStateX on GoRouterState {



  int get storeId {
    final storeId = pathParameters['storeId'];
    if (storeId == null) {
      throw Exception('Store ID not found in path parameters');
    }
    return int.parse(storeId);
  }

  int get productId {
    final productId = pathParameters['productId'];
    if (productId == null) {
      throw Exception('Product ID not found in path parameters');
    }
    return int.parse(productId);
  }

  int get id {
    final id = pathParameters['id'];
    if (id == null) {
      throw Exception('ID not found in path parameters');
    }
    return int.parse(id);
  }

  int get variantId {
    final variantId = pathParameters['variantId'];
    if (variantId == null) {
      throw Exception('Variant ID not found in path parameters');
    }
    return int.parse(variantId);
  }

  int intParam(String param) {
    final value = pathParameters[param];
    if (value == null) {
      throw Exception('$param not found in path parameters');
    }
    return int.parse(value);
  }

  int get optionId {
    final optionId = pathParameters['optionId'];
    if (optionId == null) {
      throw Exception('Option ID not found in path parameters');
    }
    return int.parse(optionId);
  }



}


extension DateFilterRangeExtension on DateFilterRange {
  // Helper para obter o texto de exibição
  Map<String, String> get displayTexts {
    switch (this) {
      case DateFilterRange.today:
        return {'line1': 'Hoje', 'line2': ''};
      case DateFilterRange.last7Days:
        return {'line1': 'Últimos 7', 'line2': 'dias'};
      case DateFilterRange.last30Days:
        return {'line1': 'Últimos 30', 'line2': 'dias'};
    }
  }
}



extension TimeOfDayExtension on TimeOfDay {
  /// Converte TimeOfDay para um valor double (ex: 9:30 -> 9.5).
  double toDouble() => hour + minute / 60.0;
}

// Adicionando um getter ao seu modelo Product para facilitar a vida
extension ProductStatusExtension on Product {
  ProductStockStatus get stockStatus {
    if (!controlStock) {
      // Para produtos sem controle, consideramos "em estoque" para não poluir a UI
      return ProductStockStatus.inStock;
    }
    if ((stockQuantity ?? 0) <= 0) {
      return ProductStockStatus.outOfStock;
    }
    if ((minStock ?? 0) > 0 && (stockQuantity ?? 0) <= (minStock ?? 0)) {
      return ProductStockStatus.lowStock;
    }
    return ProductStockStatus.inStock;
  }



}


extension CurrencyFormatExtension on num {
  String toCurrency({String locale = 'pt_BR', String symbol = 'R\$'}) {
    final format = NumberFormat.currency(locale: locale, symbol: symbol);
    return format.format(this);
  }
}