// lib/models/feature.dart

class Feature {
  final int id;
  final String featureKey;
  final String name;
  final String? description;
  final bool isAddon;
  final int? addonPrice;

  const Feature({
    required this.id,
    required this.featureKey,
    required this.name,
    this.description,
    required this.isAddon,
    this.addonPrice,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'],
      featureKey: json['feature_key'],
      name: json['name'],
      description: json['description'],
      isAddon: json['is_addon'] ?? false,
      addonPrice: json['addon_price'],
    );
  }

  Feature copyWith({
    int? id,
    String? featureKey,
    String? name,
    String? description,
    bool? isAddon,
    int? addonPrice,
  }) {
    return Feature(
      id: id ?? this.id,
      featureKey: featureKey ?? this.featureKey,
      name: name ?? this.name,
      description: description ?? this.description,
      isAddon: isAddon ?? this.isAddon,
      addonPrice: addonPrice ?? this.addonPrice,
    );
  }
}