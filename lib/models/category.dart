import 'package:dio/dio.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/widgets/app_selection_form_field.dart';

class Category implements SelectableItem {
  const Category({this.id, this.name = '', this.image, this.priority = 1, this.is_active = true});

  final int? id;
  final String name;
  final int priority;
  final ImageModel? image;
  final bool is_active;

  factory Category.fromJson(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      is_active: map['is_active'] as bool,
      image: map['image_path'] != null
          ? ImageModel(url: map['image_path'] as String)
          : null,
      priority: map['priority'] as int,
    );
  }


  Category copyWith({String? name, ImageModel? image, int? priority}) {
    return Category(
      id: id,
      name: name ?? this.name,
      is_active: is_active,
      image: image ?? this.image,
      priority: priority ?? this.priority,
    );
  }

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'name': name,
      'priority': priority,
      'is_active': is_active,
      if (image?.file != null)
        'image': MultipartFile.fromBytes(
          await image!.file!.readAsBytes(),
          filename: image!.file!.name,
        ),
    });
  }

  @override
  String get title => name;
}
