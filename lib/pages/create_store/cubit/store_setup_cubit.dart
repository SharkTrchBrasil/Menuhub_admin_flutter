// =======================================================================
// 2. CUBIT - O cérebro que gerencia o estado e a lógica
// =======================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup-state.dart';

import '../../../cubits/auth_cubit.dart';
import '../../../cubits/auth_state.dart';
import '../../../models/page_status.dart';
import '../../../models/segment.dart';
import '../../../models/store/store_with_role.dart';
import '../../../repositories/segment_repository.dart';
import '../../../repositories/store_repository.dart';
import '../../../repositories/user_repository.dart';
import '../../../services/auth_service.dart';

class StoreSetupCubit extends Cubit<StoreSetupState> {
  final StoreRepository _storeRepository;
  final SegmentRepository _segmentRepository;
  final UserRepository _userRepository;
  final AuthCubit _authCubit;


  StoreSetupCubit(
    this._storeRepository,
    this._segmentRepository,
    this._userRepository,
    this._authCubit,
     {
    String? initialResponsibleName, // <-- Parâmetro para o nome
  }) : super(StoreSetupState(responsibleName: initialResponsibleName ?? ''));

  void updateField({
    String? cep,
    String? street,
    String? number,
    String? neighborhood,
    String? city,
    String? uf,
    String? complement,
  }) {
    emit(
      state.copyWith(
        cep: cep,
        street: street,
        number: number,
        neighborhood: neighborhood,
        city: city,
        uf: uf,
        complement: complement,
      ),
    );
  }

  void setTaxIdType(TaxIdType type) {
    emit(state.copyWith(taxIdType: type));
  }

  void updateResponsibleField({String? name, String? birth, String? cpf}) {
    emit(
      state.copyWith(responsibleName: name, responsibleBirth: birth, cpf: cpf),
    );
  }

  // ✅ ATUALIZE ESTE MÉTODO
  void updateBusinessField({String? cnpj, Segment? specialty}) {
    emit(state.copyWith(cnpj: cnpj, selectedSpecialty: specialty));
  }

  // 👇 ATUALIZE ESTE MÉTODO PARA ACEITAR A NOVA FLAG 👇
  void updateStoreDetails({
    String? name,
    String? url,
    String? description,
    String? phone,
    bool? urlEditedManually, // <-- ✅ ADICIONE O PARÂMETRO AQUI
  }) {
    emit(
      state.copyWith(
        storeName: name,
        storeUrl: url,
        storeDescription: description,
        storePhone: phone,
        urlEditedManually:
            urlEditedManually, // <-- ✅ PASSE O PARÂMETRO PARA O ESTADO
      ),
    );
  }

  // 👇 ADICIONE ESTE MÉTODO 👇
  // Este método será chamado pelo DropdownSearch para buscar e filtrar a lista
  Future<List<Segment>> fetchAndFilterSpecialties(String filter) async {
    // Se a lista ainda não foi carregada, busca na API
    if (state.specialtiesList.isEmpty) {
      await fetchSpecialties();
    }

    // Se não há filtro, retorna a lista completa
    if (filter.isEmpty) {
      return state.specialtiesList;
    }

    // Filtra a lista localmente com base no que o usuário digitou
    return state.specialtiesList
        .where(
          (segment) =>
              segment.name.toLowerCase().contains(filter.toLowerCase()),
        )
        .toList();
  }

  Future<void> searchZipCode(String zipcode) async {
    // 1. Emite o estado de Loading
    emit(state.copyWith(zipCodeStatus: PageStatusLoading()));

    final result = await _storeRepository.getZipcodeAddress(zipcode);

    result.fold(
      (failure) {
        // 2a. Em caso de erro, emite o estado de Erro
        emit(state.copyWith(zipCodeStatus: PageStatusError(failure.message)));
      },
      (address) {
        // 2b. Em caso de sucesso, emite o estado de Sucesso E ATUALIZA OS CAMPOS
        emit(
          state.copyWith(
            zipCodeStatus: PageStatusSuccess(address),
            //  cep: address.zipcode,
            street: address.street,
            neighborhood: address.neighborhood,
            city: address.city,
            uf: address.state,
          ),
        );
      },
    );
  }

  Future<void> fetchSpecialties() async {
    // Evita buscar os dados novamente se eles já foram carregados
    if (state.specialtiesList.isNotEmpty) return;

    emit(state.copyWith(specialtiesStatus: const PageStatusLoading()));
    final result = await _segmentRepository.getSegments();
    result.fold(
      (failure) => emit(
        state.copyWith(specialtiesStatus: PageStatusError(failure.message)),
      ),
      (segments) => emit(
        state.copyWith(
          specialtiesStatus: const PageStatusSuccess(null),
          specialtiesList: segments,
        ),
      ),
    );
  }

  // 👇 COMPLETE ESTE MÉTODO 👇
  Future<void> checkUrlAvailability(String url) async {
    // Inicia a verificação e limpa o resultado anterior
    emit(state.copyWith(urlChecking: true, lastCheckedUrl: null));

    try {
      // Simula a chamada à API
      await Future.delayed(const Duration(seconds: 1));
      final isTaken =
          url == 'loja-existente'; // Sua lógica real de verificação aqui

      // Emite o estado final com o resultado e a URL que foi verificada
      emit(
        state.copyWith(
          isUrlTaken: isTaken,
          urlChecking: false,
          lastCheckedUrl: url, // <-- GUARDA A URL VERIFICADA
        ),
      );
    } catch (e) {
      // Garante que o estado de 'checking' seja falso em caso de erro
      emit(state.copyWith(urlChecking: false));
    }
  }

  // ✅ ADICIONE ESTE NOVO MÉTODO COMPLETO AQUI
  Future<void> fetchPlans() async {
    // Evita buscar novamente se a lista já foi carregada
    if (state.plansList.isNotEmpty) return;

    // Emite o estado de carregamento
    emit(state.copyWith(plansStatus: const PageStatusLoading()));

    // Chama o método que você criou no StoreRepository
    final result = await _storeRepository.getPlans();

    // Trata o resultado (sucesso ou falha)
    result.fold(
      (failure) =>
          emit(state.copyWith(plansStatus: PageStatusError(failure.message))),
      (plans) => emit(
        state.copyWith(
          plansStatus: const PageStatusSuccess(null),
          plansList: plans, // Salva a lista de planos no estado
        ),
      ),
    );
  }

  Future<void> submitStoreSetup() async {
    emit(state.copyWith(submissionStatus: const PageStatusLoading()));

    final result = await _storeRepository.createStore(state);

    result.fold(
      (failure) => emit(
        state.copyWith(submissionStatus: PageStatusError(failure.message)),
      ),
      (newStore) async {
        // ✅ SUCESSO! A loja foi criada.
        // O 'newStore' que recebemos é do tipo 'Store'.
        // Precisamos criar um 'StoreWithRole' para adicionar ao AuthCubit.
        final newStoreWithRole = StoreWithRole(
          store: newStore,
          role: StoreAccessRole.owner, // O criador é sempre o dono
        );

        // ✅ ATUALIZA O ESTADO GLOBAL DO APP COM A NOVA LOJA
        _authCubit.addNewStore(newStoreWithRole);

        final authState = _authCubit.state;

        if (authState is AuthAuthenticated) {
          final currentUser = authState.data.user;

          // ✅ LÓGICA DE DATA CORRIGIDA
          DateTime? newBirthDate;
          // Tenta converter a string "DD/MM/AAAA" do formulário para um DateTime
          if (state.responsibleBirth.isNotEmpty) {
            try {
              final parts = state.responsibleBirth.split('/');
              if (parts.length == 3) {
                newBirthDate = DateTime(
                  int.parse(parts[2]),
                  int.parse(parts[1]),
                  int.parse(parts[0]),
                );
              }
            } catch (e) {
              // Ignora se o formato for inválido
              newBirthDate = null;
            }
          }

          // Compara os dados do formulário com os dados atuais do usuário
          final bool needsCpfUpdate =
              state.cpf.isNotEmpty && state.cpf != currentUser.cpf;
          // Compara o DateTime convertido com o DateTime do usuário
          final bool needsBirthUpdate =
              newBirthDate != null && newBirthDate != currentUser.birthDate;

          if (needsCpfUpdate || needsBirthUpdate) {
            final updatedUser = currentUser.copyWith(
              // Usa o operador '??' para não sobrescrever com nulo se a condição for falsa
              cpf: needsCpfUpdate ? state.cpf : currentUser.cpf,
              birthDate:
                  needsBirthUpdate ? newBirthDate : currentUser.birthDate,
            );

            await _userRepository.updateUser(updatedUser);
            // Opcional: Atualizar o AuthCubit aqui
          }
        }

        // try {
        //   await _authService.reinitializeRealtimeConnection();
        // } catch (e) {
        //   // Loga qualquer erro que possa acontecer na reconexão
        //   print('[StoreSetupCubit] Erro ao reinicializar a conexão: $e');
        // }

        emit(state.copyWith(submissionStatus: PageStatusSuccess(newStore)));
      },
    );
  }
}
