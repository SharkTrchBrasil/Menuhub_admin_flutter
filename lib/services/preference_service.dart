// lib/services/preference_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const _skipHubKey = 'skip_hub_screen';
  // NOVAS chaves para uma preferência mais inteligente
  static const _lastRouteStoreIdKey = 'last_route_store_id';
  static const _lastStoreSubRouteKey = 'last_store_sub_route';

  Future<void> saveSkipHubPreference(bool shouldSkip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_skipHubKey, shouldSkip);
  }

  Future<bool> getSkipHubPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_skipHubKey) ?? false;
  }

  /// Salva a sub-rota (ex: 'dashboard', 'products') e o ID da loja associada.
  Future<void> saveLastAccessedRouteForStore({
    required int storeId,
    required String route,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Extrai a parte da rota após o ID da loja. Ex: de '/stores/123/dashboard' pega 'dashboard'
    final uri = Uri.parse(route);
    if (uri.pathSegments.length > 2) {
      final subRoute = uri.pathSegments.sublist(2).join('/');
      if (subRoute.isNotEmpty) {
        await prefs.setInt(_lastRouteStoreIdKey, storeId);
        await prefs.setString(_lastStoreSubRouteKey, subRoute);
      }
    }
  }

  /// Recupera a sub-rota salva, mas SOMENTE se pertencer à loja fornecida.
  Future<String?> getLastAccessedSubRouteForStore(int currentStoreId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedStoreId = prefs.getInt(_lastRouteStoreIdKey);

    // A preferência só é válida se o ID da loja salvo for o mesmo da loja ativa.
    if (savedStoreId == currentStoreId) {
      return prefs.getString(_lastStoreSubRouteKey);
    }

    // Se a preferência era de outra loja, retorna nulo.
    return null;
  }

  /// Limpa a preferência de rota quando o usuário desloga ou troca de loja manualmente.
  Future<void> clearLastAccessedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastRouteStoreIdKey);
    await prefs.remove(_lastStoreSubRouteKey);
  }
}