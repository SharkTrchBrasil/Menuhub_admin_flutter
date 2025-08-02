import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerencia as configurações locais específicas deste dispositivo.
class DeviceSettingsService {
  final SharedPreferences _prefs;

  static const _printerDestinationsKey = 'printer_destinations_per_printer';

  DeviceSettingsService(this._prefs);

  /// Lê o Map<String, Set<String>> salvo no SharedPreferences
  Future<Map<String, Set<String>>> getPrinterDestinationsPerPrinter() async {
    final jsonString = _prefs.getString(_printerDestinationsKey);
    if (jsonString == null || jsonString.isEmpty) return {};

    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) {
        final List<dynamic> list = value;
        final Set<String> set = list.map((e) => e.toString().trim().toLowerCase()).toSet();
        return MapEntry(key, set);
      });
    } catch (e) {
      return {};
    }
  }

  /// Salva o Map<String, Set<String>> no SharedPreferences
  Future<void> setPrinterDestinationsPerPrinter(Map<String, Set<String>> data) async {
    final Map<String, List<String>> serializableMap =
    data.map((key, value) => MapEntry(key, value.toList()));
    final jsonString = jsonEncode(serializableMap);
    await _prefs.setString(_printerDestinationsKey, jsonString);
  }

  /// Adiciona um destino para uma impressora específica
  Future<void> addPrinterDestinationForPrinter(String printerId, String destination) async {
    final current = await getPrinterDestinationsPerPrinter();
    final destinations = current[printerId] ?? <String>{};
    destinations.add(destination.trim().toLowerCase());
    current[printerId] = destinations;
    await setPrinterDestinationsPerPrinter(current);
  }

  /// Remove um destino para uma impressora específica
  Future<void> removePrinterDestinationForPrinter(String printerId, String destination) async {
    final current = await getPrinterDestinationsPerPrinter();
    final destinations = current[printerId];
    if (destinations == null) return;
    destinations.remove(destination.trim().toLowerCase());
    if (destinations.isEmpty) {
      current.remove(printerId);
    } else {
      current[printerId] = destinations;
    }
    await setPrinterDestinationsPerPrinter(current);
  }

  /// Verifica se a impressora tem um destino ativo
  Future<bool> hasPrinterDestinationForPrinter(String printerId, String destination) async {
    final current = await getPrinterDestinationsPerPrinter();
    final destinations = current[printerId];
    if (destinations == null) return false;
    return destinations.contains(destination.trim().toLowerCase());
  }

  /// Retorna um conjunto com todos os destinos ativos neste dispositivo
  Future<Set<String>> getPrinterDestinations() async {
    final data = _prefs.getString(_printerDestinationsKey);
    if (data == null || data.isEmpty) return {};

    try {
      final decoded = Map<String, dynamic>.from(jsonDecode(data));
      final allDestinations = <String>{};
      for (final entry in decoded.entries) {
        final destinations = List<String>.from(entry.value);
        allDestinations.addAll(destinations.map((d) => d.trim().toLowerCase()));
      }
      return allDestinations;
    } catch (e) {
      print('[DeviceSettingsService] Erro ao ler destinos locais: $e');
      return {};
    }
  }
}
