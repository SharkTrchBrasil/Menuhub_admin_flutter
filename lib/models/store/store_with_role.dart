import 'package:totem_pro_admin/models/store/store.dart';

import '../../core/enums/store_access.dart';



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
        // Se 'role' vem como String, busca pelo nome (machine_name)
        role = StoreAccessRole.values.firstWhere(
              (r) => r.name == json['role'],
          // CUIDADO AQUI: Mude para 'manager' ou outra role padrão válida se 'admin' não existir mais
          orElse: () => StoreAccessRole.manager,
        );
      } else if (json['role'] is Map) {
        // Se 'role' vem como Map (com 'machine_name'), busca por ele
        role = StoreAccessRole.values.firstWhere(
              (r) => r.name == (json['role']['machine_name'] ?? 'manager'),
          // CUIDADO AQUI: Mude para 'manager' ou outra role padrão válida se 'admin' não existir mais
          orElse: () => StoreAccessRole.manager,
        );
      } else {
        // Valor padrão se 'role' não for String nem Map
        role = StoreAccessRole.manager; // CUIDADO AQUI: Mude para 'manager'
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


  StoreWithRole copyWith({
    Store? store,
    StoreAccessRole? role,
    bool? isConsolidated,
  }) {
    return StoreWithRole(
      store: store ?? this.store,
      role: role ?? this.role,
      isConsolidated: isConsolidated ?? this.isConsolidated,
    );
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