import 'package:dio/dio.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/widgets/app_selection_form_field.dart';

class Category implements SelectableItem {
  const Category({this.id, this.name = '', this.image, this.priority = 1, this.active = true});

  final int? id;
  final String name;
  final int priority;
  final ImageModel? image;
  final bool active;

  factory Category.fromJson(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      active: map['is_active'] as bool,
      image: map['image_path'] != null
          ? ImageModel(url: map['image_path'] as String)
          : null,
      priority: map['priority'] as int,
    );
  }


// No seu arquivo do modelo Category.dart
  Category copyWith({
    String? name,
    ImageModel? image,
    int? priority,
    bool? active, // <-- Adicione este parâmetro
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      image: image ?? this.image,
      priority: priority ?? this.priority,
      active: active ?? this.active, // <-- Use o novo parâmetro
    );
  }

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'name': name,
      'priority': priority,
      'active': active,
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
