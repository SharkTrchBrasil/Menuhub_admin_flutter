import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/product.dart'; // Importa o modelo Product

class KitComponent extends Equatable {
  final int kitProductId;
  final int componentProductId;
  final int quantity;
  // O backend envia o objeto do componente aninhado, então o modelamos aqui
  final Product component;

  const KitComponent({
    required this.kitProductId,
    required this.componentProductId,
    required this.quantity,
    required this.component,
  });

  factory KitComponent.fromJson(Map<String, dynamic> json) {
    return KitComponent(
      kitProductId: json['kit_product_id'],
      componentProductId: json['component_product_id'],
      quantity: json['quantity'],
      // Parseia o objeto Product aninhado
      component: Product.fromJson(json['component']),
    );
  }

  @override
  List<Object?> get props => [kitProductId, componentProductId, quantity, component];
}