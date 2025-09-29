import 'package:dio/dio.dart';

class StoreNeighborhood {
  const StoreNeighborhood({
    this.id,
    required this.name,
    this.cityId,
    this.deliveryFee = 0,
    this.freeDelivery = false,
    this.isActive = true,
  });

  final int? id;
  final String name;
  final int? cityId;
  final int deliveryFee;
  final bool freeDelivery;
  final bool isActive;

  factory StoreNeighborhood.fromJson(Map<String, dynamic> json) {
    return StoreNeighborhood(
      id: json['id'] as int?,
      name: json['name'] as String,
      cityId: json['city_id'] as int?,
      deliveryFee: json['delivery_fee'] as int,
      freeDelivery: json['free_delivery'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'city_id': cityId,
      'delivery_fee': deliveryFee,
      'free_delivery': freeDelivery,
      'is_active': isActive,
    };
  }

  FormData toFormData() {
    return FormData.fromMap({
      'name': name,
      'city_id': cityId,
      'delivery_fee': deliveryFee,
      'free_delivery': freeDelivery,
      'is_active': isActive,
    });
  }

  StoreNeighborhood copyWith({
    int? id,
    String? name,
    int? cityId,
    int? deliveryFee,
    bool? freeDelivery,
    bool? isActive,
  }) {
    return StoreNeighborhood(
      id: id ?? this.id,
      name: name ?? this.name,
      cityId: cityId ?? this.cityId,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      freeDelivery: freeDelivery ?? this.freeDelivery,
      isActive: isActive ?? this.isActive,
    );
  }
}
