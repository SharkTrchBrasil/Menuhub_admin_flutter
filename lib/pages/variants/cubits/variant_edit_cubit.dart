// features/variants/cubit/variant_edit_cubit.dart

// ✅ COLOQUE TODAS AS IMPORTAÇÕES AQUI
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/enums/variant_edit_status.dart';
import '../../../models/product_variant_link.dart';
import '../../../models/variant.dart';
import '../../../models/variant_option.dart';
import '../../../repositories/product_repository.dart';


// ✅ INCLUA O ARQUIVO STATE COMO UMA PARTE
part 'variant_edit_state.dart';

class VariantEditCubit extends Cubit<VariantEditState> {
  final ProductRepository _productRepository;
  final int storeId;

  VariantEditCubit({
    required Variant initialVariant,
    required ProductRepository productRepository,
    required this.storeId,
  }) : _productRepository = productRepository,
        super(VariantEditState.initial(initialVariant));


  // ✅ ESTES MÉTODOS JÁ EXISTEM E ESTÃO CORRETOS. VAMOS USÁ-LOS.
  void updateOption(int index, VariantOption updatedOption) {
    final updatedOptions = List<VariantOption>.from(state.editableVariant.options);
    if (index >= 0 && index < updatedOptions.length) {
      updatedOptions[index] = updatedOption;
      final updatedVariant = state.editableVariant.copyWith(options: updatedOptions);
      emit(state.copyWith(editableVariant: updatedVariant));
    }
  }

  void removeOption(VariantOption optionToRemove) {
    final updatedOptions = List<VariantOption>.from(state.editableVariant.options)
      ..removeWhere((opt) => opt == optionToRemove); // ou use um ID único se tiver
    final updatedVariant = state.editableVariant.copyWith(options: updatedOptions);
    emit(state.copyWith(editableVariant: updatedVariant));
  }













  // --- MÉTODOS PARA MODIFICAR O GRUPO ---

  void nameChanged(String newName) {
    final updatedVariant = state.editableVariant.copyWith(name: newName);
    emit(state.copyWith(editableVariant: updatedVariant));
  }

  void toggleAvailability() {
    final currentStatus = state.editableVariant.available;
    final updatedVariant = state.editableVariant.copyWith(available: !currentStatus);
    emit(state.copyWith(editableVariant: updatedVariant));
  }

  // --- MÉTODOS PARA GERENCIAR OS COMPLEMENTOS (VariantOption) ---

  void addOption(VariantOption newOption) {
    final updatedOptions = List<VariantOption>.from(state.editableVariant.options)..add(newOption);
    final updatedVariant = state.editableVariant.copyWith(options: updatedOptions);
    emit(state.copyWith(editableVariant: updatedVariant));
  }



  void reorderOption(int oldIndex, int newIndex) {
    // Ajuste para reordenação
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final updatedOptions = List<VariantOption>.from(state.editableVariant.options);
    final item = updatedOptions.removeAt(oldIndex);
    updatedOptions.insert(newIndex, item);
    final updatedVariant = state.editableVariant.copyWith(options: updatedOptions);
    emit(state.copyWith(editableVariant: updatedVariant));
  }

  // --- AÇÃO DE SALVAR ---

// Dentro da classe VariantEditCubit em variant_edit_cubit.dart

  Future<void> saveChanges() async {
    if (isClosed) return;

    emit(state.copyWith(status: VariantEditStatus.loading));

    // 1. Pega os dados do grupo editado da Tab 1
    final variantData = state.editableVariant;

    // 2. Pega a lista de regras editadas da Tab 2
    final rulesData = state.linkedProducts;

    // 3. Usa o `copyWith` do seu modelo `Variant` para juntar tudo num único objeto.
    //    (Isto assume que você já fez o ajuste no modelo Variant.dart que sugeri antes)
    final finalPayload = variantData.copyWith(
      linkedProductsRules: rulesData,
    );

    // 4. Envia o payload completo para o repositório
    final saveResult = await _productRepository.saveVariant(storeId, finalPayload);

    // 5. Trata o resultado da única chamada à API
    saveResult.fold(
          (error) {
        // Caso de erro
        emit(state.copyWith(
          status: VariantEditStatus.error,
          errorMessage: "Falha ao salvar. Tente novamente.", // Você pode usar o `error` se ele for uma String
        ));
      },
          (savedVariant) {
        // Caso de sucesso
        // 'savedVariant' é o objeto Variant completo que a API retornou
        emit(
          // Reinicializa o estado com a nova versão "limpa" do backend
          VariantEditState.initial(savedVariant).copyWith(
            // Define o status como sucesso
            status: VariantEditStatus.success,
            // Atualiza a lista de produtos com o que veio na resposta (se vier)
            // Se a API não retornar os links na resposta, pode ser necessário recarregá-los.
            // Por agora, vamos assumir que a resposta do saveVariant não os inclui.
            linkedProducts: state.linkedProducts,
            linkedProductsStatus: LinkedProductsStatus.success,
          ),
        );
      },
    );
  }




}