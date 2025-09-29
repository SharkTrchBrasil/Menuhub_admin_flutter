import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/flavor_price.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/models/option_group.dart';

import '../../../core/enums/category_type.dart';
import '../../../core/enums/foodtags.dart';
import '../../../core/enums/option_group_type.dart';
import '../../../models/image_model.dart';
import '../../../models/products/product.dart';

part 'flavor_wizard_state.dart';

class FlavorWizardCubit extends Cubit<FlavorWizardState> {
  final ProductRepository _productRepository;
  final int _storeId;

  FlavorWizardCubit({
    required ProductRepository productRepository,
    required int storeId,
  })
      : _productRepository = productRepository,
        _storeId = storeId,
        super(FlavorWizardState.initial());

  void startFlow({Product? product, required Category parentCategory}) {
    // Busca o grupo de tamanho pelo TIPO, não pelo nome (mais robusto)
    final sizeGroup = parentCategory.optionGroups.firstWhere(
          (g) => g.groupType == OptionGroupType.size,
      orElse: () =>
      const OptionGroup(name: 'Tamanho',
          items: [],
          minSelection: 1,
          maxSelection: 1,
          groupType: OptionGroupType.size),
    );

    List<FlavorPrice> prices;

    if (product != null) { // --- MODO DE EDIÇÃO ---
      final priceMap = {for (var p in product.prices) p.sizeOptionId: p};
      prices = sizeGroup.items.map((sizeOption) {
        final existingPrice = priceMap[sizeOption.id];
        return existingPrice ??
            FlavorPrice(sizeOptionId: sizeOption.id!, price: 0);
      }).toList();

      emit(FlavorWizardState(
        originalProduct: product.copyWith(prices: prices),
        product: product.copyWith(prices: prices),
        parentCategory: parentCategory,
        isEditMode: true,
      ));
    } else { // --- MODO DE CRIAÇÃO ---
      prices = sizeGroup.items.map((sizeOption) =>
          FlavorPrice(
            sizeOptionId: sizeOption.id!,
            price: 0,
          )).toList();

      final initialProduct = const Product().copyWith(prices: prices);

      emit(FlavorWizardState(
        originalProduct: initialProduct,
        product: const Product().copyWith(prices: prices),
        parentCategory: parentCategory,
      ));
    }
  }



  void nameChanged(String name) {
    emit(state.copyWith(product: state.product.copyWith(name: name)));
  }

  void descriptionChanged(String description) {
    emit(state.copyWith(product: state.product.copyWith(description: description)));
  }

  void imagesChanged(List<ImageModel> newImages) {
    emit(state.copyWith(product: state.product.copyWith(images: newImages)));
  }

  void videoChanged(ImageModel? newVideo) {
    if (newVideo == null) {
      // Usa o flag 'removeVideo: true' para limpar ambos os campos de vídeo
      emit(state.copyWith(product: state.product.copyWith(removeVideo: true)));
    } else {
      emit(state.copyWith(product: state.product.copyWith(videoFile: newVideo)));
    }
  }

  void updateFlavorPrice(FlavorPrice updatedPrice) {
    final updatedPrices = state.product.prices.map((p) {
      return p.sizeOptionId == updatedPrice.sizeOptionId ? updatedPrice : p;
    }).toList();
    emit(state.copyWith(product: state.product.copyWith(prices: updatedPrices)));
  }

  void toggleDietaryTag(FoodTag tag) {
    final newTags = Set<FoodTag>.from(state.product.dietaryTags);
    newTags.contains(tag) ? newTags.remove(tag) : newTags.add(tag);
    emit(state.copyWith(product: state.product.copyWith(dietaryTags: newTags)));
  }

  // --- LÓGICA DE SALVAR (JÁ ESTAVA CORRETA, MAS AGORA É SUPORTADA PELOS MÉTODOS ACIMA) ---

  Future<void> submitFlavor() async {
    if (state.product.name.trim().isEmpty) return;
    emit(state.copyWith(status: FormStatus.loading));

    final productToSave = state.product;
    final Future<Either<String, Product>> result;

    if (state.isEditMode) {
      final originalImageIds = state.originalProduct.images.map((img) => img.id).whereType<int>().toSet();
      final editedImageIds = productToSave.images.map((img) => img.id).whereType<int>().toSet();
      final deletedImageIds = originalImageIds.difference(editedImageIds).toList();

      result = _productRepository.updateProduct(
        _storeId,
        productToSave,
        deletedImageIds: deletedImageIds,
      );
    } else {
      result = _productRepository.createFlavorProduct(
        _storeId,
        productToSave,
        parentCategory: state.parentCategory,
        images: productToSave.images,
        videoFile: productToSave.videoFile,
      );
    }

    result.fold(
          (error) => emit(state.copyWith(status: FormStatus.error, errorMessage: error)),
          (savedProduct) {
        emit(state.copyWith(
          status: FormStatus.success,
          product: savedProduct,
          originalProduct: savedProduct, // Sincroniza o estado original
        ));
      },
    );
  }
}


