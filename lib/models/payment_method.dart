// Em: lib/models/payment_method.dart

import 'package:equatable/equatable.dart';

// --- Nível 1: A Configuração da Loja ---
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
      id: json['id'] ?? 0, // Garante que não seja nulo
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

  // ✅ copyWith JÁ EXISTIA AQUI, ESTÁ CORRETO
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
      id: 0,
      isActive: false, // Começa desativado por padrão
      feePercentage: 0.0,
      details: {}, // Um mapa vazio é mais seguro que nulo
      isForDelivery: true,
      isForPickup: true,
      isForInStore: true,
    );
  }

  @override
  List<Object?> get props => [id, isActive, feePercentage, details, isForDelivery, isForPickup, isForInStore];
}



class PlatformPaymentMethod extends Equatable {
  final int id;
  final String name;
  final String? iconKey;

  // ✅ ADICIONADO: O tipo do método, que já existia no JSON
  final String methodType;

  // ✅ ADICIONADO: O novo campo booleano do backend
  final bool requiresDetails;

  final StorePaymentMethodActivation? activation;

  const PlatformPaymentMethod({
    required this.id,
    required this.name,
    this.iconKey,
    required this.methodType, // ✅ Adicionado ao construtor
    required this.requiresDetails, // ✅ Adicionado ao construtor
    this.activation,
  });

  factory PlatformPaymentMethod.fromJson(Map<String, dynamic> json) {
    return PlatformPaymentMethod(
      id: json['id'],
      name: json['name'],
      iconKey: json['icon_key'],

      // ✅ Adicionado ao parser do JSON
      methodType: json['method_type'],

      // ✅ Adicionado ao parser do JSON (com um valor padrão para segurança)
      requiresDetails: json['requires_details'] ?? false,

      activation: json['activation'] != null
          ? StorePaymentMethodActivation.fromJson(json['activation'])
          : null,
    );
  }

  PlatformPaymentMethod copyWith({
    int? id,
    String? name,
    String? iconKey,
    String? methodType, // ✅ Adicionado ao copyWith
    bool? requiresDetails, // ✅ Adicionado ao copyWith
    StorePaymentMethodActivation? activation,
  }) {
    return PlatformPaymentMethod(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      methodType: methodType ?? this.methodType, // ✅ Adicionado ao copyWith
      requiresDetails: requiresDetails ?? this.requiresDetails, // ✅ Adicionado ao copyWith
      activation: activation ?? this.activation,
    );
  }

  PlatformPaymentMethod deepCopy() => PlatformPaymentMethod(
    id: id,
    name: name,
    iconKey: iconKey,
    methodType: methodType, // ✅ Adicionado ao deepCopy
    requiresDetails: requiresDetails, // ✅ Adicionado ao deepCopy
    activation: activation?.copyWith(),
  );

  @override
  // ✅ Adicionado os novos campos às props para o Equatable funcionar corretamente
  List<Object?> get props => [id, name, iconKey, methodType, requiresDetails, activation];
}



// --- Nível 3: A Categoria ---
class PaymentMethodCategory extends Equatable {
  final String name;
  final List<PlatformPaymentMethod> methods;

  const PaymentMethodCategory({ required this.name, required this.methods });

  factory PaymentMethodCategory.fromJson(Map<String, dynamic> json) {
    final methodsList = (json['methods'] as List)
        .map((methodJson) => PlatformPaymentMethod.fromJson(methodJson))
        .toList();
    return PaymentMethodCategory( name: json['name'], methods: methodsList );
  }

  // ✅ ADICIONADO copyWith E deepCopy
  PaymentMethodCategory copyWith({ String? name, List<PlatformPaymentMethod>? methods }) {
    return PaymentMethodCategory(
      name: name ?? this.name,
      methods: methods ?? this.methods,
    );
  }

  PaymentMethodCategory deepCopy() => PaymentMethodCategory(
    name: name,
    methods: methods.map((m) => m.deepCopy()).toList(),
  );

  @override
  List<Object?> get props => [name, methods];
}


// --- Nível 4: O Grupo Principal ---
class PaymentMethodGroup extends Equatable {
  final String name;
  final String title; // ✅ Novo campo
  final String description;
  final List<PaymentMethodCategory> categories;

  const PaymentMethodGroup({
    required this.name,
    required this.title, // ✅ Novo campo
    required this.description,
    required this.categories,
  });

  factory PaymentMethodGroup.fromJson(Map<String, dynamic> json) {
    final categoriesList = (json['categories'] as List)
        .map((categoryJson) => PaymentMethodCategory.fromJson(categoryJson))
        .toList();

    return PaymentMethodGroup(
      name: json['name'],
      title: json['title'] ?? '', // ✅ Novo campo
      description: json['description'] ?? "",
      categories: categoriesList,
    );
  }

  // ✅ copyWith atualizado
  PaymentMethodGroup copyWith({
    String? name,
    String? title,
    String? description,
    List<PaymentMethodCategory>? categories,
  }) {
    return PaymentMethodGroup(
      name: name ?? this.name,
      title: title ?? this.title, // ✅ Novo campo
      description: description ?? this.description,
      categories: categories ?? this.categories,
    );
  }

  // ✅ deepCopy atualizado
  PaymentMethodGroup deepCopy() => PaymentMethodGroup(
    name: name,
    title: title, // ✅ Novo campo
    description: description,
    categories: categories.map((c) => c.deepCopy()).toList(),
  );

  @override
  List<Object?> get props => [name, title, description, categories]; // ✅ Incluído
}
