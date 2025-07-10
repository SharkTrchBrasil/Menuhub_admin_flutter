class MinimalProduct {
  final int id;
  final String name;

  MinimalProduct({
    required this.id,
    required this.name,
  });

  factory MinimalProduct.fromJson(Map<String, dynamic> json) {
    return MinimalProduct(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
