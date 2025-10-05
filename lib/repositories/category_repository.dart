import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:image_picker/image_picker.dart';
import 'package:totem_pro_admin/models/category.dart';

import '../models/option_group.dart';
import '../models/option_item.dart';

class CategoryRepository {
  CategoryRepository(this._dio);

  final Dio _dio;

  // Este método é para CRIAR (POST)
  Future<Either<String, Category>> createCategory(int storeId,
      Category category,) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/categories',
        data: category.toJson(), // Garanta que seu toJson envie os novos campos
      );
      return Right(Category.fromJson(response.data));
    } catch (e) {
      return Left("Falha ao criar categoria.");
    }
  }

  // Este método é para ATUALIZAR (PATCH)
  Future<Either<String, Category>> updateCategory(int storeId,
      Category category,) async {
    try {
      final response = await _dio.patch(
        '/stores/$storeId/categories/${category.id}',
        data: category.toJson(),
      );
      return Right(Category.fromJson(response.data));
    } catch (e) {
      return Left("Falha ao atualizar categoria.");
    }
  }


  Future<Either<String, List<Category>>> getCategories(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/categories');
      return Right(
        (response.data as List)
            .map<Category>((c) => Category.fromJson(c))
            .toList(),
      );
    } catch (e) {
      debugPrint('$e');
      return Left("Falha ao buscar categorias.");
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

  Future<Either<void, void>> deleteCategory(int storeId, int id) async {
    try {
      await _dio.delete('/stores/$storeId/categories/$id');
      return const Right(null);
    } catch (e) {
      debugPrint('Error deleteNeighborhood: $e');
      return const Left(null);
    }
  }

  // --- ✨ NOVOS MÉTODOS PARA GRUPOS E ITENS ---

  Future<Either<String, OptionGroup>> createOptionGroup({
    required int categoryId,
    required OptionGroup group,
  }) async {
    try {
      final response = await _dio.post(
        '/categories/$categoryId/option-groups',
        data: group.toJson(),
      );
      return Right(OptionGroup.fromJson(response.data));
    } catch (e) {
      debugPrint('$e');
      return Left("Falha ao criar grupo de opções.");
    }
  }

  Future<Either<String, OptionItem>> createOptionItem({
    required int groupId,
    required OptionItem item,
  }) async {
    try {
      final response = await _dio.post(
        '/option-groups/$groupId/items',
        data: item.toJson(),
      );
      return Right(OptionItem.fromJson(response.data));
    } catch (e) {
      debugPrint('$e');
      return Left("Falha ao criar item de opção.");
    }
  }

  // ✅ VERSÃO FINAL E CORRETA DO MÉTODO DE UPLOAD
  Future<Either<String, void>> uploadOptionItemImage({
    required int itemId,
    required XFile imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image_file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
        ),
      });

      // ✅ URL CORRIGIDA: Aponta para o endpoint aninhado, sem /stores/
      await _dio.post(
        '/option-items/$itemId/image',
        data: formData,
      );
      return const Right(null);
    } catch (e) {
      return Left("Falha ao enviar imagem do item.");
    }
  }
}