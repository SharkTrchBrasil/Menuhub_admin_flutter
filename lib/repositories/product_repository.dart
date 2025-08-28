import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';

import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/variant.dart';

import '../models/catalog_product.dart';
import '../models/category.dart';
import '../models/minimal_product.dart';
import '../models/product_availability.dart';
import '../models/product_variant_link.dart';
import '../models/variant_option.dart';

class ProductRepository {
  ProductRepository(this._dio);

  final Dio _dio;




  Future<Either<void, ProductAvailability>> saveProductAvailability(
      int storeId,
      int productId,
      ProductAvailability availability,
      ) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/products/$productId/availabilities',
        data: availability.toJson(),
      );

      return Right(ProductAvailability.fromJson(response.data));
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }




  Future<Either<void, Variant>> getVariant(
    int storeId,

    int id,
  ) async {
    try {
      final response = await _dio.get(
        '/stores/$storeId/variants/$id',
      );
      return Right(Variant.fromJson(response.data));
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, Variant>> saveVariant(
    int storeId,

    Variant variant,
  ) async {
    try {
      if (variant.id != null) {
        final response = await _dio.patch(
          '/stores/$storeId/variants/${variant.id}',
          data: variant.toJson(),
        );

        return Right(Variant.fromJson(response.data));
      } else {
        final response = await _dio.post(
          '/stores/$storeId/variants',
          data: variant.toJson(),
        );

        return Right(Variant.fromJson(response.data));
      }
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, VariantOption>> getVariantOption(
    int storeId,

    int variantId,
    int id,
  ) async {
    try {
      final response = await _dio.get(
        '/stores/$storeId/variants/$variantId/options/$id',
      );
      return Right(VariantOption.fromJson(response.data));
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }



  Future<Either<void, List<Variant>>> getVariantsByStore(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/variants');
      final variants = (response.data as List)
          .map((v) => Variant.fromJson(v))
          .toList();
      return Right(variants); // retorno de sucesso
    } catch (e) {
      return const Left(null); // retorno de erro
    }
  }


  Future<Either<void, void>> deleteProduct( int storeId, int id) async {
    try {
      await _dio.delete('/stores/$storeId/products/$id');
      return const Right(null);
    } catch (e) {
      debugPrint('Error deleteNeighborhood: $e');
      return const Left(null);
    }
  }



  Future<Either<void, VariantOption>> saveVariantOption(
    int storeId,

    int variantId,
    VariantOption option,
  ) async {
    try {

      // ✅ Crie uma nova instância da opção com o variantId correto
      final dataToSend = option.copyWith(variantId: variantId);




      if (option.id != null) {
        final response = await _dio.patch(
          '/stores/$storeId/variants/$variantId/options/${option.id}',
          data: dataToSend.toJson(), // Usa o objeto com o ID
        );

        return Right(VariantOption.fromJson(response.data));
      } else {
        final response = await _dio.post(
          '/stores/$storeId/variants/$variantId/options',
          data: dataToSend.toJson(), // Usa o objeto com o ID
        );

        return Right(VariantOption.fromJson(response.data));
      }
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, void>> deleteVariant(int storeId, int variantId) async {
    try {
      await _dio.delete('/stores/$storeId/variants/$variantId');
      return const Right(null);
    } catch (e) {
      debugPrint('Error deleteVariant: $e');
      return const Left(null);
    }
  }
  Future<Either<void, void>> deleteVariantOption(
      int storeId,
      int variantId,
      int optionId,
      ) async {
    try {
      await _dio.delete('/stores/$storeId/variants/$variantId/options/$optionId');
      return const Right(null);
    } catch (e) {
      debugPrint('Error deleteVariantOption: $e');
      return const Left(null);
    }
  }
  Future<List<int>> getSelectedVariants(int storeId, int productId) async {
    final response = await _dio.get('/stores/$storeId/products/$productId/variants');
    return List<int>.from(response.data);
  }

  Future<void> saveVariantsForProduct(int storeId, int productId, List<int> variantIds) async {
    await _dio.post('/stores/$storeId/products/$productId/variants', data: {
      'variant_ids': variantIds,
    });
  }














  Future<Either<void, List<MinimalProduct>>> getMinimalProducts(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/products/minimal');
      return Right((response.data as List)
          .map((e) => MinimalProduct.fromJson(e))
          .toList());
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<List<int>> getProductsLinkedToVariant(int storeId, int variantId) async {
    try {
      final response = await _dio.get(
          '/stores/$storeId/products/variants/$variantId/products');
      return List<int>.from(response.data);
    } catch (e) {
      debugPrint('Erro em getProductsLinkedToVariant: $e');
      return [];
    }
  }


  Future<Either<String, ProductVariantLink>> linkVariantToProduct({
    required int storeId,
    required int productId,
    required int variantId,
    required ProductVariantLink linkData, // Contém as regras (min/max, etc.)
  }) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/products/$productId/variants/$variantId',
        // O body da requisição são as regras, convertidas para JSON
        data: linkData.toJson(),
      );
      return Right(ProductVariantLink.fromJson(response.data));
    } on DioException catch (e) {
      debugPrint('Erro ao ligar variante ao produto: $e');
      // Retorna a mensagem de erro da API, se houver
      return Left(e.response?.data['detail'] ?? 'Erro desconhecido');
    } catch (e) {
      debugPrint('Erro inesperado: $e');
      return Left(e.toString());
    }
  }

  // (Assumindo que você tenha um ProductRepository)
  Future<void> updateProductsAvailability({
    required int storeId,
    required List<int> productIds,
    required bool isAvailable,
  }) async {
    await _dio.post( // ou seu método http
      '/stores/$storeId/products/bulk-update-status',
      data: {
        'product_ids': productIds,
        'available': isAvailable,
      },
    );
  }


  Future<void> deleteProducts({
    required int storeId,
    required List<int> productIds,
  }) async {
    await _dio.post(
      '/stores/$storeId/products/bulk-delete',
      data: {'product_ids': productIds},
    );
  }



  // ✅ ADICIONE ESTE NOVO MÉTODO COMPLETO
  Future<Either<String, List<CatalogProduct>>> searchMasterProducts(
      String query, {
        int? categoryId,
      }) async {
    try {
      // Endpoint que criamos no FastAPI
      const String path = '/master-products/search';

      final params = <String, dynamic>{
        'q': query,
      };
      if (categoryId != null) {
        params['category_id'] = categoryId;
      }

      final response = await _dio.get(path, queryParameters: params);

      final products = (response.data as List)
          .map((json) => CatalogProduct.fromJson(json))
          .toList();

      return Right(products);

    } on DioException catch (e) {
      debugPrint('Erro Dio ao buscar no catálogo: $e');
      final errorMessage = e.response?.data['detail'] ?? 'Falha na comunicação com o servidor.';
      return Left(errorMessage);
    } catch (e) {
      debugPrint('Erro inesperado ao buscar no catálogo: $e');
      return const Left('Ocorreu um erro inesperado.');
    }
  }



  // ✅ NOVO: Método dedicado para o wizard de criação
  Future<Either<String, Product>> createProductFromWizard(int storeId, Product product) async {
    try {
      // O frontend monta o objeto Product completo, e o toJson() dele
      // deve corresponder ao schema Pydantic `ProductWizardCreate`
      final response = await _dio.post(
        '/stores/$storeId/products/wizard',
        data: product.toWizardJson(), // Precisaremos criar este método no modelo
      );
      return Right(Product.fromJson(response.data));
    } on DioException catch (e) {
      final error = e.response?.data['detail'] ?? 'Erro ao criar produto.';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ✅ ATUALIZADO: Agora usado apenas para PATCH (atualizar)
  Future<Either<String, Product>> saveProduct(int storeId, Product product) async {
    if (product.id == null) {
      // A criação agora deve usar o método do wizard
      return const Left("Use 'createProductFromWizard' para criar novos produtos.");
    }
    try {
      final response = await _dio.patch(
        '/stores/$storeId/products/${product.id}',
        data: await product.toFormData(), // toFormData não deve mais incluir category_id
      );
      return Right(Product.fromJson(response.data));
    } on DioException catch (e) {
      final error = e.response?.data['detail'] ?? 'Erro ao atualizar produto.';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ✅ NOVO: Método para gerenciar as categorias de um produto
  Future<Either<String, void>> updateProductCategories(int storeId, int productId, List<int> categoryIds) async {
    try {
      await _dio.put(
        '/stores/$storeId/products/$productId/categories',
        data: {'category_ids': categoryIds},
      );
      return const Right(null);
    } on DioException catch (e) {
      final error = e.response?.data['detail'] ?? 'Erro ao atualizar categorias.';
      return Left(error);
    }
  }

  // ✅ ATUALIZADO: Carrega os dados através de `category_links`
  Future<Either<String, List<Product>>> getProducts(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/products');
      final products = (response.data as List).map<Product>((c) => Product.fromJson(c)).toList();
      return Right(products);
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? 'Falha ao buscar produtos.');
    }
  }

  // ✅ ATUALIZADO: Carrega os dados através de `category_links`
  Future<Either<String, Product>> getProduct(int storeId, int id) async {
    try {
      final response = await _dio.get('/stores/$storeId/products/$id');
      return Right(Product.fromJson(response.data));
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? 'Produto não encontrado.');
    }
  }

  // ✅ CORRIGIDO: Usa a nova lógica de apagar e recriar os vínculos
  Future<Either<String, void>> bulkUpdateProductCategory({
    required int storeId,
    required List<int> productIds,
    required int targetCategoryId,
  }) async {
    try {
      await _dio.post(
        '/stores/$storeId/products/bulk-update-category',
        data: {
          'product_ids': productIds,
          'target_category_id': targetCategoryId,
        },
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? 'Erro ao mover produtos.');
    }
  }








}
