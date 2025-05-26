import 'package:flutter/cupertino.dart';
import 'image_model.dart';
import 'package:dio/dio.dart';

class Store {
  Store({
    this.id,
    this.name = '',
    this.phone = '',
    this.image,
    this.zip_code,
    this.street,
    this.number,
    this.neighborhood,
    this.complement,
    this.reference,
    this.city,
    this.state,
    this.instagram,
    this.facebook,
    this.tiktok,
    this.description,
  });

  final int? id;
  final String name;
  final String phone;

  // Endereço
  final String? zip_code;
  final String? street;
  final String? number;
  final String? neighborhood;
  final String? complement;
  final String? reference;
  final String? city;
  final String? state;
  final String? description;

  // Redes sociais
  final String? instagram;
  final String? facebook;
  final String? tiktok;
  final ImageModel? image;

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] as int?,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      zip_code: json['zip_code'],
      street: json['street'],
      number: json['number'],
      neighborhood: json['neighborhood'],
      complement: json['complement'],
      reference: json['reference'],
      city: json['city'],
      state: json['state'],
      instagram: json['instagram'],
      facebook: json['facebook'],
      tiktok: json['tiktok'],
      description: json['description'],
      image: ImageModel(url: json['image_path']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'zip_code': zip_code,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'complement': complement,
      'reference': reference,
      'city': city,
      'state': state,
      'instagram': instagram,
      'facebook': facebook,
      'tiktok': tiktok,
      'description': description
    };
  }

  Future<FormData> toFormData() async {
    return FormData.fromMap({
      'name': name,
      'phone': phone,
      'zip_code': zip_code,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'complement': complement,
      'reference': reference,
      'city': city,
      'state': state,
      'instagram': instagram,
      'facebook': facebook,
      'tiktok': tiktok,
      'description': description,

      if (image?.file != null)
        'image': MultipartFile.fromBytes(
          await image!.file!.readAsBytes(),
          filename: image!.file!.name,
        ),
    });
  }

  Store copyWith({
    int? id,
    String? name,
    String? phone,
    String? zip_code,
    String? street,
    String? number,
    String? neighborhood,
    String? complement,
    String? reference,
    String? city,
    String? state,
    String? instagram,
    String? facebook,
    String? tiktok,
    ImageModel? image,
    String? description,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      zip_code: zip_code ?? this.zip_code,
      street: street ?? this.street,
      number: number ?? this.number,
      neighborhood: neighborhood ?? this.neighborhood,
      complement: complement ?? this.complement,
      reference: reference ?? this.reference,
      city: city ?? this.city,
      state: state ?? this.state,
      instagram: instagram ?? this.instagram,
      facebook: facebook ?? this.facebook,
      tiktok: tiktok ?? this.tiktok,
      description: description ?? this.description,
      image: image ?? this.image,
    );
  }
}
