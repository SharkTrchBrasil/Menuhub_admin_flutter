import 'package:dio/dio.dart';
import 'package:totem_pro_admin/models/store/store_neig.dart';

class StoreCity {
  const StoreCity({
    this.id,
    this.isActive = true,
    required this.name,
    this.deliveryFee = 0,
    this.neighborhoods = const [],
  });

  final int? id;
  final String name;
  final int deliveryFee; // Mantido como int para bater com o backend
  final bool isActive;
  final List<StoreNeighborhood> neighborhoods;

  factory StoreCity.fromJson(Map<String, dynamic> json) {
    return StoreCity(
      id: json['id'] as int?,
      name: json['name'] as String,
      deliveryFee: (json['delivery_fee'] as num).toInt(), // Conversão segura
      isActive: json['is_active'] as bool,
      neighborhoods: (json['neighborhoods'] as List<dynamic>?)
          ?.map((e) => StoreNeighborhood.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // O 'id' é enviado para o backend saber se é create ou update
      'id': id,
      'name': name,
      'delivery_fee': deliveryFee,
      'is_active': isActive,
      // A parte mais importante: enviar a lista de bairros!
      'neighborhoods': neighborhoods.map((e) => e.toJson()).toList(),
    };
  }

  // Este método não será mais usado para salvar a cidade com bairros.
  // Pode mantê-lo para outros usos ou remover se não for mais necessário.
  FormData toFormData() {
    return FormData.fromMap({
      'name': name,
      'delivery_fee': deliveryFee,
      'is_active': isActive,
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