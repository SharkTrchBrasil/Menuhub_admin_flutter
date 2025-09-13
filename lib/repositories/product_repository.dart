import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';

import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/variant.dart';

import '../models/catalog_product.dart';
import '../models/category.dart';
import '../models/image_model.dart';
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



  Future<Either<String, ProductVariantLink>> updateVariantLinkRules({
    required int storeId,
    required int productId,
    required int variantId,
    required ProductVariantLink linkData, // Contém as novas regras
  }) async {
    try {
      final response = await _dio.patch(
        '/stores/$storeId/products/$productId/variants/$variantId',
        data: linkData.toJson(), // O toJson do link já envia os campos certos
      );
      return Right(ProductVariantLink.fromJson(response.data));
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? 'Erro ao atualizar regras do grupo.');
    } catch (e) {
      return Left(e.toString());
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





  // ✅ NOVA ROTA PARA ARQUIVAR (SOFT DELETE)
  Future<Either<void, void>>  archiveProduct(int storeId, int productId) async {
    try {
      // A rota do backend que criamos para arquivar
      await _dio.patch('/admin/stores/$storeId/products/$productId/archive');
      return const Right(null);

    } on DioException catch (e) {
      debugPrint('Error archiveproduct: $e');
      return const Left(null);
    }
  }




  Future<Either<void, VariantOption>> saveVariantOption(
      int storeId,
      int variantId,
      VariantOption option,
      ) async {
    try {
      // ✅ 1. Converte o objeto da opção para um JSON
      final optionJson = option.copyWith(variantId: variantId).toJson();

      // ✅ 2. Cria o FormData e codifica o payload como texto
      final formData = FormData.fromMap({
        'payload': json.encode(optionJson),
      });

      // ✅ 3. Adiciona o arquivo da imagem, se existir
      if (option.image?.file != null) {
        final fileBytes = await option.image!.file!.readAsBytes();
        formData.files.add(
          MapEntry(
            'image', // Nome do campo esperado pelo backend
            MultipartFile.fromBytes(fileBytes, filename: option.image!.file!.name),
          ),
        );
      }

      // ✅ 4. Determina a URL e o método (POST para novo, PATCH para existente)
      Response response;
      if (option.id != null) {
        // Atualização (PATCH)
        response = await _dio.patch(
          '/stores/$storeId/variants/$variantId/options/${option.id}',
          data: formData, // Envia o FormData
        );
      } else {
        // Criação (POST)
        response = await _dio.post(
          '/stores/$storeId/variants/$variantId/options',
          data: formData, // Envia o FormData
        );
      }

      return Right(VariantOption.fromJson(response.data));
    } catch (e) {
      debugPrint('Erro em saveVariantOption: $e');
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




  // ===================================================================
  // MÉTODOS DE CRIAÇÃO (ATUALIZADOS)
  // ===================================================================

  /// Cria um produto simples (ex: bebida, lanche).
  /// Usa a rota `/simple-product`.
  Future<Either<String, Product>> createSimpleProduct(
      int storeId,
      Product product, {
        ImageModel? image,
      }) async {
    try {
      // Garanta que seu modelo Product tenha um método para gerar este JSON específico
      final productJson = product.toSimpleProductJson();

      final formData = FormData.fromMap({
        'payload': json.encode(productJson),
      });

      if (image?.file != null) {
        final fileBytes = await image!.file!.readAsBytes();
        formData.files.add(
          MapEntry('image', MultipartFile.fromBytes(fileBytes, filename: image.file!.name)),
        );
      }

      final response = await _dio.post(
        '/stores/$storeId/products/simple-product', // ✅ ROTA CORRETA
        data: formData,
      );

      return Right(Product.fromJson(response.data));
    } on DioException catch (e) {
      final error = e.response?.data['detail'] ?? 'Erro ao criar produto.';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }


  /// Cria um "sabor" (produto para categoria customizável).
  /// Usa a rota `/flavor-product`.
  Future<Either<String, Product>> createFlavorProduct(
      int storeId,
      Product product, {
        required Category parentCategory, // ✅ PARÂMETRO ADICIONADO AQUI
        ImageModel? image,
      }) async {
    try {
      // ✅ AGORA PASSAMOS A CATEGORIA PARA O MÉTODO toJson
      final productJson = product.toFlavorProductJson(parentCategoryId: parentCategory.id!);
      final formData = FormData.fromMap({'payload': json.encode(productJson)});

      if (image?.file != null) {
        final fileBytes = await image!.file!.readAsBytes();
        formData.files.add(MapEntry('image', MultipartFile.fromBytes(fileBytes, filename: image.file!.name)));
      }

      final response = await _dio.post('/stores/$storeId/products/flavor-product', data: formData);
      return Right(Product.fromJson(response.data));
    } on DioException catch (e) {
      final error = e.response?.data['detail'] ?? 'Erro ao criar sabor.';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ===================================================================
  // MÉTODO DE ATUALIZAÇÃO (UNIFICADO E CORRETO)
  // ===================================================================

  Future<Either<String, Product>> updateProduct(
      int storeId,
      Product product,
      ) async {
    if (product.id == null) {
      return const Left("ID do produto é inválido para atualização.");
    }
    try {
      final productJson = product.toUpdateJson();
      final formData = FormData.fromMap({
        'payload': json.encode(productJson),
      });

      if (product.image?.file != null) {
        final fileBytes = await product.image!.file!.readAsBytes();
        formData.files.add(
          MapEntry(
            'image',
            MultipartFile.fromBytes(fileBytes, filename: product.image!.file!.name),
          ),
        );
      }

      final response = await _dio.patch(
        '/stores/$storeId/products/${product.id}',
        data: formData,
      );

      return Right(Product.fromJson(response.data));
    } on DioException catch (e) {
      final error = e.response?.data['detail'] ?? 'Erro ao atualizar o produto.';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ✅ NOVO MÉTODO PARA ATUALIZAR O PREÇO DE UM SABOR
  Future<Either<String, void>> updateFlavorPrice({
    required int storeId,
    required int flavorPriceId, // O ID do registro na tabela flavor_prices
    required int newPrice,
  }) async {
    try {
      await _dio.patch(
        '/stores/$storeId/products/prices/$flavorPriceId',
        data: {'price': newPrice},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? 'Erro ao atualizar o preço do sabor.');
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



  Future<Either<String, void>> removeProductFromCategory({
    required int storeId,
    required int productId,
    required int categoryId,
  }) async {
    try {
      await _dio.delete(
        '/stores/$storeId/products/$productId/categories/$categoryId',
      );
      return const Right(null); // Sucesso
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? 'Erro ao remover produto da categoria.');
    }
  }



  Future<Either<String, void>> bulkUpdateProductCategory({
    required int storeId,
    required int targetCategoryId,
    required List<Map<String, dynamic>> products, // ✅ Precisa enviar a lista de produtos
  }) async {
    try {
      await _dio.post(
        '/stores/$storeId/products/bulk-update-category', // A rota de "mover"
        data: {
          'target_category_id': targetCategoryId,
          'products': products, // ✅ Enviando o payload completo
        },
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? 'Erro ao mover produtos.');
    }
  }




  Future<Either<String, void>> updateProductCategoryPrice({
    required int storeId,
    required int productId,
    required int categoryId,
    required int newPrice,
  }) async {
    try {
      // Chama a nova rota que criamos no backend
      await _dio.patch(
        '/stores/$storeId/products/$productId/categories/$categoryId',
        data: {
          'price': newPrice,
        },
      );
      // ✅ O 'return' deve vir DEPOIS da chamada da API
      return const Right(null);
    } on DioException catch (e) {
      // ✅ Mensagem de erro mais específica
      return Left(e.response?.data['detail'] ?? 'Erro ao atualizar o preço.');
    }
  }






// ✅ NOVO MÉTODO PARA PAUSAR/ATIVAR UM VÍNCulo
  Future<Either<String, void>> toggleLinkAvailability({
    required int storeId,
    required int productId,
    required int categoryId,
    required bool isAvailable, // O NOVO status de disponibilidade
  }) async {
    try {
      // Chama a rota PATCH que criamos no backend para o vínculo específico
      await _dio.patch(
        '/stores/$storeId/products/$productId/categories/$categoryId',
        data: {
          'is_available': isAvailable, // Envia apenas o campo que queremos alterar
        },
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? 'Erro ao atualizar status do produto na categoria.');
    }
  }


}
