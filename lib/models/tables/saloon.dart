import 'table.dart';

class Saloon {
  final int id;
  final String name;
  final int displayOrder;
  final List<TableModel> tables;  // Updated to use TableModel

  Saloon({
    required this.id,
    required this.name,
    required this.displayOrder,
    required this.tables,
  });

  factory Saloon.fromJson(Map<String, dynamic> json) {
    var tableList = json['tables'] as List;
    List<TableModel> tables = tableList.map((i) => TableModel.fromJson(i)).toList();  // Updated to TableModel

    return Saloon(
      id: json['id'],
      name: json['name'],
      displayOrder: json['display_order'],
      tables: tables,
    );
  }
}