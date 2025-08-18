// lib/models/customer_analytics_data.dart

import 'package:equatable/equatable.dart';

// ===================================================================
// MODELO PRINCIPAL DA RESPOSTA
// ===================================================================
class CustomerAnalyticsResponse extends Equatable {
  final KeyCustomerMetrics keyMetrics;
  final List<RfmSegment> segments;

  const CustomerAnalyticsResponse({
    required this.keyMetrics,
    required this.segments,
  });

  factory CustomerAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return CustomerAnalyticsResponse(
      keyMetrics: KeyCustomerMetrics.fromJson(json['key_metrics']),
      segments: (json['segments'] as List)
          .map((item) => RfmSegment.fromJson(item))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [keyMetrics, segments];
}

// ===================================================================
// MODELOS DE DADOS
// ===================================================================

class KeyCustomerMetrics extends Equatable {
  final int newCustomers;
  final int returningCustomers;
  final double retentionRate;

  const KeyCustomerMetrics({
    required this.newCustomers,
    required this.returningCustomers,
    required this.retentionRate,
  });

  factory KeyCustomerMetrics.fromJson(Map<String, dynamic> json) {
    return KeyCustomerMetrics(
      newCustomers: json['new_customers'],
      returningCustomers: json['returning_customers'],
      retentionRate: (json['retention_rate'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [newCustomers, returningCustomers, retentionRate];
}

class RfmSegment extends Equatable {
  final String segmentName;
  final String description;
  final String suggestion;
  final List<CustomerMetric> customers;

  const RfmSegment({
    required this.segmentName,
    required this.description,
    required this.suggestion,
    required this.customers,
  });

  factory RfmSegment.fromJson(Map<String, dynamic> json) {
    return RfmSegment(
      segmentName: json['segment_name'],
      description: json['description'],
      suggestion: json['suggestion'],
      customers: (json['customers'] as List)
          .map((item) => CustomerMetric.fromJson(item))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [segmentName, description, suggestion, customers];
}

class CustomerMetric extends Equatable {
  final int customerId;
  final String name;
  final double totalSpent;
  final int orderCount;
  final DateTime lastOrderDate;

  const CustomerMetric({
    required this.customerId,
    required this.name,
    required this.totalSpent,
    required this.orderCount,
    required this.lastOrderDate,
  });

  factory CustomerMetric.fromJson(Map<String, dynamic> json) {
    return CustomerMetric(
      customerId: json['customer_id'],
      name: json['name'],
      totalSpent: (json['total_spent'] as num).toDouble(),
      orderCount: json['order_count'],
      lastOrderDate: DateTime.parse(json['last_order_date']),
    );
  }

  @override
  List<Object?> get props => [customerId, name, totalSpent, orderCount, lastOrderDate];
}