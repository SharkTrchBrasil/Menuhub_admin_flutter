import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/catalog_product.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/edit_product/cubit/product_wizard_state.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

import '../../../models/image_model.dart';


// O Cubit que gerencia o estado do wizard
class ProductWizardCubit extends Cubit<ProductWizardState> {

  final ProductRepository _productRepository = getIt<ProductRepository>();
  Timer? _debounce;

  ProductWizardCubit() : super(ProductWizardState.initial());



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

  // ✅ MÉTODO PRIVADO - Chamado APENAS pelo onSearchQueryChanged
  // Garanta que este método exista dentro do seu Cubit.
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

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}