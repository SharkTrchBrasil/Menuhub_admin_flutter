import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/models/variant_option.dart';

import '../../../models/products/product.dart';

part 'add_option_state.dart';

class AddOptionCubit extends Cubit<AddOptionState> {
  // Recebe as listas para o fluxo de "Copiar"
  final List<Product> allProducts;
  final List<Variant> allVariants;

  AddOptionCubit({required this.allProducts, required this.allVariants})
      : super(const AddOptionState());

  // Navega para a tela de "Criar Novo"
  void showCreateNewFlow() {
    emit(state.copyWith(step: AddOptionStep.creationForm));
  }

  // Navega para a tela de "Copiar Existente"
  void showCopyFlow() {
    emit(state.copyWith(step: AddOptionStep.copyList));
  }

  // Volta para a tela de escolha inicial
  void goBackToChoice() {
    emit(state.copyWith(step: AddOptionStep.initialChoice));
  }

  // Método que será chamado pelo formulário quando o usuário
  // preencher os dados e clicar em "Adicionar".
  void submitNewOption(VariantOption newOption) {
    // Emite o estado de sucesso com o novo complemento criado.
    // A tela que chamou o wizard vai receber este resultado.
    emit(state.copyWith(status: FormStatus.success, result: newOption));
  }

// (Futuramente, podemos adicionar a lógica de busca e seleção para o fluxo de cópia aqui)
}