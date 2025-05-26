class VariantOption {

  const VariantOption(

       {
    this.isFree = false,
    this.id,
    this.name = '',
    this.description = '',
    this.price = 0,
    this.maxQuantity = 1,
    this.discountPrice = 0,
    this.available = true,
  });

  final int? id;
  final String name;
  final String description;
  final int price;
  final int discountPrice;
  final int maxQuantity;
  final bool available;
  final bool isFree; // já com default false no construtor, se possível


  VariantOption copyWith({
    String? name,
    String? description,
    int? price,
    int? discountPrice,
    int? maxQuantity,
    bool? available,
    bool? isFree
  }) {
    return VariantOption(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      maxQuantity:  maxQuantity ?? this.maxQuantity,
      available: available ?? this.available,
      isFree: isFree ?? this.isFree
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'max_quantity': maxQuantity,
      'available': available,
      'is_free': isFree
    };
  }

  factory VariantOption.fromJson(Map<String, dynamic> map) {
    return VariantOption(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as int,
      discountPrice: map['discount_price'] as int,
      maxQuantity: map['max_quantity'] as int,
      available: map['available'] as bool,
      isFree: map['is_free'] as bool
    );
  }
}