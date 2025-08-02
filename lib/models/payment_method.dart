// Em: lib/models/payment_method.dart

import 'package:equatable/equatable.dart';

// --- Nível 1: A Configuração da Loja (O que foi ativado) ---
// Corresponde ao schema 'StorePaymentMethodActivationOut' do Pydantic
class StorePaymentMethodActivation extends Equatable {
  final int id;
  final bool isActive;
  final double feePercentage;
  final Map<String, dynamic>? details; // Para a chave Pix, etc.
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

  // Factory para criar a partir de um JSON
  factory StorePaymentMethodActivation.fromJson(Map<String, dynamic> json) {
    return StorePaymentMethodActivation(
      id: json['id'],
      isActive: json['is_active'],
      feePercentage: (json['fee_percentage'] as num).toDouble(),
      details: json['details'] != null ? Map<String, dynamic>.from(json['details']) : null,
      isForDelivery: json['is_for_delivery'],
      isForPickup: json['is_for_pickup'],
      isForInStore: json['is_for_in_store'],
    );
  }
  // ✅ ADICIONE ESTE MÉTODO
  // Converte o objeto Dart para um Map JSON que o backend entende
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

  // ✅ ADICIONE ESTE MÉTODO COMPLETO
  /// Cria uma cópia deste objeto, mas com os valores fornecidos.
  StorePaymentMethodActivation copyWith({
    int? id,
    bool? isActive,
    double? feePercentage,
    Map<String, dynamic>? details,
    bool? isForDelivery,
    bool? isForPickup,
    bool? isForInStore,
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
  // Equatable props para comparações
  @override
  List<Object?> get props => [id, isActive, feePercentage, details, isForDelivery, isForPickup, isForInStore];
}


// --- Nível 2: A Opção Final (O Método de Pagamento) ---
// Corresponde ao schema 'PlatformPaymentMethodOut'
class PlatformPaymentMethod extends Equatable {
  final int id;
  final String name;
  final String? iconKey;

  // Aninha a configuração específica da loja dentro do método
  // Pode ser nulo se a loja nunca configurou este método
  final StorePaymentMethodActivation? activation;

  const PlatformPaymentMethod({
    required this.id,
    required this.name,
    this.iconKey,
    this.activation,
  });

  factory PlatformPaymentMethod.fromJson(Map<String, dynamic> json) {
    return PlatformPaymentMethod(
      id: json['id'],
      name: json['name'],
      iconKey: json['icon_key'],
      // Verifica se a ativação não é nula antes de tentar parsear
      activation: json['activation'] != null
          ? StorePaymentMethodActivation.fromJson(json['activation'])
          : null,
    );
  }

  @override
  List<Object?> get props => [id, name, iconKey, activation];
}


// --- Nível 3: A Categoria ---
// Corresponde ao schema 'PaymentMethodCategoryOut'
class PaymentMethodCategory extends Equatable {
  final String name;
  final List<PlatformPaymentMethod> methods;

  const PaymentMethodCategory({
    required this.name,
    required this.methods,
  });

  factory PaymentMethodCategory.fromJson(Map<String, dynamic> json) {
    // Mapeia a lista de métodos
    final methodsList = (json['methods'] as List)
        .map((methodJson) => PlatformPaymentMethod.fromJson(methodJson))
        .toList();

    return PaymentMethodCategory(
      name: json['name'],
      methods: methodsList,
    );
  }

  @override
  List<Object?> get props => [name, methods];
}


// --- Nível 4: O Grupo Principal ---
// Corresponde ao schema 'PaymentMethodGroupOut'
class PaymentMethodGroup extends Equatable {
  final String name;
  final List<PaymentMethodCategory> categories;

  const PaymentMethodGroup({
    required this.name,
    required this.categories,
  });

  factory PaymentMethodGroup.fromJson(Map<String, dynamic> json) {
    // Mapeia a lista de categorias
    final categoriesList = (json['categories'] as List)
        .map((categoryJson) => PaymentMethodCategory.fromJson(categoryJson))
        .toList();

    return PaymentMethodGroup(
      name: json['name'],
      categories: categoriesList,
    );
  }

  @override
  List<Object?> get props => [name, categories];
}