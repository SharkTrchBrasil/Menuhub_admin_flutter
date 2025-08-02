import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/product.dart';
import '../../../models/product_variant_link.dart';
import '../../../models/variant.dart';
import '../../../models/variant_option.dart';
import '../../../repositories/product_repository.dart';
import 'create_complement_state.dart';

class CreateComplementGroupCubit extends Cubit<CreateComplementGroupState> {
  final int storeId;
  final int productId;
  final ProductRepository productRepository;
  final List<Variant> allExistingVariants;
  final List<Product> allExistingProducts;

  CreateComplementGroupCubit({
    required this.storeId,
    required this.productId,
    required this.productRepository,
    required this.allExistingVariants,
    required this.allExistingProducts,
  }) : super(CreateComplementGroupState.initial());

  // --- MÉTODOS DO PASSO 0 (Painel Inicial) ---

  void startCreateNewFlow() {
    emit(state.copyWith(
      step: CreateComplementStep.selectType,
      isCopyFlow: false, // Garante que estamos no fluxo de criação
    ));
  }

  void startCopyExistingFlow() {
    emit(state.copyWith(
      isCopyFlow: true, // Define que estamos no fluxo de cópia
      groupType: GroupType.ingredients, // Define um tipo padrão para sabermos qual lista mostrar
      itemsAvailableToCopy: allExistingVariants,
      step: CreateComplementStep.addComplements,
    ));
  }

  // --- MÉTODOS DE NAVEGAÇÃO E DADOS (PASSOS 1 e 2) ---

  void goBack() {
    // Lógica de voltar um passo, considerando o fluxo de cópia
    if (state.isCopyFlow) {
      emit(CreateComplementGroupState.initial());
      return;
    }

    switch (state.step) {
      case CreateComplementStep.addComplements:
        emit(state.copyWith(step: CreateComplementStep.groupDetails));
        break;
      case CreateComplementStep.groupDetails:
        emit(state.copyWith(step: CreateComplementStep.selectType));
        break;
      case CreateComplementStep.selectType:
        emit(state.copyWith(step: CreateComplementStep.initial));
        break;
      default:
        break;
    }
  }

  void selectGroupType(GroupType type) {
    emit(state.copyWith(
      groupType: type,
      step: CreateComplementStep.groupDetails,
    ));
  }

  void setGroupDetails({required String name, required bool isRequired, required int min, required int max}) {
    emit(state.copyWith(
      groupName: name,
      isRequired: isRequired,
      minQty: min,
      maxQty: max,
      step: CreateComplementStep.addComplements,
    ));
  }

  // --- MÉTODOS DE MANIPULAÇÃO DE COMPLEMENTOS (PASSO 3) ---

  void addComplement(VariantOption option) {
    final updatedList = List<VariantOption>.from(state.complements)..add(option);
    emit(state.copyWith(complements: updatedList));
  }

  void removeComplement(VariantOption option) {
    final updatedList = List<VariantOption>.from(state.complements)..remove(option);
    emit(state.copyWith(complements: updatedList));
  }

  void searchItemsToCopy(String searchTerm) {
    final term = searchTerm.toLowerCase();
    final type = state.groupType;

    if (type == GroupType.crossSell) {
      final filteredList = term.isEmpty
          ? allExistingProducts
          : allExistingProducts.where((p) => p.name.toLowerCase().contains(term)).toList();
      emit(state.copyWith(itemsAvailableToCopy: filteredList));
    } else {
      final filteredList = term.isEmpty
          ? allExistingVariants
          : allExistingVariants.where((v) => v.name.toLowerCase().contains(term)).toList();
      emit(state.copyWith(itemsAvailableToCopy: filteredList));
    }
  }

  void toggleItemForCopy(int itemId) {
    final currentSelection = Set<int>.from(state.selectedToCopyIds);
    if (currentSelection.contains(itemId)) {
      currentSelection.remove(itemId);
    } else {
      currentSelection.add(itemId);
    }
    emit(state.copyWith(selectedToCopyIds: currentSelection));
  }

  /// ✅ CORRIGIDO: Lida com ambos os casos, Cross-sell e Ingredientes/Cópia.
  void addSelectedItemsToGroup() {
    List<VariantOption> itemsToAdd = [];

    if (state.groupType == GroupType.crossSell) {
      itemsToAdd = allExistingProducts
          .where((p) => state.selectedToCopyIds.contains(p.id))
          .map((p) => VariantOption(id: p.id!, resolvedName: p.name, resolvedPrice: p.basePrice ?? 0, imagePath: p.image?.url))
          .toList();
    } else {
      itemsToAdd = allExistingVariants
          .where((v) => state.selectedToCopyIds.contains(v.id))
          .expand((variant) => variant.options)
          .toList();
    }

    final updatedList = List<VariantOption>.from(state.complements)..addAll(itemsToAdd);

    emit(state.copyWith(
      complements: updatedList,
      selectedToCopyIds: {}, // Limpa a seleção
    ));
  }
// ✅ NOVO: Método para guardar a variante selecionada
  void selectVariantToCopy(Variant variant) {
    emit(state.copyWith(selectedVariantToCopy: variant));
  }

  // --- MÉTODO FINAL PARA SALVAR ---
  Future<void> saveGroup() async {
    emit(state.copyWith(status: FormStatus.loading));

    if (state.groupType == null) {
      emit(state.copyWith(status: FormStatus.error, errorMessage: "Tipo de grupo não selecionado."));
      return;
    }

    try {
      if (state.isCopyFlow) {
        // ✅ LÓGICA CORRIGIDA
        if (state.selectedVariantToCopy == null) {
          throw Exception("Nenhuma variante selecionada para cópia.");
        }
        final variantToCopy = state.selectedVariantToCopy!;

        final linkData = ProductVariantLink(
          variant: variantToCopy,
          minSelectedOptions: 0, // Defina as regras padrão para cópia
          maxSelectedOptions: 1, // ou colete-as da UI
          uiDisplayMode: UIDisplayMode.SINGLE,
        );

        final result = await productRepository.linkVariantToProduct(
          storeId: storeId,
          productId: productId,
          variantId: variantToCopy.id!,
          linkData: linkData,
        );
        if (result.isLeft) throw Exception(result.left);
      } else {
        // --- FLUXO DE CRIAR NOVO GRUPO ---

        // 1. Cria o "molde" Variant (sem as opções no JSON, como corrigimos no modelo)
        final newVariant = Variant(
          name: state.groupName,
          type: _mapGroupTypeToVariantType(state.groupType!),
          options: [], // A lista de opções no objeto Dart não importa para o toJson
        );

        final createdVariantResult = await productRepository.saveVariant(storeId, newVariant);
        if (createdVariantResult.isLeft) throw Exception("Falha ao criar o grupo de complementos.");

        final createdVariant = createdVariantResult.right;

        // ✅ NOVO: SALVANDO AS OPÇÕES (COMPLEMENTOS)
        // Agora que temos o ID do grupo (createdVariant.id), podemos salvar as opções.
        // Fazemos um loop em cada complemento que o usuário criou na interface.
        for (final complementOption in state.complements) {
          // Para cada um, chamamos o método para salvá-lo, associando-o ao grupo recém-criado.
          await productRepository.saveVariantOption(
            storeId,
            createdVariant.id!, // <-- Usando o ID do grupo que acabamos de criar
            complementOption,
          );
        }

        // 3. Monta o objeto de ligação com as regras
        final linkData = ProductVariantLink(
          variant: createdVariant,
          minSelectedOptions: state.minQty,
          maxSelectedOptions: state.maxQty,
          uiDisplayMode: UIDisplayMode.SINGLE,
        );

        // 4. Liga o grupo (agora com suas opções salvas) ao produto
        final linkResult = await productRepository.linkVariantToProduct(
          storeId: storeId,
          productId: productId,
          variantId: createdVariant.id!,
          linkData: linkData,
        );
        if (linkResult.isLeft) throw Exception(linkResult.left);
      }

      emit(state.copyWith(status: FormStatus.success));
    } catch (e) {
      emit(state.copyWith(status: FormStatus.error, errorMessage: e.toString()));
    }
  }
// Cole este método dentro da classe CreateComplementGroupCubit




  VariantType _mapGroupTypeToVariantType(GroupType groupType) {
    switch (groupType) {
      case GroupType.ingredients:
        return VariantType.INGREDIENTS;
      case GroupType.specifications:
        return VariantType.SPECIFICATIONS;
      case GroupType.crossSell:
        return VariantType.CROSS_SELL;
      case GroupType.disposables:
        return VariantType.DISPOSABLES;
      default:
        return VariantType.UNKNOWN;
    }
  }

}
