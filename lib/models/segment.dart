import 'package:dio/dio.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/widgets/app_selection_form_field.dart';

class Segment implements SelectableItem {
  const Segment({this.id, this.name = '', this.is_active = true});

  final int? id;
  final String name;

  final bool is_active;

  factory Segment.fromJson(Map<String, dynamic> map) {
    return Segment(
      id: map['id'] as int,
      name: map['name'] as String,
      is_active: map['is_active'] as bool,

    );
  }



  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'name': name,

      'is_active': is_active,

    });
  }

  @override
  String get title => name;
}
