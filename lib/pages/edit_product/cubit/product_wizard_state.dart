import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/catalog_product.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

import '../../../models/image_model.dart';
import '../../../models/product_variant_link.dart';

enum ProductType { PREPARED, INDUSTRIALIZED, UNKNOWN }
enum SearchStatus { initial, loading, success, failure }

class ProductWizardState extends Equatable {
  final int currentStep;
  final ProductType productType;
  final Product productInCreation;
  final SearchStatus searchStatus;
  final List<CatalogProduct> searchResults;
  final bool catalogProductSelected;
  final bool isImported; // ✅ NOVO: Flag para saber se o produto foi importado
  final List<ProductVariantLink> variantLinks;

  const ProductWizardState({
    this.currentStep = 1,
    this.productType = ProductType.PREPARED,
    required this.productInCreation,
    this.searchStatus = SearchStatus.initial,
    this.searchResults = const [],
    this.catalogProductSelected = false,
    this.isImported = false, // ✅ Inicia como falso
    this.variantLinks = const [],
  });

  factory ProductWizardState.initial() {
    return ProductWizardState(
      productInCreation: Product(available: true,  image: ImageModel()),
      variantLinks: [],
    );
  }

  ProductWizardState copyWith({
    int? currentStep,
    ProductType? productType,
    Product? productInCreation,
    SearchStatus? searchStatus,
    List<CatalogProduct>? searchResults,
    bool? catalogProductSelected,
    bool? isImported,
    List<ProductVariantLink>? variantLinks,
  }) {
    return ProductWizardState(
      currentStep: currentStep ?? this.currentStep,
      productType: productType ?? this.productType,
      productInCreation: productInCreation ?? this.productInCreation,
      searchStatus: searchStatus ?? this.searchStatus,
      searchResults: searchResults ?? this.searchResults,
      catalogProductSelected: catalogProductSelected ?? this.catalogProductSelected,
      isImported: isImported ?? this.isImported, // ✅
      variantLinks: variantLinks ?? this.variantLinks, //
    );
  }

  @override
  List<Object?> get props => [currentStep, productType, productInCreation, searchStatus, searchResults, catalogProductSelected, isImported, variantLinks];
}
