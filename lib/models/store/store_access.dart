import 'package:totem_pro_admin/models/store/store_with_role.dart';
import 'package:totem_pro_admin/models/user.dart';

class StoreAccess {

  StoreAccess({
    required this.user,
    required this.role,
  });

  final User user;
  final StoreAccessRole role;

  factory StoreAccess.fromJson(Map<String, dynamic> json) {
    return StoreAccess(
      user: User.fromJson(json['user']),
      role: StoreAccessRole.values.byName(json['role']['machine_name']),
    );
  }

}