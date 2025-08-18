import 'package:dio/dio.dart';
import 'package:totem_pro_admin/models/peak_hours.dart';
import 'package:totem_pro_admin/models/product_analytics_data.dart';
import 'package:totem_pro_admin/models/scheduled_pause.dart';


import 'customer_analytics_data.dart';
import 'dashboard_data.dart';
import 'store_core.dart';
import 'store_address.dart';
import 'store_operation.dart';
import 'store_marketing.dart';
import 'store_media.dart';
import 'store_relations.dart';

class Store {
  final StoreCore core;
  final StoreAddress? address;
  final StoreOperation? operation;
  final StoreMarketing? marketing;
  final StoreMedia? media;
  final StoreRelations relations;

  final DashboardData? dashboardData;
  final ProductAnalyticsResponse? productAnalytics;
  final CustomerAnalyticsResponse? customerAnalytics;
  final PeakHours peakHours;
  final List<ScheduledPause> scheduledPauses;

  Store({
    required this.core,
    this.address,
    this.operation,
    this.marketing,
    this.media,
    required this.relations,
    this.dashboardData,
    this.productAnalytics,
    this.customerAnalytics,
    required this.peakHours,
    required this.scheduledPauses
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      core: StoreCore.fromJson(json),
      address: StoreAddress.fromJson(json),
      operation: StoreOperation.fromJson(json),
      marketing: StoreMarketing.fromJson(json),
      media: StoreMedia.fromJson(json),
      relations: StoreRelations.fromJson(json),

      dashboardData: json['dashboard'] != null
          ? DashboardData.fromJson(json['dashboard'])
          : null,
      // ✅ 4. ADICIONE A LÓGICA DE PARSING
      productAnalytics: json['product_analytics'] != null
          ? ProductAnalyticsResponse.fromJson(json['product_analytics'])
          : null,
      // ✅ 4. ADICIONE A LÓGICA DE PARSING PARA OS DADOS DO CLIENTE
      customerAnalytics: json['customer_analytics'] != null
          ? CustomerAnalyticsResponse.fromJson(json['customer_analytics'])
          : null,
      peakHours: json['peak_hours'] != null
          ? PeakHours.fromJson(json['peak_hours'])
          : PeakHours.defaultValues(),

        scheduledPauses : (json['scheduled_pauses'] as List?)
        ?.map((i) => ScheduledPause.fromJson(i))
        .toList()
        ?? []

    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...core.toJson(),
      ...?address?.toJson(),
      ...?operation?.toJson(),
      ...?marketing?.toJson(),
      ...?media?.toJson(),
    };
  }

  Future<FormData> toFormData() async {
    final mediaData = await media?.toFormDataPart() ?? {};

    return FormData.fromMap({
      ...core.toJson(),
      ...?address?.toJson(),
      ...?operation?.toJson(),
      ...?marketing?.toJson(),
      ...mediaData,
    });
  }

  Store copyWith({
    StoreCore? core,
    StoreAddress? address,
    StoreOperation? operation,
    StoreMarketing? marketing,
    StoreMedia? media,
    StoreRelations? relations,
    DashboardData? dashboardData,
    ProductAnalyticsResponse? productAnalytics,
    CustomerAnalyticsResponse? customerAnalytics,
    PeakHours ? peakHours,
    List<ScheduledPause>? scheduledPauses

  }) {
    return Store(
      core: core ?? this.core,
      address: address ?? this.address,
      operation: operation ?? this.operation,
      marketing: marketing ?? this.marketing,
      media: media ?? this.media,
      relations: relations ?? this.relations,
      dashboardData: dashboardData ?? this.dashboardData,
      productAnalytics: productAnalytics ?? this.productAnalytics,
      customerAnalytics: customerAnalytics ?? this.customerAnalytics,
      peakHours: peakHours ?? this.peakHours,
      scheduledPauses: scheduledPauses ?? this.scheduledPauses
    );
  }
}