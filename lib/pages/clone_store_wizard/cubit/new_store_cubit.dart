import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import '../../../core/enums/wizard_type.dart';
import '../../../models/clone_options.dart';
import 'new_store_state.dart';

class NewStoreCubit extends Cubit<NewStoreState> {
  final StoreRepository _storeRepository;

  NewStoreCubit(this._storeRepository) : super( NewStoreState());

  void init(WizardMode mode) {
    emit(state.copyWith(mode: mode, status: const PageStatusLoading()));
    if (mode == WizardMode.clone) {
      _fetchUserStores();
    } else {
      emit(state.copyWith(status: const PageStatusSuccess(null)));
    }
  }

  Future<void> _fetchUserStores() async {
    final result = await _storeRepository.getStoresForUser();
    result.fold(
          (failure) => emit(state.copyWith(status: PageStatusError(failure.message))),
          (stores) => emit(state.copyWith(
        status: const PageStatusSuccess(null),
        userStores: stores,
        sourceStore: stores.isNotEmpty ? stores.first : null,
      )),
    );
  }

  // ✅ MÉTODO ADICIONADO
  void updateStep(int newStep) {
    emit(state.copyWith(currentStep: newStep));
  }

  void updateStoreDetails({
    String? name,
    String? url,
    String? description,
    String? phone,
  }) {
    emit(state.copyWith(
      storeName: name,
      storeUrl: url,
      storeDescription: description,
      storePhone: phone,
    ));
  }

  void updateAddress({
    String? cep,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? uf,
  }) {
    emit(state.copyWith(
      cep: cep,
      street: street,
      number: number,
      complement: complement,
      neighborhood: neighborhood,
      city: city,
      uf: uf,
    ));
  }

  void setSourceStore(sourceStore) {
    emit(state.copyWith(sourceStore: sourceStore));
  }

  void updateCloneOptions(CloneOptions options) {
    emit(state.copyWith(cloneOptions: options));
  }

  Future<void> submit() async {
    // Primeiro, reseta o status de submissão para poder tentar novamente
    emit(state.copyWith(submissionStatus: const PageStatusIdle()));
    // Então, emite o loading
    emit(state.copyWith(submissionStatus: const PageStatusLoading()));

    if (state.mode == WizardMode.clone && state.sourceStore != null) {
      final addressPayload = {
        'cep': state.cep,
        'street': state.street,
        'number': state.number,
        'complement': state.complement,
        'neighborhood': state.neighborhood,
        'city': state.city,
        'uf': state.uf,
      };

      final optionsPayload = state.cloneOptions.toMap();

      final result = await _storeRepository.cloneStore(
        sourceStoreId: state.sourceStore!.store.core.id!,
        name: state.storeName,
        urlSlug: state.storeUrl,
        description: state.storeDescription,
        phone: state.storePhone,
        addressJson: jsonEncode(addressPayload),
        optionsJson: jsonEncode(optionsPayload),
      );

      result.fold(
            (failure) => emit(state.copyWith(submissionStatus: PageStatusError(failure.message))),
            (newStore) => emit(state.copyWith(submissionStatus: PageStatusSuccess(newStore))),
      );
    } else {
      await Future.delayed(const Duration(seconds: 2));
      emit(state.copyWith(submissionStatus: const PageStatusError("Criação do zero ainda não implementada neste fluxo.")));
    }
  }
}