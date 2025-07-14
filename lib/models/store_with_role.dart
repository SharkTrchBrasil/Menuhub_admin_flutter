import 'package:totem_pro_admin/models/store.dart';

enum StoreAccessRole {
  owner('Proprietário', false),
  admin('Administrador', true);

  final String title;
  final bool selectable;

  const StoreAccessRole(this.title, this.selectable);
}

class StoreWithRole {
  final Store store;
  final StoreAccessRole role; // Mudança de String para StoreAccessRole
  bool isConsolidated; // NOVO: indica se está selecionada para consolidação

  StoreWithRole({
    required this.store,
    required this.role,
    this.isConsolidated = false, // Valor padrão
  });

  factory StoreWithRole.fromJson(Map<String, dynamic> json) {
    try {
      // 1. Tratamento robusto para a loja
      final storeJson = json['store'] ?? json; // Aceita tanto o formato encapsulado quanto direto
      final store = Store.fromJson(storeJson);

      // 2. Tratamento seguro para a role
      StoreAccessRole role;
      if (json['role'] is String) {
        role = StoreAccessRole.values.firstWhere(
              (r) => r.name == json['role'],
          orElse: () => StoreAccessRole.admin,
        );
      } else if (json['role'] is Map) {
        role = StoreAccessRole.values.firstWhere(
              (r) => r.name == (json['role']['machine_name'] ?? 'admin'),
          orElse: () => StoreAccessRole.admin,
        );
      } else {
        role = StoreAccessRole.admin; // Valor padrão
      }

      // 3. Obtém o estado de consolidação
      final bool isConsolidated = json['is_consolidated'] ?? false;

      return StoreWithRole(
        store: store,
        role: role,
        isConsolidated: isConsolidated, // Agora está no lugar certo!
      );
    } catch (e, stack) {
      print('Erro ao decodificar StoreWithRole: $e\n$stack');
      rethrow;
    }
  }

  // Opcional: Adicione um método toJson para isConsolidated se for enviar para o backend
  Map<String, dynamic> toJson() => {
    'store': store.toJson(),
    'role': {
      'machine_name': role.name,
      'title': role.title,
    },
    'is_consolidated': isConsolidated, // Inclua no toJson se for serializar
  };
}