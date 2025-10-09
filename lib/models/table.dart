import 'command.dart'; // You will need to create this model as well

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
}