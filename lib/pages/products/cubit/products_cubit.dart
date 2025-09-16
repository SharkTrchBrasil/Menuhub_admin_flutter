import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';

import '../../../core/enums/product_status.dart';
import '../../../models/product.dart';
import '../../../repositories/product_repository.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final CategoryRepository _categoryRepository;
  final ProductRepository _productRepository; // ✅ Adicione o repositório de produtos

  ProductsCubit({
    required CategoryRepository categoryRepository,
    required ProductRepository productRepository, // ✅ Adicione aqui
  })  : _categoryRepository = categoryRepository,
        _productRepository = productRepository, // ✅ Adicione aqui
        super(ProductsInitial());

  Future<void> updateCategoryName(int storeId, Category category, String newName) async {
    if (newName.trim().isEmpty || newName == category.name) {
      return;
    }
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
    final result = await _productRepository.updateProduct(storeId, updatedProduct);
    result.fold(
          (error) => emit(ProductsActionFailure(error)),
          (success) => emit(const ProductsActionSuccess("Estoque atualizado!")),
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

    // Determina o novo status: se está ATIVO vira INATIVO, e vice-versa.
    final newStatus = product.status == ProductStatus.ACTIVE
        ? ProductStatus.INACTIVE
        : ProductStatus.ACTIVE;

    final updatedProduct = product.copyWith(status: newStatus);

    final result = await _productRepository.updateProduct(storeId, updatedProduct);

    result.fold(
          (error) => emit(ProductsActionFailure(error)),
          (success) => emit(const ProductsActionSuccess("Status do produto atualizado!")),
    );
  }


}





