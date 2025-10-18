import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/catalog_product.dart';
import 'package:totem_pro_admin/core/enums/product_type.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/option_group.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/flavor_price.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/core/enums/product_status.dart';
import 'package:totem_pro_admin/models/products/prodcut_category_links.dart';
import 'package:totem_pro_admin/models/products/product.dart';
import 'package:totem_pro_admin/models/products/product_variant_link.dart';

enum SearchStatus { initial, loading, success, failure }

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

  // Campos para modo de edição
  final bool isEditMode;
  final int? editingProductId;
  final List<int> deletedImageIds;

  // Campos para unificação com "Sabores"
  final Category? parentCategory;
  final OptionGroup? priceVariationGroup;

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
    this.isEditMode = false,
    this.editingProductId,
    this.deletedImageIds = const [],
    this.parentCategory,
    this.priceVariationGroup,
  });

  // Factory para criação de produto simples
  factory ProductWizardState.initial() {
    return ProductWizardState(
      productInCreation: Product(
        status: ProductStatus.ACTIVE,
        images: const [],
        price: 0,
        productType: ProductType.PREPARED,
      ),
    );
  }

  // Factory para modo de edição (serve para simples e sabores)
  factory ProductWizardState.forEditing(Product product, {Category? parentCategory}) {
    OptionGroup? priceGroup;
    Product productWithPrices = product;

    // Se for edição de um sabor, calcula a estrutura de preços
    if (parentCategory != null) {
      priceGroup = parentCategory.optionGroups.firstWhere(
            (g) => g.minSelection == 1 && g.maxSelection == 1,
        orElse: () => const OptionGroup(name: 'Variação', items: []),
      );
      final priceMap = {for (var p in product.prices) p.sizeOptionId: p};
      final prices = priceGroup.items.map((option) {
        return priceMap[option.id] ?? FlavorPrice(sizeOptionId: option.id!, price: 0);
      }).toList();
      productWithPrices = product.copyWith(prices: prices);
    }

    return ProductWizardState(
      isEditMode: true,
      editingProductId: product.id,
      productInCreation: productWithPrices,
      categoryLinks: product.categoryLinks,
      variantLinks: product.variantLinks ?? [],
      productType: product.productType,
      parentCategory: parentCategory,
      priceVariationGroup: priceGroup,
      currentStep: parentCategory != null ? 10 : 2, // 10 para UI de abas, 2 para wizard normal
      catalogProductSelected: true, // Em edição, o formulário sempre aparece
    );
  }

  // Factory para criação de um novo sabor
  factory ProductWizardState.forFlavorCreation(Category parentCategory) {
    final priceGroup = parentCategory.optionGroups.firstWhere(
          (g) => g.minSelection == 1 && g.maxSelection == 1,
      orElse: () => const OptionGroup(name: 'Variação', items: []),
    );
    final prices = priceGroup.items.map((option) =>
        FlavorPrice(sizeOptionId: option.id!, price: 0)).toList();

    return ProductWizardState(
      parentCategory: parentCategory,
      priceVariationGroup: priceGroup,
      productInCreation: Product(
        status: ProductStatus.ACTIVE,
        images: const [],
        price: 0,
        prices: prices,
        productType: ProductType.PREPARED, // Sabores são, por padrão, preparados
      ),
      currentStep: 10, // Pula direto para a UI de abas
      catalogProductSelected: true, // Mostra o formulário direto
      isImported: false, // Um sabor novo nunca é importado
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
    FormStatus? submissionStatus,
    List<ProductCategoryLink>? categoryLinks,
    String? errorMessage,
    String? searchQuery,
    bool? isEditMode,
    int? editingProductId,
    List<int>? deletedImageIds,
    Category? parentCategory,
    OptionGroup? priceVariationGroup,
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
      parentCategory: parentCategory ?? this.parentCategory,
      priceVariationGroup: priceVariationGroup ?? this.priceVariationGroup,
    );
  }

  @override
  List<Object?> get props => [
    currentStep, productType, productInCreation, searchStatus,
    searchResults, catalogProductSelected, isImported, variantLinks,
    submissionStatus, categoryLinks, errorMessage, searchQuery, isEditMode,
    editingProductId, deletedImageIds, parentCategory, priceVariationGroup,
  ];
}