import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import '../../../models/page_status.dart';
import '../../../models/plans/plans.dart';
import '../../../models/segment.dart';

enum TaxIdType { none, cnpj, cpf }

class StoreSetupState extends Equatable {
  final String cep;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String uf;
  final TaxIdType taxIdType;
  final String cnpj;

  final String responsibleName;
  final String responsibleBirth;
  final String cpf;
  final PageStatus zipCodeStatus;
  final String complement;
  final List<Segment> specialtiesList;
  final PageStatus specialtiesStatus;
  final String storeName;
  final String storeUrl;
  final String storeDescription;
  final String storePhone;
  final bool urlEditedManually;
  final bool isUrlTaken;
  final bool urlChecking;
  final String? lastCheckedUrl;


  final List<Plans> plansList;
  final PageStatus plansStatus;
  final PageStatus submissionStatus;
  final Segment? selectedSpecialty;



  const StoreSetupState({
    this.cep = '',
    this.street = '',
    this.number = '',
    this.neighborhood = '',
    this.city = '',
    this.uf = '',
    this.taxIdType = TaxIdType.none,
    this.cnpj = '',
    this.selectedSpecialty,
    this.responsibleName = '',
    this.responsibleBirth = '',
    this.cpf = '',
    this.complement = '',
    this.storeName = '',
    this.storeUrl = '',
    this.storeDescription = '',
    this.storePhone = '',
    this.urlEditedManually = false,
    this.isUrlTaken = false,
    this.urlChecking = false,
    this.lastCheckedUrl,

    this.plansList = const [],
    this.plansStatus = const PageStatusIdle(),
    PageStatus? zipCodeStatus,
    List<Segment>? specialtiesList,
    PageStatus? specialtiesStatus,
    this.submissionStatus = const PageStatusIdle(),
  })  : zipCodeStatus = zipCodeStatus ?? const PageStatusIdle(),
        specialtiesList = specialtiesList ?? const [],
        specialtiesStatus = specialtiesStatus ?? const PageStatusIdle();

  StoreSetupState copyWith({
    String? cep,
    String? street,
    String? number,
    String? neighborhood,
    String? city,
    String? uf,
    TaxIdType? taxIdType,
    String? cnpj,
    Segment? selectedSpecialty,
    String? responsibleName,
    String? responsibleBirth,
    String? cpf,
    String? complement,
    PageStatus? zipCodeStatus,
    List<Segment>? specialtiesList,
    PageStatus? specialtiesStatus,
    String? storeName,
    String? storeUrl,
    String? storeDescription,
    String? storePhone,
    bool? urlEditedManually,
    bool? isUrlTaken,
    bool? urlChecking,
    String? lastCheckedUrl,



    List<Plans>? plansList,
    PageStatus? plansStatus,
    PageStatus? submissionStatus
  }) {
    return StoreSetupState(
      cep: cep ?? this.cep,
      street: street ?? this.street,
      number: number ?? this.number,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      uf: uf ?? this.uf,
      taxIdType: taxIdType ?? this.taxIdType,
      cnpj: cnpj ?? this.cnpj,
      selectedSpecialty: selectedSpecialty ?? this.selectedSpecialty,
      responsibleName: responsibleName ?? this.responsibleName,
      responsibleBirth: responsibleBirth ?? this.responsibleBirth,
      cpf: cpf ?? this.cpf,
      complement: complement ?? this.complement,
      zipCodeStatus: zipCodeStatus ?? this.zipCodeStatus,
      specialtiesList: specialtiesList ?? this.specialtiesList,
      specialtiesStatus: specialtiesStatus ?? this.specialtiesStatus,
      storeName: storeName ?? this.storeName,
      storeUrl: storeUrl ?? this.storeUrl,
      storeDescription: storeDescription ?? this.storeDescription,
      storePhone: storePhone ?? this.storePhone,
      urlEditedManually: urlEditedManually ?? this.urlEditedManually,
      isUrlTaken: isUrlTaken ?? this.isUrlTaken,
      urlChecking: urlChecking ?? this.urlChecking,
      lastCheckedUrl: lastCheckedUrl ?? this.lastCheckedUrl,

      plansList: plansList ?? this.plansList,
      plansStatus: plansStatus ?? this.plansStatus,
      submissionStatus: submissionStatus ?? this.submissionStatus,

    );
  }

  @override
  List<Object?> get props => [ // Adicione ? no final de List<Object> se alguns props forem nulos
    cep, street, number, neighborhood, city, uf,
    taxIdType, cnpj, selectedSpecialty,
    responsibleName, responsibleBirth, cpf, zipCodeStatus, complement, specialtiesList,
    specialtiesStatus, storeName, storeUrl, storeDescription, storePhone, isUrlTaken,
    urlChecking, urlEditedManually,
    lastCheckedUrl,
    plansList,
    plansStatus,
    submissionStatus,

  ];




// Em store_setup-state.dart
  Map<String, dynamic> toJson() {
    // ✅ CORREÇÃO: Adicione os campos que estão faltando
    return {
      // --- Dados da Loja ---
      'name': storeName,
      'store_url': storeUrl,
      'description': storeDescription.isNotEmpty ? storeDescription : null,
      'phone': storePhone.replaceAll(RegExp(r'\D'), ''),
      'cnpj': cnpj.isNotEmpty ? cnpj.replaceAll(RegExp(r'\D'), '') : null,
      'segment_id': selectedSpecialty?.id,

      // ✅ CORREÇÃO: Adicione os dados do responsável que estão faltando
      'responsible': {
        'name': responsibleName,
        'phone': storePhone.replaceAll(RegExp(r'\D'), ''), // ou crie um campo específico para phone do responsável
      },

      // ✅ ESTRUTURA ANINHADA PARA O ENDEREÇO
      'address': {
        'cep': cep.replaceAll(RegExp(r'\D'), ''),
        'street': street,
        'number': number,
        'neighborhood': neighborhood,
        'city': city,
        'uf': uf,
        'complement': complement.isNotEmpty ? complement : null,
      },
    };
  }



}