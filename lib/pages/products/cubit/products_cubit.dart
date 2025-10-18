import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';
import 'package:totem_pro_admin/core/enums/inventory_stock.dart';
import 'package:totem_pro_admin/core/enums/product_status.dart';
import 'package:totem_pro_admin/models/products/product.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final CategoryRepository _categoryRepository;
  final ProductRepository _productRepository;

  ProductsCubit({
    required CategoryRepository categoryRepository,
    required ProductRepository productRepository,
  })  : _categoryRepository = categoryRepository,
        _productRepository = productRepository,
        super(ProductsInitial());


// Em: cubits/products_cubit.dart

  /// Pausa múltiplos produtos de uma vez
  Future<void> pauseProducts(int storeId, List<int> productIds) async {
    emit(ProductsActionInProgress());
    try {
      await _productRepository.updateProductsAvailability(
        storeId: storeId,
        productIds: productIds,
        isAvailable: false,
      );
      emit(const ProductsActionSuccess("Produtos pausados com sucesso!"));
    } catch (error) {
      emit(ProductsActionFailure(error.toString()));
    }
  }

  /// Ativa múltiplos produtos de uma vez
  Future<void> activateProducts(int storeId, List<int> productIds) async {
    emit(ProductsActionInProgress());
    try {
      await _productRepository.updateProductsAvailability(
        storeId: storeId,
        productIds: productIds,
        isAvailable: true,
      );
      emit(const ProductsActionSuccess("Produtos ativados com sucesso!"));
    } catch (error) {
      emit(ProductsActionFailure(error.toString()));
    }
  }

  /// Arquiva múltiplos produtos de uma vez
  Future<void> archiveProducts(int storeId, List<int> productIds) async {
    emit(ProductsActionInProgress());
    try {
      await _productRepository.archiveProducts(
        storeId: storeId,
        productIds: productIds,
      );
      emit(const ProductsActionSuccess("Produtos arquivados com sucesso!"));
    } catch (error) {
      emit(ProductsActionFailure(error.toString()));
    }
  }





  Future<void> addStockMovement({
    required int storeId,
    required Product product,
    required int quantity,
    required StockOperationType operationType,
    int? cost,
  }) async {
    if (!product.controlStock) {
      emit(const ProductsActionFailure("Este produto não controla estoque."));
      return;
    }
    emit(ProductsActionInProgress());
    final currentStock = product.stockQuantity;
    Product updatedProduct;

    if (operationType == StockOperationType.add) {
      updatedProduct = product.copyWith(
        stockQuantity: currentStock + quantity,
        costPrice: cost,
      );
    } else {
      final newQuantity = currentStock - quantity;
      if (newQuantity < 0) {
        emit(ProductsActionFailure("A baixa excede a quantidade em estoque ($currentStock un)."));
        return;
      }
      updatedProduct = product.copyWith(stockQuantity: newQuantity);
    }

    final result = await _productRepository.updateProduct(storeId, updatedProduct, deletedImageIds: []);
    result.fold(
          (error) => emit(ProductsActionFailure(error)),
          (success) => emit(const ProductsActionSuccess("Estoque atualizado com sucesso!")),
    );
  }

  Future<void> updateCategoryName(int storeId, Category category, String newName) async {
    if (newName.trim().isEmpty || newName == category.name) return;
    emit(ProductsActionInProgress());
    final updatedCategory = category.copyWith(name: newName.trim());
    final result = await _categoryRepository.updateCategory(storeId, updatedCategory);
    result.fold(
          (error) => emit(ProductsActionFailure("Erro ao salvar: $error")),
          (success) => emit(const ProductsActionSuccess("Nome da categoria atualizado!")),
    );
  }

  Future<void> toggleCategoryStatus(int storeId, Category category) async {
    emit(ProductsActionInProgress());
    final updatedCategory = category.copyWith(active: !category.active);
    final result = await _categoryRepository.updateCategory(storeId, updatedCategory);
    result.fold(
          (error) => emit(ProductsActionFailure(error)),
          (success) => emit(const ProductsActionSuccess("Status da categoria atualizado!")),
    );
  }

  Future<void> deleteCategory(int storeId, Category category) async {
    emit(ProductsActionInProgress());
    final result = await _categoryRepository.deleteCategory(storeId, category.id!);
    result.fold(
          (error) => emit(ProductsActionFailure('Erro ao excluir: error')),
          (success) => emit(ProductsActionSuccess('Categoria "${category.name}" excluída.')),
    );
  }

  Future<void> updateProductPriceInCategory({
    required int storeId,
    required int productId,
    required int categoryId,
    required int newPrice,
  }) async {
    emit(ProductsActionInProgress());
    final result = await _productRepository.updateProductCategoryPrice(
      storeId: storeId,
      productId: productId,
      categoryId: categoryId,
      newPrice: newPrice,
    );
    result.fold(
          (error) => emit(ProductsActionFailure(error)),
          (success) => emit(const ProductsActionSuccess("Preço atualizado!")),
    );
  }

  Future<void> toggleAvailabilityInCategory({
    required int storeId,
    required Product product,
    required Category parentCategory,
  }) async {
    emit(ProductsActionInProgress());
    final link = product.categoryLinks.firstWhere((l) => l.categoryId == parentCategory.id);
    final result = await _productRepository.toggleLinkAvailability(
      storeId: storeId,
      productId: product.id!,
      categoryId: parentCategory.id!,
      isAvailable: !link.isAvailable,
    );
    result.fold(
          (error) => emit(ProductsActionFailure(error)),
          (success) => emit(const ProductsActionSuccess("Status do produto atualizado nesta categoria!")),
    );
  }

  Future<void> removeProductFromCategory({
    required int storeId,
    required int productId,
    required int categoryId,
  }) async {
    emit(ProductsActionInProgress());
    final result = await _productRepository.removeProductFromCategory(
      storeId: storeId,
      productId: productId,
      categoryId: categoryId,
    );
    result.fold(
          (error) => emit(ProductsActionFailure(error)),
          (success) => emit(const ProductsActionSuccess("Produto removido da categoria.")),
    );
  }

  Future<void> toggleProductStatus(int storeId, Product product) async {
    emit(ProductsActionInProgress());
    final newStatus = product.status == ProductStatus.ACTIVE ? ProductStatus.INACTIVE : ProductStatus.ACTIVE;
    final updatedProduct = product.copyWith(status: newStatus);
    final result = await _productRepository.updateProduct(storeId, updatedProduct, deletedImageIds: []);
    result.fold(
          (error) => emit(ProductsActionFailure(error)),
          (success) => emit(const ProductsActionSuccess("Status do produto atualizado!")),
    );
  }

  // ✅ MÉTODO RESTAURADO
  Future<void> updateStock({
    required int storeId,
    required Product product,
    required int newQuantity,
  }) async {
    final newControlStatus = newQuantity > 0;
    if (product.stockQuantity == newQuantity && product.controlStock == newControlStatus) return;

    emit(ProductsActionInProgress());
    final updatedProduct = product.copyWith(
      stockQuantity: newQuantity,
      controlStock: newControlStatus,
    );
    final result = await _productRepository.updateProduct(storeId, updatedProduct, deletedImageIds: []);
    result.fold(
          (error) => emit(ProductsActionFailure(error)),
          (success) => emit(const ProductsActionSuccess("Estoque atualizado!")),
    );
  }

  // ✅ MÉTODO RESTAURADO
  Future<void> adjustStock({
    required int storeId,
    required Product product,
    required int newQuantity,
    required int newMinStock,
    required bool controlStock,
  }) async {
    if (product.stockQuantity == newQuantity &&
        product.minStock == newMinStock &&
        product.controlStock == controlStock) {
      return;
    }

    emit(ProductsActionInProgress());
    final updatedProduct = product.copyWith(
      stockQuantity: newQuantity,
      minStock: newMinStock,
      controlStock: controlStock,
    );

    final result = await _productRepository.updateProduct(
        storeId, updatedProduct, deletedImageIds: []);
    result.fold(
          (error) => emit(ProductsActionFailure(error)),
          (success) =>
          emit(const ProductsActionSuccess("Estoque ajustado com sucesso!")),
    );
  }




}