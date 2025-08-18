// store_relations.dart
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/rating_summary.dart';
import 'package:totem_pro_admin/models/store_city.dart';
import 'package:totem_pro_admin/models/store_hour.dart';
import 'package:totem_pro_admin/models/store_neig.dart';
import 'package:totem_pro_admin/models/store_operation_config.dart';
import 'package:totem_pro_admin/models/subscription_summary.dart';
import 'package:totem_pro_admin/models/variant.dart';

import 'category.dart';
import 'coupon.dart';

class StoreRelations {
  final List<PaymentMethodGroup> paymentMethodGroups;
  final List<StoreHour> hours;
  final StoreOperationConfig? storeOperationConfig;
  final RatingsSummary? ratingsSummary;
  final List<StoreCity>? cities;
  final List<StoreNeighborhood>? neighborhoods;
  final SubscriptionSummary? subscription;
  final List<Category> categories;
  final List<Product> products;
  final List<Variant> variants;
  final List<Coupon> coupons;

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
  });

  factory StoreRelations.fromJson(Map<String, dynamic> json) {
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
      subscription: json['subscription'] != null && json['subscription'] is Map<String, dynamic>
          ? SubscriptionSummary.fromJson(json['subscription'])
          : null,
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
    );
  }

  // Adicione este método dentro da sua classe StoreRelations

  StoreRelations copyWith({
    List<PaymentMethodGroup>? paymentMethodGroups,
    List<StoreHour>? hours,
    StoreOperationConfig? storeOperationConfig,
    RatingsSummary? ratingsSummary,
    List<StoreCity>? cities,
    List<StoreNeighborhood>? neighborhoods,
    SubscriptionSummary? subscription,
    List<Category>? categories,
    List<Product>? products,
    List<Variant>? variants,
    List<Coupon>? coupons,
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
    );
  }



}