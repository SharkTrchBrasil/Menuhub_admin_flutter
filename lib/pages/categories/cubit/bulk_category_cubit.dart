import 'package:bloc/bloc.dart';

import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

import '../../../models/prodcut_category_links.dart';
import 'bulk_category_state.dart';

class BulkAddToCategoryCubit extends Cubit<BulkAddToCategoryState> {
  final ProductRepository _productRepository;
  final int _storeId;

  BulkAddToCategoryCubit({
    required ProductRepository productRepository,
    required int storeId,
    required List<Product> selectedProducts,
  })  : _productRepository = productRepository,
        _storeId = storeId,
        super(BulkAddToCategoryState.initial(selectedProducts));

  void selectCategory(Category category) {
    emit(state.copyWith(targetCategory: category));
  }

  void updatePriceForProduct(int productId, int price) {
    final newUpdates = Map<int, Map<String, dynamic>>.from(state.priceUpdates);
    newUpdates.update(
      productId,
          (value) => {...value, 'price': price},
      ifAbsent: () => {'price': price},
    );
    emit(state.copyWith(priceUpdates: newUpdates));
  }

  void updatePosCodeForProduct(int productId, String posCode) {
    final newUpdates = Map<int, Map<String, dynamic>>.from(state.priceUpdates);
    newUpdates.update(
      productId,
          (value) => {...value, 'pos_code': posCode},
      ifAbsent: () => {'pos_code': posCode},
    );
    emit(state.copyWith(priceUpdates: newUpdates));
  }

  Future<void> submit() async {
    if (state.targetCategory == null) return;
    emit(state.copyWith(status: FormStatus.loading));

    final productsPayload = state.selectedProducts.map((product) {
      final updates = state.priceUpdates[product.id!] ?? {};

      // Lógica segura para encontrar o vínculo original, se existir
      ProductCategoryLink? originalLink;
      try {
        originalLink = product.categoryLinks.firstWhere(
              (link) => link.category?.id == state.targetCategory!.id,
        );
      } catch (e) {
        originalLink = null;
      }

      // Monta o payload para este produto específico
      return {
        'product_id': product.id!,
        // Prioridade da informação: 1º o que o usuário digitou, 2º o preço que já existia no link, 3º o preço base do produto, 4º zero.
        'price': updates['price'] ?? originalLink?.price ?? product.price ?? 0,
        'pos_code': updates['pos_code'] ?? originalLink?.posCode,
      };
    }).toList();

    // ✅ A ÚNICA MUDANÇA É AQUI: Chamar o método de MOVER
    final result = await _productRepository.bulkUpdateProductCategory(
      storeId: _storeId,
      targetCategoryId: state.targetCategory!.id!,
      products: productsPayload,
    );

    result.fold(
          (error) => emit(state.copyWith(status: FormStatus.error, errorMessage: error)),
          (_) => emit(state.copyWith(status: FormStatus.success)),
    );
  }
}