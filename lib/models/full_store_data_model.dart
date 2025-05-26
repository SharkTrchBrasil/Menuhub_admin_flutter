// full_store_data_model.dart
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/coupon.dart';
import 'package:totem_pro_admin/models/product.dart';

class FullStoreDataModel {
  final Store store;
  final List<Category> categories;
  final List<Coupon> coupons;
  final List<StorePaymentMethod> paymentMethods;
  final List<Product> products;

  FullStoreDataModel({
    required this.store,
    required this.categories,
    required this.coupons,
    required this.paymentMethods,
   required this.products,
  });

  factory FullStoreDataModel.fromJson(Map<String, dynamic> json) {
    return FullStoreDataModel(
      store: Store.fromJson(json['store'] as Map<String, dynamic>), // 'store' não deve ser nulo pela estrutura da sua API
      categories: (json['categories'] as List?)?.map((c) => Category.fromJson(c as Map<String, dynamic>)).toList() ?? [],
      coupons: (json['coupons'] as List?)?.map((c) => Coupon.fromJson(c as Map<String, dynamic>)).toList() ?? [],
      paymentMethods: (json['payment_methods'] as List?)?.map((pm) => StorePaymentMethod.fromJson(pm as Map<String, dynamic>)).toList() ?? [],
      products: (json['products'] as List?)?.map((p) => Product.fromJson(p as Map<String, dynamic>)).toList() ?? [],

    );
  }
}