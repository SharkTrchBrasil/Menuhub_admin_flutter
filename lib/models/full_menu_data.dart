// Em: lib/models/full_menu_data.dart
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/variant.dart';

class FullMenuData {
  final List<Product> products;
  final List<Category> categories;
  final List<Variant> variants;

  FullMenuData({
    required this.products,
    required this.categories,
    required this.variants,
  });
}