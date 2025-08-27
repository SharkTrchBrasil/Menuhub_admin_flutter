import 'image_model.dart';

class CatalogProduct {
  final int id;
  final String name;
  final String? description;
  final String? ean;
  final String? brand;
  final ImageModel? imagePath;

  CatalogProduct({
    required this.id,
    required this.name,
    this.description,
    this.ean,
    this.brand,
    this.imagePath,
  });

  factory CatalogProduct.fromJson(Map<String, dynamic> json) {
    return CatalogProduct(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      ean: json['ean'],
      brand: json['brand'],


      imagePath: ImageModel(url: json['image_path']),

    );
  }
}