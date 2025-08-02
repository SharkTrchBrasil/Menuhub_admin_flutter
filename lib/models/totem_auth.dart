class TotemAuth {
  TotemAuth({
    required this.id,
    required this.token,
    required this.name,
    required this.publicKey,
    required this.storeId,
    required this.granted,
    this.grantedById,
    this.sid,
    required this.storeUrl,
  });

  final int id;
  final String token; // Corresponde a 'totem_token'
  final String name; // Corresponde a 'totem_name'
  final String publicKey;
  final int storeId;
  final bool granted;
  final int? grantedById;
  final String? sid;
  final String storeUrl;

  /// ✅ MÉTODO ADICIONADO:
  /// Cria uma instância "vazia" do TotemAuth.
  /// É útil como um placeholder no novo fluxo de autenticação,
  /// onde o token JWT do usuário é o principal, e não mais os dados do totem.
  factory TotemAuth.dummy() {
    return TotemAuth(
      id: 0,
      token: '',
      name: '',
      publicKey: '',
      storeId: 0,
      granted: false,
      storeUrl: '',
    );
  }

  factory TotemAuth.fromJson(Map<String, dynamic> json) {
    return TotemAuth(
      id: json['id'] as int,
      token: json['totem_token'] as String,
      name: json['totem_name'] as String,
      publicKey: json['public_key'] as String,
      storeId: json['store_id'] as int,
      granted: json['granted'] as bool,
      grantedById: json['granted_by_id'] as int?,
      sid: json['sid'] as String?,
      storeUrl: json['store_url'] as String,
    );
  }
}
