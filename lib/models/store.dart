import 'package:flutter/cupertino.dart';
import 'package:totem_pro_admin/models/delivery_options.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/models/rating_summary.dart';
import 'package:totem_pro_admin/models/store_city.dart';
import 'package:totem_pro_admin/models/store_hour.dart';
import 'package:totem_pro_admin/models/store_neig.dart';
import 'package:totem_pro_admin/models/store_settings.dart';
import 'image_model.dart';
import 'package:dio/dio.dart';

class Store {
  Store({
    this.id,
    this.name = '',
    this.phone = '',
    this.image,
    this.banner,
    this.zip_code,
    this.street,
    this.number,
    this.neighborhood,
    this.complement,
    this.reference,
    this.city,
    this.state,
    this.instagram,
    this.facebook,
    this.tiktok,
    this.description,
    this.store_url,
    this.paymentMethods = const [],
    this.hours = const [],
    this.deliveryOptions,
    this.ratingsSummary,
    this.cities,
    this.neighborhoods,
    this.storeSettings,
  });

  final int? id;
  final String name;
  final String phone;
  final String? store_url;
  // Endereço
  final String? zip_code;
  final String? street;
  final String? number;
  final String? neighborhood;
  final String? complement;
  final String? reference;
  final String? city;
  final String? state;
  final String? description;

  // Redes sociais
  final String? instagram;
  final String? facebook;
  final String? tiktok;
  final ImageModel? image;
  final ImageModel? banner;

  final List<StorePaymentMethod> paymentMethods;
  final List<StoreHour> hours;
  final DeliveryOptionsModel? deliveryOptions;
  RatingsSummary? ratingsSummary;
  final List<StoreCity>? cities; // NOVO: Adicionar aqui
  final List<StoreNeighborhood>? neighborhoods; // NOVO: Adicionar aqui
  final StoreSettings? storeSettings;

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as int?,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      zip_code: json['zip_code'],
      street: json['street'],
      number: json['number'],
      neighborhood: json['neighborhood'],
      complement: json['complement'],
      reference: json['reference'],
      city: json['city'],
      state: json['state'],
      instagram: json['instagram'],
      facebook: json['facebook'],
      tiktok: json['tiktok'],
      store_url: json['store_url'],
      description: json['description'],
      image: ImageModel(url: json['image_path']),
      banner: ImageModel(url: json['banner_path']),

      paymentMethods:
          (json['payment_methods'] as List<dynamic>?)
              ?.map((e) => StorePaymentMethod.fromJson(e))
              .toList() ??
          [],
      hours:
          (json['hours'] as List<dynamic>?)
              ?.map((e) => StoreHour.fromJson(e))
              .toList() ??
          [],
      deliveryOptions:
          json['delivery_config'] != null
              ? DeliveryOptionsModel.fromJson(json['delivery_config'])
              : null,

      ratingsSummary:
          json['ratingsSummary'] != null
              ? RatingsSummary.fromMap(json['ratingsSummary'])
              : null,

      cities:
          (json['cities']
                  as List<dynamic>?) // NOVO: Parsear cities da raiz da Store
              ?.map((e) => StoreCity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      neighborhoods:
          (json['neighborhoods']
                  as List<
                    dynamic
                  >?) // NOVO: Parsear neighborhoods da raiz da Store
              ?.map(
                (e) => StoreNeighborhood.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],

      storeSettings:
          json['store_settings'] != null
              ? StoreSettings.fromJson(json['store_settings'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'zip_code': zip_code,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'complement': complement,
      'reference': reference,
      'city': city,
      'state': state,
      'instagram': instagram,
      'facebook': facebook,
      'tiktok': tiktok,
      'store_url': store_url,
      'description': description,
    };
  }

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'name': name,
      'phone': phone,
      'zip_code': zip_code,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'complement': complement,
      'reference': reference,
      'city': city,
      'state': state,
      'instagram': instagram,
      'facebook': facebook,
      'tiktok': tiktok,
      'description': description,

      if (image?.file != null)
        'image': MultipartFile.fromBytes(
          await image!.file!.readAsBytes(),
          filename: image!.file!.name,
        ),

      if (banner?.file != null)
        'banner': MultipartFile.fromBytes(
          await banner!.file!.readAsBytes(),
          filename: banner!.file!.name,
        ),
    });
  }

  Store copyWith({
    int? id,
    String? name,
    String? phone,
    String? zip_code,
    String? street,
    String? number,
    String? neighborhood,
    String? complement,
    String? reference,
    String? city,
    String? state,
    String? instagram,
    String? facebook,
    String? tiktok,
    ImageModel? image,
    ImageModel? banner,
    String? description,
    String? store_url,
    List<StorePaymentMethod>? paymentMethods,
    List<StoreHour>? hours,
    DeliveryOptionsModel? deliveryOptions,
    RatingsSummary? ratingsSummary,
    List<StoreCity>? cities,
    List<StoreNeighborhood>? neighborhoods,
    StoreSettings? storeSettings,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      zip_code: zip_code ?? this.zip_code,
      street: street ?? this.street,
      number: number ?? this.number,
      neighborhood: neighborhood ?? this.neighborhood,
      complement: complement ?? this.complement,
      reference: reference ?? this.reference,
      city: city ?? this.city,
      state: state ?? this.state,
      instagram: instagram ?? this.instagram,
      facebook: facebook ?? this.facebook,
      tiktok: tiktok ?? this.tiktok,
      description: description ?? this.description,
      image: image ?? this.image,
      banner: banner ?? this.banner,
      store_url: store_url ?? this.store_url,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      hours: hours ?? this.hours,
      deliveryOptions: deliveryOptions ?? this.deliveryOptions,
      ratingsSummary: ratingsSummary ?? this.ratingsSummary,
      cities: cities ?? this.cities,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      storeSettings: storeSettings ?? this.storeSettings,
    );
  }
}
