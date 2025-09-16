




import '../../../core/enums/form_status.dart';
import '../../../models/category.dart';
import '../../../models/prodcut_category_links.dart';
import '../../../models/product.dart';

import 'package:equatable/equatable.dart';

class BulkAddToCategoryState extends Equatable {
  final List<Product> selectedProducts;
  final Category? targetCategory;
  final Map<int, Map<String, dynamic>> priceUpdates;
  final FormStatus status;
  final String? errorMessage;
  final List<ProductCategoryLink>? addResult;

  const BulkAddToCategoryState({
    required this.selectedProducts,
    this.targetCategory,
    required this.priceUpdates,
    this.status = FormStatus.initial,
    this.errorMessage,
    this.addResult,
  });

  factory BulkAddToCategoryState.initial(List<Product> products) {
    return BulkAddToCategoryState(
      selectedProducts: products,
      priceUpdates: {},
    );
  }

  BulkAddToCategoryState copyWith({
    Category? targetCategory,
    Map<int, Map<String, dynamic>>? priceUpdates,
    FormStatus? status,
    String? errorMessage,
    List<ProductCategoryLink>? addResult,
  }) {
    return BulkAddToCategoryState(
      selectedProducts: selectedProducts,
      targetCategory: targetCategory ?? this.targetCategory,
      priceUpdates: priceUpdates ?? this.priceUpdates,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      addResult: addResult,
    );
  }

  @override
  List<Object?> get props => [selectedProducts, targetCategory, priceUpdates, status, errorMessage, addResult,];
}