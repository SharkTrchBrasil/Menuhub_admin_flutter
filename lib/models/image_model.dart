import 'package:image_picker/image_picker.dart';
import 'package:equatable/equatable.dart';

class ImageModel extends Equatable {
  final int? id;
  final String? url;
  final XFile? file;
  final bool isVideo;

  const ImageModel({
    this.id,
    this.url,
    this.file,
    this.isVideo = false,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      url: json['image_url'],
    );
  }

  @override
  List<Object?> get props => [id, url, file, isVideo]; // ✅ CORREÇÃO: isVideo adicionado aqui
}