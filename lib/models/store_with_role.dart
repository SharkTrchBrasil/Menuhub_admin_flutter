import 'package:totem_pro_admin/models/store.dart';

enum StoreAccessRole {
  owner('Proprietário', false),
  admin('Administrador', true);

  final String title;
  final bool selectable;

  const StoreAccessRole(this.title, this.selectable);
}

// class StoreWithRole {
//
//   StoreWithRole({
//     required this.store,
//     required this.role,
//   });
//
//   final Store store;
//   final StoreAccessRole role;
//
//   factory StoreWithRole.fromJson(Map<String, dynamic> json) {
//     return StoreWithRole(
//       store: Store.fromJson(json['store']),
//       role: StoreAccessRole.values.byName(json['role']['machine_name']),
//     );
//   }
//
// }


class StoreWithRole {
  final Store store;
  final StoreAccessRole role;

  StoreWithRole({
    required this.store,
    required this.role,
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

      return StoreWithRole(
        store: store,
        role: role,
      );
    } catch (e, stack) {
      print('Erro ao decodificar StoreWithRole: $e\n$stack');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'store': store.toJson(),
    'role': {
      'machine_name': role.name,
      'title': role.title,
    },
  };
}