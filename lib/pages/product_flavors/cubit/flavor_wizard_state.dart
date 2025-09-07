part of 'flavor_wizard_cubit.dart';

class FlavorWizardState extends Equatable {
  final Product product;
  final Category parentCategory;
  final FormStatus status;
  final bool isEditMode;


  // ✅ 1. ADICIONE A PROPRIEDADE PARA A MENSAGEM DE ERRO
  final String? errorMessage;

  final Map<int, int> pricesBySize;



  const FlavorWizardState({
    required this.product,
    required this.parentCategory,
    this.status = FormStatus.initial,
    this.isEditMode = false,
    this.errorMessage,
    this.pricesBySize = const {},
  });

  factory FlavorWizardState.initial() => FlavorWizardState(
    product: Product(price: 0),
    parentCategory: const Category(id: 0, name: '', type: CategoryType.CUSTOMIZABLE),
  );

  FlavorWizardState copyWith({
    Product? product,
    Category? parentCategory,
    FormStatus? status,
    bool? isEditMode,
    String? errorMessage,
    Map<int, int>? pricesBySize,
  }) {
    return FlavorWizardState(
      product: product ?? this.product,
      parentCategory: parentCategory ?? this.parentCategory,
      status: status ?? this.status,
      isEditMode: isEditMode ?? this.isEditMode,
      errorMessage: errorMessage ?? this.errorMessage,
      pricesBySize: pricesBySize ?? this.pricesBySize,
    );
  }

  @override
  List<Object?> get props => [product, parentCategory, status, isEditMode, errorMessage, pricesBySize];
}