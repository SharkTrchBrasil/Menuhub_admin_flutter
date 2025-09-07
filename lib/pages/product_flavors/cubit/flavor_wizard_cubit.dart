import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/core/enums/category_type.dart';
import 'package:totem_pro_admin/models/option_group.dart';
import 'package:totem_pro_admin/models/product.dart';

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

  // ✅ MÉTODO 'startFlow' CORRIGIDO E COMPLETO
  void startFlow({Product? product, required Category parentCategory}) {
    // Pega a lista de todos os tamanhos disponíveis na categoria pai
    final sizeOptions = parentCategory.optionGroups
        .firstWhere(
          (g) => g.name == 'Tamanho',
      orElse: () => OptionGroup(name: 'Tamanho', items: [], minSelection: 0, maxSelection: 0),
    )
        .items;

    if (product != null) {
      // --- MODO DE EDIÇÃO ---

      // 1. Cria um mapa para busca rápida de preços: {id_do_tamanho: objeto_price}
      final priceMap = {for (var p in product.prices) p.sizeOptionId: p};

      // 2. Itera sobre todos os TAMANHOS disponíveis na categoria
      final linksWithData = sizeOptions.map((sizeOption) {
        // 3. Para cada tamanho, pega as informações de preço existentes ou usa valores padrão
        final existingPriceInfo = priceMap[sizeOption.id];
        final price = existingPriceInfo?.price ?? 0;
        // (Adapte aqui para pegar o pos_code se ele existir no seu modelo FlavorPrice)
        // final posCode = existingPriceInfo?.posCode ?? '';

        return ProductCategoryLink(
          categoryId: parentCategory.id!,
          optionItemId: sizeOption.id,
          price: price,
          // posCode: posCode,
          product: product,
          category: parentCategory,
        );
      }).toList();

      // 4. Atualiza o produto com a nova lista de links preenchida
      final updatedProduct = product.copyWith(categoryLinks: linksWithData);

      emit(FlavorWizardState(
        product: updatedProduct,
        parentCategory: parentCategory,
        isEditMode: true,
      ));

    } else {
      // --- MODO DE CRIAÇÃO ---
      final initialLinks = sizeOptions
          .map((sizeOption) => ProductCategoryLink(
        categoryId: parentCategory.id!,
        optionItemId: sizeOption.id,
        price: 0,
        product: Product(),
        category: parentCategory,
      ))
          .toList();

      emit(FlavorWizardState(
        product: Product(categoryLinks: initialLinks),
        parentCategory: parentCategory,
      ));
    }
  }

  // ✅ O MÉTODO startEditFlow() FOI REMOVIDO, POIS A LÓGICA AGORA ESTÁ NO startFlow()

  void updateProduct(Product updatedProduct) {
    emit(state.copyWith(product: updatedProduct));
  }

  // Este método pode ser removido ou adaptado, pois a lógica de preço agora está na UI
  void updatePriceForSize(int optionItemId, int priceInCents) {
    final updatedLinks = state.product.categoryLinks.map((link) {
      if (link.optionItemId == optionItemId) {
        return link.copyWith(price: priceInCents);
      }
      return link;
    }).toList();
    updateProduct(state.product.copyWith(categoryLinks: updatedLinks));
  }

  Future<void> submitFlavor() async {
    if (state.product.name.trim().isEmpty) return;

    emit(state.copyWith(status: FormStatus.loading));

    final Future<Either<String, Product>> result;

    // A lógica de submit já está correta, não precisa mudar
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