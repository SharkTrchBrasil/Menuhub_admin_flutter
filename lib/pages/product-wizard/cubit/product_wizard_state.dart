
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/catalog_product.dart';

import 'package:totem_pro_admin/models/product_variant_link.dart';
import 'package:totem_pro_admin/core/enums/product_type.dart';
import 'package:totem_pro_admin/models/image_model.dart';

import '../../../core/enums/form_status.dart';
import '../../../core/enums/product_status.dart';
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


  final List<ProductCategoryLink> categoryLinks;

  final String? errorMessage;
  final String searchQuery;

  // ✅ CAMPOS ADICIONADOS PARA O MODO DE EDIÇÃO
  final bool isEditMode;
  final int? editingProductId;

  final List<int> deletedImageIds;

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
    this.categoryLinks = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.isEditMode = false, // ✅ Valor padrão
    this.editingProductId,
    this.deletedImageIds = const [],

  });

  factory ProductWizardState.initial() {
    return ProductWizardState(
      productInCreation: Product(status: ProductStatus.ACTIVE, images: const [], price: 0),

    );
  }


  bool get isDirty => this != ProductWizardState.initial();
  //    Ele calcula a validade dinamicamente a partir do estado atual.
  bool get isStep2Valid => productInCreation.name.trim().isNotEmpty;


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
    List<ProductCategoryLink>? categoryLinks,
    String? errorMessage,
    String? searchQuery,
    bool? isEditMode,
    int? editingProductId,
    List<int>? deletedImageIds,

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
      searchQuery: searchQuery ?? this.searchQuery,
      isEditMode: isEditMode ?? this.isEditMode,
      editingProductId: editingProductId ?? this.editingProductId,
      deletedImageIds: deletedImageIds ?? this.deletedImageIds,

    );
  }

  @override
  List<Object?> get props => [
    currentStep, productType, productInCreation, searchStatus,
    searchResults, catalogProductSelected, isImported, variantLinks,
    submissionStatus, categoryLinks, errorMessage,searchQuery, isEditMode,
    editingProductId,
    deletedImageIds,
  ];
}