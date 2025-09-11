import 'package:dio/dio.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/option_group.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';
import 'package:totem_pro_admin/widgets/app_selection_form_field.dart';


import '../core/enums/available_type.dart';
import '../core/enums/cashback_type.dart';
import '../core/enums/category_type.dart';
import '../core/enums/pricing_strategy.dart';
import 'availability_model.dart';
import 'package:equatable/equatable.dart';

class Category extends Equatable implements SelectableItem{
  final int? id;
  final String name;
  final int priority;
  final ImageModel? image;
  final bool active;
  final CategoryType type;
  final List<OptionGroup> optionGroups;

  // ✨ NOVOS CAMPOS ADICIONADOS
  final CashbackType cashbackType;
  final double cashbackValue;
  // ✨ NOVO CAMPO ADICIONADO
  final List<ProductCategoryLink> productLinks;
  // --- ✨ CAMPOS DE DISPONIBILIDADE ADICIONADOS ---
  final AvailabilityType availabilityType;
  final List<ScheduleRule> schedules;
  final String? printerDestination;

  final PricingStrategy pricingStrategy;
  final bool priceVariesBySize;

  const Category({
    this.id,
    required this.name,
    this.image,
    this.priority = 0,
    this.active = true,
    required this.type,
    this.optionGroups = const [],
    this.productLinks = const [],
    // ✨ ATUALIZADO: Construtor inclui os novos campos com valores padrão
    this.cashbackType = CashbackType.none,
    this.cashbackValue = 0.0,
    // --- ✨ ADICIONADOS AO CONSTRUTOR ---
    this.availabilityType = AvailabilityType.always,
    this.schedules = const [],
    this.printerDestination,
    this.pricingStrategy = PricingStrategy.sumOfItems,
    this.priceVariesBySize = false,
  });


  // ✅ 5. ADICIONE OS PROPS DO EQUATABLE
  @override
  List<Object?> get props => [
    id, name, priority, image, active, type, optionGroups, cashbackType,
    cashbackValue, productLinks, availabilityType, schedules,
    printerDestination, pricingStrategy,priceVariesBySize
  ];


  factory Category.fromJson(Map<String, dynamic> map) {
    // --- LÓGICA ROBUSTA E SIMPLIFICADA PARA ENUMS EM MAIÚSCULAS ---

    // 1. Pega a string da API para 'type', com um valor padrão seguro
    final typeString = map['type'] as String? ?? 'GENERAL';

    // 2. Procura pelo enum correspondente. Se não achar, usa GENERAL.
    final categoryType = CategoryType.values.firstWhere(
          (e) => e.name == typeString, // Agora a comparação é direta, sem toLowerCase()
      orElse: () => CategoryType.GENERAL,
    );

    // 3. Faz o mesmo para 'availability_type'
    final availabilityString = map['availability_type'] as String? ?? 'ALWAYS';
    final availabilityTypeParsed = AvailabilityType.values.firstWhere(
          (e) => e.name == availabilityString,
      orElse: () => AvailabilityType.always,
    );

    // --- FIM DA LÓGICA ---


    final pricingStrategyString = map['pricing_strategy'] as String? ?? 'SUM_OF_ITEMS';
    final pricingStrategyParsed = PricingStrategy.values.firstWhere(
          (e) => e.name.toUpperCase() == pricingStrategyString,
      orElse: () => PricingStrategy.sumOfItems,
    );



    return Category(
      id: map['id'],
      name: map['name'] ?? '',
      active: map['is_active'] ?? true,
      priority: map['priority'] ?? 0,
      image: map['image_path'] != null ? ImageModel(url: map['image_path']) : null,

      type: categoryType, // ✨ Usa o valor parseado corretamente

      optionGroups: (map['option_groups'] as List<dynamic>?)
          ?.map((groupJson) => OptionGroup.fromJson(groupJson))
          .toList() ?? [],

      productLinks: (map['product_links'] as List<dynamic>?)
          ?.map((linkJson) => ProductCategoryLink.fromJson(linkJson))
          .toList() ?? [],

      cashbackType: CashbackType.fromString(map['cashback_type']),
      cashbackValue: double.tryParse(map['cashback_value']?.toString() ?? '0.0') ?? 0.0,

      availabilityType: availabilityTypeParsed, // ✨ Usa o valor parseado corretamente

      schedules: (map['schedules'] as List<dynamic>?)
          ?.map((scheduleJson) => ScheduleRule.fromJson(scheduleJson))
          .toList() ?? [],
      printerDestination: map['printer_destination'], // ✨
      pricingStrategy: pricingStrategyParsed,
      priceVariesBySize: map['price_varies_by_size'] ?? false,
    );
  }






  Map<String, dynamic> toJson() {
    return {
      // --- Campos Simples ---
      'name': name,
      'is_active': active,
      'priority': priority,
      'cashback_value': cashbackValue,

      // --- Enums (convertidos para String e para MAIÚSCULAS) ---
      'type': type.name.toUpperCase(),              // ✅ CORREÇÃO
      'cashback_type': cashbackType.name, // ✅ CORREÇÃO
      'availability_type': availabilityType.name.toUpperCase(), // ✅ CORREÇÃO

      // --- Listas Aninhadas ---
      // Cada item da lista chama seu próprio método toJson recursivamente.
      // Isso é o que permite enviar a "mega estrutura" completa.

      'schedules': schedules.map((schedule) => schedule.toJson()).toList(),
      'option_groups': optionGroups.map((group) => group.toJson()).toList(),
      'product_links': productLinks.map((link) => link.toJson()).toList(),
      'printer_destination': printerDestination, // ✨
      'pricing_strategy': pricingStrategy.name.toUpperCase(),
      'price_varies_by_size': priceVariesBySize,

      // Campos opcionais (só inclui se não forem nulos)
      if (id != null) 'id': id,
      if (image != null) 'image_path': image!.url,

      // NOTA: 'id' não é enviado aqui porque o backend o gera na criação (POST).
      // Na atualização (PATCH), o 'id' vai na URL da rota, não no corpo do JSON.
      // Os IDs dos sub-itens (option_groups, items, etc.) DEVEM estar no toJson deles.
    };
  }

  Category copyWith({
    int? id,
    String? name,
    ImageModel? image,
    int? priority,
    bool? active,
    CategoryType? type,
    List<OptionGroup>? optionGroups,
    // ✨ ATUALIZADO: copyWith agora inclui os novos campos
    CashbackType? cashbackType,
    double? cashbackValue,
    List<ProductCategoryLink>? productLinks,
    AvailabilityType? availabilityType,
    List<ScheduleRule>? schedules,
    String? printerDestination,
    PricingStrategy? pricingStrategy,
    bool? priceVariesBySize
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      priority: priority ?? this.priority,
      active: active ?? this.active,
      type: type ?? this.type,
      optionGroups: optionGroups ?? this.optionGroups,
      cashbackType: cashbackType ?? this.cashbackType,
      cashbackValue: cashbackValue ?? this.cashbackValue,
      productLinks: productLinks ?? this.productLinks,
      availabilityType: availabilityType ?? this.availabilityType,
      schedules: schedules ?? this.schedules,
      printerDestination: printerDestination ?? this.printerDestination,
      pricingStrategy: pricingStrategy ?? this.pricingStrategy,
      priceVariesBySize: priceVariesBySize ?? this.priceVariesBySize,
    );
  }

  @override
  String get title => name;
}