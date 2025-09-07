part of 'edit_product_cubit.dart';

class EditProductState extends Equatable {
  final Product originalProduct;
  final Product editedProduct;
  final FormStatus status;
  final String? errorMessage;

  const EditProductState({
    required this.originalProduct,
    required this.editedProduct,
    this.status = FormStatus.initial,
    this.errorMessage,
  });

  factory EditProductState.fromProduct(Product product) {
    return EditProductState(
      originalProduct: product,
      editedProduct: product,
    );
  }

  bool get isDirty => originalProduct != editedProduct;

  // ✅ --- MÉTODO COPYWITH CORRIGIDO E COMPLETO --- ✅
  EditProductState copyWith({
    Product? originalProduct, // 1. PARÂMETRO ADICIONADO
    Product? editedProduct,
    FormStatus? status,
    String? errorMessage,
  }) {
    return EditProductState(
      originalProduct: originalProduct ?? this.originalProduct, // 2. LÓGICA ADICIONADA
      editedProduct: editedProduct ?? this.editedProduct,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [originalProduct, editedProduct, status, errorMessage];
}