// ✅ 1. Importe o Equatable para comparação de objetos
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/option_item.dart';

import '../core/enums/pricing_strategy.dart';

// ✅ 2. Adicione 'extends Equatable'
class OptionGroup extends Equatable {
  final int? id; // ID do banco de dados (pode ser nulo se for um grupo novo)
  final String? localId; // ✅ 3. ID temporário para a UI gerenciar itens novos
  final String name;
  final int minSelection;
  final int maxSelection;
  final int? priority;
  final List<OptionItem> items;
  final PricingStrategy pricingStrategy;

  const OptionGroup({
    this.id,
    this.localId, // ✅ Adicionado ao construtor
    required this.name,
    required this.minSelection,
    required this.maxSelection,
    this.priority,
    this.items = const [],
    this.pricingStrategy = PricingStrategy.sumOfItems,
  });

  // ✅ 4. MÉTODO COPYWITH COMPLETO
  /// Cria uma cópia do objeto, permitindo a alteração de campos específicos.
  OptionGroup copyWith({
    int? id,
    String? localId,
    String? name,
    int? minSelection,
    int? maxSelection,
    int? priority,
    List<OptionItem>? items,
    PricingStrategy? pricingStrategy
  }) {
    return OptionGroup(
        id: id ?? this.id,
        localId: localId ?? this.localId,
        name: name ?? this.name,
        minSelection: minSelection ?? this.minSelection,
        maxSelection: maxSelection ?? this.maxSelection,
        priority: priority ?? this.priority,
        items: items ?? this.items,
        pricingStrategy: pricingStrategy ?? this.pricingStrategy
    );
  }

  // ✅ 5. PROPS PARA O EQUATABLE
  //    Isso garante que o BLoC saiba quando um OptionGroup realmente mudou.
  @override
  List<Object?> get props => [id, localId, name, minSelection, maxSelection, priority, items, pricingStrategy];

  // ✅ MÉTODO FROMJSON COMPLETO
  factory OptionGroup.fromJson(Map<String, dynamic> json) {
    return OptionGroup(
      id: json['id'],
      localId: json['local_id'], // ✅ Adicionado localId
      name: json['name'],
      minSelection: json['min_selection'] ?? 0,
      maxSelection: json['max_selection'] ?? 1,
      priority: json['priority'],
      pricingStrategy: json['pricing_strategy'] != null
          ? PricingStrategy.values.firstWhere(
            (e) => e.toString() == 'PricingStrategy.${json['pricing_strategy']}',
        orElse: () => PricingStrategy.sumOfItems,
      )
          : PricingStrategy.sumOfItems,
      items: (json['items'] as List<dynamic>?)
          ?.map((itemJson) => OptionItem.fromJson(itemJson))
          .toList() ??
          [],
    );
  }

  // ✅ MÉTODO TOJSON COMPLETO
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'local_id': localId, // ✅ Adicionado localId
      'name': name,
      'min_selection': minSelection,
      'max_selection': maxSelection,
      'priority': priority,
      'pricing_strategy': pricingStrategy.toString().split('.').last, // Converte enum para string
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // ✅ MÉTODO PARA CONVERSÃO DE JSON EM LOTE (OPCIONAL)
  static List<OptionGroup> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => OptionGroup.fromJson(json)).toList();
  }

  // ✅ MÉTODO PARA CONVERSÃO PARA JSON EM LOTE (OPCIONAL)
  static List<Map<String, dynamic>> toJsonList(List<OptionGroup> groups) {
    return groups.map((group) => group.toJson()).toList();
  }
}