import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/printer_config.dart';

class PrinterMappingService {
  final SharedPreferences _prefs;
  static const _printerMapKey = 'printer_destination_map_v2';
  static const _printerDestinationsKey = 'printer_destinations_per_printer';

  PrinterMappingService(this._prefs);

  /// Salva a configuração de uma impressora para um destino.
  Future<void> setMapping(String destination, PrinterConfig config) async {
    final map = await getAllMappings();
    map[destination.toLowerCase()] = config; // Garante consistência
    final jsonMap = map.map((key, value) => MapEntry(key, value.toJson()));
    await _prefs.setString(_printerMapKey, json.encode(jsonMap));
  }

  // ✅ ====================================================================
  // ✅ MÉTODO CORRIGIDO COM A LÓGICA DE FALLBACK
  // ✅ ====================================================================
  /// Retorna a configuração da impressora para um destino, com lógica de fallback.
  Future<PrinterConfig?> getConfigForDestination(String destination) async {
    final map = await getAllMappings();
    final destLowerCase = destination.toLowerCase();

    // 1. Tenta encontrar a impressora para o destino EXATO solicitado.
    if (map.containsKey(destLowerCase)) {
      print('[MappingService] Impressora encontrada para o destino exato: "$destLowerCase"');
      return map[destLowerCase];
    }

    // 2. Se não encontrou, inicia a busca por impressoras de FALLBACK.
    print('[MappingService] Nenhuma impressora para "$destLowerCase". Procurando por fallbacks...');

    // Lista de fallbacks em ordem de prioridade. Você pode customizar esta lista.
    final fallbackOrder = ['balcao', 'caixa', 'bar'];

    for (final fallbackDest in fallbackOrder) {
      if (map.containsKey(fallbackDest)) {
        print('[MappingService] Usando impressora de fallback "$fallbackDest" para o destino "$destLowerCase".');
        // Retorna a configuração da primeira impressora de fallback que encontrar.
        return map[fallbackDest];
      }
    }

    // 3. Se nem o destino exato nem os fallbacks foram encontrados, retorna null.
    print('[MappingService] Nenhum fallback encontrado. Não é possível imprimir para o destino "$destLowerCase".');
    return null;
  }

  /// Retorna todos os mapeamentos salvos.
  Future<Map<String, PrinterConfig>> getAllMappings() async {
    final jsonString = _prefs.getString(_printerMapKey);
    if (jsonString == null) return {};

    final decodedMap = json.decode(jsonString) as Map<String, dynamic>;
    return decodedMap.map(
          (key, value) => MapEntry(key, PrinterConfig.fromJson(value)),
    );
  }

  /// Remove o mapeamento de um destino.
  Future<void> removeMapping(String destination) async {
    final map = await getAllMappings();
    map.remove(destination.toLowerCase()); // Garante consistência
    final jsonMap = map.map((key, value) => MapEntry(key, value.toJson()));
    await _prefs.setString(_printerMapKey, json.encode(jsonMap));
  }
}