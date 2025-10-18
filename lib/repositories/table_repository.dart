// lib/repositories/table_repository.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';

import 'package:totem_pro_admin/models/tables/saloon.dart';
import 'package:totem_pro_admin/models/tables/table.dart';

class TableRepository {
  final Dio _dio;

  TableRepository(this._dio);

  // ========== SALÕES ==========

  /// Cria um novo salão
  Future<Either<String, Saloon>> createSaloon({
    required int storeId,
    required String name,
    int displayOrder = 0,
  }) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/tables/saloons',
        data: {
          'name': name,
          'display_order': displayOrder,
        },
      );

      return Right(Saloon.fromJson(response.data));
    } on DioException catch (e) {
      debugPrint('Erro ao criar salão: $e');
      final error = e.response?.data['detail'] ?? 'Erro ao criar salão';
      return Left(error);
    } catch (e) {
      debugPrint('Erro inesperado: $e');
      return Left(e.toString());
    }
  }

  /// Atualiza um salão existente
  Future<Either<String, Saloon>> updateSaloon({
    required int storeId,
    required int saloonId,
    String? name,
    int? displayOrder,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (displayOrder != null) body['display_order'] = displayOrder;
      if (isActive != null) body['is_active'] = isActive;

      final response = await _dio.patch(
        '/stores/$storeId/tables/saloons/$saloonId',
        data: body,
      );

      return Right(Saloon.fromJson(response.data));
    } on DioException catch (e) {
      debugPrint('Erro ao atualizar salão: $e');
      final error = e.response?.data['detail'] ?? 'Erro ao atualizar salão';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Deleta um salão
  Future<Either<String, void>> deleteSaloon({
    required int storeId,
    required int saloonId,
  }) async {
    try {
      await _dio.delete('/stores/$storeId/tables/saloons/$saloonId');
      return const Right(null);
    } on DioException catch (e) {
      debugPrint('Erro ao deletar salão: $e');
      final error = e.response?.data['detail'] ?? 'Erro ao deletar salão';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ========== MESAS ==========

  /// Cria uma nova mesa
  Future<Either<String, TableModel>> createTable({
    required int storeId,
    required int saloonId,
    required String name,
    int maxCapacity = 4,
    String? locationDescription,
  }) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/tables',
        data: {
          'saloon_id': saloonId,
          'name': name,
          'max_capacity': maxCapacity,
          'location_description': locationDescription,
        },
      );

      return Right(TableModel.fromJson(response.data));
    } on DioException catch (e) {
      debugPrint('Erro ao criar mesa: $e');
      final error = e.response?.data['detail'] ?? 'Erro ao criar mesa';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Atualiza uma mesa existente
  Future<Either<String, TableModel>> updateTable({
    required int storeId,
    required int tableId,
    String? name,
    int? maxCapacity,
    String? locationDescription,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (maxCapacity != null) body['max_capacity'] = maxCapacity;
      if (locationDescription != null) body['location_description'] = locationDescription;
      if (status != null) body['status'] = status;

      final response = await _dio.patch(
        '/stores/$storeId/tables/$tableId',
        data: body,
      );

      return Right(TableModel.fromJson(response.data));
    } on DioException catch (e) {
      debugPrint('Erro ao atualizar mesa: $e');
      final error = e.response?.data['detail'] ?? 'Erro ao atualizar mesa';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Deleta uma mesa
  Future<Either<String, void>> deleteTable({
    required int storeId,
    required int tableId,
  }) async {
    try {
      await _dio.delete('/stores/$storeId/tables/$tableId');
      return const Right(null);
    } on DioException catch (e) {
      debugPrint('Erro ao deletar mesa: $e');
      final error = e.response?.data['detail'] ?? 'Erro ao deletar mesa';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ========== ABERTURA/FECHAMENTO DE MESAS ==========

  // lib/repositories/table_repository.dart

  /// Abre uma mesa (cria uma comanda)
  Future<Either<String, Map<String, dynamic>>> openTable({
    required int storeId,
    int? tableId, // ✅ MUDOU PARA NULLABLE
    String? customerName,
    String? customerContact,
    int? attendantId,
    String? notes,
  }) async {
    try {
      // ✅ Constrói o body dinamicamente (não envia table_id se for null)
      final Map<String, dynamic> requestBody = {};

      if (tableId != null) {
        requestBody['table_id'] = tableId;
      }

      if (customerName != null) {
        requestBody['customer_name'] = customerName;
      }

      if (customerContact != null) {
        requestBody['customer_contact'] = customerContact;
      }

      if (attendantId != null) {
        requestBody['attendant_id'] = attendantId;
      }

      if (notes != null) {
        requestBody['notes'] = notes;
      }

      final response = await _dio.post(
        '/stores/$storeId/tables/open',
        data: requestBody,
      );

      return Right(response.data);
    } on DioException catch (e) {
      debugPrint('Erro ao abrir mesa: $e');

      // ✅ FIX NO ERROR HANDLER
      String errorMessage = 'Erro ao abrir mesa';

      if (e.response?.data != null) {
        final responseData = e.response!.data;

        // Verifica se é um erro de validação do FastAPI
        if (responseData is Map && responseData['detail'] != null) {
          final detail = responseData['detail'];

          // ✅ TRATAMENTO CORRETO PARA LISTA DE ERROS
          if (detail is List && detail.isNotEmpty) {
            final firstError = detail[0];
            if (firstError is Map) {
              final field = firstError['loc']?.last ?? 'campo desconhecido';
              final msg = firstError['msg'] ?? 'inválido';
              errorMessage = 'Erro de validação: $field - $msg';
            } else {
              errorMessage = detail.toString();
            }
          } else if (detail is String) {
            errorMessage = detail;
          }
        }
      }

      return Left(errorMessage);
    } catch (e) {
      debugPrint('Erro inesperado: $e');
      return Left(e.toString());
    }
  }

  /// Fecha uma mesa
  Future<Either<String, Map<String, dynamic>>> closeTable({
    required int storeId,
    required int tableId,
    required int commandId,
  }) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/tables/close',
        data: {
          'table_id': tableId,
          'command_id': commandId,
        },
      );

      return Right(response.data);
    } on DioException catch (e) {
      debugPrint('Erro ao fechar mesa: $e');
      final error = e.response?.data['detail'] ?? 'Erro ao fechar mesa';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ========== ADICIONAR/REMOVER ITENS ==========

  /// Adiciona um item à mesa
  Future<Either<String, Map<String, dynamic>>> addItemToTable({
    required int storeId,
    required int tableId,
    required int commandId,
    required int productId,
    required int categoryId,
    int quantity = 1,
    String? note,
    List<Map<String, dynamic>>? variants,
  }) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/tables/add-item',
        data: {
          'table_id': tableId,
          'command_id': commandId,
          'product_id': productId,
          'category_id': categoryId,
          'quantity': quantity,
          'note': note,
          'variants': variants ?? [],
        },
      );

      return Right(response.data);
    } on DioException catch (e) {
      debugPrint('Erro ao adicionar item: $e');
      final error = e.response?.data['detail'] ?? 'Erro ao adicionar item';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Remove um item da mesa
  Future<Either<String, Map<String, dynamic>>> removeItemFromTable({
    required int storeId,
    required int orderProductId,
    required int commandId,
  }) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/tables/remove-item',
        data: {
          'order_product_id': orderProductId,
          'command_id': commandId,
        },
      );

      return Right(response.data);
    } on DioException catch (e) {
      debugPrint('Erro ao remover item: $e');
      final error = e.response?.data['detail'] ?? 'Erro ao remover item';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }
}