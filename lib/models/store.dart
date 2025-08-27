import 'package:dio/dio.dart';

import 'store_core.dart';
import 'store_address.dart';
import 'store_operation.dart';
import 'store_marketing.dart';
import 'store_media.dart';
import 'store_relations.dart';

class Store {
  final StoreCore core;
  final StoreAddress? address;
  final StoreOperation? operation;
  final StoreMarketing? marketing;
  final StoreMedia? media;
  final StoreRelations relations;



  Store({
    required this.core,
    this.address,
    this.operation,
    this.marketing,
    this.media,
    required this.relations,

  });

  factory Store.fromJson(Map<String, dynamic> json) {



    return Store(
      core: StoreCore.fromJson(json),
      address: StoreAddress.fromJson(json),
      operation: StoreOperation.fromJson(json),
      marketing: StoreMarketing.fromJson(json),
      media: StoreMedia.fromJson(json),
      relations: StoreRelations.fromJson(json),




    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...core.toJson(),
      ...?address?.toJson(),
      ...?operation?.toJson(),
      ...?marketing?.toJson(),
      ...?media?.toJson(),
    };
  }

  Future<FormData> toFormData() async {
    final mediaData = await media?.toFormDataPart() ?? {};

    return FormData.fromMap({
      ...core.toJson(),
      ...?address?.toJson(),
      ...?operation?.toJson(),
      ...?marketing?.toJson(),
      ...mediaData,
    });
  }

  Store copyWith({
    StoreCore? core,
    StoreAddress? address,
    StoreOperation? operation,
    StoreMarketing? marketing,
    StoreMedia? media,
    StoreRelations? relations,


  }) {
    return Store(
      core: core ?? this.core,
      address: address ?? this.address,
      operation: operation ?? this.operation,
      marketing: marketing ?? this.marketing,
      media: media ?? this.media,
      relations: relations ?? this.relations,

    );
  }
}