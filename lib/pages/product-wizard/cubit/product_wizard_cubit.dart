import 'dart:async';


import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/enums/beverage.dart';
import 'package:totem_pro_admin/core/enums/foodtags.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/core/enums/product_status.dart';
import 'package:totem_pro_admin/core/enums/product_type.dart';
import 'package:totem_pro_admin/models/catalog_product.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';
import 'package:totem_pro_admin/models/product_variant_link.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import '../../../models/variant_option.dart';
import 'product_wizard_state.dart';


class ProductWizardCubit extends Cubit<ProductWizardState> {
  final ProductRepository _productRepository = getIt<ProductRepository>();
  final int storeId;
  Timer? _debounce;

  ProductWizardCubit({required this.storeId}) : super(ProductWizardState.initial());

  // ✅ 1. O MÉTODO startEditFlow(Category category) FOI REMOVIDO.
  //    Ele pertencia ao CUBIT de Categorias.

  // ✅ 2. O MÉTODO startEditFlow(Product product) FOI MANTIDO.
  //    Ele é o correto para iniciar a edição de um PRODUTO.
  void startEditFlow(Product product) {
    emit(ProductWizardState(
      isEditMode: true,
      editingProductId: product.id,
      productInCreation: product,
      categoryLinks: product.categoryLinks,
      variantLinks: product.variantLinks ?? [],
      productType: product.productType,
      currentStep: 2, // Pula direto para a etapa de detalhes
    ));
  }

  // --- MÉTODOS DE CONTROLE DO WIZARD ---

  void setProductType(ProductType type) {
    final showForm = (type == ProductType.PREPARED);
    emit(state.copyWith(
      productType: type,
      catalogProductSelected: showForm,
      isImported: false,
      productInCreation: Product(status: ProductStatus.ACTIVE),
      searchResults: [],
      searchStatus: SearchStatus.initial,
    ));
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

  // --- MÉTODOS DE BUSCA NO CATÁLOGO ---

  void onSearchQueryChanged(String query) {
    emit(state.copyWith(searchQuery: query));
    if (_debounce?.isActive ?? false) _debounce?.cancel();
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

  void selectCatalogProduct(CatalogProduct catalogProduct) {
    final newProduct = state.productInCreation.copyWith(
      name: catalogProduct.name,
      description: catalogProduct.description,
      ean: catalogProduct.ean,
      image: catalogProduct.imagePath != null ? ImageModel(url: catalogProduct.imagePath!.url) : null,
      masterProductId: catalogProduct.id,
    );
    emit(state.copyWith(
      productInCreation: newProduct,
      catalogProductSelected: true,
      isImported: true,
    ));
  }

  void resetToSearch() {
    emit(state.copyWith(
      catalogProductSelected: false,
      isImported: false,
      productInCreation: Product(status: ProductStatus.ACTIVE),
      searchQuery: '',
    ));
  }

  // --- MÉTODOS PARA ATUALIZAR O PRODUTO EM MEMÓRIA ---

  void updateProduct(Product updatedProduct) {
    emit(state.copyWith(productInCreation: updatedProduct));
  }

  // ✅ 3. MÉTODO 'addCategoryLink' ATUALIZADO E SEGURO
  void addCategoryLink(ProductCategoryLink newLink) {
    if (state.categoryLinks.any((link) => link.category?.id == newLink.category?.id)) return;
    final updatedLinks = List<ProductCategoryLink>.from(state.categoryLinks)..add(newLink);
    emit(state.copyWith(categoryLinks: updatedLinks));
  }

  void removeCategoryLink(ProductCategoryLink link) {
    final updatedLinks = List<ProductCategoryLink>.from(state.categoryLinks)..remove(link);
    emit(state.copyWith(categoryLinks: updatedLinks));
  }

  void updateCategoryLink(ProductCategoryLink updatedLink) {
    final currentLinks = List<ProductCategoryLink>.from(state.categoryLinks);
    final index = currentLinks.indexWhere((link) => link.category?.id == updatedLink.category?.id);
    if (index != -1) {
      currentLinks[index] = updatedLink;
      emit(state.copyWith(categoryLinks: currentLinks));
    }
  }

  // --- MÉTODOS PARA ATRIBUTOS (COPIADOS DO EDIT CUBIT) ---

  void controlStockToggled(bool controlStock) {
    final p = state.productInCreation;
    updateProduct(p.copyWith(controlStock: controlStock, stockQuantity: controlStock ? p.stockQuantity : 0));
  }

  void stockQuantityChanged(String value) {
    updateProduct(state.productInCreation.copyWith(stockQuantity: int.tryParse(value) ?? 0));
  }

  void unitChanged(String unit) {
    updateProduct(state.productInCreation.copyWith(unit: unit));
  }

  void weightChanged(String weight) {
    updateProduct(state.productInCreation.copyWith(weight: int.tryParse(weight)));
  }

  void servesUpToChanged(int? count) {
    updateProduct(state.productInCreation.copyWith(servesUpTo: count));
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






  // Em ProductWizardCubit

// --- MÉTODOS PARA A ABA "GRUPO DE COMPLEMENTOS" ---

// Remove um grupo de complementos (um link inteiro) do produto em memória
  void removeVariantLink(ProductVariantLink linkToRemove) {
    final updatedLinks = List<ProductVariantLink>.from(state.variantLinks)
      ..removeWhere((link) => link.variant.id == linkToRemove.variant.id);
    updateProduct(state.productInCreation.copyWith(variantLinks: updatedLinks));
  }

// Atualiza um grupo de complementos (ex: regras de min/max)
  void updateVariantLink(ProductVariantLink updatedLink) {
    final updatedLinks = state.variantLinks.map((link) {
      return link.variant.id == updatedLink.variant.id ? updatedLink : link;
    }).toList();
    updateProduct(state.productInCreation.copyWith(variantLinks: updatedLinks));
  }



// Altera o nome do grupo de complementos
  void updateVariantLinkName(ProductVariantLink linkToUpdate, String newName) {
    final updatedVariant = linkToUpdate.variant.copyWith(name: newName);
    final updatedLink = linkToUpdate.copyWith(variant: updatedVariant);
    updateVariantLink(updatedLink); // Reutiliza o método que já temos!
  }

// Adiciona uma nova opção (ex: "Bacon") a um grupo existente (ex: "Adicionais")
  void addOptionToLink(VariantOption newOption, ProductVariantLink parentLink) {
    final updatedOptions = List<VariantOption>.from(parentLink.variant.options)..add(newOption);
    final updatedLink = parentLink.copyWith(
      variant: parentLink.variant.copyWith(options: updatedOptions),
    );
    updateVariantLink(updatedLink);
  }

// Atualiza uma opção que já existe dentro de um grupo
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

// Remove uma opção de dentro de um grupo
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

// Reordena a lista de grupos de complementos
  void reorderVariantLinks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final updatedLinks = List<ProductVariantLink>.from(state.variantLinks);
    final item = updatedLinks.removeAt(oldIndex);
    updatedLinks.insert(newIndex, item);
    updateProduct(state.productInCreation.copyWith(variantLinks: updatedLinks));
  }

  void addVariantLink(ProductVariantLink newLink) {
    // Garante que não vamos adicionar um grupo que já existe
    if (state.variantLinks.any((link) => link.variant.id == newLink.variant.id)) return;

    final updatedLinks = List<ProductVariantLink>.from(state.variantLinks)..add(newLink);
    // Reutiliza o método 'updateProduct' que já temos para manter o código limpo
    updateProduct(state.productInCreation.copyWith(variantLinks: updatedLinks));
  }















  // --- AÇÃO FINAL DE SALVAR ---

  Future<void> saveProduct() async {
    emit(state.copyWith(submissionStatus: FormStatus.loading));

    final finalProduct = state.productInCreation.copyWith(
      categoryLinks: state.categoryLinks,
      variantLinks: state.variantLinks,
    );

    final Future<Either<String, Product>> result;
    if (state.isEditMode) {
      result = _productRepository.updateProduct(storeId, finalProduct);
    } else {
      result = _productRepository.createSimpleProduct(
        storeId,
        finalProduct,
        image: state.productInCreation.image,
      );
    }

    result.fold(
          (error) => emit(state.copyWith(submissionStatus: FormStatus.error, errorMessage: error)),
      // ✅ MELHORIA: Atualiza o estado com o produto final que veio do servidor
          (product) => emit(state.copyWith(
        submissionStatus: FormStatus.success,
        productInCreation: product,
      )),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}