import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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

// ✨ NOVO MÉTODO PARA INICIAR O FLUXO DE "ADICIONAR OPÇÃO"
  void startAddOptionFlow(ProductVariantLink existingLink) {
    emit(state.copyWith(
      // Define o passo inicial direto para a adição de complementos
      step: CreateComplementStep.addComplements,
      isCopyFlow: false, // Não é o fluxo de cópia de grupo

      // Pré-preenche o estado com os dados do grupo existente
      groupName: existingLink.variant.name,
      groupType: _mapVariantTypeToGroupType(existingLink.variant.type),
      // Carrega os complementos que já existem nesse grupo
      complements: List<VariantOption>.from(existingLink.variant.options),
      // Zera os outros campos para um estado limpo
      isRequired: existingLink.isRequired,
      minQty: existingLink.minSelectedOptions,
      maxQty: existingLink.maxSelectedOptions,
    ));
  }
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


// ✨ MÉTODO ADICIONADO AQUI ✨
  void clearSelectedItems() {
    emit(state.copyWith(selectedToCopyIds: {}));
  }

// ✅ MÉTODO `goBack` SIMPLIFICADO E CORRIGIDO
  void goBack() {
    // Se já estamos no primeiro passo, não há para onde voltar.
    // (O botão "Voltar" nem deveria aparecer no Step0InitialChoice)
    if (state.step == CreateComplementStep.initial) return;

    // Lógica clara para voltar um passo
    CreateComplementStep newStep;
    switch (state.step) {
      case CreateComplementStep.selectType:
      case CreateComplementStep.copyGroup_SelectGroup:
        newStep = CreateComplementStep.initial;
        break;
      case CreateComplementStep.groupDetails:
        newStep = CreateComplementStep.selectType;
        break;
      case CreateComplementStep.addComplements:
        newStep = CreateComplementStep.groupDetails;
        break;
      case CreateComplementStep.copyGroup_SetRules:
        newStep = CreateComplementStep.copyGroup_SelectGroup;
        break;
      default:
        newStep = CreateComplementStep.initial;
    }

    emit(state.copyWith(
      step: newStep,
    ));
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



  Future<void> fetchInitialItemsToCopy() async {
    // Apenas chama a busca com uma query vazia para pegar todos os itens iniciais
    // Supondo que `groupType` já esteja definido no estado
    if (state.groupType != null) {
      searchItemsToCopy("", type: state.groupType!);
    }
  }



  Future<ProductVariantLink?> completeFlowAndGetResult() async {
    emit(state.copyWith(status: FormStatus.loading));
    try {
      final linkResult = state.isCopyFlow
          ? _buildResultForCopyFlow()
          : _buildResultForCreateFlow();

      emit(state.copyWith(status: FormStatus.success));
      return linkResult;

    } catch (e) {
      emit(state.copyWith(status: FormStatus.error, errorMessage: e.toString()));
      return null;
    }
  }

// Método auxiliar para o fluxo de CÓPIA
  ProductVariantLink _buildResultForCopyFlow() {
    if (state.selectedVariantToCopy == null) {
      throw Exception("Nenhum grupo foi selecionado para cópia.");
    }
    return ProductVariantLink(
      variant: state.selectedVariantToCopy!,
      minSelectedOptions: state.minQty,
      maxSelectedOptions: state.maxQty,
      uiDisplayMode: state.maxQty > 1 ? UIDisplayMode.MULTIPLE : UIDisplayMode.SINGLE,
    );
  }

// Método auxiliar para o fluxo de CRIAÇÃO
  ProductVariantLink _buildResultForCreateFlow() {
    final newVariantData = Variant(
      id: -DateTime.now().millisecondsSinceEpoch,
      name: state.groupName,
      type: _mapGroupTypeToVariantType(state.groupType!),
      options: state.complements,
    );

    return ProductVariantLink(
      variant: newVariantData,
      minSelectedOptions: state.minQty,
      maxSelectedOptions: state.maxQty,
      uiDisplayMode: state.maxQty > 1 ? UIDisplayMode.MULTIPLE : UIDisplayMode.SINGLE,
    );
  }



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

// DENTRO DA CLASSE CreateComplementGroupCubit

  void addSelectedItemsToGroup() {
    final availableItems = state.itemsAvailableToCopy;
    final selectedIds = state.selectedToCopyIds;

    final selectedItems = availableItems.where((item) {
      final int itemId = (item is Product) ? item.id! : (item as Variant).id!;
      return selectedIds.contains(itemId);
    }).toList();

    final newOptions = selectedItems.map((item) {
      if (item is Product) {
        // ✨ LÓGICA ATUALIZADA AQUI ✨
        // Agora, além do ID, passamos o objeto Product inteiro.
        // A UI poderá ler o nome e outras informações diretamente dele.
        return VariantOption(
          linked_product_id: item.id,
          linkedProduct: item, // Passa o objeto completo!
        );
      } else if (item is Variant) {
        // Para outros complementos, a lógica continua a mesma.
        return VariantOption(
          name_override: item.name,
          price_override: 0,
        );
      }
      return null;
    }).whereType<VariantOption>().toList();

    final updatedComplements = List<VariantOption>.from(state.complements)
      ..addAll(newOptions);

    emit(state.copyWith(
      complements: updatedComplements,
      selectedToCopyIds: {},
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