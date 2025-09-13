// Em: lib/models/option_group.dart
import 'package:equatable/equatable.dart';
import 'package:recase/recase.dart';
import 'package:totem_pro_admin/models/option_item.dart';

import '../core/enums/option_group_type.dart';
import '../core/enums/pricing_strategy.dart';

class OptionGroup extends Equatable {
  final int? id;
  final String? localId;
  final String name;
  final int minSelection;
  final int maxSelection;
  final int? priority;
  final List<OptionItem> items;
  final PricingStrategy pricingStrategy;
  final OptionGroupType groupType;
  final bool isConfigurable;

  const OptionGroup({
    this.id,
    this.localId,
    required this.name,
    this.minSelection = 1,
    this.maxSelection = 1,
    this.priority,
    this.items = const [],
    this.pricingStrategy = PricingStrategy.sumOfItems,
    this.groupType = OptionGroupType.generic,
    this.isConfigurable = true,
  });

  @override
  List<Object?> get props => [
    id, localId, name, minSelection, maxSelection, priority, items,
    pricingStrategy, groupType, isConfigurable
  ];

  OptionGroup copyWith({
    int? id,
    String? localId,
    String? name,
    int? minSelection,
    int? maxSelection,
    int? priority,
    List<OptionItem>? items,
    PricingStrategy? pricingStrategy,
    OptionGroupType? groupType,
    bool? isConfigurable,
  }) {
    return OptionGroup(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      name: name ?? this.name,
      minSelection: minSelection ?? this.minSelection,
      maxSelection: maxSelection ?? this.maxSelection,
      priority: priority ?? this.priority,
      items: items ?? this.items,
      pricingStrategy: pricingStrategy ?? this.pricingStrategy,
      groupType: groupType ?? this.groupType,
      isConfigurable: isConfigurable ?? this.isConfigurable,
    );
  }

  factory OptionGroup.fromJson(Map<String, dynamic> json) {
    // ✅ LÓGICA ROBUSTA PARA PARSE DE ENUMS
    final groupTypeString = json['group_type'] as String? ?? 'GENERIC';
    final groupType = OptionGroupType.values.firstWhere(
          (e) => e.name.toUpperCase() == groupTypeString.toUpperCase(),
      orElse: () => OptionGroupType.generic,
    );

    final pricingStrategyString = json['pricing_strategy'] as String? ?? 'SUM_OF_ITEMS';
    final pricingStrategy = PricingStrategy.values.firstWhere(
          (e) => e.name.constantCase == pricingStrategyString,
      orElse: () => PricingStrategy.sumOfItems,
    );

    return OptionGroup(
      id: json['id'],
      name: json['name'] ?? '',
      minSelection: json['min_selection'] ?? 1,
      maxSelection: json['max_selection'] ?? 1,
      priority: json['priority'],
      groupType: groupType,
      pricingStrategy: pricingStrategy,
      isConfigurable: json['is_configurable'] ?? true,
      items: (json['items'] as List<dynamic>?)
          ?.map((itemJson) => OptionItem.fromJson(itemJson))
          .toList() ??
          [],
      // Note que 'localId' não é lido do JSON, pois ele só existe no frontend.
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'min_selection': minSelection,
      'max_selection': maxSelection,
      'priority': priority,

      // ✅ ENVIA OS ENUMS E FLAGS NO FORMATO CORRETO PARA A API
      'group_type': groupType.name.toUpperCase(),
      'pricing_strategy': pricingStrategy.name.constantCase,
      'is_configurable': isConfigurable,

      'items': items.map((item) => item.toJson()).toList(),
      // Note que 'local_id' não é enviado, pois o backend não precisa dele.
    };
  }
}