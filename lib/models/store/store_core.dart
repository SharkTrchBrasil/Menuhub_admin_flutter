// store_core.dart
class StoreCore {
  final int? id;
  final String name;
  final String? urlSlug;
  final String? description;
  final String? phone;
  final String? cnpj;
  final int? segmentId;
  final bool isActive;
  final bool isSetupComplete;
  final bool isFeatured;
  final String verificationStatus;
  final String? internalNotes;
  final String? storeUrl;

  // ✅ NOVOS CAMPOS DO PAGAR.ME
  final String? pagarmeCustomerId;
  final String? pagarmeCardId;

  StoreCore({
    this.id,
    this.name = '',
    this.urlSlug,
    this.description,
    this.phone,
    this.cnpj,
    this.segmentId,
    this.isActive = true,
    this.isSetupComplete = false,
    this.isFeatured = false,
    this.verificationStatus = 'UNVERIFIED',
    this.internalNotes,
    this.storeUrl,
    // ✅ ADICIONAR AQUI
    this.pagarmeCustomerId,
    this.pagarmeCardId,
  });

  factory StoreCore.fromJson(Map<String, dynamic> json) {
    return StoreCore(
      id: json['id'] as int?,
      name: json['name'] ?? '',
      urlSlug: json['url_slug'],
      description: json['description'],
      phone: json['phone'],
      cnpj: json['cnpj'],
      segmentId: json['segment_id'] as int?,
      isActive: json['is_active'] ?? true,
      isSetupComplete: json['is_setup_complete'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      verificationStatus: json['verification_status'] ?? 'UNVERIFIED',
      internalNotes: json['internal_notes'],
      storeUrl: json['store_url'],
      // ✅ PARSE DOS NOVOS CAMPOS
      pagarmeCustomerId: json['pagarme_customer_id'] as String?,
      pagarmeCardId: json['pagarme_card_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url_slug': urlSlug,
      'description': description,
      'phone': phone,
      'cnpj': cnpj,
      'segment_id': segmentId,
      'is_active': isActive,
      'is_setup_complete': isSetupComplete,
      'is_featured': isFeatured,
      'verification_status': verificationStatus,
      'internal_notes': internalNotes,
      'store_url': storeUrl,
      // ✅ SERIALIZAR OS NOVOS CAMPOS
      'pagarme_customer_id': pagarmeCustomerId,
      'pagarme_card_id': pagarmeCardId,
    };
  }

  StoreCore copyWith({
    int? id,
    String? name,
    String? urlSlug,
    String? description,
    String? phone,
    String? cnpj,
    int? segmentId,
    bool? isActive,
    bool? isSetupComplete,
    bool? isFeatured,
    String? verificationStatus,
    String? internalNotes,
    String? storeUrl,
    // ✅ ADICIONAR NOS PARÂMETROS DO COPYWITH
    String? pagarmeCustomerId,
    String? pagarmeCardId,
  }) {
    return StoreCore(
      id: id ?? this.id,
      name: name ?? this.name,
      urlSlug: urlSlug ?? this.urlSlug,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      cnpj: cnpj ?? this.cnpj,
      segmentId: segmentId ?? this.segmentId,
      isActive: isActive ?? this.isActive,
      isSetupComplete: isSetupComplete ?? this.isSetupComplete,
      isFeatured: isFeatured ?? this.isFeatured,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      internalNotes: internalNotes ?? this.internalNotes,
      storeUrl: storeUrl ?? this.storeUrl,
      // ✅ APLICAR NO COPYWITH
      pagarmeCustomerId: pagarmeCustomerId ?? this.pagarmeCustomerId,
      pagarmeCardId: pagarmeCardId ?? this.pagarmeCardId,
    );
  }
}