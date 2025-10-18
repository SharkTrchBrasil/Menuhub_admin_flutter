// Em: models/store/store_access.dart

import 'package:totem_pro_admin/models/user.dart';

import '../../core/enums/store_access.dart';



/// Modelo que representa um acesso de usuário a uma loja
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
      role: StoreAccessRole.fromName(json['role']['machine_name']),
    );
  }
}