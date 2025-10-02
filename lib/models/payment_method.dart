// Em: lib/models/payment_method.dart

import 'package:equatable/equatable.dart';

// --- Nível 1: A Configuração da Loja (StorePaymentMethodActivation) ---
// (Esta classe não precisa de alterações, já está correta)
class StorePaymentMethodActivation extends Equatable {
  final int id;
  final bool isActive;
  final double feePercentage;
  final Map<String, dynamic>? details;
  final bool isForDelivery;
  final bool isForPickup;
  final bool isForInStore;

  const StorePaymentMethodActivation({
    required this.id,
    required this.isActive,
    required this.feePercentage,
    this.details,
    required this.isForDelivery,
    required this.isForPickup,
    required this.isForInStore,
  });

  factory StorePaymentMethodActivation.fromJson(Map<String, dynamic> json) {
    return StorePaymentMethodActivation(
      id: json['id'] ?? 0,
      isActive: json['is_active'],
      feePercentage: (json['fee_percentage'] as num).toDouble(),
      details: json['details'] != null ? Map<String, dynamic>.from(json['details']) : null,
      isForDelivery: json['is_for_delivery'],
      isForPickup: json['is_for_pickup'],
      isForInStore: json['is_for_in_store'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_active': isActive,
      'fee_percentage': feePercentage,
      'details': details,
      'is_for_delivery': isForDelivery,
      'is_for_pickup': isForPickup,
      'is_for_in_store': isForInStore,
    };
  }

  StorePaymentMethodActivation copyWith({
    int? id, bool? isActive, double? feePercentage, Map<String, dynamic>? details,
    bool? isForDelivery, bool? isForPickup, bool? isForInStore,
  }) {
    return StorePaymentMethodActivation(
      id: id ?? this.id,
      isActive: isActive ?? this.isActive,
      feePercentage: feePercentage ?? this.feePercentage,
      details: details ?? this.details,
      isForDelivery: isForDelivery ?? this.isForDelivery,
      isForPickup: isForPickup ?? this.isForPickup,
      isForInStore: isForInStore ?? this.isForInStore,
    );
  }

  factory StorePaymentMethodActivation.empty() {
    return const StorePaymentMethodActivation(
      id: 0, isActive: false, feePercentage: 0.0, details: {},
      isForDelivery: true, isForPickup: true, isForInStore: true,
    );
  }

  @override
  List<Object?> get props => [id, isActive, feePercentage, details, isForDelivery, isForPickup, isForInStore];
}

// --- Nível 2: O Método de Pagamento (PlatformPaymentMethod) ---
// (Esta classe também não precisa de alterações)
class PlatformPaymentMethod extends Equatable {
  final int id;
  final String name;
  final String? iconKey;
  final String methodType;
  final bool requiresDetails;
  final StorePaymentMethodActivation? activation;

  const PlatformPaymentMethod({
    required this.id,
    required this.name,
    this.iconKey,
    required this.methodType,
    required this.requiresDetails,
    this.activation,
  });

  factory PlatformPaymentMethod.fromJson(Map<String, dynamic> json) {
    return PlatformPaymentMethod(
      id: json['id'],
      name: json['name'],
      iconKey: json['icon_key'],
      methodType: json['method_type'],
      requiresDetails: json['requires_details'] ?? false,
      activation: json['activation'] != null
          ? StorePaymentMethodActivation.fromJson(json['activation'])
          : null,
    );
  }

  PlatformPaymentMethod copyWith({
    int? id, String? name, String? iconKey, String? methodType,
    bool? requiresDetails, StorePaymentMethodActivation? activation,
  }) {
    return PlatformPaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      methodType: methodType ?? this.methodType,
      requiresDetails: requiresDetails ?? this.requiresDetails,
      activation: activation ?? this.activation,
    );
  }

  PlatformPaymentMethod deepCopy() => PlatformPaymentMethod(
    id: id, name: name, iconKey: iconKey, methodType: methodType,
    requiresDetails: requiresDetails, activation: activation?.copyWith(),
  );

  @override
  List<Object?> get props => [id, name, iconKey, methodType, requiresDetails, activation];
}


// ✅ ================== CORREÇÃO E SIMPLIFICAÇÃO AQUI ==================
// O Grupo agora contém a lista de métodos diretamente.
class PaymentMethodGroup extends Equatable {
  final String name;
  final String title;
  final String description;
  final List<PlatformPaymentMethod> methods; // A lista de métodos está aqui!

  const PaymentMethodGroup({
    required this.name,
    required this.title,
    required this.description,
    required this.methods, // Adicionado ao construtor
  });

  factory PaymentMethodGroup.fromJson(Map<String, dynamic> json) {
    // Faz o parse da lista de métodos que agora vem diretamente no JSON do grupo.
    final methodsList = (json['methods'] as List? ?? [])
        .map((methodJson) => PlatformPaymentMethod.fromJson(methodJson))
        .toList();

    return PaymentMethodGroup(
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? "",
      methods: methodsList, // Atribui a lista parseada
    );
  }

  PaymentMethodGroup copyWith({
    String? name,
    String? title,
    String? description,
    List<PlatformPaymentMethod>? methods, // Adicionado ao copyWith
  }) {
    return PaymentMethodGroup(
      name: name ?? this.name,
      title: title ?? this.title,
      description: description ?? this.description,
      methods: methods ?? this.methods, // Adicionado ao copyWith
    );
  }

  PaymentMethodGroup deepCopy() => PaymentMethodGroup(
    name: name,
    title: title,
    description: description,
    methods: methods.map((m) => m.deepCopy()).toList(), // Garante cópia profunda
  );

  @override
  List<Object?> get props => [name, title, description, methods]; // Adicionado 'methods'
}