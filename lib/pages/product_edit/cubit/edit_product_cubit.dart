import 'package:bloc/bloc.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:equatable/equatable.dart';

import '../../../core/enums/beverage.dart';
import '../../../core/enums/cashback_type.dart';
import '../../../core/enums/foodtags.dart';
import '../../../core/enums/product_status.dart';
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


  Future<void> saveProduct() async {
    // A verificação de 'isDirty' agora é feita apenas na UI, o que está ótimo.
    // Se o botão está habilitado, significa que há mudanças.

    emit(state.copyWith(status: FormStatus.loading));

    final result = await _productRepository.updateProduct(_storeId, state.editedProduct);

    result.fold(
          (error) {
        if (!isClosed) {
          // Em caso de erro, apenas emitimos o erro. O estado continua 'sujo'
          // para que o usuário possa tentar salvar novamente.
          emit(state.copyWith(status: FormStatus.error, errorMessage: error));
        }
      },
          (savedProduct) {
        if (!isClosed) {
          // ✅ --- AQUI ESTÁ A MÁGICA ---

          // 1. Emite o estado de SUCESSO. O BlocListener na UI vai pegar
          //    este evento e mostrar o SnackBar verde.
          emit(state.copyWith(status: FormStatus.success));

          // 2. Emite um NOVO estado "limpo" logo em seguida.
          //    Ele usa o produto recém-salvo (retornado pela API) como a nova
          //    base. Agora, `initialProduct` e `editedProduct` serão iguais.
          //    Isso fará com que `isDirty` se torne `false`, e o BlocBuilder
          //    na UI vai reconstruir o botão no estado desabilitado.
          emit(EditProductState.fromProduct(savedProduct));
        }
      },
    );
  }




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



// ✅ --- LÓGICA PARA A ABA "DISPONIBILIDADE E OPÇÕES" ---

  void statusChanged(bool isActive) {
    // ✅ A lógica agora decide entre os status ACTIVE e INACTIVE
    final newStatus = isActive ? ProductStatus.ACTIVE : ProductStatus.INACTIVE;

    // ✅ Em vez de 'available', atualizamos o campo 'status'
    emit(state.copyWith(
        editedProduct: state.editedProduct.copyWith(status: newStatus)
    ));
  }


  void featuredToggled(bool isFeatured) {
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(featured: isFeatured)));
  }

  void controlStockToggled(bool controlStock) {
    final stockQuantity = controlStock ? state.editedProduct.stockQuantity : 0;
    emit(state.copyWith(
      editedProduct: state.editedProduct.copyWith(
        controlStock: controlStock,
        stockQuantity: stockQuantity,
      ),
    ));
  }

  void stockQuantityChanged(String value) {
    final quantity = int.tryParse(value) ?? 0;
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(stockQuantity: quantity)));
  }

// ✅ --- LÓGICA PARA A SEÇÃO DE ATRIBUTOS (a que faltava) ---

  void servesUpToChanged(int? count) {
    emit(state.copyWith(
      editedProduct: state.editedProduct.copyWith(servesUpTo: count),
    ));
  }

  void weightChanged(String weight) {
    emit(state.copyWith(
      // tryParse é seguro: se o texto for inválido, ele retorna null
      editedProduct: state.editedProduct.copyWith(weight: int.tryParse(weight)),
    ));
  }

  void unitChanged(String unit) {
    emit(state.copyWith(
      editedProduct: state.editedProduct.copyWith(unit: unit),
    ));
  }

  void toggleDietaryTag(FoodTag tag) {
    final product = state.editedProduct;
    final newTags = Set<FoodTag>.from(product.dietaryTags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    emit(state.copyWith(editedProduct: product.copyWith(dietaryTags: newTags)));
  }

  void toggleBeverageTag(BeverageTag tag) {
    final product = state.editedProduct;
    final newTags = Set<BeverageTag>.from(product.beverageTags);
    if (newTags.contains(tag)) {
      newTags.remove(tag);
    } else {
      newTags.add(tag);
    }
    emit(state.copyWith(editedProduct: product.copyWith(beverageTags: newTags)));
  }


// Em EditProductCubit.dart

// --- Métodos para a Nova Aba "Cashback" ---

  void cashbackTypeChanged(CashbackType? newType) {
    if (newType == null) return;

    // Se o tipo for mudado para 'nenhum', zera o valor por segurança.
    final newCashbackValue = (newType == CashbackType.none) ? 0 : state.editedProduct.cashbackValue;

    emit(state.copyWith(
      editedProduct: state.editedProduct.copyWith(
        cashbackType: newType,
        cashbackValue: newCashbackValue,
      ),
    ));
  }

  void cashbackValueChanged(String value) {
    final product = state.editedProduct;
    int newValueInCents = 0;

    if (product.cashbackType == CashbackType.fixed) {
      // Converte de R$ para centavos
      newValueInCents = (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt();
    } else {
      // Para percentual, o valor já é o número inteiro
      newValueInCents = int.tryParse(value) ?? 0;
    }

    emit(state.copyWith(
      editedProduct: product.copyWith(cashbackValue: newValueInCents),
    ));
  }


  void addCategoryLink(ProductCategoryLink newLink) {
    // Evita adicionar a mesma categoria duas vezes
    if (state.editedProduct.categoryLinks.any((link) => link.categoryId == newLink.categoryId)) {
      return;
    }
    final updatedLinks = List<ProductCategoryLink>.from(state.editedProduct.categoryLinks)..add(newLink);
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(categoryLinks: updatedLinks)));
  }

  void removeCategoryLink(ProductCategoryLink linkToRemove) {
    final updatedLinks = List<ProductCategoryLink>.from(state.editedProduct.categoryLinks)
      ..removeWhere((link) => link.categoryId == linkToRemove.categoryId);
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(categoryLinks: updatedLinks)));
  }

  void updateCategoryLink(ProductCategoryLink updatedLink) {
    final updatedLinks = state.editedProduct.categoryLinks.map((link) {
      return link.categoryId == updatedLink.categoryId ? updatedLink : link;
    }).toList();
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(categoryLinks: updatedLinks)));
  }



  Future<void> togglePauseInCategory(ProductCategoryLink linkToToggle) async {


    final result = await _productRepository.toggleLinkAvailability(
      storeId: _storeId,
      productId: linkToToggle.productId!,
      categoryId: linkToToggle.categoryId,
      isAvailable: !linkToToggle.isAvailable, // Envia o valor invertido
    );



    result.fold(
            (error) => BotToast.showText(text: "Erro: $error"),
            (_) { /* Sucesso! O socket vai atualizar a UI, não precisamos fazer nada. */ }
    );
  }






}