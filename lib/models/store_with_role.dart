import 'package:totem_pro_admin/models/store.dart';

enum StoreAccessRole {
  owner('Proprietário', false),
  admin('Administrador', true);

  final String title;
  final bool selectable;

  const StoreAccessRole(this.title, this.selectable);
}

class StoreWithRole {

  StoreWithRole({
    required this.store,
    required this.role,
  });

  final Store store;
  final StoreAccessRole role;

  factory StoreWithRole.fromJson(Map<String, dynamic> json) {
    return StoreWithRole(
      store: Store.fromJson(json['store']),
      role: StoreAccessRole.values.byName(json['role']['machine_name']),
    );
  }

}