import 'package:equatable/equatable.dart';


class CloneOptions extends Equatable {
  final bool cloneProducts;
  final bool cloneCategories;
  final bool cloneOperationConfig;
  final bool clonePaymentMethods;
  final bool cloneTheme;

  const CloneOptions({
    this.cloneProducts = true,
    this.cloneCategories = true,
    this.cloneOperationConfig = true,
    this.clonePaymentMethods = true,
    this.cloneTheme = true,
  });

  CloneOptions copyWith({
    bool? cloneProducts,
    bool? cloneCategories,
    bool? cloneOperationConfig,
    bool? clonePaymentMethods,
    bool? cloneTheme,
  }) {
    return CloneOptions(
      cloneProducts: cloneProducts ?? this.cloneProducts,
      cloneCategories: cloneCategories ?? this.cloneCategories,
      cloneOperationConfig: cloneOperationConfig ?? this.cloneOperationConfig,
      clonePaymentMethods: clonePaymentMethods ?? this.clonePaymentMethods,
      cloneTheme: cloneTheme ?? this.cloneTheme,
    );
  }

  Map<String, bool> toMap() {
    return {
      'products': cloneProducts,
      'categories': cloneCategories,
      'operation_config': cloneOperationConfig,
      'payment_methods': clonePaymentMethods,
      'theme': cloneTheme,
    };
  }

  @override
  List<Object?> get props => [
    cloneProducts,
    cloneCategories,
    cloneOperationConfig,
    clonePaymentMethods,
    cloneTheme
  ];
}