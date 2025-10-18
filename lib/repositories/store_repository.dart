import 'dart:convert';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/models/store/store_with_role.dart';

import '../core/enums/store_access.dart';
import '../core/failures.dart';
import '../core/payment_token.dart';
import '../models/address.dart';
import '../models/cash_session.dart';
import '../models/cash_transaction.dart';
import '../models/store/store_access.dart';
import '../models/store/store_city.dart';
import '../models/store/store_customer.dart';
import '../models/store/store_hour.dart';
import '../models/store/store_neig.dart';
import '../models/store/store_payable.dart';
import '../models/store/store_pix_config.dart';
import '../models/store/store_theme.dart';
import '../models/subscription/create_subscription_payload.dart';
import '../models/holiday.dart';
import '../models/plans/plans.dart';
import '../models/scheduled_pause.dart';
import '../models/subscription/details/subscription_details.dart';
import '../pages/create_store/cubit/store_setup-state.dart';
import '../services/pagarme_service.dart';

class StoreRepository {
  StoreRepository(this._dio);

  final Dio _dio;
  final _pagarmeService = PagarmeService();

  List<StoreWithRole>? _stores;
  List<StoreWithRole> get stores => _stores!;

  // ═══════════════════════════════════════════════════════════
  // STORES - MÉTODOS BÁSICOS
  // ═══════════════════════════════════════════════════════════

  Future<Either<Failure, List<StoreWithRole>>> getStores() async {
    if (_stores != null) return Right(_stores!);

    try {
      final response = await _dio.get('/stores');
      _stores = response.data
          .map<StoreWithRole>((j) => StoreWithRole.fromJson(j))
          .toList();
      return Right(_stores!);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar lojas',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, List<StoreWithRole>>> getStoresForUser() async {
    try {
      final response = await _dio.get('/stores');
      final stores = (response.data as List)
          .map<StoreWithRole>((json) => StoreWithRole.fromJson(json))
          .toList();
      return Right(stores);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar lojas',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, StoreWithRole>> cloneStore({
    required int sourceStoreId,
    required String name,
    required String urlSlug,
    required String? description,
    required String phone,
    required String addressJson,
    required String optionsJson,
  }) async {
    try {
      final formData = FormData.fromMap({
        'source_store_id': sourceStoreId,
        'name': name,
        'url_slug': urlSlug,
        'phone': phone,
        if (description != null) 'description': description,
        'address': addressJson,
        'options': optionsJson,
      });

      final response = await _dio.post('/stores/clone', data: formData);
      final newStore = StoreWithRole.fromJson(response.data);
      return Right(newStore);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Não foi possível clonar a loja',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<bool> urlExists(String url) async {
    try {
      await _dio.get('/stores/check-url/$url');
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return true;
      }
      return false;
    }
  }

  Future<Either<Failure, StoreWithRole>> createStore(
      CreateStoreState setupData) async {
    try {
      final jsonData = setupData.toJson();

      if (jsonData.isEmpty) {
        return Left(Failure(message: 'Dados de configuração inválidos'));
      }

      if (jsonData['name'] == null || jsonData['name'].toString().isEmpty) {
        return Left(Failure(message: 'Nome da loja é obrigatório'));
      }

      if (jsonData['address'] == null) {
        return Left(Failure(message: 'Endereço é obrigatório'));
      }

      final Map<String, dynamic> flattenedData = {
        'name': jsonData['name'] ?? '',
        'store_url': jsonData['store_url'] ?? '',
        'description': jsonData['description'],
        'phone': jsonData['phone'] ?? '',
        'cnpj': jsonData['cnpj'],
        'segment_id': jsonData['segment_id'],
        'cep': jsonData['address']?['cep'] ?? '',
        'street': jsonData['address']?['street'] ?? '',
        'number': jsonData['address']?['number'] ?? '',
        'complement': jsonData['address']?['complement'],
        'neighborhood': jsonData['address']?['neighborhood'] ?? '',
        'city': jsonData['address']?['city'] ?? '',
        'uf': jsonData['address']?['uf'] ?? '',
        'responsible_name': jsonData['responsible']?['name'] ?? '',
        'responsible_phone': jsonData['responsible']?['phone'] ?? '',
      };

      flattenedData.removeWhere((key, value) {
        if (value == null) return true;
        if (value is String && value.isEmpty) {
          final requiredFields = [
            'name',
            'cep',
            'street',
            'number',
            'neighborhood',
            'city',
            'uf'
          ];
          return requiredFields.contains(key);
        }
        return false;
      });

      final formData = FormData.fromMap(flattenedData);
      final response = await _dio.post('/stores', data: formData);
      final createdStoreWithRole = StoreWithRole.fromJson(response.data);

      if (createdStoreWithRole.store.core.id == null) {
        return Left(Failure(message: 'A API retornou uma loja sem ID'));
      }

      return Right(createdStoreWithRole);
    } on DioException catch (e) {
      debugPrint('DioException em createStore: $e');
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Não foi possível criar a loja. Tente novamente',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      debugPrint('Erro inesperado em createStore: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, Store>> updateStore(int storeId, Store store) async {
    try {
      if (store.core.id != null) {
        final response = await _dio.patch(
          '/stores/$storeId',
          data: await store.toFormData(),
        );
        return Right(Store.fromJson(response.data));
      } else {
        final response = await _dio.post(
          '/stores/$storeId/',
          data: await store.toFormData(),
        );
        return Right(Store.fromJson(response.data));
      }
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao atualizar loja',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, StoreAccess>> createUserForStore({
    required int storeId,
    required String name,
    required String email,
    required String phone,
    required String password,
    required StoreAccessRole role,
  }) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/accesses',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role_machine_name': role.name,
        },
      );

      return Right(StoreAccess.fromJson(response.data));
    } on DioException catch (e) {
      debugPrint('DioException em createUserForStore: ${e.response?.data}');
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Falha ao criar usuário',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, List<StoreAccess>>> getStoreAccesses(
      int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/accesses');
      return Right(response.data
          .map<StoreAccess>((s) => StoreAccess.fromJson(s))
          .toList());
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar acessos',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, void>> revokeAccess(int storeId, int userId) async {
    try {
      await _dio.delete(
        '/stores/$storeId/accesses',
        queryParameters: {'user_id': userId},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao revogar acesso',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, Store>> getStore(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId');
      return Right(Store.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar loja',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, Store>> fetchStore(int id) async {
    try {
      final response = await _dio.get('/stores/$id');
      if (response.statusCode == 200) {
        final storeData = response.data;
        final store = Store.fromJson(storeData);
        return Right(store);
      } else {
        return Left(Failure(
          message: 'Erro ao buscar loja',
          statusCode: response.statusCode,
        ));
      }
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro de conexão',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // THEME
  // ═══════════════════════════════════════════════════════════

  Future<Either<Failure, StoreTheme?>> getStoreTheme(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/theme');
      return Right(response.data != null
          ? StoreTheme.fromJson(response.data)
          : null);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar tema',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, StoreTheme>> updateStoreTheme(
      int storeId, StoreTheme theme) async {
    try {
      final response = await _dio.put(
        '/stores/$storeId/theme',
        data: theme.toJson(),
      );
      return Right(StoreTheme.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao atualizar tema',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PIX CONFIG
  // ═══════════════════════════════════════════════════════════

  Future<Either<Failure, StorePixConfig?>> getStorePixConfig(
      int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/pix-configs');
      return Right(response.data != null
          ? StorePixConfig.fromJson(response.data)
          : null);
    } on DioException catch (e) {
      return Left(Failure(
        message:
        e.response?.data?['detail'] ?? 'Erro ao buscar configuração Pix',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, StorePixConfig>> updateStorePixConfig(
      int storeId, StorePixConfig pixConfig) async {
    try {
      final response = await _dio.put('/stores/$storeId/pix-configs',
          data: await pixConfig.toFormData());
      return Right(StorePixConfig.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Erro ao atualizar configuração Pix',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // HOURS
  // ═══════════════════════════════════════════════════════════

  Future<Either<Failure, void>> updateHours(
      int storeId, List<StoreHour> hours) async {
    try {
      final hoursJson = hours.map((h) => h.toJson()).toList();
      await _dio.put('/stores/$storeId/hours', data: hoursJson);
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao atualizar horários',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CUSTOMERS
  // ═══════════════════════════════════════════════════════════

  Future<Either<Failure, List<StoreCustomer>>> getStoreCustomers(
      int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/customers');
      final list = (response.data as List<dynamic>)
          .map((e) => StoreCustomer.fromJson(e))
          .toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar clientes',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CITIES & NEIGHBORHOODS
  // ═══════════════════════════════════════════════════════════

  Future<Either<Failure, StoreCity>> saveCityWithNeighborhoods(
      int storeId, StoreCity city) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/cities-with-neighborhoods',
        data: city.toJson(),
      );
      return Right(StoreCity.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(
        message:
        e.response?.data?['detail'] ?? 'Não foi possível salvar os locais',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, List<StoreCity>>> getCities(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/cities');
      final list = (response.data as List<dynamic>)
          .map((e) => StoreCity.fromJson(e))
          .toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar cidades',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, StoreCity>> getCity(int storeId, int cityId) async {
    try {
      final response = await _dio.get('/stores/$storeId/cities/$cityId');
      return Right(StoreCity.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar cidade',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, StoreCity>> saveCity(
      int storeId, StoreCity city) async {
    try {
      if (city.id != null) {
        final response = await _dio.patch(
          '/stores/$storeId/cities/${city.id}',
          data: city.toFormData(),
        );
        return Right(StoreCity.fromJson(response.data));
      } else {
        final response = await _dio.post(
          '/stores/$storeId/cities',
          data: city.toFormData(),
        );
        return Right(StoreCity.fromJson(response.data));
      }
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao salvar cidade',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, void>> deleteCity(int storeId, int cityId) async {
    try {
      await _dio.delete('/stores/$storeId/cities/$cityId');
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao deletar cidade',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, List<StoreNeighborhood>>> getNeighborhoods(
      int cityId) async {
    try {
      final response = await _dio.get('/cities/$cityId/neighborhoods');
      final list = (response.data as List<dynamic>)
          .map((e) => StoreNeighborhood.fromJson(e))
          .toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar bairros',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, StoreNeighborhood>> getNeighborhood(
      int cityId, int neighborhoodId) async {
    try {
      final response =
      await _dio.get('/cities/$cityId/neighborhoods/$neighborhoodId');
      return Right(StoreNeighborhood.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar bairro',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, StoreNeighborhood>> saveNeighborhood(
      int cityId, StoreNeighborhood neighborhood) async {
    try {
      if (neighborhood.id != null) {
        final response = await _dio.patch(
          '/cities/$cityId/neighborhoods/${neighborhood.id}',
          data: await neighborhood.toFormData(),
        );
        return Right(StoreNeighborhood.fromJson(response.data));
      } else {
        final response = await _dio.post(
          '/cities/$cityId/neighborhoods',
          data: await neighborhood.toFormData(),
        );
        return Right(StoreNeighborhood.fromJson(response.data));
      }
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao salvar bairro',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, void>> deleteNeighborhood(
      int cityId, int neighborhoodId) async {
    try {
      await _dio.delete('/cities/$cityId/neighborhoods/$neighborhoodId');
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao deletar bairro',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PAYABLES
  // ═══════════════════════════════════════════════════════════

  Future<Either<Failure, List<StorePayable>>> getPayables(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/payables');
      final list =
      (response.data as List).map((e) => StorePayable.fromJson(e)).toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar formas de pagamento',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, StorePayable>> getPayable(
      int storeId, int payableId) async {
    try {
      final response = await _dio.get('/stores/$storeId/payables/$payableId');
      return Right(StorePayable.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar forma de pagamento',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, StorePayable>> savePayable(
      int storeId, StorePayable payable) async {
    try {
      if (payable.id != null) {
        final response = await _dio.patch(
          '/stores/$storeId/payables/${payable.id}',
          data: payable.toJson(),
        );
        return Right(StorePayable.fromJson(response.data));
      } else {
        final response = await _dio.post(
          '/stores/$storeId/payables',
          data: payable.toJson(),
        );
        return Right(StorePayable.fromJson(response.data));
      }
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao salvar forma de pagamento',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, void>> deletePayable(
      int storeId, int payableId) async {
    try {
      await _dio.delete('/stores/$storeId/payables/$payableId');
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao deletar forma de pagamento',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CASHIER SESSIONS
  // ═══════════════════════════════════════════════════════════

  Future<Either<Failure, CashierSession>> getSession(
      int storeId, int id) async {
    try {
      final response =
      await _dio.get('/stores/$storeId/cashier-sessions/$id');
      return Right(CashierSession.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar sessão',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, void>> deleteSession(int storeId, int id) async {
    try {
      await _dio.delete('/stores/$storeId/cashier-sessions/$id');
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao deletar sessão',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, CashierSession>> closeSession(
      int storeId,
      int sessionId,
      double expectedAmount,
      double informedAmount,
      double cashDifference,
      ) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/cashier-sessions/$sessionId/close',
        data: {
          "expected_amount": expectedAmount,
          "informed_amount": informedAmount,
          "cash_difference": cashDifference
        },
      );
      return Right(CashierSession.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao fechar sessão',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, CashierTransaction>> addCash(
      int storeId,
      int sessionId,
      double amount,
      String description,
      int paymentMethodId,
      ) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/cashier-sessions/$sessionId/add-cash',
        data: {
          "amount": amount,
          "description": description,
          "payment_method_id": paymentMethodId
        },
      );
      return Right(CashierTransaction.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao adicionar dinheiro',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, CashierTransaction>> removeCash(
      int storeId,
      int sessionId,
      double amount,
      String description,
      int paymentMethodId,
      ) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/cashier-sessions/$sessionId/remove-cash',
        data: {
          "amount": amount,
          "description": description,
          "payment_method_id": paymentMethodId
        },
      );
      return Right(CashierTransaction.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao remover dinheiro',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, List<CashierSession>>> listCashierSessions(
      int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/cashier-sessions');
      final List<dynamic> data = response.data;
      final sessions =
      data.map((json) => CashierSession.fromJson(json)).toList();
      return Right(sessions);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao listar sessões',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, CashierSession>> getCurrentCashierSession(
      int storeId) async {
    try {
      final response =
      await _dio.get('/stores/$storeId/cashier-sessions/current');
      final data = response.data;
      final session = CashierSession.fromJson(data);
      return Right(session);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar sessão atual',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, List<CashierTransaction>>> listCashierTransactions(
      int storeId, int sessionId) async {
    try {
      final response = await _dio
          .get('/stores/$storeId/cashier-sessions/$sessionId/transactions');
      final List<dynamic> data = response.data;
      final transactions =
      data.map((json) => CashierTransaction.fromJson(json)).toList();
      return Right(transactions);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao listar transações',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, Map<String, double>>> getCashierSessionPaymentSummary(
      int storeId, int sessionId) async {
    try {
      final response = await _dio.get(
          '/stores/$storeId/cashier-sessions/$sessionId/payment-summary');

      final Map<String, dynamic> rawSummary = response.data;

      final Map<String, double> summary = rawSummary.map((key, value) {
        if (value is num) {
          return MapEntry(key, value.toDouble());
        }
        throw FormatException(
            'Valor inesperado para o resumo de pagamento: $value');
      });

      return Right(summary);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar resumo de pagamentos',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, CashierSession>> openCashierSession(
      int storeId, int paymentMethodId, double initialBalance) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/cashier-sessions',
        data: {
          'opening_amount': initialBalance,
          'payment_method_id': paymentMethodId
        },
      );

      final openedSession = CashierSession.fromJson(response.data);
      return Right(openedSession);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao abrir sessão',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // TRANSACTIONS
  // ═══════════════════════════════════════════════════════════

  Future<Either<Failure, List<CashierTransaction>>> listTransactions(
      int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/cashier_transactions');
      final list = (response.data as List)
          .map((e) => CashierTransaction.fromJson(e))
          .toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao listar transações',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, CashierTransaction>> getTransaction(
      int storeId, int id) async {
    try {
      final response =
      await _dio.get('/stores/$storeId/cashier_transactions/$id');
      return Right(CashierTransaction.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao buscar transação',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, CashierTransaction>> saveTransaction(
      int storeId, CashierTransaction transaction) async {
    try {
      if (transaction.id != null) {
        final response = await _dio.put(
          '/stores/$storeId/cashier_transactions/${transaction.id}',
          data: transaction.toJson(),
        );
        return Right(CashierTransaction.fromJson(response.data));
      } else {
        final response = await _dio.post(
          '/stores/$storeId/cashier_transactions',
          data: transaction.toJson(),
        );
        return Right(CashierTransaction.fromJson(response.data));
      }
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao salvar transação',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, void>> deleteTransaction(
      int storeId, int id) async {
    try {
      await _dio.delete('/stores/$storeId/cashier_transactions/$id');
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Erro ao deletar transação',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PLANS & SUBSCRIPTIONS
  // ═══════════════════════════════════════════════════════════

  Future<Either<Failure, List<Plans>>> getPlans() async {
    try {
      final response = await _dio.get('/plans');

      if (response.data is! List) {
        return Left(Failure(message: 'Resposta inesperada do servidor'));
      }

      final plans = (response.data as List)
          .map<Plans>((json) => Plans.fromJson(json))
          .toList();

      return Right(plans);
    } on DioException catch (e) {
      debugPrint('DioException em getPlans: $e');
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Erro de comunicação com o servidor. Tente novamente',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      debugPrint('Erro inesperado em getPlans: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, Address>> getZipcodeAddress(String zipcode) async {
    try {
      final response = await _dio.get(
        'https://viacep.com.br/ws/${UtilBrasilFields.removeCaracteres(zipcode)}/json/',
      );
      if (response.data['erro'] == true) {
        return Left(Failure(message: 'CEP não encontrado'));
      }
      return Right(Address.fromJson(response.data));
    } on DioException catch (e) {
      debugPrint('DioException em getZipcodeAddress: $e');
      return Left(Failure(
        message: 'Não foi possível buscar o CEP',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      debugPrint('Erro inesperado em getZipcodeAddress: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, PagarmeTokenResult>> generatePagarmeCardToken({
    required String cardNumber,
    required String holderName,
    required String expirationMonth,
    required String expirationYear,
    required String cvv,
  }) async {
    try {
      print('═' * 60);
      print('🔐 [Repository] Gerando token Pagar.me...');
      print(
          '   Número: ${cardNumber.substring(0, 4)}...${cardNumber.substring(cardNumber.length - 4)}');
      print('   Titular: $holderName');
      print('   Validade: $expirationMonth/$expirationYear');
      print('   CVV: ${cvv.length} dígitos');
      print('═' * 60);

      final result = await _pagarmeService.tokenizeCard(
        cardNumber: cardNumber,
        holderName: holderName,
        expirationMonth: expirationMonth,
        expirationYear: expirationYear,
        cvv: cvv,
      );

      print(
          '✅ [Repository] Token gerado: ${result.token.substring(0, 20)}...');
      print('   Cartão: ${result.cardMask}');
      print('   Bandeira: ${result.brand}');
      print('═' * 60);

      return Right(result);
    } on PagarmeException catch (e) {
      print('❌ [Repository] Erro Pagar.me: $e');
      print('═' * 60);
      return Left(Failure(message: e.message));
    } catch (e) {
      print('❌ [Repository] Erro inesperado: $e');
      print('═' * 60);
      return Left(Failure(message: 'Erro ao validar cartão. Tente novamente'));
    }
  }

  Future<Either<Failure, void>> createSubscription(
      int storeId,
      CreateSubscriptionPayload subscription,
      ) async {
    try {
      debugPrint(
          '📤 [Repository] Ativando assinatura para loja $storeId...');

      await _dio.post(
        '/stores/$storeId/subscriptions',
        data: subscription.toJson(),
      );

      debugPrint('✅ [Repository] Assinatura ativada com sucesso!');
      return const Right(null);
    } on DioException catch (e) {
      debugPrint('❌ [Repository] DioException: ${e.response?.data}');

      String errorMsg = 'Falha ao criar assinatura. Tente novamente';

      if (e.response?.data != null && e.response!.data['detail'] != null) {
        final detail = e.response!.data['detail'];

        if (detail is Map) {
          errorMsg = detail['message'] ?? errorMsg;
        } else if (detail is String) {
          errorMsg = detail;
        }
      }

      return Left(Failure(
        message: errorMsg,
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      debugPrint('❌ [Repository] Erro inesperado: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }



  Future<Either<Failure, Map<String, dynamic>>> cancelSubscription(
      int storeId,
      ) async {
    try {
      debugPrint(
          '📡 [Repository] Cancelando assinatura para loja $storeId...');

      final response = await _dio.delete(
        '/stores/$storeId/subscriptions',
      );

      debugPrint('✅ [Repository] Assinatura cancelada com sucesso');

      return Right(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint(
          '❌ [Repository] DioException ao cancelar: ${e.response?.data}');

      String errorMsg = 'Erro ao cancelar assinatura';

      if (e.response?.data != null && e.response!.data['detail'] != null) {
        final detail = e.response!.data['detail'];

        if (detail is String) {
          errorMsg = detail;
        } else if (detail is Map && detail['message'] != null) {
          errorMsg = detail['message'];
        }
      }

      return Left(Failure(
        message: errorMsg,
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      debugPrint('❌ [Repository] Erro inesperado ao cancelar: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

// lib/repositories/store_repository.dart

// ═══════════════════════════════════════════════════════════
// REACTIVATE SUBSCRIPTION
// ═══════════════════════════════════════════════════════════

  Future<Either<Failure, Map<String, dynamic>>> reactivateSubscription(
      int storeId, {
        CreateSubscriptionPayload? cardData,
      }) async {
    try {
      debugPrint('📡 [Repository] Reativando assinatura para loja $storeId...');

      final response = await _dio.post(
        '/stores/$storeId/subscriptions/reactivate',
        data: cardData?.toJson(), // ✅ Envia cartão apenas se fornecido
      );

      debugPrint('✅ [Repository] Assinatura reativada com sucesso');

      return Right(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('❌ [Repository] DioException ao reativar: ${e.response?.data}');

      String errorMsg = 'Erro ao reativar assinatura';

      if (e.response?.data != null && e.response!.data['detail'] != null) {
        final detail = e.response!.data['detail'];

        if (detail is String) {
          errorMsg = detail;
        } else if (detail is Map && detail['message'] != null) {
          errorMsg = detail['message'];
        }
      }

      return Left(Failure(
        message: errorMsg,
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      debugPrint('❌ [Repository] Erro inesperado ao reativar: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, void>> updateSubscriptionCard(
      int storeId,
      CreateSubscriptionPayload cardData,
      ) async {
    try {
      debugPrint('📡 [Repository] Atualizando cartão para loja $storeId...');

      await _dio.patch(
        '/stores/$storeId/subscriptions/card',
        data: cardData.toJson(),
      );

      debugPrint('✅ [Repository] Cartão atualizado com sucesso');

      return const Right(null);
    } on DioException catch (e) {
      debugPrint('❌ [Repository] DioException: ${e.response?.data}');

      String errorMsg = 'Erro ao atualizar cartão';

      if (e.response?.data != null && e.response!.data['detail'] != null) {
        final detail = e.response!.data['detail'];

        if (detail is String) {
          errorMsg = detail;
        } else if (detail is Map && detail['message'] != null) {
          errorMsg = detail['message'];
        }
      }

      return Left(Failure(
        message: errorMsg,
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      debugPrint('❌ [Repository] Erro inesperado: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }




  // ═══════════════════════════════════════════════════════════
  // SCHEDULED PAUSES
  // ═══════════════════════════════════════════════════════════

  Future<Either<Failure, ScheduledPause>> createScheduledPause({
    required int storeId,
    required String? reason,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final response = await _dio.post(
        '/pauses/store/$storeId',
        data: {
          'reason': reason,
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
        },
      );

      final newPause = ScheduledPause.fromJson(response.data);
      return Right(newPause);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Não foi possível criar a pausa. Tente novamente',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, void>> deleteScheduledPause({
    required int pauseId,
  }) async {
    try {
      await _dio.delete('/pauses/$pauseId');
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Não foi possível deletar a pausa. Tente novamente',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // HOLIDAYS
  // ═══════════════════════════════════════════════════════════

  Future<Either<Failure, List<Holiday>>> getHolidays(int year) async {
    try {
      final response = await _dio.get('/holidays/$year');
      final holidays =
      (response.data as List).map((h) => Holiday.fromJson(h)).toList();
      return Right(holidays);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Falha ao buscar feriados. Tente novamente',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STORE SETUP
  // ═══════════════════════════════════════════════════════════

  Future<Either<Failure, void>> completeStoreSetup(int storeId) async {
    try {
      final formData = FormData.fromMap({
        'is_setup_complete': true,
      });

      await _dio.patch(
        '/stores/$storeId',
        data: formData,
      );

      return const Right(null);
    } on DioException catch (e) {
      debugPrint('DioException em completeStoreSetup: $e');
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Não foi possível finalizar a configuração',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      debugPrint('Erro inesperado em completeStoreSetup: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }
}