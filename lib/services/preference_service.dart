// lib/services/preference_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const _skipHubKey = 'skip_hub_screen';
  static const _lastRouteKey = 'last_accessed_route';

  Future<void> saveSkipHubPreference(bool shouldSkip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_skipHubKey, shouldSkip);
  }

  Future<bool> getSkipHubPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_skipHubKey) ?? false;
  }

  Future<void> saveLastAccessedRoute(String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastRouteKey, route);
  }

  Future<String?> getLastAccessedRoute() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastRouteKey);
  }
}