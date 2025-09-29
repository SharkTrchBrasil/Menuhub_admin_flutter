import 'package:dio/dio.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/products/product.dart';


class BannerModel {
  const BannerModel({
    this.id,
    this.startDate,
    this.endDate,
    this.product,
    this.category,
    this.image,
    this.position = 1,
    this.linkUrl,
    this.isActive = true,
  });

  final int? id;
  final Product? product;
  final Category? category;
  final ImageModel? image;
  final int position;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? linkUrl;

  factory BannerModel.fromJson(Map<String, dynamic> map) {
    return BannerModel(
      id: map['id'] as int?,
      linkUrl: map['link_url'] as String?, // Pode ser null

      product: map['product'] != null ? Product.fromJson(map['product']) : null,
      category: map['category'] != null ? Category.fromJson(map['category']) : null,

      image: map['image_path'] != null
          ? ImageModel(url: map['image_path'] as String)
          : null,

      position: map['position'] as int? ?? 1,

      isActive: map['is_active'] as bool? ?? true,

      startDate: map['start_date'] != null
          ? DateTime.tryParse(map['start_date'])
          : null,

      endDate: map['end_date'] != null
          ? DateTime.tryParse(map['end_date'])
          : null,
    );
  }

  BannerModel copyWith({
    int? storeId,
    Product? product,
    Category? category,
    ImageModel? image,
    int? position,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    String? linkUrl,
  }) {
    return BannerModel(
      id: id,
      product: product ?? this.product,
      category: category ?? this.category,
      image: image ?? this.image,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      linkUrl: linkUrl ?? this.linkUrl,
    );
  }

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      if (product?.id != null) 'product_id': product!.id,
      if (category?.id != null) 'category_id': category!.id,
      'is_active': isActive,
      if (linkUrl != null) 'link_url': linkUrl,
      if (startDate != null) 'start_date': startDate!.toIso8601String(),
      if (endDate != null) 'end_date': endDate!.toIso8601String(),
      'position': position,
      if (image?.file != null)
        'image': MultipartFile.fromBytes(
          await image!.file!.readAsBytes(),
          filename: image!.file!.name,
        ),
    });
  }
}
