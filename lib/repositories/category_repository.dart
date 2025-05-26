import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:totem_pro_admin/models/category.dart';

class CategoryRepository {
  CategoryRepository(this._dio);

  final Dio _dio;

  Future<Either<void, List<Category>>> getCategories(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/categories');
      return Right(
        response.data.map<Category>((c) => Category.fromJson(c)).toList(),
      );
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, Category>> getCategory(int storeId, int id) async {
    try {
      final response = await _dio.get('/stores/$storeId/categories/$id');
      return Right(Category.fromJson(response.data));
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, Category>> saveCategory(
    int storeId,
    Category category,
  ) async {
    try {
      if (category.id != null) {
        final response = await _dio.patch(
          '/stores/$storeId/categories/${category.id}',
          data: await category.toFormData(),
        );
        return Right(Category.fromJson(response.data));
      } else {
        final response = await _dio.post(
          '/stores/$storeId/categories',
          data: await category.toFormData(),
        );
        return Right(Category.fromJson(response.data));
      }
    } catch (e) {
      debugPrint('$e');
      return Left(null);
    }
  }
}
