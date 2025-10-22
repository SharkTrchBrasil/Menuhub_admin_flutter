// lib/services/preference_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferenceService {
  static const _skipHubKey = 'skip_hub_screen';
  static const _skipHubStoreIdKey = 'skip_hub_store_id';
  static const _lastRouteStoreIdKey = 'last_route_store_id';
  static const _lastStoreSubRouteKey = 'last_store_sub_route';

  static const _rememberMeKey = 'remember_me';
  static const _savedEmailKey = 'saved_email';
  static const _savedPasswordKey = 'saved_password';

  static const _secureStorage = FlutterSecureStorage();

  // ============ FUNÇÕES PARA SKIP HUB ============

  /// Salva a preferência de pular o hub com o ID da loja
  Future<void> saveSkipHubPreference(bool shouldSkip, int storeId) async {
    final prefs = await SharedPreferences.getInstance();

    if (shouldSkip) {
      await prefs.setBool(_skipHubKey, true);
      await prefs.setInt(_skipHubStoreIdKey, storeId);
    } else {
      await clearSkipHubPreference();
    }
  }

  /// Recupera se deve pular o hub
  Future<bool> getSkipHubPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_skipHubKey) ?? false;
  }

  /// Recupera o ID da loja que foi marcada para pular
  Future<int?> getLastSkippedStoreId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_skipHubStoreIdKey);
  }

  /// Limpa a preferência de pular hub
  Future<void> clearSkipHubPreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_skipHubKey, false);
    await prefs.remove(_skipHubStoreIdKey);
  }

  // ============ FUNÇÕES PARA LAST ROUTE ============

  Future<void> saveLastAccessedRouteForStore({
    required int storeId,
    required String route,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final uri = Uri.parse(route);
    if (uri.pathSegments.length > 2) {
      final subRoute = uri.pathSegments.sublist(2).join('/');
      if (subRoute.isNotEmpty) {
        await prefs.setInt(_lastRouteStoreIdKey, storeId);
        await prefs.setString(_lastStoreSubRouteKey, subRoute);
      }
    }
  }

  Future<String?> getLastAccessedSubRouteForStore(int currentStoreId) async {
    final prefs = await SharedPreferences.getInstance();
    final savedStoreId = prefs.getInt(_lastRouteStoreIdKey);

    if (savedStoreId == currentStoreId) {
      return prefs.getString(_lastStoreSubRouteKey);
    }

    return null;
  }

  Future<void> clearLastAccessedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastRouteStoreIdKey);
    await prefs.remove(_lastStoreSubRouteKey);
  }

  // ============ FUNÇÕES PARA CREDENCIAIS ============

  /// Salva email e senha de forma segura quando o usuário marca "Permanecer conectado"
  Future<void> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (rememberMe) {
        await prefs.setString(_savedEmailKey, email);

        await _secureStorage.write(
          key: _savedPasswordKey,
          value: password,
        );

        await prefs.setBool(_rememberMeKey, true);
      } else {
        await clearSavedCredentials();
      }
    } catch (e) {
      print('Erro ao salvar credenciais: $e');
      rethrow;
    }
  }

  /// Recupera as credenciais salvas (email e senha)
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isRemembered = prefs.getBool(_rememberMeKey) ?? false;

      if (!isRemembered) {
        return null;
      }

      final email = prefs.getString(_savedEmailKey);
      final password = await _secureStorage.read(key: _savedPasswordKey);

      if (email != null && password != null) {
        return {
          'email': email,
          'password': password,
        };
      }

      return null;
    } catch (e) {
      print('Erro ao recuperar credenciais: $e');
      return null;
    }
  }

  /// Verifica se há credenciais salvas
  Future<bool> hasRememberedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      print('Erro ao verificar credenciais salvas: $e');
      return false;
    }
  }

  /// Limpa as credenciais salvas (chamar no logout)
  Future<void> clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_rememberMeKey, false);
      await prefs.remove(_savedEmailKey);
      await _secureStorage.delete(key: _savedPasswordKey);
    } catch (e) {
      print('Erro ao limpar credenciais: $e');
    }
  }

  /// Limpa todas as preferências (chamar no logout)
  Future<void> clearAllPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _secureStorage.deleteAll();
    } catch (e) {
      print('Erro ao limpar todas as preferências: $e');
    }
  }
}