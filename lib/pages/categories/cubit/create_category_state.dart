import 'package:equatable/equatable.dart';

// Enum para controlar o tipo de categoria e o passo da pizza
enum CategoryType { mainItem, pizza }
enum PizzaCreationStep { details, size, crust, edge, availability }

class CreateCategoryState extends Equatable {
  final CategoryType? selectedType;
  final PizzaCreationStep pizzaStep;
  final String categoryName;
  // Adicione aqui as listas para os dados da pizza
  // final List<PizzaSize> sizes;

  const CreateCategoryState({
    this.selectedType,
    this.pizzaStep = PizzaCreationStep.details,
    this.categoryName = '',
    // this.sizes = const [],
  });

  CreateCategoryState copyWith({
    CategoryType? selectedType,
    bool clearSelectedType = false, // Flag para voltar à tela de escolha
    PizzaCreationStep? pizzaStep,
    String? categoryName,
  }) {
    return CreateCategoryState(
      selectedType: clearSelectedType ? null : selectedType ?? this.selectedType,
      pizzaStep: pizzaStep ?? this.pizzaStep,
      categoryName: categoryName ?? this.categoryName,
    );
  }

  @override
  List<Object?> get props => [selectedType, pizzaStep, categoryName];
}