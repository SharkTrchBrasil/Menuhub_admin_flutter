import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';

import '../models/banners.dart';


class BannerRepository {
  BannerRepository(this._dio);

  final Dio _dio;

  Future<Either<void, List<BannerModel>>> getBanners(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/banners');
      return Right(
        (response.data as List)
            .map<BannerModel>((json) => BannerModel.fromJson(json))
            .toList(),
      );
    } catch (e) {
      debugPrint('getBanners error: $e');
      return const Left(null);
    }
  }

  Future<Either<void, BannerModel>> getBanner(int storeId, int id) async {
    try {
      final response = await _dio.get('/stores/$storeId/banners/$id');
      return Right(BannerModel.fromJson(response.data));
    } catch (e) {
      debugPrint('getBanner error: $e');
      return const Left(null);
    }
  }

  Future<Either<void, BannerModel>> saveBanner(int storeId, BannerModel banner) async {
    try {
      if (banner.id != null) {
        final response = await _dio.patch(
          '/stores/$storeId/banners/${banner.id}',
          data: await banner.toFormData(),
        );
        return Right(BannerModel.fromJson(response.data));
      } else {
        final response = await _dio.post(
          '/stores/$storeId/banners',
          data: await banner.toFormData(),
        );
        return Right(BannerModel.fromJson(response.data));
      }
    } catch (e) {
      debugPrint('saveBanner error: $e');
      return const Left(null);
    }
  }

  Future<Either<void, void>> deleteBanner(int storeId, int id) async {
    try {
      await _dio.delete('/stores/$storeId/banners/$id');
      return const Right(null);
    } catch (e) {
      debugPrint('deleteBanner error: $e');
      return const Left(null);
    }
  }
}
