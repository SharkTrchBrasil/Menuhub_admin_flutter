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


  void startEditFlow(Product product) {
    emit(ProductWizardState(
      isEditMode: true,
      editingProductId: product.id,
      productInCreation: product,
      categoryLinks: product.categoryLinks,
      variantLinks: product.variantLinks ?? [],
      productType: product.productType,
      currentStep: 2,
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



  // ✅ NOVO MÉTODO PARA LIDAR COM A REMOÇÃO DE IMAGENS
  void removeImage(ImageModel imageToRemove) {
    // Cria uma nova lista de imagens no produto em criação
    final updatedImages = List<ImageModel>.from(state.productInCreation.images)
      ..remove(imageToRemove);

    // Cria uma nova lista de IDs a serem deletados
    final updatedDeletedIds = List<int>.from(state.deletedImageIds);

    // Se a imagem removida já existia no servidor (tinha um ID),
    // adicionamos seu ID à lista de exclusão.
    if (imageToRemove.id != null) {
      updatedDeletedIds.add(imageToRemove.id!);
    }

    emit(state.copyWith(
      productInCreation: state.productInCreation.copyWith(images: updatedImages),
      deletedImageIds: updatedDeletedIds,
    ));
  }

  void videoChanged(ImageModel? newVideo) {
    if (newVideo == null) {
      // Se o novo vídeo for nulo, significa que o usuário removeu.
      // Usamos o flag 'removeVideo: true' para limpar ambos os campos.
      emit(state.copyWith(
        productInCreation: state.productInCreation.copyWith(removeVideo: true),
      ));
    } else {
      // Se for um novo vídeo, apenas atualizamos o videoFile.
      emit(state.copyWith(
        productInCreation: state.productInCreation.copyWith(videoFile: newVideo),
      ));
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


  void toggleLinkAvailability(ProductCategoryLink linkToToggle) {
    final updatedLink = linkToToggle.copyWith(isAvailable: !linkToToggle.isAvailable);
    updateCategoryLink(updatedLink);
  }

  void selectCatalogProduct(CatalogProduct catalogProduct) {

    // ✅ LÓGICA DE IMAGEM CORRIGIDA AQUI
    List<ImageModel> initialImages = [];
    if (catalogProduct.imagePath != null) {
      // Se o produto do catálogo tem uma imagem, ela se torna a primeira (e única)
      // imagem na nossa nova lista de imagens.
      initialImages.add(ImageModel(url: catalogProduct.imagePath!.url));
    }




    final newProduct = state.productInCreation.copyWith(
      name: catalogProduct.name,
      description: catalogProduct.description,
      ean: catalogProduct.ean,
      images: initialImages,
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

  void addCategoryLink(ProductCategoryLink newLink) {

    // ✅ PONTO DE CHECAGEM 4: O link que chegou do wizard tem o preço correto?
    print('DEBUG 4: [WizardCubit] addCategoryLink recebeu um link com o preço: ${newLink.price}');

    if (state.categoryLinks.any((link) => link.category?.id == newLink.category?.id)) return;

    final updatedLinks = List<ProductCategoryLink>.from(state.categoryLinks)..add(newLink);

    // Agora, também atualiza o produto em criação com a nova lista
    emit(state.copyWith(
      categoryLinks: updatedLinks,
      productInCreation: state.productInCreation.copyWith(categoryLinks: updatedLinks),
    ));
  }

  void removeCategoryLink(ProductCategoryLink link) {
    final updatedLinks = List<ProductCategoryLink>.from(state.categoryLinks)..remove(link);

    // Atualiza ambos os lugares
    emit(state.copyWith(
      categoryLinks: updatedLinks,
      productInCreation: state.productInCreation.copyWith(categoryLinks: updatedLinks),
    ));
  }

  void updateCategoryLink(ProductCategoryLink updatedLink) {
    final currentLinks = List<ProductCategoryLink>.from(state.categoryLinks);
    final index = currentLinks.indexWhere((link) => link.category?.id == updatedLink.category?.id);
    if (index != -1) {
      currentLinks[index] = updatedLink;

      // Atualiza ambos os lugares
      emit(state.copyWith(
        categoryLinks: currentLinks,
        productInCreation: state.productInCreation.copyWith(categoryLinks: currentLinks),
      ));
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





  void removeVariantLink(ProductVariantLink linkToRemove) {
    final updatedLinks = List<ProductVariantLink>.from(state.variantLinks)
      ..removeWhere((link) => link.variant.id == linkToRemove.variant.id);

    // CORREÇÃO: Emita o estado atualizando as duas propriedades
    emit(state.copyWith(
      variantLinks: updatedLinks,
      productInCreation: state.productInCreation.copyWith(variantLinks: updatedLinks),
    ));
  }




  void updateVariantLink(ProductVariantLink updatedLink) {
    final updatedLinks = state.variantLinks.map((link) {
      return link.variant.id == updatedLink.variant.id ? updatedLink : link;
    }).toList();

    // CORREÇÃO: Emita o estado atualizando as duas propriedades
    emit(state.copyWith(
      variantLinks: updatedLinks,
      productInCreation: state.productInCreation.copyWith(variantLinks: updatedLinks),
    ));
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



  void reorderVariantLinks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final updatedLinks = List<ProductVariantLink>.from(state.variantLinks);
    final item = updatedLinks.removeAt(oldIndex);
    updatedLinks.insert(newIndex, item);

    // CORREÇÃO: Emita o estado atualizando as duas propriedades
    emit(state.copyWith(
      variantLinks: updatedLinks,
      productInCreation: state.productInCreation.copyWith(variantLinks: updatedLinks),
    ));
  }



  void addVariantLink(ProductVariantLink newLink) {
    if (state.variantLinks.any((link) => link.variant.id == newLink.variant.id)) return;
    final updatedLinks = List<ProductVariantLink>.from(state.variantLinks)..add(newLink);

    // CORREÇÃO: Emita o estado atualizando as duas propriedades
    emit(state.copyWith(
      variantLinks: updatedLinks,
      productInCreation: state.productInCreation.copyWith(variantLinks: updatedLinks),
    ));
  }





  void onImagesChanged(List<ImageModel> newImageList) {

    // Lógica para encontrar os deletados
    final currentIds = newImageList.where((i) => i.id != null).map((i) => i.id!).toSet();
    final originalIds = state.productInCreation.images.where((i) => i.id != null).map((i) => i.id!).toSet();
    final deleted = originalIds.difference(currentIds).toList();


    final updatedDeletedIds = List<int>.from(state.deletedImageIds);
    updatedDeletedIds.addAll(deleted);


    emit(state.copyWith(
        productInCreation: state.productInCreation.copyWith(images: newImageList),
        deletedImageIds: updatedDeletedIds.toSet().toList() // Evita duplicados
    ));
  }







  // --- AÇÃO FINAL DE SALVAR ---









  Future<void> saveProduct() async {
    emit(state.copyWith(submissionStatus: FormStatus.loading));

    final productWithLocalFiles = state.productInCreation.copyWith(
      categoryLinks: state.categoryLinks,
      variantLinks: state.variantLinks,
    );

    final Future<Either<String, Product>> result;

    if (state.isEditMode) {
      // A lógica de edição já está correta, lidando com IDs de imagens deletadas.
      // Não precisamos mexer aqui.
      result = _productRepository.updateProduct(
        storeId,
        productWithLocalFiles,
        deletedImageIds: state.deletedImageIds,

      );
    } else {

      result = _productRepository.createSimpleProduct(
        storeId,
        productWithLocalFiles,
        images: productWithLocalFiles.images,

      );
    }

    // Processa o resultado da ETAPA 1
    (await result).fold(
          (error) {
        // Se a Etapa 1 falhar, mostramos o erro e paramos.
        emit(state.copyWith(submissionStatus: FormStatus.error, errorMessage: error));
      },
          (savedProduct) {

        emit(state.copyWith(
          submissionStatus: FormStatus.success,
          productInCreation: savedProduct,
        ));

        _uploadComplementImages(
          originalProduct: productWithLocalFiles,
          savedProduct: savedProduct,
        );
      },
    );
  }

// ✅ NOVO MÉTODO AUXILIAR PARA A ETAPA 2
  void _uploadComplementImages({
    required Product originalProduct,
    required Product savedProduct,
  }) {
    // Itera sobre os grupos de complementos que o usuário montou na tela
    for (final originalLink in originalProduct.variantLinks ?? []) {
      // Encontra o grupo correspondente que foi salvo e agora tem um ID real
      final savedLink = savedProduct.variantLinks?.firstWhere(
            (sl) => sl.variant.name == originalLink.variant.name,
        orElse: () => ProductVariantLink.empty(),
      );

      if (savedLink != null && savedLink.variant.id != null) {
        // Itera sobre as opções dentro do grupo original
        for (final originalOption in originalLink.variant.options) {
          // Se a opção tinha um arquivo de imagem local para ser enviado
          if (originalOption.image?.file != null) {
            // Encontra a opção correspondente que foi salva e agora tem um ID
            final savedOption = savedLink.variant.options.firstWhere(
                  (so) => so.resolvedName == originalOption.resolvedName,
              orElse: () =>  VariantOption.empty(),
            );

            if (savedOption != null && savedOption.id != null) {
              print('Disparando upload para a opção: ${savedOption
                  .resolvedName} (ID: ${savedOption.id})');
              _productRepository.saveVariantOption(
                storeId,
                savedLink.variant.id!,
                savedOption.copyWith(image: originalOption.image),
              );
            }
          }
        }
      }
    }
  }














  // Future<void> saveProduct() async {
  //   emit(state.copyWith(submissionStatus: FormStatus.loading));
  //
  //   final finalProduct = state.productInCreation.copyWith(
  //     categoryLinks: state.categoryLinks,
  //     variantLinks: state.variantLinks,
  //   );
  //
  //
  //
  //   final Future<Either<String, Product>> result;
  //   if (state.isEditMode) {
  //     result = _productRepository.updateProduct(
  //       storeId,
  //       finalProduct,
  //       // ✅ PASSA A LISTA DE IDs PARA O REPOSITÓRIO
  //       deletedImageIds: state.deletedImageIds,
  //     );
  //   } else {
  //     result = _productRepository.createSimpleProduct(
  //       storeId,
  //       finalProduct,
  //       images: state.productInCreation.images,
  //     );
  //   }
  //
  //   (await result).fold(
  //         (error) => emit(state.copyWith(submissionStatus: FormStatus.error, errorMessage: error)),
  //         (product) => emit(state.copyWith(
  //       submissionStatus: FormStatus.success,
  //       productInCreation: product,
  //     )),
  //   );
  // }
  //

















  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}