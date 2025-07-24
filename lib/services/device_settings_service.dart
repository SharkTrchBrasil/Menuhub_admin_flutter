import 'package:shared_preferences/shared_preferences.dart';

/// Gerencia as configurações locais específicas deste dispositivo.
class DeviceSettingsService {
  final SharedPreferences _prefs;
  static const _printerDestinationKey = 'printer_destination';

  DeviceSettingsService(this._prefs);

  /// Retorna o destino de impressão configurado para este dispositivo (ex: "cozinha").
  /// Retorna null se não houver configuração.
  String? getPrinterDestination() {
    return _prefs.getString(_printerDestinationKey);
  }

  /// Salva o destino de impressão para este dispositivo.
  Future<void> setPrinterDestination(String destination) async {
    await _prefs.setString(_printerDestinationKey, destination);
  }
}