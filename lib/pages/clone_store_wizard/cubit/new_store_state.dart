import '../../../core/enums/wizard_type.dart';
import '../../../models/clone_options.dart';
import '../../../models/page_status.dart';
import 'package:equatable/equatable.dart';

import '../../../models/store/store_with_role.dart';

class NewStoreState extends Equatable {
  // Wizard flow control
  final WizardMode mode;
  final PageStatus status;
  final PageStatus submissionStatus;
  final int currentStep; // ✅ CAMPO ADICIONADO

  // Data for the new store
  final String storeName;
  final String storeUrl;
  final String storeDescription;
  final String storePhone;
  final String cep;
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String uf;

  // Clone specific data
  final StoreWithRole? sourceStore; // Loja selecionada para clonar
  final List<StoreWithRole> userStores; // Lista de lojas do usuário
  final CloneOptions cloneOptions;

  const NewStoreState({
    this.mode = WizardMode.fromScratch,
    this.status = const PageStatusIdle(),
    this.submissionStatus = const PageStatusIdle(),
    this.currentStep = 0, // ✅ VALOR PADRÃO
    this.storeName = '',
    this.storeUrl = '',
    this.storeDescription = '',
    this.storePhone = '',
    this.cep = '',
    this.street = '',
    this.number = '',
    this.complement = '',
    this.neighborhood = '',
    this.city = '',
    this.uf = '',
    this.sourceStore,
    this.userStores = const [],
    this.cloneOptions = const CloneOptions(),
  });

  NewStoreState copyWith({
    WizardMode? mode,
    PageStatus? status,
    PageStatus? submissionStatus,
    int? currentStep, // ✅ ADICIONADO AO COPYWITH
    String? storeName,
    String? storeUrl,
    String? storeDescription,
    String? storePhone,
    String? cep,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? uf,
    StoreWithRole? sourceStore,
    List<StoreWithRole>? userStores,
    CloneOptions? cloneOptions,
  }) {
    return NewStoreState(
      mode: mode ?? this.mode,
      status: status ?? this.status,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      currentStep: currentStep ?? this.currentStep, // ✅ ATUALIZAÇÃO
      storeName: storeName ?? this.storeName,
      storeUrl: storeUrl ?? this.storeUrl,
      storeDescription: storeDescription ?? this.storeDescription,
      storePhone: storePhone ?? this.storePhone,
      cep: cep ?? this.cep,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      uf: uf ?? this.uf,
      sourceStore: sourceStore ?? this.sourceStore,
      userStores: userStores ?? this.userStores,
      cloneOptions: cloneOptions ?? this.cloneOptions,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    status,
    submissionStatus,
    currentStep, // ✅ ADICIONADO AOS PROPS
    storeName,
    storeUrl,
    storeDescription,
    storePhone,
    cep,
    street,
    number,
    complement,
    neighborhood,
    city,
    uf,
    sourceStore,
    userStores,
    cloneOptions,
  ];
}