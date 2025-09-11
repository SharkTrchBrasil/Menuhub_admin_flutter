// ARQUIVO: category_link_state.dart
part of 'category_link_cubit.dart';

class CategoryLinkState extends Equatable {
  final int currentStep;
  final FormStatus status;
  final ProductCategoryLink linkData;

  const CategoryLinkState({
    this.currentStep = 1,
    this.status = FormStatus.initial,
    required this.linkData,
  });

  factory CategoryLinkState.initial(Product product) {
    return CategoryLinkState(
      linkData: ProductCategoryLink(
          categoryId: 0,
          price: product.price ?? 0,
          product: product,
          category: null
      ),
    );
  }

  CategoryLinkState copyWith({
    int? currentStep,
    FormStatus? status,
    ProductCategoryLink? linkData,
  }) {
    return CategoryLinkState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      linkData: linkData ?? this.linkData,
    );
  }

  @override
  List<Object?> get props => [currentStep, status, linkData];
}
