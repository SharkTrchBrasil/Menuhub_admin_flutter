import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_category_state.dart';

// Re-exporte o enum para facilitar o import
export 'create_category_state.dart' show CategoryType, PizzaCreationStep;

class CreateCategoryCubit extends Cubit<CreateCategoryState> {
  CreateCategoryCubit() : super(const CreateCategoryState());

  void selectType(CategoryType type) {
    emit(state.copyWith(selectedType: type));
  }

  void changeType() {
    emit(state.copyWith(clearSelectedType: true, pizzaStep: PizzaCreationStep.details));
  }

  void updateCategoryName(String name) {
    emit(state.copyWith(categoryName: name));
  }

  void goToPizzaStep(PizzaCreationStep step) {
    emit(state.copyWith(pizzaStep: step));
  }

  void nextPizzaStep() {
    final currentStepIndex = PizzaCreationStep.values.indexOf(state.pizzaStep);
    if (currentStepIndex < PizzaCreationStep.values.length - 1) {
      final nextStep = PizzaCreationStep.values[currentStepIndex + 1];
      emit(state.copyWith(pizzaStep: nextStep));
    } else {
      // Chegou ao final, pode chamar o save
      saveCategory();
    }
  }

  Future<void> saveCategory() async {
    if (state.selectedType == CategoryType.mainItem) {
      print("SALVANDO CATEGORIA DE ITEM PRINCIPAL: ${state.categoryName}");
      // Lógica de API para salvar item principal...
    } else if (state.selectedType == CategoryType.pizza) {
      print("SALVANDO CATEGORIA DE PIZZA COMPLETA: ${state.categoryName}");
      // Lógica para pegar todos os dados (nome, tamanhos, massas...) e salvar na API
    }
  }
}