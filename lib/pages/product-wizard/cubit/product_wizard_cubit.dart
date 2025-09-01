import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/catalog_product.dart';
import 'package:totem_pro_admin/models/product.dart';

import 'package:totem_pro_admin/repositories/product_repository.dart';

import '../../../core/enums/form_status.dart';
import '../../../core/enums/product_type.dart';
import '../../../models/category.dart';
import '../../../models/image_model.dart';
import '../../../models/prodcut_category_links.dart';
import '../../../models/product_variant_link.dart';
import '../../../models/variant_option.dart';


// ❌ REMOVA ESTA LINHA:
// part 'product_wizard_state.dart';

// ✅ ADICIONE ESTA LINHA:
import 'product_wizard_state.dart';

class ProductWizardCubit extends Cubit<ProductWizardState> {
  final ProductRepository _productRepository = getIt<ProductRepository>();
  final int storeId; // ✅ O Cubit precisa saber a qual loja o produto pertence
  Timer? _debounce;

  // ✅ Construtor corrigido para receber o storeId
  ProductWizardCubit({required this.storeId}) : super(ProductWizardState.initial());


  void updateVariantLinkName(ProductVariantLink linkToUpdate, String newName) {
    final updatedVariant = linkToUpdate.variant.copyWith(name: newName);
    final updatedLink = linkToUpdate.copyWith(variant: updatedVariant);
    updateVariantLink(updatedLink);
  }

  // Em lib/pages/product_edit/cubit/product_wizard_cubit.dart

// Adicione este método para adicionar uma opção a um grupo que está sendo criado
  void addOptionToLink(VariantOption newOption, ProductVariantLink parentLink) {
    // Encontra o link na lista do estado
    final targetLink = state.variantLinks.firstWhere((link) => link.variant.id == parentLink.variant.id);

    // Cria uma nova lista de opções, adicionando a nova
    final updatedOptions = List<VariantOption>.from(targetLink.variant.options)..add(newOption);

    // Cria cópias atualizadas dos objetos
    final updatedVariant = targetLink.variant.copyWith(options: updatedOptions);
    final updatedLink = targetLink.copyWith(variant: updatedVariant);

    // Atualiza o link na lista principal do estado
    updateVariantLink(updatedLink);
  }

  void setProductType(ProductType type) {
    final showForm = (type == ProductType.PREPARED);
    emit(state.copyWith(
      productType: type,
      catalogProductSelected: showForm,
      isImported: false,
      productInCreation: Product(available: true, image: ImageModel(), price: 0),

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
      productInCreation: Product(available: true, image: ImageModel(), price: 0),
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

// DENTRO DA CLASSE ProductWizardCubit

// ✅ MÉTODO `nextStep` ATUALIZADO
  void nextStep() {
    // Regra especial para pular a etapa de complementos
    if (state.currentStep == 2 && state.productType == ProductType.INDUSTRIALIZED) {
      // Se está no passo 2 e o produto é industrializado, pula direto para o 4
      emit(state.copyWith(currentStep: 4));
      return;
    }

    // Lógica padrão para os outros casos
    if (state.currentStep < 4) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

// ✅ MÉTODO `previousStep` ATUALIZADO
  void previousStep() {
    // Regra especial para voltar do pulo
    if (state.currentStep == 4 && state.productType == ProductType.INDUSTRIALIZED) {
      // Se está no passo 4 e o produto é industrializado, volta direto para o 2
      emit(state.copyWith(currentStep: 2));
      return;
    }

    // Lógica padrão para os outros casos
    if (state.currentStep > 1) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }



  void addCategoryLink(Category category) {
    if (state.categoryLinks.any((link) => link.category.id == category.id)) return;

    // ✅ CORRIGIDO: Usando os nomes de parâmetros corretos ('price' e 'posCode')
    final newLink = ProductCategoryLink(
      category: category,
      price: 0,   // O nome correto do parâmetro é 'price'
      posCode: null, // O nome correto do parâmetro é 'posCode'
    );

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
// Remova ou substitua o seu método saveProduct() atual por este:
  Future<void> saveProduct() async {
    emit(state.copyWith(submissionStatus: FormStatus.loading));

    // ✅ CORREÇÃO: Monta o objeto final do produto aqui!
    // Ele pega os dados básicos de `productInCreation` e combina
    // com as listas de `variantLinks` e `categoryLinks` do estado.
    final finalProduct = state.productInCreation.copyWith(
      variantLinks: () => state.variantLinks,
      categoryLinks: () => state.categoryLinks,
    );

    // Agora sim, enviamos o produto completo para o repositório.
    final result = await _productRepository.createProductFromWizard(storeId, finalProduct);

    result.fold(
          (error) => emit(state.copyWith(submissionStatus: FormStatus.error, errorMessage: error)),
          (product) => emit(state.copyWith(submissionStatus: FormStatus.success)),
    );
  }


// DENTRO DA CLASSE ProductWizardCubit

// ✅ NOVO MÉTODO PARA ATUALIZAR UMA OPÇÃO
  void updateOptionInLink({
    required VariantOption updatedOption,
    required ProductVariantLink parentLink,
  }) {
    // Encontra o link pai na lista de links do estado
    final targetLink = state.variantLinks.firstWhere((link) => link.variant.id == parentLink.variant.id);

    // Cria uma nova lista de opções, substituindo a antiga pela atualizada
    final updatedOptions = targetLink.variant.options.map((option) {
      return option.id == updatedOption.id ? updatedOption : option;
    }).toList();

    // Cria uma cópia atualizada do link com a nova lista de opções
    final updatedLink = targetLink.copyWith(
      variant: targetLink.variant.copyWith(options: updatedOptions),
    );

    // Finalmente, atualiza o link na lista principal do estado
    updateVariantLink(updatedLink);
  }

// ✅ NOVO MÉTODO PARA REMOVER UMA OPÇÃO
  void removeOptionFromLink({
    required VariantOption optionToRemove,
    required ProductVariantLink parentLink,
  }) {
    final targetLink = state.variantLinks.firstWhere((link) => link.variant.id == parentLink.variant.id);

    // Cria uma nova lista de opções, removendo a opção desejada
    final updatedOptions = targetLink.variant.options.where((option) {
      return option.id != optionToRemove.id;
    }).toList();

    final updatedLink = targetLink.copyWith(
      variant: targetLink.variant.copyWith(options: updatedOptions),
    );

    updateVariantLink(updatedLink);
  }



  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}