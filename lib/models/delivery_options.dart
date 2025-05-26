import 'package:dio/dio.dart';

class DeliveryOptionsModel {
  final int? id;
  final int? storeId;

  // DELIVERY
  final bool deliveryEnabled;
  final int? deliveryEstimatedMin;
  final int? deliveryEstimatedMax;
  final double? deliveryFee;
  final double? deliveryMinOrder;
  final String?  deliveryScope;

  // PICKUP
  final bool pickupEnabled;
  final int? pickupEstimatedMin;
  final int? pickupEstimatedMax;
  final String? pickupInstructions;

  // TABLE
  final bool tableEnabled;
  final int? tableEstimatedMin;
  final int? tableEstimatedMax;
  final String? tableInstructions;

  DeliveryOptionsModel(
       {
    this.id,
    this.storeId,
         this.deliveryScope,
    this.deliveryEnabled = false,
    this.deliveryEstimatedMin,
    this.deliveryEstimatedMax,
    this.deliveryFee,
    this.deliveryMinOrder,
    this.pickupEnabled = false,
    this.pickupEstimatedMin,
    this.pickupEstimatedMax,
    this.pickupInstructions,
    this.tableEnabled = false,
    this.tableEstimatedMin,
    this.tableEstimatedMax,
    this.tableInstructions,
  });

  factory DeliveryOptionsModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOptionsModel(
      id: json['id'],
      storeId: json['store_id'],
      deliveryEnabled: json['delivery_enabled'] ?? false,
      deliveryEstimatedMin: json['delivery_estimated_min'],
      deliveryEstimatedMax: json['delivery_estimated_max'],
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble(),
      deliveryMinOrder: (json['delivery_min_order'] as num?)?.toDouble(),
      deliveryScope: json['delivery_scope'],
      pickupEnabled: json['pickup_enabled'] ?? false,
      pickupEstimatedMin: json['pickup_estimated_min'],
      pickupEstimatedMax: json['pickup_estimated_max'],
      pickupInstructions: json['pickup_instructions'],
      tableEnabled: json['table_enabled'] ?? false,
      tableEstimatedMin: json['table_estimated_min'],
      tableEstimatedMax: json['table_estimated_max'],
      tableInstructions: json['table_instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'delivery_enabled': deliveryEnabled,
      'delivery_estimated_min': deliveryEstimatedMin,
      'delivery_estimated_max': deliveryEstimatedMax,
      'delivery_fee': deliveryFee,
      'delivery_min_order': deliveryMinOrder,
      'delivery_scope': deliveryScope,
      'pickup_enabled': pickupEnabled,
      'pickup_estimated_min': pickupEstimatedMin,
      'pickup_estimated_max': pickupEstimatedMax,
      'pickup_instructions': pickupInstructions,
      'table_enabled': tableEnabled,
      'table_estimated_min': tableEstimatedMin,
      'table_estimated_max': tableEstimatedMax,
      'table_instructions': tableInstructions,
    };
  }

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'delivery_enabled': deliveryEnabled,
      if (deliveryEstimatedMin != null) 'delivery_estimated_min': deliveryEstimatedMin,
      if (deliveryEstimatedMax != null) 'delivery_estimated_max': deliveryEstimatedMax,
      if (deliveryFee != null) 'delivery_fee': deliveryFee,
      if (deliveryMinOrder != null) 'delivery_min_order': deliveryMinOrder,
      if (deliveryScope != null) 'delivery_scope': deliveryScope,

      'pickup_enabled': pickupEnabled,
      if (pickupEstimatedMin != null) 'pickup_estimated_min': pickupEstimatedMin,
      if (pickupEstimatedMax != null) 'pickup_estimated_max': pickupEstimatedMax,
      if (pickupInstructions != null) 'pickup_instructions': pickupInstructions,

      'table_enabled': tableEnabled,
      if (tableEstimatedMin != null) 'table_estimated_min': tableEstimatedMin,
      if (tableEstimatedMax != null) 'table_estimated_max': tableEstimatedMax,
      if (tableInstructions != null) 'table_instructions': tableInstructions,
    });
  }

  DeliveryOptionsModel copyWith({
    int? id,
    int? storeId,
    bool? deliveryEnabled,
    int? deliveryEstimatedMin,
    int? deliveryEstimatedMax,
    double? deliveryFee,
    double? deliveryMinOrder,
    bool? pickupEnabled,
    int? pickupEstimatedMin,
    int? pickupEstimatedMax,
    String? pickupInstructions,
    bool? tableEnabled,
    int? tableEstimatedMin,
    int? tableEstimatedMax,
    String? tableInstructions,
    String?  deliveryScope
  }) {
    return DeliveryOptionsModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      deliveryEnabled: deliveryEnabled ?? this.deliveryEnabled,
      deliveryEstimatedMin: deliveryEstimatedMin ?? this.deliveryEstimatedMin,
      deliveryEstimatedMax: deliveryEstimatedMax ?? this.deliveryEstimatedMax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryMinOrder: deliveryMinOrder ?? this.deliveryMinOrder,
      deliveryScope: deliveryScope ?? this.deliveryScope,
      pickupEnabled: pickupEnabled ?? this.pickupEnabled,
      pickupEstimatedMin: pickupEstimatedMin ?? this.pickupEstimatedMin,
      pickupEstimatedMax: pickupEstimatedMax ?? this.pickupEstimatedMax,
      pickupInstructions: pickupInstructions ?? this.pickupInstructions,
      tableEnabled: tableEnabled ?? this.tableEnabled,
      tableEstimatedMin: tableEstimatedMin ?? this.tableEstimatedMin,
      tableEstimatedMax: tableEstimatedMax ?? this.tableEstimatedMax,
      tableInstructions: tableInstructions ?? this.tableInstructions,
    );
  }
}
