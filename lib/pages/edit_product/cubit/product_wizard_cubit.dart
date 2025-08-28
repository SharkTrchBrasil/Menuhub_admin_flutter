import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/catalog_product.dart';
import 'package:totem_pro_admin/models/product.dart';

import 'package:totem_pro_admin/repositories/product_repository.dart';

import '../../../core/enums/product_type.dart';
import '../../../models/category.dart';
import '../../../models/image_model.dart';
import '../../../models/product_variant_link.dart';
import '../groups/cubit/create_complement_cubit.dart';


part 'product_wizard_state.dart';

class ProductWizardCubit extends Cubit<ProductWizardState> {
  final ProductRepository _productRepository = getIt<ProductRepository>();
  final int storeId; // ✅ O Cubit precisa saber a qual loja o produto pertence
  Timer? _debounce;

  // ✅ Construtor corrigido para receber o storeId
  ProductWizardCubit({required this.storeId}) : super(ProductWizardState.initial());


  void setProductType(ProductType type) {
    final showForm = (type == ProductType.PREPARED);
    emit(state.copyWith(
      productType: type,
      catalogProductSelected: showForm,
      isImported: false,
      productInCreation: Product(available: true, image: ImageModel()),

      // Também é uma boa prática resetar o estado da busca
      searchResults: [],
      searchStatus: SearchStatus.initial,
    ));
  }

  void updateProduct(Product updatedProduct) {
    emit(state.copyWith(productInCreation: updatedProduct));
  }

// ✅ NOVOS MÉTODOS PARA GERENCIAR OS GRUPOS DE COMPLEMENTOS
  void addVariantLink(ProductVariantLink link) {
    final updatedLinks = List<ProductVariantLink>.from(state.variantLinks)..add(link);
    emit(state.copyWith(variantLinks: updatedLinks));
  }

  // ✅ NOVO: O Cubit agora gerencia o controller de busca
  void onSearchQueryChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 3) {
        _performSearch(query);
      } else {
        emit(state.copyWith(searchResults: [], searchStatus: SearchStatus.initial));
      }
    });
  }


  void updateVariantLink(ProductVariantLink updatedLink) {
    final currentLinks = List<ProductVariantLink>.from(state.variantLinks);
    final index = currentLinks.indexWhere((link) => link.variant.id == updatedLink.variant.id);

    if (index != -1) {
      currentLinks[index] = updatedLink;
      emit(state.copyWith(variantLinks: currentLinks));
    }
  }

  Future<void> _performSearch(String query) async {
    emit(state.copyWith(searchStatus: SearchStatus.loading));
    final result = await _productRepository.searchMasterProducts(query);
    result.fold(
          (error) => emit(state.copyWith(searchStatus: SearchStatus.failure)),
          (products) => emit(state.copyWith(
        searchStatus: SearchStatus.success,
        searchResults: products,
      )),
    );
  }


  Future<void> searchCatalog(String query) async {
    if (query.length < 3) {
      emit(state.copyWith(searchResults: [], searchStatus: SearchStatus.initial));
      return;
    }
    emit(state.copyWith(searchStatus: SearchStatus.loading));
    final result = await _productRepository.searchMasterProducts(query);
    result.fold(
          (error) => emit(state.copyWith(searchStatus: SearchStatus.failure)),
          (products) => emit(state.copyWith(searchStatus: SearchStatus.success, searchResults: products)),
    );
  }

  void selectCatalogProduct(CatalogProduct catalogProduct) {
    // Cria um novo `Product` a partir dos dados do catálogo
    final newProduct = state.productInCreation.copyWith(
      name: catalogProduct.name,
      description: catalogProduct.description,
      ean: catalogProduct.ean,
      image: ImageModel(url: catalogProduct.imagePath!.url),

      // Aqui você pode pré-preencher a imagem também se o modelo permitir
    );
    emit(state.copyWith(
      productInCreation: newProduct,
      catalogProductSelected: true,
      isImported: true,
    ));
  }
// ✅ NOVO MÉTODO: Para o AppProductImageFormField atualizar a imagem
  void onImageChanged(ImageModel newImage) {
    final updatedProduct = state.productInCreation.copyWith(image: newImage);
    emit(state.copyWith(productInCreation: updatedProduct));
  }


  void resetToSearch(TextEditingController searchController) {
    searchController.clear(); // Limpa o texto na UI
    emit(state.copyWith(
      catalogProductSelected: false,
      isImported: false,
      productInCreation: Product(available: true, image: ImageModel()),
      searchResults: [],
      searchStatus: SearchStatus.initial,
    ));
  }



  void removeVariantLink(ProductVariantLink link) {
    final updatedLinks = List<ProductVariantLink>.from(state.variantLinks)..remove(link);
    emit(state.copyWith(variantLinks: updatedLinks));
  }

  // ✅ MÉTODO PARA REORDENAR OS GRUPOS
  void reorderVariantLinks(int oldIndex, int newIndex) {
    // Lógica padrão para reordenação
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final updatedLinks = List<ProductVariantLink>.from(state.variantLinks);
    final item = updatedLinks.removeAt(oldIndex);
    updatedLinks.insert(newIndex, item);
    emit(state.copyWith(variantLinks: updatedLinks));
  }

  void nextStep() {
    if (state.currentStep < 4) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }





  void addCategoryLink(Category category) {
    if (state.categoryLinks.any((link) => link.category.id == category.id)) return;
    final newLink = ProductCategoryLink(category: category);
    final updatedLinks = List<ProductCategoryLink>.from(state.categoryLinks)..add(newLink);
    emit(state.copyWith(categoryLinks: updatedLinks));
  }

  void removeCategoryLink(ProductCategoryLink link) {
    final updatedLinks = List<ProductCategoryLink>.from(state.categoryLinks)..remove(link);
    emit(state.copyWith(categoryLinks: updatedLinks));
  }

  void updateCategoryLink(ProductCategoryLink updatedLink) {
    final currentLinks = List<ProductCategoryLink>.from(state.categoryLinks);
    final index = currentLinks.indexWhere((link) => link.category.id == updatedLink.category.id);
    if (index != -1) {
      currentLinks[index] = updatedLink;
      emit(state.copyWith(categoryLinks: currentLinks));
    }
  }



  // --- FINALIZAÇÃO ---

  Future<void> saveProduct() async {
    emit(state.copyWith(submissionStatus: FormStatus.loading));

    final finalProduct = state.productInCreation.copyWith(
      variantLinks: () => state.variantLinks,
      categoryLinks: () => state.categoryLinks,
    );

    // ✅ CORREÇÃO: Usa o `storeId` que é um membro da classe Cubit
    final result = await _productRepository.createProductFromWizard(storeId, finalProduct);

    result.fold(
          (error) => emit(state.copyWith(submissionStatus: FormStatus.error, errorMessage: error)),
          (product) => emit(state.copyWith(submissionStatus: FormStatus.success)),
    );
  }






  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}