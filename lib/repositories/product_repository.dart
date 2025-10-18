import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart'; // Import necessário


import 'package:totem_pro_admin/models/variant.dart';

import '../models/catalog_product.dart';
import '../models/category.dart';
import '../models/image_model.dart';
import '../models/minimal_product.dart';

import '../models/products/product.dart';
import '../models/products/product_availability.dart';
import '../models/products/product_variant_link.dart';
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

  // DENTRO DO SEU ProductRepository

// ✅ CÓDIGO CORRIGIDO
  Future<Either<void, Variant>> saveVariant(
      int storeId,
      Variant variant,
      ) async {
    try {
      // ✅ CONDIÇÃO CORRIGIDA:
      // Só faz PATCH se o ID não for nulo E for maior que 0.
      if (variant.id != null && variant.id! > 0) {
        // --- ATUALIZA UMA VARIANTE EXISTENTE ---
        final response = await _dio.patch(
          '/stores/$storeId/variants/${variant.id}',
          data: variant.toJson(),
        );

        return Right(Variant.fromJson(response.data));
      } else {
        // --- CRIA UMA NOVA VARIANTE ---
        // IDs nulos, negativos ou zero caem aqui para criar um novo registro.
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






  Future<Either<void, void>>  archiveProduct(int storeId, int productId) async {
    try {
      // A rota do backend que criamos para arquivar
      await _dio.patch('/stores/$storeId/products/$productId/archive');
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


        final fileName = option.image?.file?.name != null
            ? option.image?.file?.name ?? ''
            : 'upload.jpg';

        formData.files.add(
          MapEntry(
            'images',
            MultipartFile.fromBytes(fileBytes, filename: fileName),
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




// ✅ ADICIONE ESTE NOVO MÉTODO PARA ARQUIVAR
  Future<void> archiveProducts({
    required int storeId,
    required List<int> productIds,
  }) async {
    // A chamada agora aponta para o endpoint de arquivamento
    await _dio.post(
      '/stores/$storeId/products/bulk-archive',
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

  Future<Either<String, Product>> createSimpleProduct(
      int storeId,
      Product product,
      ) async {
    try {
      final productJson = product.toSimpleProductJson();
      final formData = FormData.fromMap({
        'payload': json.encode(productJson),
      });

      // ✅ --- LÓGICA RESTAURADA PARA UPLOAD DE ARQUIVOS ---
      // Anexa as imagens da galeria
      for (var imageModel in product.images) {
        if (imageModel.file != null) {
          final fileBytes = await imageModel.file!.readAsBytes();
          final fileName = imageModel.file!.name;
          final fileExtension = fileName.split('.').last;

          formData.files.add(MapEntry(
            'files', // Nome do campo que a API espera para os arquivos da galeria
            MultipartFile.fromBytes(
              fileBytes,
              filename: fileName,
              contentType: MediaType('image', fileExtension),
            ),
          ));
        }
      }

      // Anexa o vídeo, se houver
      if (product.videoFile?.file != null) {
        final videoFile = product.videoFile!.file!;
        final videoBytes = await videoFile.readAsBytes();
        final videoFileName = videoFile.name;
        final videoFileExtension = videoFileName.split('.').last;

        formData.files.add(MapEntry(
          'video', // Nome do campo que a API espera para o vídeo
          MultipartFile.fromBytes(
            videoBytes,
            filename: videoFileName,
            contentType: MediaType('video', videoFileExtension),
          ),
        ));
      }
      // ✅ --- FIM DA LÓGICA RESTAURADA ---

      final response = await _dio.post(
        '/admin/stores/$storeId/products/simple-product',
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


  Future<Either<String, Product>> createFlavorProduct(
      int storeId,
      Product product, {
        required Category parentCategory,

        List<ImageModel>? images,
        ImageModel? videoFile,
      }) async {
    try {
      // A lógica do payload JSON continua a mesma
      final productJson = product.toFlavorProductJson(parentCategoryId: parentCategory.id!);
      final formData = FormData.fromMap({'payload': json.encode(productJson)});



      // ✅ 3. NOVA LÓGICA PARA A GALERIA DE IMAGENS
      if (images != null && images.isNotEmpty) {
        for (var imageModel in images) {
          if (imageModel.file != null) {
            final fileBytes = await imageModel.file!.readAsBytes();

            final fileName = imageModel.file!.name.isNotEmpty
                ? imageModel.file!.name
                : 'upload.jpg';

            formData.files.add(
              MapEntry(
                'images',
                MultipartFile.fromBytes(fileBytes, filename: fileName),
              ),
            );
          }
        }
      }

      // ✅ ADICIONE A LÓGICA PARA ANEXAR O VÍDEO
      if (videoFile?.file != null) {
        final videoBytes = await videoFile!.file!.readAsBytes();
        final videoFileName = videoFile.file!.name.isNotEmpty
            ? videoFile.file!.name
            : 'upload.mp4';

        formData.files.add(
          MapEntry(
            'video',
            MultipartFile.fromBytes(videoBytes, filename: videoFileName),
          ),
        );
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
      Product product, {
        // ✅ 1. ADICIONE O PARÂMETRO 'deletedImageIds' À ASSINATURA DA FUNÇÃO
        required List<int> deletedImageIds,
      }) async {
    if (product.id == null) {
      return const Left("ID do produto é inválido para atualização.");
    }
    try {
      // --- LÓGICA DE PRÉ-PROCESSAMENTO DOS GRUPOS DE COMPLEMENTOS ---
      // (Sua lógica de variantLinks continua a mesma aqui, sem alterações)
      final processedLinks = List<ProductVariantLink>.from(product.variantLinks ?? []);
      for (var i = 0; i < processedLinks.length; i++) {
        final link = processedLinks[i];
        if (link.variant.id != null && link.variant.id! < 0) {
          final result = await saveVariant(storeId, link.variant);
          if (result.isRight) {
            processedLinks[i] = link.copyWith(variant: result.right);
          } else {
            return const Left("Falha ao criar um novo grupo de complemento durante o salvamento.");
          }
        }
      }
      final productToSave = product.copyWith(variantLinks: processedLinks);

      // --- MONTAGEM DO FORMDATA ---

      // ✅ 2. PASSE A LISTA DE IDs DELETADOS PARA O MÉTODO toUpdateJson
      final productJson = productToSave.toUpdateJson(deletedImageIds: deletedImageIds);

      final formData = FormData.fromMap({
        'payload': json.encode(productJson),
      });

      // Identifica e anexa apenas as NOVAS imagens para upload
      final newImagesToUpload = productToSave.images.where((img) => img.file != null).toList();

      if (newImagesToUpload.isNotEmpty) {
        for (var imageModel in newImagesToUpload) {
          final fileBytes = await imageModel.file!.readAsBytes();

          final fileName = imageModel.file!.name.isNotEmpty
              ? imageModel.file!.name
              : 'upload.jpg';

          formData.files.add(
            MapEntry(
              'images',
              MultipartFile.fromBytes(fileBytes, filename: fileName),
            ),
          );
        }
      }

      // ✅ LÓGICA PARA ANEXAR O VÍDEO
      if (product.videoFile?.file != null) {
        final videoBytes = await product.videoFile!.file!.readAsBytes();
        final videoFileName = product.videoFile!.file!.name.isNotEmpty
            ? product.videoFile!.file!.name
            : 'upload.mp4';

        formData.files.add(
          MapEntry(
            'video', // O nome do campo que o backend espera
            MultipartFile.fromBytes(videoBytes, filename: videoFileName),
          ),
        );
      }


      // Envia a requisição
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











// Adicione este método em qualquer lugar dentro da classe ProductRepository

  Future<Either<String, ProductVariantLink>> createAndLinkVariantToProduct({
    required int storeId,
    required int productId,
    required ProductVariantLink linkData, // Contém os dados do novo grupo
  }) async {
    try {
      // 1. Primeiro, cria o Variant no banco de dados
      final variantResult = await saveVariant(storeId, linkData.variant);

      if (variantResult.isLeft) {
        return const Left('Falha ao criar o novo grupo.');
      }
      final savedVariant = variantResult.right;

      // 2. Agora, com o ID real da variant, faz o link com o produto
      final linkResult = await linkVariantToProduct(
        storeId: storeId,
        productId: productId,
        variantId: savedVariant.id!,
        linkData: linkData,
      );

      return linkResult; // Retorna o resultado da operação de link

    } catch (e) {
      return Left(e.toString());
    }
  }

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
    required List<Map<String, dynamic>> products,
  }) async {
    try {
      // ❌ REMOVA A LINHA QUE CRIAVA O `productIds`
      // final productIds = products.map((p) => p['product_id']).toList();

      await _dio.post(
        '/stores/$storeId/products/bulk-update-category',
        data: {
          'target_category_id': targetCategoryId,
          // ✅ VOLTE A ENVIAR A CHAVE 'products' COM A LISTA COMPLETA
          'products': products,
        },
      );
      return const Right(null);

    } on DioException catch (e) {
      // ... seu tratamento de erro robusto continua aqui ...
      String errorMessage = 'Erro ao mover produtos.';
      if (e.response?.data is Map) {
        final responseData = e.response!.data;
        if (responseData['detail'] is List && (responseData['detail'] as List).isNotEmpty) {
          final firstError = responseData['detail'][0];
          if (firstError is Map) {
            final field = firstError['loc']?.last ?? 'campo desconhecido';
            final msg = firstError['msg'] ?? 'inválido';
            errorMessage = 'Erro de validação: O campo "$field" está $msg.';
          }
        } else if (responseData['detail'] is String) {
          errorMessage = responseData['detail'];
        }
      }
      return Left(errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }



  Future<Either<String, void>> bulkAddOrUpdateLinks({
    required int storeId,
    required int targetCategoryId,
    required List<Map<String, dynamic>> products,
  }) async {
    try {
      // Chama a nova rota que criamos no backend
      await _dio.post(
        '/stores/$storeId/products/bulk-add-update-links',
        data: {
          'target_category_id': targetCategoryId,
          'products': products,
        },
      );
      return const Right(null); // Retorna sucesso

    } on DioException catch (e) {
      // Tratamento de erro robusto
      String errorMessage = 'Erro ao adicionar produtos à categoria.';
      if (e.response?.data is Map && e.response?.data['detail'] != null) {
        errorMessage = e.response!.data['detail'];
      }
      return Left(errorMessage);
    } catch (e) {
      return Left(e.toString());
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


  Future<Either<String, void>> toggleLinkAvailability({
    required int storeId,
    required int productId,
    required int categoryId,
    required bool isAvailable, // O NOVO status de disponibilidade
  }) async {
    try {
      // Chama a nova rota PATCH específica para disponibilidade
      await _dio.patch(
        '/stores/$storeId/products/$productId/categories/$categoryId/availability',
        data: {
          'is_available': isAvailable,
        },
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? 'Erro ao atualizar status do produto na categoria.');
    }
  }







// ===================================================================
// MÉTODOS DE AÇÃO EM MASSA - CORRIGIDOS
// ===================================================================

  /// Ativa ou pausa TODOS OS VÍNCULOS de uma lista de grupos.
// ✅ NOME ATUALIZADO para maior clareza (afeta os vínculos, não o grupo)
  Future<Either<String, void>> updateLinksAvailability({
    required int storeId,
    required List<int> variantIds,
    required bool isAvailable,
  }) async {
    try {
      // A rota e o payload continuam os mesmos, pois o backend espera os IDs dos grupos
      await _dio.post(
        '/stores/$storeId/variants/bulk-update-status',
        data: {
          'variant_ids': variantIds,
          'is_available': isAvailable,
        },
      );
      return const Right(null); // Sucesso
    } on DioException catch (e) {
      final error = e.response?.data['detail'] ?? 'Erro ao atualizar status dos vínculos.';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Desvincula (remove o link) de todos os produtos uma lista de grupos de complementos.
// ✅ NOME ATUALIZADO para refletir a ação de desvincular
  Future<Either<String, void>> unlinkVariants({
    required int storeId,
    required List<int> variantIds,
  }) async {
    try {
      // ✅ ROTA ATUALIZADA de 'bulk-delete' para 'bulk-unlink'
      await _dio.post(
        '/stores/$storeId/variants/bulk-unlink',
        data: {
          'variant_ids': variantIds,
        },
      );
      return const Right(null); // Sucesso
    } on DioException catch (e) {
      final error = e.response?.data['detail'] ?? 'Erro ao remover os vínculos dos grupos.';
      return Left(error);
    } catch (e) {
      return Left(e.toString());
    }
  }


  // ✅ NOVO MÉTODO PARA IMPORTAÇÃO POR IA
  Future<Either<String, String>> importMenuFromImages({
    required int storeId,
    required List<XFile> imageFiles,
    required Function(int, int) onSendProgress,
  }) async {
    try {
      final formData = FormData();

      // Adiciona cada arquivo de imagem ao FormData
      for (final file in imageFiles) {
        formData.files.add(MapEntry(
          'files', // A chave que o backend espera
          MultipartFile.fromBytes(
            await file.readAsBytes(),
            filename: file.name,
          ),
        ));
      }

      // Faz a chamada POST para o endpoint que criamos no backend
      final response = await _dio.post(
        '/stores/$storeId/import/menu-from-images',
        data: formData,
        onSendProgress: onSendProgress, // Passa a função de progresso para o Dio
      );

      // Retorna a mensagem de sucesso do backend (ex: "Recebemos seu cardápio...")
      return Right(response.data['message']);

    } on DioException catch (e) {
      final error = e.response?.data['detail'] ?? 'Erro ao enviar as imagens.';
      return Left(error);
    } catch (e) {
      return Left('Ocorreu um erro inesperado: ${e.toString()}');
    }
  }












}