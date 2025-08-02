import 'package:flutter/cupertino.dart';
import 'package:dio/dio.dart';

// --- NOVOS IMPORTS PARA OS DADOS DO CATÁLOGO ---
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/models/coupon.dart';

// Imports existentes
import 'package:totem_pro_admin/models/delivery_options.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/models/rating_summary.dart';
import 'package:totem_pro_admin/models/store_city.dart';
import 'package:totem_pro_admin/models/store_hour.dart';
import 'package:totem_pro_admin/models/store_neig.dart';
import 'package:totem_pro_admin/models/store_settings.dart';
import 'package:totem_pro_admin/models/subscription_summary.dart';
import 'image_model.dart';

class Store {
  final int? id;
  final String name;
  final String? urlSlug;
  final String? description;
  final String? phone;
  final String? cnpj;
  final int? segmentId;
  // Endereço
  final String? zipCode;
  final String? street;
  final String? number;
  final String? neighborhood;
  final String? complement;
  final String? city;
  final String? state;
  final double? latitude;
  final double? longitude;
  final double? deliveryRadiusKm;
  // Operacional
  final int? averagePreparationTime;
  final String? orderNumberPrefix;
  final DateTime? manualCloseUntil;
  // Responsável
  final String? responsibleName;
  final String? responsiblePhone;
  // Marketing e SEO
  final List<String>? tags;
  final String? metaTitle;
  final String? metaDescription;
  final double? ratingAverage;
  final int? ratingCount;
  final String? fileKey;
  final String? bannerFileKey;
  // Gerenciamento
  final bool isActive;
  final bool isSetupComplete;
  final bool isFeatured;
  final String verificationStatus;
  final String? internalNotes;
  // Redes sociais
  final String? instagram;
  final String? facebook;
  final String? tiktok;
  final ImageModel? image;
  final ImageModel? banner;
  final String? storeUrl;

  // --- Relações ---
  final List<PaymentMethodGroup> paymentMethodGroups;
  final List<StoreHour> hours;
  final DeliveryOptionsModel? deliveryOptions;
  final RatingsSummary? ratingsSummary;
  final List<StoreCity>? cities;
  final List<StoreNeighborhood>? neighborhoods;
  final StoreSettings? storeSettings;
  final SubscriptionSummary? subscription;
  final List<Category> categories;
  final List<Product> products;
  final List<Variant> variants;
  final List<Coupon> coupons;

  Store({
    this.id,
    this.name = '',
    this.urlSlug,
    this.description,
    this.phone,
    this.cnpj,
    this.segmentId,
    this.zipCode,
    this.street,
    this.number,
    this.neighborhood,
    this.complement,
    this.city,
    this.state,
    this.latitude,
    this.longitude,
    this.deliveryRadiusKm,
    this.averagePreparationTime,
    this.orderNumberPrefix,
    this.manualCloseUntil,
    this.responsibleName,
    this.responsiblePhone,
    this.tags,
    this.metaTitle,
    this.metaDescription,
    this.ratingAverage,
    this.ratingCount,
    this.fileKey,
    this.bannerFileKey,
    this.isActive = true,
    this.isSetupComplete = false,
    this.isFeatured = false,
    this.verificationStatus = 'UNVERIFIED',
    this.internalNotes,
    this.instagram,
    this.facebook,
    this.tiktok,
    this.image,
    this.banner,
    this.storeUrl,
    this.paymentMethodGroups = const [],
    this.hours = const [],
    this.deliveryOptions,
    this.ratingsSummary,
    this.cities,
    this.neighborhoods,
    this.storeSettings,
    this.subscription,
    this.categories = const [],
    this.products = const [],
    this.variants = const [],
    this.coupons = const [],
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as int?,
      name: json['name'] ?? '',
      urlSlug: json['url_slug'],
      description: json['description'],
      phone: json['phone'],
      cnpj: json['cnpj'],
      segmentId: json['segment_id'] as int?,
      zipCode: json['zip_code'],
      street: json['street'],
      number: json['number'],
      neighborhood: json['neighborhood'],
      complement: json['complement'],
      city: json['city'],
      state: json['state'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      deliveryRadiusKm: json['delivery_radius_km']?.toDouble(),
      averagePreparationTime: json['average_preparation_time'] as int?,
      orderNumberPrefix: json['order_number_prefix'],
      manualCloseUntil: json['manual_close_until'] != null
          ? DateTime.parse(json['manual_close_until'])
          : null,
      responsibleName: json['responsible_name'],
      responsiblePhone: json['responsible_phone'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      metaTitle: json['meta_title'],
      metaDescription: json['meta_description'],
      ratingAverage: json['rating_average']?.toDouble(),
      ratingCount: json['rating_count'] as int?,
      fileKey: json['file_key'],
      bannerFileKey: json['banner_file_key'],
      isActive: json['is_active'] ?? true,
      isSetupComplete: json['is_setup_complete'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      verificationStatus: json['verification_status'] ?? 'UNVERIFIED',
      internalNotes: json['internal_notes'],
      instagram: json['instagram'],
      facebook: json['facebook'],
      tiktok: json['tiktok'],
      storeUrl: json['store_url'],
      image: json['image_path'] != null ? ImageModel(url: json['image_path']) : null,
      banner: json['banner_path'] != null ? ImageModel(url: json['banner_path']) : null,
      paymentMethodGroups: (json['payment_method_groups'] as List<dynamic>?)
          ?.map((e) => PaymentMethodGroup.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      hours: (json['hours'] as List<dynamic>?)
          ?.map((e) => StoreHour.fromJson(e))
          .toList() ?? [],
      deliveryOptions: json['delivery_config'] != null
          ? DeliveryOptionsModel.fromJson(json['delivery_config'])
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
      storeSettings: json['store_settings'] != null
          ? StoreSettings.fromJson(json['store_settings'])
          : null,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url_slug': urlSlug,
      'description': description,
      'phone': phone,
      'cnpj': cnpj,
      'segment_id': segmentId,
      'zip_code': zipCode,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'complement': complement,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_radius_km': deliveryRadiusKm,
      'average_preparation_time': averagePreparationTime,
      'order_number_prefix': orderNumberPrefix,
      'manual_close_until': manualCloseUntil?.toIso8601String(),
      'responsible_name': responsibleName,
      'responsible_phone': responsiblePhone,
      'tags': tags,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'rating_average': ratingAverage,
      'rating_count': ratingCount,
      'file_key': fileKey,
      'banner_file_key': bannerFileKey,
      'is_active': isActive,
      'is_setup_complete': isSetupComplete,
      'is_featured': isFeatured,
      'verification_status': verificationStatus,
      'internal_notes': internalNotes,
      'instagram': instagram,
      'facebook': facebook,
      'tiktok': tiktok,
      'store_url': storeUrl,
      'image_path': image?.url,
      'banner_path': banner?.url,
    };
  }

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'name': name,
      'url_slug': urlSlug,
      'description': description,
      'phone': phone,
      'cnpj': cnpj,
      'segment_id': segmentId,
      'zip_code': zipCode,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'complement': complement,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_radius_km': deliveryRadiusKm,
      'average_preparation_time': averagePreparationTime,
      'order_number_prefix': orderNumberPrefix,
      'manual_close_until': manualCloseUntil?.toIso8601String(),
      'responsible_name': responsibleName,
      'responsible_phone': responsiblePhone,
      'tags': tags?.join(','),
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'is_active': isActive,
      'is_setup_complete': isSetupComplete,
      'is_featured': isFeatured,
      'verification_status': verificationStatus,
      'internal_notes': internalNotes,
      'instagram': instagram,
      'facebook': facebook,
      'tiktok': tiktok,
      'store_url': storeUrl,
      if (image?.file != null)
        'image': await MultipartFile.fromFile(
          image!.file!.path,
          filename: image!.file!.name,
        ),
      if (banner?.file != null)
        'banner': await MultipartFile.fromFile(
          banner!.file!.path,
          filename: banner!.file!.name,
        ),
    });
  }

  Store copyWith({
    int? id,
    String? name,
    String? urlSlug,
    String? description,
    String? phone,
    String? cnpj,
    int? segmentId,
    String? zipCode,
    String? street,
    String? number,
    String? neighborhood,
    String? complement,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
    double? deliveryRadiusKm,
    int? averagePreparationTime,
    String? orderNumberPrefix,
    DateTime? manualCloseUntil,
    String? responsibleName,
    String? responsiblePhone,
    List<String>? tags,
    String? metaTitle,
    String? metaDescription,
    double? ratingAverage,
    int? ratingCount,
    String? fileKey,
    String? bannerFileKey,
    bool? isActive,
    bool? isSetupComplete,
    bool? isFeatured,
    String? verificationStatus,
    String? internalNotes,
    String? instagram,
    String? facebook,
    String? tiktok,
    ImageModel? image,
    ImageModel? banner,
    String? storeUrl,
    List<PaymentMethodGroup>? paymentMethodGroups,
    List<StoreHour>? hours,
    DeliveryOptionsModel? deliveryOptions,
    RatingsSummary? ratingsSummary,
    List<StoreCity>? cities,
    List<StoreNeighborhood>? neighborhoods,
    StoreSettings? storeSettings,
    SubscriptionSummary? subscription,
    List<Category>? categories,
    List<Product>? products,
    List<Variant>? variants,
    List<Coupon>? coupons,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      urlSlug: urlSlug ?? this.urlSlug,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      cnpj: cnpj ?? this.cnpj,
      segmentId: segmentId ?? this.segmentId,
      zipCode: zipCode ?? this.zipCode,
      street: street ?? this.street,
      number: number ?? this.number,
      neighborhood: neighborhood ?? this.neighborhood,
      complement: complement ?? this.complement,
      city: city ?? this.city,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      deliveryRadiusKm: deliveryRadiusKm ?? this.deliveryRadiusKm,
      averagePreparationTime: averagePreparationTime ?? this.averagePreparationTime,
      orderNumberPrefix: orderNumberPrefix ?? this.orderNumberPrefix,
      manualCloseUntil: manualCloseUntil ?? this.manualCloseUntil,
      responsibleName: responsibleName ?? this.responsibleName,
      responsiblePhone: responsiblePhone ?? this.responsiblePhone,
      tags: tags ?? this.tags,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      ratingCount: ratingCount ?? this.ratingCount,
      fileKey: fileKey ?? this.fileKey,
      bannerFileKey: bannerFileKey ?? this.bannerFileKey,
      isActive: isActive ?? this.isActive,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
      isFeatured: isFeatured ?? this.isFeatured,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      internalNotes: internalNotes ?? this.internalNotes,
      instagram: instagram ?? this.instagram,
      facebook: facebook ?? this.facebook,
      tiktok: tiktok ?? this.tiktok,
      image: image ?? this.image,
      banner: banner ?? this.banner,
      storeUrl: storeUrl ?? this.storeUrl,
      paymentMethodGroups: paymentMethodGroups ?? this.paymentMethodGroups,
      hours: hours ?? this.hours,
      deliveryOptions: deliveryOptions ?? this.deliveryOptions,
      ratingsSummary: ratingsSummary ?? this.ratingsSummary,
      cities: cities ?? this.cities,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      storeSettings: storeSettings ?? this.storeSettings,
      subscription: subscription ?? this.subscription,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      variants: variants ?? this.variants,
      coupons: coupons ?? this.coupons,
    );
  }
}
