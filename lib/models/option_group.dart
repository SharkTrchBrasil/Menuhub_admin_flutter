import 'package:totem_pro_admin/models/option_item.dart';

class OptionGroup {
  // ✨ Trocamos de 'int' para 'int?' para permitir valor nulo
  final int? id;
  final String name;
  final int minSelection;
  final int maxSelection;
  final int? priority; // ✨ Também se tornou opcional
  final List<OptionItem> items;

  const OptionGroup({
    this.id, // ✨ 'required' foi removido
    required this.name,
    required this.minSelection,
    required this.maxSelection,
    this.priority, // ✨ 'required' foi removido
    this.items = const [],
  });

  factory OptionGroup.fromJson(Map<String, dynamic> json) {
    return OptionGroup(
      id: json['id'],
      name: json['name'],
      minSelection: json['min_selection'],
      maxSelection: json['max_selection'],
      priority: json['priority'],
      items: (json['items'] as List<dynamic>?)
          ?.map((itemJson) => OptionItem.fromJson(itemJson))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'min_selection': minSelection,
      'max_selection': maxSelection,
      // ✨ Incluímos a lista de itens no JSON para criação
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}