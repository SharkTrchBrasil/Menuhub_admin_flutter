import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // ✅ ADICIONADO
import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

part 'variants_tab_state.dart';

class VariantsTabCubit extends Cubit<VariantsTabState> {
  final ProductRepository _productRepository;
  final int storeId;

  // ✅ NOVO: Controller gerenciado pelo Cubit
  final TextEditingController searchController = TextEditingController();

  VariantsTabCubit({
    required List<Variant> initialVariants,
    required ProductRepository productRepository,
    required this.storeId,
  })  : _productRepository = productRepository,
        super(VariantsTabState(
        status: VariantsTabStatus.success,
        allVariants: initialVariants,
      )) {
    // ✅ NOVO: Conecta o controller ao método de busca
    searchController.addListener(() {
      if (!isClosed) {
        searchChanged(searchController.text);
      }
    });
  }

  void searchChanged(String text) {
    if (isClosed) return;
    emit(state.copyWith(searchText: text.toLowerCase()));
  }

  void toggleVariantSelection(int variantId) {
    if (isClosed) return;
    final newSet = Set<int>.from(state.selectedVariantIds);
    if (newSet.contains(variantId)) {
      newSet.remove(variantId);
    } else {
      newSet.add(variantId);
    }
    emit(state.copyWith(selectedVariantIds: newSet));
  }

  void toggleSelectAll() {
    if (isClosed) return;
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
    if (state.selectedVariantIds.isEmpty || isClosed) return;

    emit(state.copyWith(status: VariantsTabStatus.loading, clearMessages: true));

    final result = await _productRepository.updateLinksAvailability(
      storeId: storeId,
      variantIds: state.selectedVariantIds.toList(),
      isAvailable: isAvailable,
    );

    if (isClosed) return;

    result.fold(
          (error) {
        emit(state.copyWith(
          status: VariantsTabStatus.success,
          errorMessage: error,
        ));
      },
          (success) {
        final updatedVariants = state.allVariants.map((variant) {
          if (state.selectedVariantIds.contains(variant.id)) {
            return variant.copyWith(available: isAvailable);
          }
          return variant;
        }).toList();

        emit(state.copyWith(
          status: VariantsTabStatus.success,
          allVariants: updatedVariants,
          selectedVariantIds: {},
          successMessage: isAvailable
              ? 'Grupos ativados com sucesso!'
              : 'Grupos pausados com sucesso!',
        ));
      },
    );
  }

  Future<void> unlinkSelectedVariants() async {
    if (state.selectedVariantIds.isEmpty || isClosed) return;

    emit(state.copyWith(status: VariantsTabStatus.loading, clearMessages: true));

    final result = await _productRepository.unlinkVariants(
      storeId: storeId,
      variantIds: state.selectedVariantIds.toList(),
    );

    if (isClosed) return;

    result.fold(
          (error) {
        emit(state.copyWith(
          status: VariantsTabStatus.success,
          errorMessage: error,
        ));
      },
          (success) {
        final remainingVariants = state.allVariants
            .where((v) => !state.selectedVariantIds.contains(v.id))
            .toList();

        emit(state.copyWith(
          status: VariantsTabStatus.success,
          allVariants: remainingVariants,
          selectedVariantIds: {},
          successMessage: 'Grupos removidos com sucesso!',
        ));
      },
    );
  }

  // ✅ NOVO: Limpa o controller ao fechar o Cubit
  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}