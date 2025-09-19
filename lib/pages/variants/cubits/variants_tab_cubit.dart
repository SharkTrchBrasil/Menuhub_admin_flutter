import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

part 'variants_tab_state.dart';

class VariantsTabCubit extends Cubit<VariantsTabState> {
  final ProductRepository _productRepository;
  final int storeId;
  VariantsTabCubit({
    required List<Variant> initialVariants,
    required ProductRepository productRepository,
    required this.storeId,
  })  : _productRepository = productRepository,
  // ✅ O CONSTRUTOR AGORA APENAS RECEBE A LISTA PRONTA.
  // A lógica de filtro foi movida para o BlocProvider.
        super(VariantsTabState(
        status: VariantsTabStatus.success,
        allVariants: initialVariants,
      ));



  void searchChanged(String text) {
    emit(state.copyWith(searchText: text));
  }

  void toggleVariantSelection(int variantId) {
    final newSet = Set<int>.from(state.selectedVariantIds);
    if (newSet.contains(variantId)) {
      newSet.remove(variantId);
    } else {
      newSet.add(variantId);
    }
    emit(state.copyWith(selectedVariantIds: newSet));
  }

  void toggleSelectAll() {
    final allVisibleIds = state.filteredVariants.map((v) => v.id!).toSet();
    if (state.selectedVariantIds.length == allVisibleIds.length) {
      emit(state.copyWith(selectedVariantIds: {}));
    } else {
      final newSet = Set<int>.from(state.selectedVariantIds)..addAll(allVisibleIds);
      emit(state.copyWith(selectedVariantIds: newSet));
    }
  }

  Future<void> activateSelectedVariants() async {
    await _updateStatus(isAvailable: true);
  }

  Future<void> pauseSelectedVariants() async {
    await _updateStatus(isAvailable: false);
  }

  Future<void> _updateStatus({required bool isAvailable}) async {
    if (state.selectedVariantIds.isEmpty) return;

    emit(state.copyWith(status: VariantsTabStatus.loading, clearMessages: true));

    // ✅ 1. NOME DA CHAMADA CORRIGIDO
    final result = await _productRepository.updateLinksAvailability(
      storeId: storeId,
      variantIds: state.selectedVariantIds.toList(),
      isAvailable: isAvailable,
    );

    result.fold(
          (error) {
        emit(state.copyWith(status: VariantsTabStatus.success, errorMessage: error));
      },
          (success) {
        // A lógica de atualização do estado local continua a mesma e está correta
        final updatedVariants = state.allVariants.map((variant) {
          if (state.selectedVariantIds.contains(variant.id)) {
            // No backend, atualizamos o `available` do VÍNCULO. Aqui, para refletir
            // na UI, podemos atualizar o `available` do grupo principal também.
            // Se um grupo não tiver vínculos ativos, ele pode ser visualmente distinto.
            // A sua lógica atual de atualizar o variant.available está boa para feedback visual.
            return variant.copyWith(available: isAvailable);
          }
          return variant;
        }).toList();

        emit(state.copyWith(
          status: VariantsTabStatus.success,
          allVariants: updatedVariants,
          selectedVariantIds: {},
          successMessage: 'Vínculos atualizados com sucesso!',
        ));
      },
    );
  }

  // ✅ 1. NOME DO MÉTODO E DA CHAMADA CORRIGIDOS
  Future<void> unlinkSelectedVariants() async {
    if (state.selectedVariantIds.isEmpty) return;

    emit(state.copyWith(status: VariantsTabStatus.loading, clearMessages: true));

    final result = await _productRepository.unlinkVariants(
      storeId: storeId,
      variantIds: state.selectedVariantIds.toList(),
    );

    result.fold(
          (error) {
        emit(state.copyWith(status: VariantsTabStatus.success, errorMessage: error));
      },
          (success) {
        // Após desvincular, os grupos não aparecerão mais na lista
        // porque o filtro no construtor da próxima vez que a tela for carregada
        // irá removê-los. Para uma atualização instantânea, removemos da lista atual.
        final remainingVariants = state.allVariants
            .where((v) => !state.selectedVariantIds.contains(v.id))
            .toList();

        emit(state.copyWith(
          status: VariantsTabStatus.success,
          allVariants: remainingVariants,
          selectedVariantIds: {},
          successMessage: 'Vínculos removidos com sucesso!',
        ));
      },
    );
  }
}