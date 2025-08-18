import 'package:totem_pro_admin/models/auth_tokens.dart'; // ✅ Importe o modelo correto
import 'package:totem_pro_admin/models/store_with_role.dart';
import 'package:totem_pro_admin/models/user.dart';

class TotemAuthAndStores {
  // ✅ O campo agora é do tipo AuthTokens
  final AuthTokens authTokens;
  final User user;
  final List<StoreWithRole> stores;

  TotemAuthAndStores({
    required this.authTokens, // ✅
    required this.user,
    required this.stores,
  });

  TotemAuthAndStores copyWith({
    AuthTokens? authTokens, // ✅
    User? user,
    List<StoreWithRole>? stores,
  }) {
    return TotemAuthAndStores(
      authTokens: authTokens ?? this.authTokens, // ✅
      user: user ?? this.user,
      stores: stores ?? this.stores,
    );
  }
}