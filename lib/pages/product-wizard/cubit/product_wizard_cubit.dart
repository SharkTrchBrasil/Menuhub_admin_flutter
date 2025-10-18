import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/enums/beverage.dart';
import 'package:totem_pro_admin/core/enums/foodtags.dart';
import 'package:totem_pro_admin/core/enums/product_type.dart';
import 'package:totem_pro_admin/models/catalog_product.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/flavor_price.dart';
import 'package:totem_pro_admin/models/products/prodcut_category_links.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/models/products/product.dart';
import 'package:totem_pro_admin/models/products/product_variant_link.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import '../../../core/enums/form_status.dart';
import 'product_wizard_state.dart';

class ProductWizardCubit extends Cubit<ProductWizardState> {
  final ProductRepository _productRepository = getIt<ProductRepository>();
  final int storeId;
  Timer? _debounce;

  ProductWizardCubit({required this.storeId}) : super(ProductWizardState.initial());

  // INÍCIO: Métodos de controle do fluxo/wizard
  void startFlow({Product? product, Category? parentCategory}) {
    if (product != null) {
      emit(ProductWizardState.forEditing(product, parentCategory: parentCategory));
    } else if (parentCategory != null) {
      emit(ProductWizardState.forFlavorCreation(parentCategory));
    } else {
      emit(ProductWizardState.initial());
    }
  }

  void nextStep() {
    final totalSteps = state.productType == ProductType.INDUSTRIALIZED ? 3 : 4;
    if (state.currentStep < totalSteps) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }
  // FIM: Métodos de controle do fluxo/wizard

  // INÍCIO: Métodos de manipulação do objeto Product em memória
  void updateProduct(Product updatedProduct) {
    emit(state.copyWith(productInCreation: updatedProduct));
  }

  void setProductType(ProductType type) {
    final isPrepared = (type == ProductType.PREPARED);
    emit(state.copyWith(
      productType: type,
      catalogProductSelected: isPrepared,
      isImported: false,
      productInCreation: state.productInCreation.copyWith(productType: type),
      searchResults: [],
      searchStatus: SearchStatus.initial,
    ));
  }

  void selectCatalogProduct(CatalogProduct catalogProduct) {
    final images = catalogProduct.imagePath != null
        ? [ImageModel(url: catalogProduct.imagePath!.url)]
        : <ImageModel>[];

    final newProduct = state.productInCreation.copyWith(
      name: catalogProduct.name,
      description: catalogProduct.description,
      ean: catalogProduct.ean,
      images: images,
      masterProductId: catalogProduct.id,
      productType: ProductType.INDUSTRIALIZED,
    );
    emit(state.copyWith(
      productInCreation: newProduct,
      catalogProductSelected: true,
      isImported: true,
    ));
  }

  void onImagesChanged(List<ImageModel> newImageList) {
    final currentIds = newImageList.where((i) => i.id != null).map((i) => i.id!).toSet();
    final originalIds = state.productInCreation.images.where((i) => i.id != null).map((i) => i.id!).toSet();
    final deleted = originalIds.difference(currentIds);

    final updatedDeletedIds = List<int>.from(state.deletedImageIds)..addAll(deleted);

    emit(state.copyWith(
        productInCreation: state.productInCreation.copyWith(images: newImageList),
        deletedImageIds: updatedDeletedIds.toSet().toList()
    ));
  }

  void videoChanged(ImageModel? newVideo) {
    updateProduct(state.productInCreation.copyWith(
      videoFile: newVideo,
      removeVideo: newVideo == null,
    ));
  }

  void addCategoryLink(ProductCategoryLink newLink) {
    if (state.categoryLinks.any((link) => link.categoryId == newLink.categoryId)) return;
    final updatedLinks = List.of(state.categoryLinks)..add(newLink);
    emit(state.copyWith(categoryLinks: updatedLinks));
  }

  void removeCategoryLink(ProductCategoryLink link) {
    final updatedLinks = List.of(state.categoryLinks)..remove(link);
    emit(state.copyWith(categoryLinks: updatedLinks));
  }

  void updateCategoryLink(ProductCategoryLink updatedLink) {
    final index = state.categoryLinks.indexWhere((link) => link.categoryId == updatedLink.categoryId);
    if (index != -1) {
      final updatedLinks = List.of(state.categoryLinks);
      updatedLinks[index] = updatedLink;
      emit(state.copyWith(categoryLinks: updatedLinks));
    }
  }

  void toggleLinkAvailability(ProductCategoryLink linkToToggle) {
    final updatedLink = linkToToggle.copyWith(isAvailable: !linkToToggle.isAvailable);
    updateCategoryLink(updatedLink);
  }

  void updateFlavorPrice(FlavorPrice updatedPrice) {
    final updatedPrices = state.productInCreation.prices.map((p) {
      return p.sizeOptionId == updatedPrice.sizeOptionId ? updatedPrice : p;
    }).toList();
    updateProduct(state.productInCreation.copyWith(prices: updatedPrices));
  }

  void toggleDietaryTag(FoodTag tag) {
    final newTags = Set<FoodTag>.from(state.productInCreation.dietaryTags);
    newTags.contains(tag) ? newTags.remove(tag) : newTags.add(tag);
    updateProduct(state.productInCreation.copyWith(dietaryTags: newTags));
  }

  void toggleBeverageTag(BeverageTag tag) {
    final newTags = Set<BeverageTag>.from(state.productInCreation.beverageTags);
    newTags.contains(tag) ? newTags.remove(tag) : newTags.add(tag);
    updateProduct(state.productInCreation.copyWith(beverageTags: newTags));
  }

  void controlStockToggled(bool controlStock) {
    updateProduct(state.productInCreation.copyWith(
      controlStock: controlStock,
      stockQuantity: controlStock ? state.productInCreation.stockQuantity : 0,
    ));
  }

  void stockQuantityChanged(String value) {
    updateProduct(state.productInCreation.copyWith(stockQuantity: int.tryParse(value) ?? 0));
  }

  // ✅ MÉTODOS CORRIGIDOS/ADICIONADOS AQUI
  void servesUpToChanged(int? count) {
    updateProduct(state.productInCreation.copyWith(servesUpTo: count));
  }

  void weightChanged(String weight) {
    updateProduct(state.productInCreation.copyWith(weight: int.tryParse(weight)));
  }

  void unitChanged(String unit) {
    updateProduct(state.productInCreation.copyWith(unit: unit));
  }

  void addVariantLink(ProductVariantLink newLink) {
    if (state.variantLinks.any((link) => link.variant.id == newLink.variant.id)) return;
    final updatedLinks = [...state.variantLinks, newLink];
    emit(state.copyWith(variantLinks: updatedLinks));
  }

  void updateVariantLink(ProductVariantLink updatedLink) {
    final updatedLinks = state.variantLinks.map((link) {
      return link.variant.id == updatedLink.variant.id ? updatedLink : link;
    }).toList();
    emit(state.copyWith(variantLinks: updatedLinks));
  }

  void removeVariantLink(ProductVariantLink linkToRemove) {
    final updatedLinks = state.variantLinks.where((link) => link.variant.id != linkToRemove.variant.id).toList();
    emit(state.copyWith(variantLinks: updatedLinks));
  }

  void updateVariantLinkName(ProductVariantLink linkToUpdate, String newName) {
    final updatedVariant = linkToUpdate.variant.copyWith(name: newName);
    final updatedLink = linkToUpdate.copyWith(variant: updatedVariant);
    updateVariantLink(updatedLink);
  }

  void addOptionToLink(VariantOption newOption, ProductVariantLink parentLink) {
    final updatedOptions = List<VariantOption>.from(parentLink.variant.options)..add(newOption);
    final updatedLink = parentLink.copyWith(
      variant: parentLink.variant.copyWith(options: updatedOptions),
    );
    updateVariantLink(updatedLink);
  }

  void updateOptionInLink({
    required VariantOption updatedOption,
    required ProductVariantLink parentLink,
  }) {
    final updatedOptions = parentLink.variant.options.map((option) {
      return option.id == updatedOption.id ? updatedOption : option;
    }).toList();
    final updatedLink = parentLink.copyWith(
      variant: parentLink.variant.copyWith(options: updatedOptions),
    );
    updateVariantLink(updatedLink);
  }

  void removeOptionFromLink({
    required VariantOption optionToRemove,
    required ProductVariantLink parentLink,
  }) {
    final updatedOptions = parentLink.variant.options
        .where((option) => option.id != optionToRemove.id)
        .toList();
    final updatedLink = parentLink.copyWith(
      variant: parentLink.variant.copyWith(options: updatedOptions),
    );
    updateVariantLink(updatedLink);
  }

  void reorderVariantLinks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final updatedLinks = List<ProductVariantLink>.from(state.variantLinks);
    final item = updatedLinks.removeAt(oldIndex);
    updatedLinks.insert(newIndex, item);
    emit(state.copyWith(variantLinks: updatedLinks));
  }
  // FIM: Métodos de manipulação do objeto

  // INÍCIO: Métodos de persistência (API)
  void onSearchQueryChanged(String query) {
    emit(state.copyWith(searchQuery: query));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 3) _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    emit(state.copyWith(searchStatus: SearchStatus.loading));
    final result = await _productRepository.searchMasterProducts(query);
    result.fold(
          (error) => emit(state.copyWith(searchStatus: SearchStatus.failure)),
          (products) => emit(state.copyWith(searchStatus: SearchStatus.success, searchResults: products)),
    );
  }

  Future<void> saveProduct() async {
    emit(state.copyWith(submissionStatus: FormStatus.loading));

    final isFlavor = state.parentCategory != null;
    final productToSave = state.productInCreation.copyWith(
      categoryLinks: state.categoryLinks,
      variantLinks: state.variantLinks,
      productType: state.isImported ? ProductType.INDUSTRIALIZED : state.productType,
    );

    final Future<Either<String, Product>> result;
    if (state.isEditMode) {
      result = _productRepository.updateProduct(storeId, productToSave, deletedImageIds: state.deletedImageIds);
    } else if (isFlavor) {
      result = _productRepository.createFlavorProduct(storeId, productToSave, parentCategory: state.parentCategory!);
    } else {
      result = _productRepository.createSimpleProduct(storeId, productToSave);
    }

    (await result).fold(
          (error) => emit(state.copyWith(submissionStatus: FormStatus.error, errorMessage: error)),
          (savedProduct) {
        emit(state.copyWith(submissionStatus: FormStatus.success, productInCreation: savedProduct));
      },
    );
  }
  // FIM: Métodos de persistência

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}