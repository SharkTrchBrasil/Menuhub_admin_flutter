
import 'package:dio/dio.dart';



import 'image_model.dart';

class StoreMedia {
  final String? fileKey;
  final String? bannerFileKey;
  final ImageModel? image;
  final ImageModel? banner;

  StoreMedia({
    this.fileKey,
    this.bannerFileKey,
    this.image,
    this.banner,
  });

  factory StoreMedia.fromJson(Map<String, dynamic> json) {
    return StoreMedia(
      fileKey: json['file_key'],
      bannerFileKey: json['banner_file_key'],
      image: json['image_path'] != null ? ImageModel(url: json['image_path']) : null,
      banner: json['banner_path'] != null ? ImageModel(url: json['banner_path']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_key': fileKey,
      'banner_file_key': bannerFileKey,
      'image_path': image?.url,
      'banner_path': banner?.url,
    };
  }

  Future<Map<String, dynamic>> toFormDataPart() async {
    return {
      if (image?.file != null)
        'image': await MultipartFile.fromFile(
          image!.file!.path,
          filename: image!.file!.name,
        ),
      if (banner?.file != null)
        'banner': await MultipartFile.fromFile(
          banner!.file!.path,
          filename: banner!.file!.name,
        ),
    };
  }


  StoreMedia copyWith({
    String? fileKey,
    String? bannerFileKey,
    ImageModel? image,
    ImageModel? banner,
  }) {
    return StoreMedia(
      fileKey: fileKey ?? this.fileKey,
      bannerFileKey: bannerFileKey ?? this.bannerFileKey,
      image: image ?? this.image,
      banner: banner ?? this.banner,
    );
  }
}