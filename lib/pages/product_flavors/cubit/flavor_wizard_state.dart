part of 'flavor_wizard_cubit.dart';

class FlavorWizardState extends Equatable {
  final Product originalProduct;
  final Product product;
  final Category parentCategory;
  final FormStatus status;
  final bool isEditMode;


  // ✅ 1. ADICIONE A PROPRIEDADE PARA A MENSAGEM DE ERRO
  final String? errorMessage;





  const FlavorWizardState({
    required this.originalProduct,
    required this.product,
    required this.parentCategory,
    this.status = FormStatus.initial,
    this.isEditMode = false,
    this.errorMessage,

  });

  factory FlavorWizardState.initial() {
    final initialProduct = Product(price: 0, images: const []);
    return FlavorWizardState(
      originalProduct: initialProduct, // ✅ INICIALIZE AQUI
      product: initialProduct,
      parentCategory: const Category(id: 0, name: '', type: CategoryType.CUSTOMIZABLE),
    );
  }

  FlavorWizardState copyWith({
    Product? originalProduct,
    Product? product,
    Category? parentCategory,
    FormStatus? status,
    bool? isEditMode,
    String? errorMessage,
    Map<int, int>? pricesBySize,
  }) {
    return FlavorWizardState(
      originalProduct: originalProduct ?? this.originalProduct,
      product: product ?? this.product,
      parentCategory: parentCategory ?? this.parentCategory,
      status: status ?? this.status,
      isEditMode: isEditMode ?? this.isEditMode,
      errorMessage: errorMessage ?? this.errorMessage,

    );
  }

  @override
  List<Object?> get props => [originalProduct, product, parentCategory, status, isEditMode, errorMessage];
}