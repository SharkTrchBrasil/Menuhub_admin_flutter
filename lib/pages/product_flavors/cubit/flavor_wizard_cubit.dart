import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/flavor_price.dart'; // ✅ Garanta que FlavorPrice está importado
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/models/option_group.dart';
import 'package:totem_pro_admin/models/product.dart';

import '../../../core/enums/category_type.dart';

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
    // Pega a lista de todos os tamanhos disponíveis na categoria pai
    final sizeOptions = parentCategory.optionGroups
        .firstWhere(
          (g) => g.name == 'Tamanho',
      orElse: () => OptionGroup(name: 'Tamanho', items: [], minSelection: 1 , maxSelection: 1),
    )
        .items;

    if (product != null) {
      // --- MODO DE EDIÇÃO ---

      // 1. Cria um mapa para busca rápida de preços: {id_do_tamanho: objeto_FlavorPrice}
      final priceMap = {for (var p in product.prices) p.sizeOptionId: p};

      // 2. Itera sobre todos os TAMANHOS e cria a lista de FlavorPrice
      final pricesWithData = sizeOptions.map((sizeOption) {
        final existingPrice = priceMap[sizeOption.id];
        return FlavorPrice(
          sizeOptionId: sizeOption.id!,
          price: existingPrice?.price ?? 0,
          posCode: existingPrice?.posCode,
          isAvailable: existingPrice?.isAvailable ?? true,
          id: existingPrice?.id,

        );
      }).toList();

      // 3. Atualiza o produto com a nova lista de PREÇOS preenchida
      final updatedProduct = product.copyWith(prices: pricesWithData);

      emit(FlavorWizardState(
        product: updatedProduct,
        parentCategory: parentCategory,
        isEditMode: true,
      ));

    } else {
      // --- MODO DE CRIAÇÃO ---
      // Cria uma lista inicial de FlavorPrice, um para cada tamanho
      final initialPrices = sizeOptions
          .map((sizeOption) => FlavorPrice(
        sizeOptionId: sizeOption.id!,
        price: 0,
      ))
          .toList();

      // Inicia o estado com a lista de PREÇOS
      emit(FlavorWizardState(
        product: Product(prices: initialPrices),
        parentCategory: parentCategory,
      ));
    }
  }

  void updateProduct(Product updatedProduct) {
    emit(state.copyWith(product: updatedProduct));
  }


  void updateFlavorPrice(FlavorPrice updatedPrice) {
    final updatedPrices = state.product.prices.map((flavorPrice) {
      if (flavorPrice.sizeOptionId == updatedPrice.sizeOptionId) {
        return updatedPrice; // Substitui o preço antigo pelo novo
      }
      return flavorPrice;
    }).toList();

    emit(state.copyWith(
      product: state.product.copyWith(prices: updatedPrices),
    ));
  }

  Future<void> submitFlavor() async {
    if (state.product.name.trim().isEmpty) return;

    emit(state.copyWith(status: FormStatus.loading));

    final Future<Either<String, Product>> result;

    if (state.isEditMode) {
      result = _productRepository.updateProduct(_storeId, state.product);
    } else {
      result = _productRepository.createFlavorProduct(
        _storeId,
        state.product,
        parentCategory: state.parentCategory,
      );
    }

    result.fold(
          (error) {
        if (!isClosed) emit(state.copyWith(status: FormStatus.error, errorMessage: error));
      },
          (success) {
        if (!isClosed) emit(state.copyWith(status: FormStatus.success));
      },
    );
  }
}