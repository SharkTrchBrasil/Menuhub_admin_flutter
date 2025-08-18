// Salve como: models/store_configuration.dart

import 'package:flutter/foundation.dart' show required;

class StoreOperationConfig {
  // --- Configurações Gerais de Operação ---
  final bool isStoreOpen;
  final bool autoAcceptOrders;
  final bool autoPrintOrders;

  // --- Configurações de Entrega (Delivery) ---
  final bool deliveryEnabled;
  final int? deliveryEstimatedMin;
  final int? deliveryEstimatedMax;
  final double? deliveryFee;
  final double? deliveryMinOrder;
  final String? deliveryScope;

  // --- Configurações de Retirada (Pickup/Takeout) ---
  final bool pickupEnabled;
  final int? pickupEstimatedMin;
  final int? pickupEstimatedMax;
  final String? pickupInstructions;

  // --- Configurações de Consumo no Local (Mesas) ---
  final bool tableEnabled;
  final int? tableEstimatedMin;
  final int? tableEstimatedMax;
  final String? tableInstructions;

  // --- Configurações de Impressora ---
  final String? mainPrinterDestination;
  final String? kitchenPrinterDestination;
  final String? barPrinterDestination;

  StoreOperationConfig({
    // Gerais
    this.isStoreOpen = true,
    this.autoAcceptOrders = false,
    this.autoPrintOrders = false,
    // Delivery
    this.deliveryEnabled = false,
    this.deliveryEstimatedMin,
    this.deliveryEstimatedMax,
    this.deliveryFee,
    this.deliveryMinOrder,
    this.deliveryScope = 'neighborhood',
    // Pickup
    this.pickupEnabled = false,
    this.pickupEstimatedMin,
    this.pickupEstimatedMax,
    this.pickupInstructions,
    // Table
    this.tableEnabled = false,
    this.tableEstimatedMin,
    this.tableEstimatedMax,
    this.tableInstructions,
    // Printers
    this.mainPrinterDestination,
    this.kitchenPrinterDestination,
    this.barPrinterDestination,
  });

  factory StoreOperationConfig.fromJson(Map<String, dynamic> json) {
    return StoreOperationConfig(
      // Gerais
      isStoreOpen: json['is_store_open'] ?? true,
      autoAcceptOrders: json['auto_accept_orders'] ?? false,
      autoPrintOrders: json['auto_print_orders'] ?? false,
      // Delivery
      deliveryEnabled: json['delivery_enabled'] ?? false,
      deliveryEstimatedMin: json['delivery_estimated_min'],
      deliveryEstimatedMax: json['delivery_estimated_max'],
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
      deliveryMinOrder: (json['delivery_min_order'] as num?)?.toDouble(),
      deliveryScope: json['delivery_scope'],
      // Pickup
      pickupEnabled: json['pickup_enabled'] ?? false,
      pickupEstimatedMin: json['pickup_estimated_min'],
      pickupEstimatedMax: json['pickup_estimated_max'],
      pickupInstructions: json['pickup_instructions'],
      // Table
      tableEnabled: json['table_enabled'] ?? false,
      tableEstimatedMin: json['table_estimated_min'],
      tableEstimatedMax: json['table_estimated_max'],
      tableInstructions: json['table_instructions'],
      // Printers
      mainPrinterDestination: json['main_printer_destination'],
      kitchenPrinterDestination: json['kitchen_printer_destination'],
      barPrinterDestination: json['bar_printer_destination'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Gerais
      'is_store_open': isStoreOpen,
      'auto_accept_orders': autoAcceptOrders,
      'auto_print_orders': autoPrintOrders,
      // Delivery
      'delivery_enabled': deliveryEnabled,
      'delivery_estimated_min': deliveryEstimatedMin,
      'delivery_estimated_max': deliveryEstimatedMax,
      'delivery_fee': deliveryFee,
      'delivery_min_order': deliveryMinOrder,
      'delivery_scope': deliveryScope,
      // Pickup
      'pickup_enabled': pickupEnabled,
      'pickup_estimated_min': pickupEstimatedMin,
      'pickup_estimated_max': pickupEstimatedMax,
      'pickup_instructions': pickupInstructions,
      // Table
      'table_enabled': tableEnabled,
      'table_estimated_min': tableEstimatedMin,
      'table_estimated_max': tableEstimatedMax,
      'table_instructions': tableInstructions,
      // Printers
      'main_printer_destination': mainPrinterDestination,
      'kitchen_printer_destination': kitchenPrinterDestination,
      'bar_printer_destination': barPrinterDestination,
    };
  }

  StoreOperationConfig copyWith({
    bool? isStoreOpen,
    bool? autoAcceptOrders,
    bool? autoPrintOrders,
    bool? deliveryEnabled,
    int? deliveryEstimatedMin,
    int? deliveryEstimatedMax,
    double? deliveryFee,
    double? deliveryMinOrder,
    String? deliveryScope,
    bool? pickupEnabled,
    int? pickupEstimatedMin,
    int? pickupEstimatedMax,
    String? pickupInstructions,
    bool? tableEnabled,
    int? tableEstimatedMin,
    int? tableEstimatedMax,
    String? tableInstructions,
    String? mainPrinterDestination,
    String? kitchenPrinterDestination,
    String? barPrinterDestination,
  }) {
    return StoreOperationConfig(
      // Gerais
      isStoreOpen: isStoreOpen ?? this.isStoreOpen,
      autoAcceptOrders: autoAcceptOrders ?? this.autoAcceptOrders,
      autoPrintOrders: autoPrintOrders ?? this.autoPrintOrders,
      // Delivery
      deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
      deliveryEstimatedMin: deliveryEstimatedMin ?? this.deliveryEstimatedMin,
      deliveryEstimatedMax: deliveryEstimatedMax ?? this.deliveryEstimatedMax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryMinOrder: deliveryMinOrder ?? this.deliveryMinOrder,
      deliveryScope: deliveryScope ?? this.deliveryScope,
      // Pickup
      pickupEnabled: pickupEnabled ?? this.pickupEnabled,
      pickupEstimatedMin: pickupEstimatedMin ?? this.pickupEstimatedMin,
      pickupEstimatedMax: pickupEstimatedMax ?? this.pickupEstimatedMax,
      pickupInstructions: pickupInstructions ?? this.pickupInstructions,
      // Table
      tableEnabled: tableEnabled ?? this.tableEnabled,
      tableEstimatedMin: tableEstimatedMin ?? this.tableEstimatedMin,
      tableEstimatedMax: tableEstimatedMax ?? this.tableEstimatedMax,
      tableInstructions: tableInstructions ?? this.tableInstructions,
      // Printers
      mainPrinterDestination: mainPrinterDestination ?? this.mainPrinterDestination,
      kitchenPrinterDestination: kitchenPrinterDestination ?? this.kitchenPrinterDestination,
      barPrinterDestination: barPrinterDestination ?? this.barPrinterDestination,
    );
  }
}