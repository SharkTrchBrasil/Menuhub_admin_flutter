// lib/models/totem_auth_and_stores.dart
import 'package:totem_pro_admin/models/totem_auth.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';

class TotemAuthAndStores {
  final TotemAuth totemAuth;
  final List<StoreWithRole> stores;

  TotemAuthAndStores({required this.totemAuth, required this.stores});
}