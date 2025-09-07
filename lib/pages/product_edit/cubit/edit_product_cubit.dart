import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart' hide FormStatus;
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:equatable/equatable.dart';

import '../../../core/enums/beverage.dart';
import '../../../core/enums/foodtags.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import '../../../models/product_variant_link.dart';
import '../../../models/variant_option.dart';
import '../../product-wizard/cubit/product_wizard_state.dart';
import '../../product_groups/cubit/create_complement_cubit.dart';
import '../../product_groups/helper/side_panel_helper.dart';
import '../../product_groups/widgets/multi_step_panel_container.dart';
part 'edit_product_state.dart';

class EditProductCubit extends Cubit<EditProductState> {
  final ProductRepository _productRepository;
  final int _storeId;

  EditProductCubit({
    required Product initialProduct,
    required ProductRepository productRepository,
    required int storeId,
  })  : _productRepository = productRepository,
        _storeId = storeId,
        super(EditProductState.fromProduct(initialProduct));

  // --- Métodos para a Aba "Sobre o produto" ---
  void nameChanged(String name) {
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(name: name)));
  }

  void descriptionChanged(String description) {
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(description: description)));
  }

  void imageChanged(ImageModel? image) {
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(image: image)));
  }

  // --- Métodos para a Aba "Categorias e Preços" ---
  void updatePriceInCategory(ProductCategoryLink linkToUpdate, int newPriceInCents) {
    final updatedLinks = state.editedProduct.categoryLinks.map((link) {
      if (link.productId == linkToUpdate.productId && link.categoryId == linkToUpdate.categoryId) {
        return link.copyWith(price: newPriceInCents);
      }
      return link;
    }).toList();
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(categoryLinks: updatedLinks)));
  }

  // --- Métodos para a Aba "Disponibilidade" ---
  void availabilityChanged(bool isAvailable) {
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(available: isAvailable)));
  }
  // (Adicione aqui outros métodos para os switches: featured, controlStock, etc.)

  // --- Ação Principal de Salvar ---
  Future<void> saveProduct() async {
    if (!state.isDirty) {
      print("Nenhuma alteração detectada, não salvando.");
      return;
    }
    emit(state.copyWith(status: FormStatus.loading));

    final result = await _productRepository.updateProduct(_storeId, state.editedProduct);

    result.fold(
          (error) => emit(state.copyWith(status: FormStatus.error, errorMessage: error)),
          (updatedProductFromServer) {
        // ✅ Sucesso: Atualiza ambos os produtos no estado com a versão final que veio do servidor.
        emit(state.copyWith(
          status: FormStatus.success,
          editedProduct: updatedProductFromServer,
          // Também atualiza o 'original' para que 'isDirty' se torne falso
          // e o botão Salvar seja desabilitado até a próxima mudança.
          originalProduct: updatedProductFromServer,
        ));
      },
    );
  }

// Em EditProductCubit

// Este método precisa do BuildContext para poder abrir o painel lateral
  Future<void> addNewComplementGroup(BuildContext context) async {
    final storesState = context.read<StoresManagerCubit>().state;
    if (storesState is! StoresManagerLoaded) return;

    final newLink = await showResponsiveSidePanelGroup<ProductVariantLink>(
      context,
      panel: BlocProvider(
        create: (_) => CreateComplementGroupCubit(
          storeId: _storeId,
          productId: state.originalProduct.id,
          productRepository: _productRepository,
          allStoreVariants: storesState.activeStore!.relations.variants ?? [],
          allStoreProducts: storesState.activeStore!.relations.products ?? [],
        ),
        child: const FractionallySizedBox(
          heightFactor: 0.9,
          child: MultiStepPanelContainer(),
        ),
      ),
    );

    if (newLink != null) {
      // Se um novo link foi criado no painel, salvamos no banco
      final result = await _productRepository.linkVariantToProduct(
        storeId: _storeId,
        productId: state.originalProduct.id!,
        variantId: newLink.variant.id!,
        linkData: newLink,
      );

      result.fold(
            (error) {
          // Mostra erro se falhar ao salvar no banco
          emit(state.copyWith(status: FormStatus.error, errorMessage: error));
        },
            (savedLink) {
          // Sucesso: Adiciona o novo link salvo ao estado local
          final updatedLinks = List<ProductVariantLink>.from(state.editedProduct.variantLinks ?? [])..add(savedLink);
          emit(state.copyWith(
            editedProduct: state.editedProduct.copyWith(variantLinks: updatedLinks),
          ));
        },
      );
    }
  }


  // Em EditProductCubit

// --- Métodos para a Aba "Complementos" ---

  void addVariantLink(ProductVariantLink newLink) {
    final updatedLinks = List<ProductVariantLink>.from(state.editedProduct.variantLinks ?? [])..add(newLink);
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(variantLinks: updatedLinks)));
  }

  void removeVariantLink(ProductVariantLink linkToRemove) {
    final updatedLinks = List<ProductVariantLink>.from(state.editedProduct.variantLinks ?? [])..remove(linkToRemove);
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(variantLinks: updatedLinks)));
  }

  void updateVariantLink(ProductVariantLink updatedLink) {
    final updatedLinks = (state.editedProduct.variantLinks ?? []).map((link) {
      return link.variant.id == updatedLink.variant.id ? updatedLink : link;
    }).toList();
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(variantLinks: updatedLinks)));
  }

  void reorderVariantLinks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final updatedLinks = List<ProductVariantLink>.from(state.editedProduct.variantLinks ?? []);
    final item = updatedLinks.removeAt(oldIndex);
    updatedLinks.insert(newIndex, item);
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(variantLinks: updatedLinks)));
  }




// Altera o nome do grupo de complementos
  void updateVariantLinkName(ProductVariantLink linkToUpdate, String newName) {
    final updatedVariant = linkToUpdate.variant.copyWith(name: newName);
    final updatedLink = linkToUpdate.copyWith(variant: updatedVariant);
    updateVariantLink(updatedLink); // Reutiliza o método que já temos!
  }

// Adiciona uma nova opção (complemento) a um grupo existente
  void addOptionToLink(ProductVariantLink parentLink, VariantOption newOption) {
    // Cria uma nova lista de opções, adicionando a nova
    final updatedOptions = List<VariantOption>.from(parentLink.variant.options)..add(newOption);
    // Cria uma cópia atualizada do link com a nova lista
    final updatedLink = parentLink.copyWith(
      variant: parentLink.variant.copyWith(options: updatedOptions),
    );
    updateVariantLink(updatedLink);
  }

// Atualiza uma opção (complemento) dentro de um grupo
  void updateOptionInLink(ProductVariantLink parentLink, VariantOption updatedOption) {
    // Mapeia as opções existentes, substituindo apenas a que foi alterada
    final updatedOptions = parentLink.variant.options.map((option) {
      return option.id == updatedOption.id ? updatedOption : option;
    }).toList();

    final updatedLink = parentLink.copyWith(
      variant: parentLink.variant.copyWith(options: updatedOptions),
    );
    updateVariantLink(updatedLink);
  }

// Remove uma opção (complemento) de um grupo
  void removeOptionFromLink(ProductVariantLink parentLink, VariantOption optionToRemove) {
    // Filtra a lista de opções, removendo a que foi marcada para exclusão
    final updatedOptions = parentLink.variant.options
        .where((option) => option.id != optionToRemove.id)
        .toList();

    final updatedLink = parentLink.copyWith(
      variant: parentLink.variant.copyWith(options: updatedOptions),
    );
    updateVariantLink(updatedLink);
  }





  void servesUpToChanged(int? count) {
    // Adapte para chamar o método de update correto do seu Cubit
    // Ex: updateProduct(product.copyWith(servesUpTo: count));
  }

  void weightChanged(String weight) {
    // Adapte para chamar o método de update correto do seu Cubit
    // Ex: updateProduct(product.copyWith(weight: int.tryParse(weight)));
  }

  void unitChanged(String unit) {
    // Adapte para chamar o método de update correto do seu Cubit
    // Ex: updateProduct(product.copyWith(unit: unit));
  }

// Em seu CUBIT

  void toggleDietaryTag(FoodTag tag) {
    final product = state.editedProduct; // ou state.productInCreation
    final newTags = Set<FoodTag>.from(product.dietaryTags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    // Chame o método de update correto do seu CUBIT
    // Ex: emit(state.copyWith(editedProduct: product.copyWith(dietaryTags: newTags)));
  }

  void toggleBeverageTag(BeverageTag tag) {
    final product = state.editedProduct; // ou state.productInCreation
    final newTags = Set<BeverageTag>.from(product.beverageTags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    // Chame o método de update correto do seu CUBIT
    // Ex: emit(state.copyWith(editedProduct: product.copyWith(beverageTags: newTags)));
  }



}