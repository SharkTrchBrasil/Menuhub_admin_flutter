
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/catalog_product.dart';

import 'package:totem_pro_admin/models/product_variant_link.dart';
import 'package:totem_pro_admin/core/enums/product_type.dart';
import 'package:totem_pro_admin/models/image_model.dart';

import '../../../core/enums/form_status.dart';
import '../../../models/prodcut_category_links.dart';



class ProductWizardState extends Equatable {
  final int currentStep;
  final ProductType productType;
  final Product productInCreation;
  final SearchStatus searchStatus;
  final List<CatalogProduct> searchResults;
  final bool catalogProductSelected;
  final bool isImported;
  final List<ProductVariantLink> variantLinks;
  final FormStatus submissionStatus;

  // ✅ CAMPO QUE ESTAVA FALTANDO
  final List<ProductCategoryLink> categoryLinks;
  // ✅ CAMPO QUE ESTAVA FALTANDO
  final String? errorMessage;

  const ProductWizardState({
    this.currentStep = 1,
    this.productType = ProductType.PREPARED,
    required this.productInCreation,
    this.searchStatus = SearchStatus.initial,
    this.searchResults = const [],
    this.catalogProductSelected = false,
    this.isImported = false,
    this.variantLinks = const [],
    this.submissionStatus = FormStatus.initial,
    this.categoryLinks = const [], // ✅ ADICIONADO
    this.errorMessage,             // ✅ ADICIONADO
  });

  factory ProductWizardState.initial() {
    return ProductWizardState(
      productInCreation: Product(available: true, image: ImageModel(), price: 0),
    );
  }

  // ✅ ADICIONE ESTE GETTER NO FINAL DA CLASSE
  /// Retorna `true` se o estado atual for diferente do estado inicial.
  bool get isDirty => this != ProductWizardState.initial();


  ProductWizardState copyWith({
    int? currentStep,
    ProductType? productType,
    Product? productInCreation,
    SearchStatus? searchStatus,
    List<CatalogProduct>? searchResults,
    bool? catalogProductSelected,
    bool? isImported,
    List<ProductVariantLink>? variantLinks,
    FormStatus? submissionStatus,
    List<ProductCategoryLink>? categoryLinks, // ✅ ADICIONADO
    String? errorMessage,                      // ✅ ADICIONADO
  }) {
    return ProductWizardState(
      currentStep: currentStep ?? this.currentStep,
      productType: productType ?? this.productType,
      productInCreation: productInCreation ?? this.productInCreation,
      searchStatus: searchStatus ?? this.searchStatus,
      searchResults: searchResults ?? this.searchResults,
      catalogProductSelected: catalogProductSelected ?? this.catalogProductSelected,
      isImported: isImported ?? this.isImported,
      variantLinks: variantLinks ?? this.variantLinks,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      categoryLinks: categoryLinks ?? this.categoryLinks,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    currentStep, productType, productInCreation, searchStatus,
    searchResults, catalogProductSelected, isImported, variantLinks,
    submissionStatus, categoryLinks, errorMessage
  ];
}