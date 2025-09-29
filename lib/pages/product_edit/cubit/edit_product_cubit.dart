import 'package:bloc/bloc.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/image_model.dart';

import 'package:totem_pro_admin/models/products/prodcut_category_links.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:equatable/equatable.dart';

import '../../../core/enums/beverage.dart';
import '../../../core/enums/cashback_type.dart';
import '../../../core/enums/foodtags.dart';
import '../../../core/enums/product_status.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';

import '../../../models/products/product.dart';
import '../../../models/products/product_variant_link.dart';
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

  // ✅ ADICIONE ESTES DOIS NOVOS MÉTODOS
  void videoUrlChanged(String url) {
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(videoUrl: url)));
  }

  void imagesChanged(List<ImageModel> newImages) {
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(images: newImages)));
  }



  void videoChanged(ImageModel? newVideo) {
    if (newVideo == null) {
      // Se o novo vídeo for nulo, significa que o usuário removeu.
      // Usamos o flag 'removeVideo: true' para limpar ambos os campos.
      emit(state.copyWith(
        editedProduct: state.editedProduct.copyWith(removeVideo: true),
      ));
    } else {
      // Se for um novo vídeo, apenas atualizamos o videoFile.
      emit(state.copyWith(
        editedProduct: state.editedProduct.copyWith(videoFile: newVideo),
      ));
    }
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
    emit(state.copyWith(status: FormStatus.loading));


    final productWithLocalFiles = state.editedProduct;

    // A lógica para detectar imagens da galeria deletadas continua a mesma
    final originalImageIds = state.originalProduct.images.map((img) => img.id).whereType<int>().toSet();
    final editedImageIds = productWithLocalFiles.images.map((img) => img.id).whereType<int>().toSet();
    final deletedImageIds = originalImageIds.difference(editedImageIds).toList();
    debugPrint("IMAGENS DA GALERIA A DELETAR (IDs): $deletedImageIds");

    // --- ETAPA 1: Salvar a Estrutura Principal ---
    final result = await _productRepository.updateProduct(
      _storeId,
      state.editedProduct,
      deletedImageIds: deletedImageIds,
    );

    result.fold(
          (error) {
        if (!isClosed) {
          emit(state.copyWith(status: FormStatus.error, errorMessage: error));
        }
      },
          (savedProduct) {
        // --- SUCESSO NA ETAPA 1! ---
        if (!isClosed) {
          BotToast.showText(text: "Produto salvo com sucesso!");
          // Atualiza o estado imediatamente para dar feedback ao usuário
          emit(EditProductState.fromProduct(savedProduct));

          // --- ETAPA 2: Adicionar os Detalhes (Imagens dos Complementos) ---
          // Dispara os uploads em segundo plano (fire and forget)
          _uploadComplementImages(
            originalProduct: productWithLocalFiles,
            savedProduct: savedProduct,
          );
        }
      },
    );
  }

  // ✅ NOVO MÉTODO AUXILIAR PARA A ETAPA 2 (idêntico ao do WizardCubit)
  void _uploadComplementImages({
    required Product originalProduct,
    required Product savedProduct,
  }) async {
    // Itera sobre os grupos de complementos que o usuário montou na tela
    for (final originalLink in originalProduct.variantLinks ?? []) {
      // Encontra o grupo correspondente que foi salvo e agora tem um ID real
      final savedLink = savedProduct.variantLinks?.firstWhere(
            (sl) => sl.variant.id == originalLink.variant.id, // Compara por ID
        orElse: () => const ProductVariantLink.empty(),
      );

      // ✅ CORREÇÃO APLICADA AQUI
      if (savedLink != null && savedLink.variant.id != null) {
        // Itera sobre as opções dentro do grupo original
        for (final originalOption in originalLink.variant.options) {
          // Se a opção tinha um arquivo de imagem local para ser enviado
          if (originalOption.image?.file != null) {
            // Encontra a opção correspondente que foi salva
            final savedOption = savedLink.variant.options.firstWhere(
                  (so) => so.clientId == originalOption.clientId, // Compara pelo clientId
              orElse: () => const VariantOption.empty(),
            );
            if (savedOption.id != null) {
              // ✅ 2. AGUARDE O RESULTADO DO UPLOAD
              final result = await _productRepository.saveVariantOption(
                _storeId,
                savedLink.variant.id!,
                savedOption.copyWith(image: originalOption.image),
              );

              // ✅ 3. SE O UPLOAD FUNCIONOU, ATUALIZE O ESTADO NOVAMENTE
              if (result.isRight) {
                final updatedOptionWithImage = result.right;
                // Chama o método que já temos para atualizar a opção no estado
                updateOptionInLink(savedLink, updatedOptionWithImage);
              }
            }


          }
        }
      }
    }
  }




  // Future<void> saveProduct() async {
  //   emit(state.copyWith(status: FormStatus.loading));
  //
  //   // --- LÓGICA INTELIGENTE E ROBUSTA PARA DETECTAR IMAGENS DELETADAS ---
  //
  //   // 1. Pega os IDs das imagens que já existiam no servidor
  //   final originalImageIds = state.originalProduct.images
  //       .map((img) => img.id)
  //       .whereType<int>() // Filtra apenas os que não são nulos
  //       .toSet();
  //
  //   // 2. Pega os IDs das imagens que sobraram na tela de edição
  //   final editedImageIds = state.editedProduct.images
  //       .map((img) => img.id)
  //       .whereType<int>() // Filtra apenas os que não são nulos
  //       .toSet();
  //
  //   // 3. A diferença entre os dois conjuntos são os IDs das imagens que foram deletadas
  //   final deletedImageIds = originalImageIds.difference(editedImageIds).toList();
  //
  //   debugPrint("IMAGENS A DELETAR (IDs): $deletedImageIds");
  //
  //   // 4. Chama o repositório com as informações corretas
  //   final result = await _productRepository.updateProduct(
  //     _storeId,
  //     state.editedProduct,
  //     deletedImageIds: deletedImageIds, // Passa a lista de IDs a serem deletados
  //   );
  //
  //   result.fold(
  //         (error) {
  //       if (!isClosed) {
  //         emit(state.copyWith(status: FormStatus.error, errorMessage: error));
  //       }
  //     },
  //         (savedProduct) {
  //       if (!isClosed) {
  //         // Sucesso!
  //         BotToast.showText(text: "Produto salvo com sucesso!");
  //         // Atualiza o estado para que 'original' e 'editado' sejam o mesmo produto salvo
  //         // Isso "limpa" o estado de 'isDirty' e prepara para a próxima edição.
  //         emit(EditProductState.fromProduct(savedProduct));
  //       }
  //     },
  //   );
  // }
  //


  // ✅ ADICIONE ESTE MÉTODO AQUI
  void updateProduct(Product updatedProduct) {
    emit(state.copyWith(editedProduct: updatedProduct));
  }

  Future<void> addNewComplementGroup(BuildContext context) async {
    final storesState = context.read<StoresManagerCubit>().state;
    if (storesState is! StoresManagerLoaded) return;

    final newLink = await showResponsiveSidePanelGroup<ProductVariantLink>(
      context,
      panel: BlocProvider(
        create: (_) => CreateComplementGroupCubit(
          storeId: _storeId,
          productId: state.originalProduct.id,
          productRepository: _productRepository, // Renomeado de productRepository para _productRepository
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

      final updatedLinks = List<ProductVariantLink>.from(state.editedProduct.variantLinks ?? [])..add(newLink);

      emit(state.copyWith(
        editedProduct: state.editedProduct.copyWith(variantLinks: updatedLinks),
      ));
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





  void updateVariantLinkName(ProductVariantLink linkToUpdate, String newName) {
    final updatedVariant = linkToUpdate.variant.copyWith(name: newName);
    final updatedLink = linkToUpdate.copyWith(variant: updatedVariant);
    updateVariantLink(updatedLink); // Reutiliza o método que já temos!
  }

  void addOptionToLink(ProductVariantLink parentLink, VariantOption newOption) {

    final updatedOptions = List<VariantOption>.from(parentLink.variant.options)..add(newOption);

    final updatedLink = parentLink.copyWith(
      variant: parentLink.variant.copyWith(options: updatedOptions),
    );
    updateVariantLink(updatedLink);
  }


  void updateOptionInLink(ProductVariantLink parentLink, VariantOption updatedOption) {
    // 1. Mapeia a lista de links para encontrar o link pai que está sendo alterado.
    final updatedLinks = state.editedProduct.variantLinks?.map((link) {
      // Se não for o link que queremos, retorna ele sem mudanças.
      if (link.variant.id != parentLink.variant.id) {
        return link;
      }

      // Se for o link correto, atualizamos sua lista de opções.
      final updatedOptions = link.variant.options.map((option) {
        // Comparamos pelo clientId, que é um ID único e estável gerado no app.
        // Se for a opção que alteramos, usamos a versão atualizada.
        // Se não, mantemos a original.
        return option.clientId == updatedOption.clientId ? updatedOption : option;
      }).toList();

      // Retorna uma nova versão do link com as opções atualizadas.
      return link.copyWith(variant: link.variant.copyWith(options: updatedOptions));
    }).toList();

    // 2. Emite um novo estado com a lista de links atualizada.
    emit(state.copyWith(
      editedProduct: state.editedProduct.copyWith(variantLinks: updatedLinks),
    ));
  }



  void removeOptionFromLink(ProductVariantLink parentLink, VariantOption optionToRemove) {
    // Filtra a lista de opções, removendo a que foi marcada para exclusão
    final updatedOptions = parentLink.variant.options
    // ✅ CORREÇÃO: Compara pelo 'clientId'.
        .where((option) => option.clientId != optionToRemove.clientId)
        .toList();

    final updatedLink = parentLink.copyWith(
      variant: parentLink.variant.copyWith(options: updatedOptions),
    );
    updateVariantLink(updatedLink);
  }





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


  void eanChanged(String ean) {
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(ean: ean)));
  }

  void priorityChanged(String priority) {
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(priority: int.tryParse(priority) ?? 0)));
  }

  void minStockChanged(String value) {
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(minStock: int.tryParse(value) ?? 0)));
  }

  void maxStockChanged(String value) {
    emit(state.copyWith(editedProduct: state.editedProduct.copyWith(maxStock: int.tryParse(value) ?? 0)));
  }



}