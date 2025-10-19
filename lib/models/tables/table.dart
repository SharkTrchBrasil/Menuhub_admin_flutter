// lib/models/tables/table.dart
import 'command.dart';

class TableModel {
  final int id;
  final int storeId;
  final int saloonId;
  final String name;
  final String status;
  final int maxCapacity;
  final String? locationDescription;
  final List<Command> commands;

  TableModel({
    required this.id,
    required this.storeId,
    required this.saloonId,
    required this.name,
    required this.status,
    required this.maxCapacity,
    this.locationDescription,
    required this.commands,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    var commandList = json['commands'] as List? ?? [];
    List<Command> commands = commandList.map((i) => Command.fromJson(i)).toList();

    return TableModel(
      id: json['id'],
      storeId: json['store_id'],
      saloonId: json['saloon_id'],
      name: json['name'],
      status: json['status'],
      maxCapacity: json['max_capacity'],
      locationDescription: json['location_description'],
      commands: commands,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'store_id': storeId,
    'saloon_id': saloonId,
    'name': name,
    'status': status,
    'max_capacity': maxCapacity,
    'location_description': locationDescription,
    'commands': commands.map((c) => c.toJson()).toList(),
  };

  // ===== HELPERS =====

  bool get isAvailable => status == 'AVAILABLE';
  bool get isOccupied => status == 'OCCUPIED';
  bool get isReserved => status == 'RESERVED';

  // ✅ CORREÇÃO APLICADA
  Command? get activeCommand {
    // Busca a primeira comanda ativa, retorna null se não encontrar
    for (final command in commands) {
      if (command.isActive) {
        return command;
      }
    }
    return null;
  }

  // ✅ ALTERNATIVA 2 (Mais concisa usando cast)
  // Command? get activeCommand => commands.cast<Command?>().firstWhere(
  //   (c) => c?.isActive ?? false,
  //   orElse: () => null,
  // );

  // ✅ ALTERNATIVA 3 (Usando where + firstOrNull - requer Dart 2.17+)
  // Command? get activeCommand => commands.where((c) => c.isActive).firstOrNull;

  // Cria uma cópia com campos atualizados
  TableModel copyWith({
    int? id,
    int? storeId,
    int? saloonId,
    String? name,
    String? status,
    int? maxCapacity,
    String? locationDescription,
    List<Command>? commands,
  }) {
    return TableModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      saloonId: saloonId ?? this.saloonId,
      name: name ?? this.name,
      status: status ?? this.status,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      locationDescription: locationDescription ?? this.locationDescription,
      commands: commands ?? this.commands,
    );
  }
}