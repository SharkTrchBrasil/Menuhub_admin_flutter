import 'package:totem_pro_admin/models/totem_auth.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';
import 'package:totem_pro_admin/models/user.dart'; // ✅ IMPORTE O NOVO MODELO

class TotemAuthAndStores {
  final TotemAuth totemAuth;
  final List<StoreWithRole> stores;
  final User user; // ✅ ADICIONE A PROPRIEDADE DO USUÁRIO AQUI

  TotemAuthAndStores({
    required this.totemAuth,
    required this.stores,
    required this.user, // ✅ ADICIONE AO CONSTRUTOR
  });
}