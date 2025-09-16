import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import '../../../core/enums/bulk_action_type.dart';
import '../../../models/prodcut_category_links.dart';
import 'bulk_category_state.dart';

class BulkAddToCategoryCubit extends Cubit<BulkAddToCategoryState> {
  final ProductRepository _productRepository;
  final int _storeId;
  final BulkActionType _actionType;


  static const int _newProductKey = -1;

  BulkAddToCategoryCubit({
    required ProductRepository productRepository,
    required int storeId,
    required List<Product> selectedProducts,
    required BulkActionType actionType,
  })  : _productRepository = productRepository,
        _storeId = storeId,
        _actionType = actionType,
        super(BulkAddToCategoryState.initial(selectedProducts));

  void selectCategory(Category category) {
    emit(state.copyWith(targetCategory: category));
  }

  void togglePromotionForProduct(int? productId, bool isOnPromotion) {
    final key = productId ?? _newProductKey;
    final newUpdates = Map<int, Map<String, dynamic>>.from(state.priceUpdates);

    newUpdates.update(
      key,
          (value) {
        if (!isOnPromotion) {
          value.remove('promotionalPrice');
        }
        return {...value, 'isOnPromotion': isOnPromotion};
      },
      ifAbsent: () => {'isOnPromotion': isOnPromotion},
    );
    emit(state.copyWith(priceUpdates: newUpdates));
  }

  void updatePromotionalPriceForProduct(int? productId, int? promotionalPrice) {
    final key = productId ?? _newProductKey;
    final newUpdates = Map<int, Map<String, dynamic>>.from(state.priceUpdates);
    newUpdates.update(
      key,
          (value) => {...value, 'promotionalPrice': promotionalPrice},
      ifAbsent: () => {'promotionalPrice': promotionalPrice},
    );
    emit(state.copyWith(priceUpdates: newUpdates));
  }

  void updatePriceForProduct(int? productId, int price) {

    // ✅ PONTO DE CHECAGEM 1: O preço digitado está chegando aqui?
    print('DEBUG 1: [BulkCubit] updatePriceForProduct recebeu o preço: $price');

    final key = productId ?? _newProductKey;
    final newUpdates = Map<int, Map<String, dynamic>>.from(state.priceUpdates);
    newUpdates.update(
      key,
          (value) => {...value, 'price': price},
      ifAbsent: () => {'price': price},
    );
    emit(state.copyWith(priceUpdates: newUpdates));
  }

  void updatePosCodeForProduct(int? productId, String posCode) {
    final key = productId ?? _newProductKey;
    final newUpdates = Map<int, Map<String, dynamic>>.from(state.priceUpdates);
    newUpdates.update(
      key,
          (value) => {...value, 'pos_code': posCode},
      ifAbsent: () => {'pos_code': posCode},
    );
    emit(state.copyWith(priceUpdates: newUpdates));
  }

  Future<void> submit() async {
    final targetCategory = state.targetCategory;
    if (targetCategory == null) return;

    if (_actionType == BulkActionType.move) {
      await _submitMoveAction(targetCategory);
    } else {
      _submitAddAction(targetCategory);
    }
  }

  Future<void> _submitMoveAction(Category targetCategory) async {
    emit(state.copyWith(status: FormStatus.loading));
    final productsPayload = _buildPayload(targetCategory);

    final Either<String, void> result =
    await _productRepository.bulkUpdateProductCategory(
      storeId: _storeId,
      targetCategoryId: targetCategory.id!,
      products: productsPayload,
    );

    result.fold(
          (error) => emit(state.copyWith(status: FormStatus.error, errorMessage: error)),
          (_) => emit(state.copyWith(status: FormStatus.success)),
    );
  }


  void _submitAddAction(Category targetCategory) {
    // Como neste fluxo só temos um produto, pegamos o primeiro.
    final product = state.selectedProducts.first;
    // Usa o ID do produto ou a chave temporária para encontrar as atualizações
    final key = product.id ?? _newProductKey;
    final updates = state.priceUpdates[key] ?? {};
    // ✅ PONTO DE CHECAGEM 2: O mapa 'updates' contém o preço correto antes de criar o link?
    print('DEBUG 2: [BulkCubit] _submitAddAction está usando o mapa de updates: $updates');

    // A lógica para encontrar o link original (se houver) é útil para o fallback
    ProductCategoryLink? originalLink;
    try {
      originalLink = product.categoryLinks.firstWhere(
            (link) => link.categoryId == targetCategory.id,
      );
    } catch (e) {
      originalLink = null;
    }

    final newLinks = [
      ProductCategoryLink(
        product: product,
        productId: product.id,
        category: targetCategory,
        categoryId: targetCategory.id!,

        price: updates['price'] ?? originalLink?.price ?? product.price ?? 0,
        posCode: updates['pos_code'] ?? originalLink?.posCode,
        isOnPromotion: updates['isOnPromotion'] ?? originalLink?.isOnPromotion ?? false,
        promotionalPrice: updates['promotionalPrice'] ?? originalLink?.promotionalPrice,
        isAvailable: true,
      )
    ];
    // ✅ CORREÇÃO APLICADA AQUI
    // Agora estamos imprimindo o preço do link que acabamos de criar.
    print('DEBUG 3: [BulkCubit] _submitAddAction criou um link com o preço: ${newLinks.first.price}');

    emit(state.copyWith(addResult: newLinks));
  }

  List<Map<String, dynamic>> _buildPayload(Category targetCategory) {
    return state.selectedProducts.map((product) {
      final updates = state.priceUpdates[product.id!] ?? {};
      ProductCategoryLink? originalLink;
      try {
        originalLink = product.categoryLinks.firstWhere(
              (link) => link.categoryId == targetCategory.id,
        );
      } catch (e) {
        originalLink = null;
      }
      return {
        'product_id': product.id!,
        'price': updates['price'] ?? originalLink?.price ?? product.price ?? 0,
        'pos_code': updates['pos_code'] ?? originalLink?.posCode,
        'is_on_promotion': updates['isOnPromotion'] ?? originalLink?.isOnPromotion ?? false,
        'promotional_price': updates['promotionalPrice'] ?? originalLink?.promotionalPrice,
      };
    }).toList();
  }
}