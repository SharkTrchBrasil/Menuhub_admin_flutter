import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/product_variant_link.dart';
import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

import '../../../../core/enums/ui_display_mode.dart';
import '../../../../core/enums/variant_type.dart';

part 'create_complement_state.dart';

class CreateComplementGroupCubit extends Cubit<CreateComplementGroupState> {
  final int storeId;
  final int? productId;
  final ProductRepository productRepository;
  final List<Variant> allStoreVariants;
  final List<Product> allStoreProducts;

  CreateComplementGroupCubit({
    required this.storeId,
    this.productId,
    required this.productRepository,
    required this.allStoreVariants,
    required this.allStoreProducts,
  }) : super(CreateComplementGroupState.initial());

  // --- CONTROLE DE FLUXO E NAVEGAÇÃO ---


  void startFlow(bool isCopy) {
    emit(state.copyWith(
      isCopyFlow: isCopy,
      step: isCopy ? CreateComplementStep.copyGroup_SelectGroup : CreateComplementStep.selectType,
      itemsAvailableToCopy: isCopy ? allStoreVariants : [],
    ));
  }

  // ✅ NOVO MÉTODO PARA INICIAR O FLUXO DE EDIÇÃO
  void startEditFlow(ProductVariantLink linkToEdit) {
    emit(state.copyWith(
      // Define o passo inicial para a edição dos detalhes do grupo
      step: CreateComplementStep.groupDetails,
      isCopyFlow: false, // Garante que não está no fluxo de cópia

      // Pré-preenche o estado com os dados do link existente
      groupName: linkToEdit.variant.name,
      groupType: _mapVariantTypeToGroupType(linkToEdit.variant.type),
      isRequired: linkToEdit.isRequired,
      minQty: linkToEdit.minSelectedOptions,
      maxQty: linkToEdit.maxSelectedOptions,
      complements: List<VariantOption>.from(linkToEdit.variant.options),
    ));
  }

  void goBack() {
    CreateComplementStep newStep;
    switch (state.step) {
      case CreateComplementStep.selectType:
      case CreateComplementStep.copyGroup_SelectGroup:
        newStep = CreateComplementStep.initial;
        break;
      default:
        newStep = CreateComplementStep.values[state.step.index - 1];
    }
    emit(state.copyWith(
        step: newStep, status: FormStatus.initial, errorMessage: null));
  }

  // --- FLUXO DE CRIAÇÃO ---

  void selectGroupType(GroupType type) {
    emit(state.copyWith(
        groupType: type, step: CreateComplementStep.groupDetails));
  }

  // ✅ MÉTODO QUE ESTAVA FALTANDO NO SEU ARQUIVO ATUAL
  void updateRulesForCopiedGroup({required bool isRequired, required int min, required int max}) {
    emit(state.copyWith(isRequired: isRequired, minQty: min, maxQty: max));
  }

  void setGroupDetails(
      {required String name, required bool isRequired, required int min, required int max}) {
    emit(state.copyWith(
      groupName: name,
      isRequired: isRequired,
      minQty: min,
      maxQty: max,
      step: CreateComplementStep.addComplements,
    ));
  }

  void addComplementOption(VariantOption option) {
    final updatedList = List<VariantOption>.from(state.complements)
      ..add(option);
    emit(state.copyWith(complements: updatedList));
  }

  void removeComplementOption(VariantOption option) {
    final updatedList = List<VariantOption>.from(state.complements)
      ..remove(option);
    emit(state.copyWith(complements: updatedList));
  }

  // --- FLUXO DE CÓPIA ---

  void selectGroupToCopy(Variant variant) {
    emit(state.copyWith(
      selectedVariantToCopy: variant,
      step: CreateComplementStep.copyGroup_SetRules,
      minQty: variant.productLinks?.firstOrNull?.minSelectedOptions ??
          (variant.options.isNotEmpty ? 1 : 0),
      maxQty: variant.productLinks?.firstOrNull?.maxSelectedOptions ?? 1,
      isRequired: (variant.productLinks?.firstOrNull?.minSelectedOptions ?? 0) >
          0,
    ));
  }



  // --- LÓGICA DE BUSCA ---

  void searchItemsToCopy(String searchTerm, {required GroupType type}) {
    final term = searchTerm.toLowerCase();
    if (term.isEmpty) {
      emit(state.copyWith(itemsAvailableToCopy: type == GroupType.crossSell
          ? allStoreProducts
          : allStoreVariants));
      return;
    }
    if (type == GroupType.crossSell) {
      final filtered = allStoreProducts.where((p) =>
          p.name.toLowerCase().contains(term)).toList();
      emit(state.copyWith(itemsAvailableToCopy: filtered));
    } else {
      final filtered = allStoreVariants.where((v) =>
          v.name.toLowerCase().contains(term)).toList();
      emit(state.copyWith(itemsAvailableToCopy: filtered));
    }
  }

  Future<ProductVariantLink?> completeFlowAndGetResult() async {
    emit(state.copyWith(status: FormStatus.loading));
    try {
      Variant finalVariant;

      if (state.isCopyFlow) {
        // --- FLUXO DE CÓPIA ---
        if (state.selectedVariantToCopy == null) {
          throw Exception("Nenhum grupo foi selecionado para cópia.");
        }
        // Apenas pega a variante que já foi selecionada
        finalVariant = state.selectedVariantToCopy!;
      } else {
        // --- FLUXO DE CRIAÇÃO ---
        // Cria um novo objeto Variant com os dados coletados, TUDO EM MEMÓRIA.
        final newVariantData = Variant(
          // Usamos um ID negativo temporário para diferenciá-lo de itens já salvos
          id: -DateTime.now().millisecondsSinceEpoch,
          name: state.groupName,
          type: _mapGroupTypeToVariantType(state.groupType!),
          options: state.complements,
        );
        finalVariant = newVariantData;

        // NENHUMA CHAMADA AO REPOSITÓRIO É FEITA AQUI.
      }

      // Monta o objeto ProductVariantLink que será o resultado final do painel.
      final linkResult = ProductVariantLink(
        variant: finalVariant,
        minSelectedOptions: state.minQty,
        maxSelectedOptions: state.maxQty,
        uiDisplayMode: state.maxQty > 1 ? UIDisplayMode.MULTIPLE : UIDisplayMode.SINGLE,
      );

      emit(state.copyWith(status: FormStatus.success));
      // Retorna o link montado para a tela que chamou o painel
      return linkResult;

    } catch (e) {
      emit(state.copyWith(status: FormStatus.error, errorMessage: e.toString()));
      return null;
    }
  }



  // DENTRO DA CLASSE CreateComplementGroupCubit

// ✅ NOVO MÉTODO 1: Para marcar e desmarcar itens
  void toggleItemForCopy(dynamic item) {
    // Pega o ID, não importa se o item é um Product ou Variant
    final int itemId = (item is Product) ? item.id! : (item as Variant).id!;

    // Cria uma nova cópia do Set de IDs para não modificar o estado diretamente
    final updatedIds = Set<int>.from(state.selectedToCopyIds);

    // Adiciona ou remove o ID do Set
    if (updatedIds.contains(itemId)) {
      updatedIds.remove(itemId);
    } else {
      updatedIds.add(itemId);
    }

    // Emite o novo estado com a lista de IDs atualizada
    emit(state.copyWith(selectedToCopyIds: updatedIds));
  }

// ✅ NOVO MÉTODO 2: Para adicionar os selecionados à lista principal
  void addSelectedItemsToGroup() {
    // Pega a lista de itens disponíveis para cópia e os IDs selecionados
    final availableItems = state.itemsAvailableToCopy;
    final selectedIds = state.selectedToCopyIds;

    // Filtra apenas os itens que foram selecionados
    final selectedItems = availableItems.where((item) {
      final int itemId = (item is Product) ? item.id! : (item as Variant).id!;
      return selectedIds.contains(itemId);
    }).toList();

    // Converte os itens selecionados em VariantOption
    final newOptions = selectedItems.map((item) {
      if (item is Product) {
        // Se for um produto (Cross-Sell), cria uma opção linkada a ele
        return VariantOption(
          linked_product_id: item.id,
          // O nome e o preço serão resolvidos automaticamente pelo modelo
        );
      } else if (item is Variant) {
        // Se for um grupo (Ingrediente/Especificação), cria uma opção com o nome dele
        return VariantOption(
          name_override: item.name,
          price_override: 0, // Assume preço 0, pode ser editado depois
        );
      }
      return null; // Caso de segurança
    }).whereType<VariantOption>().toList(); // Filtra qualquer nulo

    // Adiciona as novas opções à lista de complementos já existente
    final updatedComplements = List<VariantOption>.from(state.complements)..addAll(newOptions);

    // Emite o novo estado com a lista de complementos atualizada e limpa a seleção
    emit(state.copyWith(
      complements: updatedComplements,
      selectedToCopyIds: {}, // Limpa os checkboxes
    ));
  }

  // Helper para mapear o enum na direção oposta (pode ser útil)
  GroupType _mapVariantTypeToGroupType(VariantType vt) {
    switch (vt) {
      case VariantType.INGREDIENTS: return GroupType.ingredients;
      case VariantType.SPECIFICATIONS: return GroupType.specifications;
      case VariantType.CROSS_SELL: return GroupType.crossSell;
      case VariantType.DISPOSABLES: return GroupType.disposables;
      default: return GroupType.ingredients; // Um padrão seguro
    }
  }
  // Helper para mapear enums
  VariantType _mapGroupTypeToVariantType(GroupType gt) {
    switch (gt) {
      case GroupType.ingredients:
        return VariantType.INGREDIENTS;
      case GroupType.specifications:
        return VariantType.SPECIFICATIONS;
      case GroupType.crossSell:
        return VariantType.CROSS_SELL;
      case GroupType.disposables:
        return VariantType.DISPOSABLES;
    }
  }
}