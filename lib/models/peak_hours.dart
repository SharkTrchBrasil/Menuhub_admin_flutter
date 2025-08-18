import 'package:flutter/material.dart';

/// Representa os horários de pico de pedidos para uma loja,
/// calculados com base em dados históricos.
class PeakHours {
  final TimeOfDay lunchPeakStart;
  final TimeOfDay lunchPeakEnd;
  final TimeOfDay dinnerPeakStart;
  final TimeOfDay dinnerPeakEnd;

  PeakHours({
    required this.lunchPeakStart,
    required this.lunchPeakEnd,
    required this.dinnerPeakStart,
    required this.dinnerPeakEnd,
  });

  /// Construtor de fábrica para criar uma instância de PeakHours a partir de um mapa JSON.
  ///
  /// Espera chaves em camelCase (ex: "lunchPeakStart") como vêm da API.
  factory PeakHours.fromJson(Map<String, dynamic> json) {
    // Validação para garantir que os dados não sejam nulos.
    // Se forem, retorna um valor padrão seguro para evitar crashes.
    if (json['lunchPeakStart'] == null ||
        json['lunchPeakEnd'] == null ||
        json['dinnerPeakStart'] == null ||
        json['dinnerPeakEnd'] == null) {
      return PeakHours.defaultValues();
    }

    return PeakHours(
      lunchPeakStart: _timeFromString(json['lunchPeakStart']),
      lunchPeakEnd: _timeFromString(json['lunchPeakEnd']),
      dinnerPeakStart: _timeFromString(json['dinnerPeakStart']),
      dinnerPeakEnd: _timeFromString(json['dinnerPeakEnd']),
    );
  }

  /// Um construtor nomeado para fornecer valores padrão caso os dados da API
  /// falhem ou ainda não estejam disponíveis.
  factory PeakHours.defaultValues() {
    return PeakHours(
      lunchPeakStart: const TimeOfDay(hour: 12, minute: 0),
      lunchPeakEnd: const TimeOfDay(hour: 14, minute: 0),
      dinnerPeakStart: const TimeOfDay(hour: 19, minute: 0),
      dinnerPeakEnd: const TimeOfDay(hour: 21, minute: 0),
    );
  }

  /// Função auxiliar (helper) para converter uma string no formato "HH:mm"
  /// para um objeto TimeOfDay.
  static TimeOfDay _timeFromString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) {
        // Retorna um valor padrão se o formato estiver incorreto
        return const TimeOfDay(hour: 0, minute: 0);
      }
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      // Em caso de qualquer erro de parsing, retorna um valor seguro
      print('Erro ao converter a string de tempo "$timeString": $e');
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  @override
  String toString() {
    return 'PeakHours(Almoço: ${lunchPeakStart.format(BuildContext as BuildContext)}-${lunchPeakEnd.format(BuildContext as BuildContext)}, Janta: ${dinnerPeakStart.format(BuildContext as BuildContext)}-${dinnerPeakEnd.format(BuildContext as BuildContext)})';
  }
}