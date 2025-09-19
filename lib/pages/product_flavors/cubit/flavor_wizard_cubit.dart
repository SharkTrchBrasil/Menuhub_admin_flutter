import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/flavor_price.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/models/option_group.dart';
import 'package:totem_pro_admin/models/product.dart';
import '../../../core/enums/category_type.dart';
import '../../../core/enums/option_group_type.dart';

part 'flavor_wizard_state.dart';

class FlavorWizardCubit extends Cubit<FlavorWizardState> {
  final ProductRepository _productRepository;
  final int _storeId;

  FlavorWizardCubit({
    required ProductRepository productRepository,
    required int storeId,
  })  : _productRepository = productRepository,
        _storeId = storeId,
        super(FlavorWizardState.initial());

  void startFlow({Product? product, required Category parentCategory}) {
    // Busca o grupo de tamanho pelo TIPO, não pelo nome (mais robusto)
    final sizeGroup = parentCategory.optionGroups.firstWhere(
          (g) => g.groupType == OptionGroupType.size,
      orElse: () => const OptionGroup(name: 'Tamanho', items: [], minSelection: 1, maxSelection: 1, groupType: OptionGroupType.size),
    );

    List<FlavorPrice> prices;

    if (product != null) { // --- MODO DE EDIÇÃO ---
      final priceMap = {for (var p in product.prices) p.sizeOptionId: p};
      prices = sizeGroup.items.map((sizeOption) {
        final existingPrice = priceMap[sizeOption.id];
        return existingPrice ?? FlavorPrice(sizeOptionId: sizeOption.id!, price: 0);
      }).toList();

      emit(FlavorWizardState(
        originalProduct: product.copyWith(prices: prices),
        product: product.copyWith(prices: prices),
        parentCategory: parentCategory,
        isEditMode: true,
      ));

    } else { // --- MODO DE CRIAÇÃO ---
      prices = sizeGroup.items.map((sizeOption) => FlavorPrice(
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

  void updateProduct(Product updatedProduct) {
    emit(state.copyWith(product: updatedProduct));
  }

  void updateFlavorPrice(FlavorPrice updatedPrice) {
    final updatedPrices = state.product.prices.map((p) {
      return p.sizeOptionId == updatedPrice.sizeOptionId ? updatedPrice : p;
    }).toList();
    emit(state.copyWith(product: state.product.copyWith(prices: updatedPrices)));
  }

  // ✅ SUBSTITUA SEU MÉTODO submitFlavor POR ESTE
  Future<void> submitFlavor() async {
    if (state.product.name.trim().isEmpty) return;

    emit(state.copyWith(status: FormStatus.loading));
    final productToSave = state.product;

    final Future<Either<String, Product>> result;
    if (state.isEditMode) {
      // Lógica "inteligente" para encontrar imagens deletadas
      final originalImageUrls = state.originalProduct.images.where((img) => img.url != null).map((img) => img.url).toSet();
      final editedImageUrls = state.product.images.where((img) => img.url != null).map((img) => img.url).toSet();
      final deletedImageUrls = originalImageUrls.difference(editedImageUrls);
      final deletedImageIds = deletedImageUrls.map((url) {
        try {
          return int.tryParse(Uri.parse(url!).pathSegments.last.split('.').first);
        } catch (e) { return null; }
      }).whereType<int>().toList();

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
        images: productToSave.images, // Passa as imagens para a criação
      );
    }

    result.fold(
          (error) => emit(state.copyWith(status: FormStatus.error, errorMessage: error)),
          (savedProduct) {
        // Ao salvar com sucesso, atualiza o estado original e o de edição
        emit(state.copyWith(
            status: FormStatus.success,
            product: savedProduct,
            originalProduct: savedProduct
        ));
      },
    );
  }
}









