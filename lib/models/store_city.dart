import 'package:dio/dio.dart';
import 'package:totem_pro_admin/models/store_neig.dart';



class StoreCity {
  const StoreCity( {
    this.id,
    this.isActive = true,
    required this.name,
    this.deliveryFee = 0,
    this.neighborhoods = const [],
  });

  final int? id;
  final String name;
  final int deliveryFee;
  final bool isActive;

  final List<StoreNeighborhood> neighborhoods;

  factory StoreCity.fromJson(Map<String, dynamic> json) {
    return StoreCity(
      id: json['id'] as int?,
      name: json['name'] as String,
      deliveryFee: json['delivery_fee'] as int,
      isActive: json['is_active'] as bool,

      neighborhoods: (json['neighborhoods'] as List<dynamic>?)
          ?.map((e) => StoreNeighborhood.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'delivery_fee': deliveryFee,
      'is_active': isActive,

      'neighborhoods': neighborhoods.map((e) => e.toJson()).toList(),
    };
  }

  FormData toFormData() {
    return FormData.fromMap({
      'name': name,
      'delivery_fee': deliveryFee,
      'is_active': isActive

    });
  }

  StoreCity copyWith({
    int? id,
    String? name,
    int? deliveryFee,
    bool? isActive,

    List<StoreNeighborhood>? neighborhoods,
  }) {
    return StoreCity(
      id: id ?? this.id,
      name: name ?? this.name,
      deliveryFee: deliveryFee ?? this.deliveryFee,
   isActive: isActive ?? this.isActive,
     neighborhoods: neighborhoods ?? this.neighborhoods,
    );
  }
}
