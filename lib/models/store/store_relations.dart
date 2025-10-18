// store_relations.dart
import 'package:totem_pro_admin/models/payable_category.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/models/peak_hours.dart';

import 'package:totem_pro_admin/models/rating_summary.dart';
import 'package:totem_pro_admin/models/receivable_category.dart';
import 'package:totem_pro_admin/models/scheduled_pause.dart';
import 'package:totem_pro_admin/models/store/store_chatbot_config.dart';
import 'package:totem_pro_admin/models/store/store_chatbot_message.dart';

import 'package:totem_pro_admin/models/store/store_city.dart';
import 'package:totem_pro_admin/models/store/store_hour.dart';
import 'package:totem_pro_admin/models/store/store_neig.dart';
import 'package:totem_pro_admin/models/store/store_operation_config.dart';
import 'package:totem_pro_admin/models/store/store_payable.dart';
import 'package:totem_pro_admin/models/store/store_receivable.dart';


import 'package:totem_pro_admin/models/supplier.dart';

import 'package:totem_pro_admin/models/variant.dart';

import '../billing_preview.dart';
import '../category.dart';

import '../coupon.dart';
import '../customer_analytics_data.dart';
import '../dashboard_data.dart';
import '../dashboard_insight.dart';
import '../products/product.dart';
import '../products/product_analytics_data.dart';

import '../subscription/subscription.dart';

import '../tables/saloon.dart';



class StoreRelations {
  final List<PaymentMethodGroup> paymentMethodGroups;
  final List<StoreHour> hours;
  final StoreOperationConfig? storeOperationConfig;
  final RatingsSummary? ratingsSummary;
  final List<StoreCity>? cities;
  final List<StoreNeighborhood>? neighborhoods;
  final Subscription? subscription;
  final List<Category> categories;
  final List<Product> products;
  final List<Variant> variants;
  final List<Coupon> coupons;

  final DashboardData? dashboardData;
  final ProductAnalyticsResponse? productAnalytics;
  final CustomerAnalyticsResponse? customerAnalytics;
  final PeakHours peakHours;
  final List<ScheduledPause> scheduledPauses;
  final List<DashboardInsight> insights;
  final List<StorePayable> payables;
  final List<Supplier> suppliers;
  final List<PayableCategory> payableCategories;

  final List<StoreReceivable> receivables;
  final List<ReceivableCategory> receivableCategories;


  final List<Saloon> saloons;

  final List<StoreChatbotMessage> chatbotMessages;
  final StoreChatbotConfig? chatbotConfig;
  final BillingPreview? billingPreview;

  StoreRelations({
    this.paymentMethodGroups = const [],
    this.hours = const [],
    this.ratingsSummary,
    this.cities,
    this.neighborhoods,
    this.storeOperationConfig,
    this.subscription,
    this.categories = const [],
    this.products = const [],
    this.variants = const [],
    this.coupons = const [],
    this.dashboardData,
    this.productAnalytics,
    this.customerAnalytics,
    required this.peakHours,
    required this.scheduledPauses,
    this.insights = const [],
    this.payables = const [],
    this.suppliers = const [],
    this.payableCategories = const [],
    this.receivables = const [],
    this.receivableCategories = const [],

    this.saloons = const [],
    this.chatbotMessages = const [],
    this.chatbotConfig,
    this.billingPreview,
  });

  factory StoreRelations.fromJson(Map<String, dynamic> json) {



    Subscription? subscription;
    if (json.containsKey('active_subscription')) {
      print('   ✅ active_subscription presente');
      if (json['active_subscription'] != null && json['active_subscription'] is Map<String, dynamic>) {
        subscription = Subscription.fromJson(json['active_subscription']);
        print('   ✅ Subscription parseada: status=${subscription.status}');
      } else {
        print('   ⚠️ active_subscription é NULL ou inválido');
      }
    } else {
      print('   ❌ active_subscription NÃO está no JSON!');
    }



    return StoreRelations(
      paymentMethodGroups: (json['payment_method_groups'] as List<dynamic>?)
          ?.map((e) => PaymentMethodGroup.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      hours: (json['hours'] as List<dynamic>?)
          ?.map((e) => StoreHour.fromJson(e))
          .toList() ?? [],
      storeOperationConfig: json['store_operation_config'] != null
          ? StoreOperationConfig.fromJson(json['store_operation_config'])
          : null,
      ratingsSummary: json['ratingsSummary'] != null
          ? RatingsSummary.fromMap(json['ratingsSummary'])
          : null,
      cities: (json['cities'] as List<dynamic>?)
          ?.map((e) => StoreCity.fromJson(e as Map<String, dynamic>))
          .toList(),
      neighborhoods: (json['neighborhoods'] as List<dynamic>?)
          ?.map((e) => StoreNeighborhood.fromJson(e as Map<String, dynamic>))
          .toList(),

      subscription: subscription,

      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      products: (json['products'] as List<dynamic>? ?? [])
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      variants: (json['variants'] as List<dynamic>? ?? [])
          .map((e) => Variant.fromJson(e as Map<String, dynamic>))
          .toList(),
      coupons: (json['coupons'] as List<dynamic>? ?? [])
          .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
          .toList(),
      dashboardData: json['dashboard'] != null
          ? DashboardData.fromJson(json['dashboard'])
          : null,
      productAnalytics: json['product_analytics'] != null
          ? ProductAnalyticsResponse.fromJson(json['product_analytics'])
          : null,
      customerAnalytics: json['customer_analytics'] != null
          ? CustomerAnalyticsResponse.fromJson(json['customer_analytics'])
          : null,
      peakHours: json['peak_hours'] != null
          ? PeakHours.fromJson(json['peak_hours'])
          : PeakHours.defaultValues(),
      scheduledPauses : (json['scheduled_pauses'] as List?)
          ?.map((i) => ScheduledPause.fromJson(i))
          .toList()
          ?? [],
      payables: (json['payables'] as List<dynamic>? ?? [])
          .map((i) => StorePayable.fromJson(i as Map<String, dynamic>))
          .toList(),
      suppliers: (json['suppliers'] as List<dynamic>? ?? [])
          .map((s) => Supplier.fromJson(s as Map<String, dynamic>))
          .toList(),
      payableCategories: (json['payable_categories'] as List<dynamic>? ?? [])
          .map((c) => PayableCategory.fromJson(c as Map<String, dynamic>))
          .toList(),
      insights: (json['insights'] as List<dynamic>? ?? [])
          .map((i) => DashboardInsight.fromJson(i as Map<String, dynamic>))
          .toList(),
      receivables: (json['receivables'] as List<dynamic>? ?? [])
          .map((r) => StoreReceivable.fromJson(r as Map<String, dynamic>))
          .toList(),
      receivableCategories: (json['receivable_categories'] as List<dynamic>? ?? [])
          .map((c) => ReceivableCategory.fromJson(c as Map<String, dynamic>))
          .toList(),

      saloons: (json['saloons'] as List<dynamic>? ?? [])
          .map((s) => Saloon.fromJson(s as Map<String, dynamic>))
          .toList(),
      chatbotMessages: (json['chatbot_messages'] as List<dynamic>? ?? [])
          .map((e) => StoreChatbotMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      chatbotConfig: json['chatbot_config'] != null
          ? StoreChatbotConfig.fromJson(json['chatbot_config'])
          : null,
      billingPreview: json['billing_preview'] != null
          ? BillingPreview.fromJson(json['billing_preview'])
          : null,
    );
  }

  StoreRelations copyWith({
    List<PaymentMethodGroup>? paymentMethodGroups,
    List<StoreHour>? hours,
    StoreOperationConfig? storeOperationConfig,
    RatingsSummary? ratingsSummary,
    List<StoreCity>? cities,
    List<StoreNeighborhood>? neighborhoods,
    Subscription? subscription,
    List<Category>? categories,
    List<Product>? products,
    List<Variant>? variants,
    List<Coupon>? coupons,
    DashboardData? dashboardData,
    ProductAnalyticsResponse? productAnalytics,
    CustomerAnalyticsResponse? customerAnalytics,
    PeakHours ? peakHours,
    List<ScheduledPause>? scheduledPauses,
    List<DashboardInsight>? insights,
    List<StorePayable>? payables,
    List<Supplier>? suppliers,
    List<PayableCategory>? payableCategories,
    List<StoreReceivable>? receivables,
    List<ReceivableCategory>? receivableCategories,

    List<Saloon>? saloons,
    List<StoreChatbotMessage>? chatbotMessages,
    StoreChatbotConfig? chatbotConfig,
    BillingPreview? billingPreview,
  }) {
    return StoreRelations(
        paymentMethodGroups: paymentMethodGroups ?? this.paymentMethodGroups,
        hours: hours ?? this.hours,
        storeOperationConfig: storeOperationConfig ?? this.storeOperationConfig,
        ratingsSummary: ratingsSummary ?? this.ratingsSummary,
        cities: cities ?? this.cities,
        neighborhoods: neighborhoods ?? this.neighborhoods,
        subscription: subscription ?? this.subscription,
        categories: categories ?? this.categories,
        products: products ?? this.products,
        variants: variants ?? this.variants,
        coupons: coupons ?? this.coupons,
        dashboardData: dashboardData ?? this.dashboardData,
        productAnalytics: productAnalytics ?? this.productAnalytics,
        customerAnalytics: customerAnalytics ?? this.customerAnalytics,
        peakHours: peakHours ?? this.peakHours,
        scheduledPauses: scheduledPauses ?? this.scheduledPauses,
        insights: insights ?? this.insights,
        payables: payables ?? this.payables,
        suppliers: suppliers ?? this.suppliers,
        payableCategories: payableCategories ?? this.payableCategories,
        receivables: receivables ?? this.receivables,
        receivableCategories: receivableCategories ?? this.receivableCategories,

        saloons: saloons ?? this.saloons,
        chatbotMessages: chatbotMessages ?? this.chatbotMessages,
        chatbotConfig: chatbotConfig ?? this.chatbotConfig,
      billingPreview: billingPreview ?? this.billingPreview

    );
  }
}