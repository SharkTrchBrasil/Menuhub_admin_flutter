import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/models/store_access.dart';
import 'package:totem_pro_admin/models/store_theme.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';



import '../core/failures.dart';
import '../core/payment_token.dart';
import '../models/address.dart';
import '../models/cash_session.dart';
import '../models/cash_transaction.dart';
import '../models/create_subscription_payload.dart';
import '../models/credit_card.dart';
import '../models/full_store_data_model.dart';

import '../models/plan.dart';
import '../models/store_city.dart';
import '../models/store_customer.dart';
import '../models/store_hour.dart';
import '../models/store_neig.dart';
import '../models/store_payable.dart';
import '../models/store_pix_config.dart';

import '../models/tokenized_card.dart';


class StoreRepository {

  StoreRepository(this._dio);

  final Dio _dio;

  List<StoreWithRole>? _stores;

  List<StoreWithRole> get stores => _stores!;

  Future<Either<void, List<StoreWithRole>>> getStores() async {
    if(_stores != null) return Right(_stores!);

    try {
      final response = await _dio.get('/stores');
      _stores = response.data.map<StoreWithRole>((j) => StoreWithRole.fromJson(j)).toList();
      return Right(_stores!);
    } catch (e) {
      return const Left(null);
    }
  }



  Future<Either<String, FullStoreDataModel>> getFullStore(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/full');
  //    print('Resposta da API (getFullStore): ${response.data}'); // Log da resposta bruta
      return Right(FullStoreDataModel.fromJson(response.data));
    } catch (e) {
      print('Erro capturado no getFullStore: $e, tipo: ${e.runtimeType}'); // Log do erro e seu tipo
      String errorMessage = 'Erro ao buscar dados completos da loja.';
      if (e is DioError) {
        if (e.response != null) {
          errorMessage = 'Erro HTTP ${e.response?.statusCode}: ${e.response?.data}';
          print('Erro Dio com resposta: $errorMessage');
        } else {
          errorMessage = 'Erro de conexão: ${e.message}';
          print('Erro Dio sem resposta: $errorMessage');
        }
      } else {
        print('Outro tipo de erro: $e');
      }
      return Left(errorMessage);
    }
  }

  Future<Either<void, StoreWithRole>> createStore(String name, String phone) async {
    try {
      final response = await _dio.post('/stores', data: {'name': name, 'phone': phone});
      final newStore = StoreWithRole.fromJson(response.data);
      _stores!.add(newStore);
      return Right(newStore);
    } catch (e) {
      return const Left(null);
    }
  }


  Future<Either<void, Store>> updateStore(
      int storeId,
      Store store,
      ) async {
    try {
      if (store.id != null) {
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
    } catch (e) {
      debugPrint('$e');
      return Left(null);
    }
  }



  Future<Either<void, void>> createStoreAccess(
      int storeId, String email, StoreAccessRole role) async {
    try {
      await _dio.put(
        '/stores/$storeId/accesses',
        queryParameters: {
          'user_email': email,
          'role': role.name,
        },
      );
      return const Right(null);
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, List<StoreAccess>>> getStoreAccesses(
      int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/accesses');
      return Right(response.data
          .map<StoreAccess>((s) => StoreAccess.fromJson(s))
          .toList());
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, void>> revokeAccess(int storeId, int userId) async {
    try {
      await _dio.delete(
        '/stores/$storeId/accesses',
        queryParameters: {'user_id': userId},
      );
      return const Right(null);
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, Store>> getStore(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId');
      return Right(Store.fromJson(response.data));
    } catch (e, s) {
      debugPrint('$e $s');
      return const Left(null);
    }
  }


  // store_repository.dart
  Future<Either<String, Store>> fetchStore(int id) async {  // Mudança aqui
    try {
      final response = await _dio.get('/stores/$id');
      if (response.statusCode == 200) {
        final storeData = response.data;
        final store = Store.fromJson(storeData);
        return Right(store);
      } else {
        return Left("Erro ao buscar loja: ${response.statusCode}"); // Retorne uma String
      }
    } catch (e) {
      return Left("Erro de conexão: ${e.toString()}"); // Retorne uma String
    }
  }
  // Future<Either<void, Store>> updateStore(Store store) async {
  //   try {
  //     final response =
  //     await _dio.patch('/stores/${store.id}', data: {'name': store.name});
  //     return Right(Store.fromJson(response.data));
  //   } catch (e) {
  //     debugPrint('$e');
  //     return const Left(null);
  //   }
  // }

  Future<Either<void, StoreTheme?>> getStoreTheme(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/theme');
      return Right(response.data != null ? StoreTheme.fromJson(response.data) : null);
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, StoreTheme>> updateStoreTheme(int storeId, StoreTheme theme) async {
    try {
      final response = await _dio.put(
        '/stores/$storeId/theme',
        data: theme.toJson(),
      );
      return Right(StoreTheme.fromJson(response.data));
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, StorePixConfig?>> getStorePixConfig(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/pix-configs');
      return Right(response.data != null
          ? StorePixConfig.fromJson(response.data)
          : null);
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, StorePixConfig>> updateStorePixConfig(
      int storeId, StorePixConfig pixConfig) async {
    try {
      final response = await _dio.put('/stores/$storeId/pix-configs',
          data: await pixConfig.toFormData());
      return Right(StorePixConfig.fromJson(response.data));
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }




  // HOURS ///
  Future<Either<void, List<StoreHour>>> getHours(int storeId) async {
    try {
      final data = await _dio.get('/stores/$storeId/hours');
      final list = (data.data as List<dynamic>)
          .map<StoreHour>((c) => StoreHour.fromJson(c))
          .toList();
      return Right(list);
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, StoreHour>> getStoreHour(int storeId, int id) async {
    try {
      final response = await _dio.get('/stores/$storeId/hours/$id');
      return Right(StoreHour.fromJson(response.data));
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, StoreHour>> saveStoreHour(
      int storeId,
      StoreHour storeHour,
      ) async {
    try {
      if (storeHour.id != null) {
        final response = await _dio.patch(
          '/stores/$storeId/hours/${storeHour.id}',
          data: await storeHour.toFormData(),
        );
        return Right(StoreHour.fromJson(response.data));
      } else {
        final response = await _dio.post(
          '/stores/$storeId/hours',
          data: await storeHour.toFormData(),
        );
        return Right(StoreHour.fromJson(response.data));
      }
    } catch (e) {
      debugPrint('$e');
      return Left(null);
    }
  }

  Future<Either<void, void>> deleteStoreHour(int storeId, int hourId) async {
    try {
      await _dio.delete('/stores/$storeId/hours/$hourId');
      return const Right(null);
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }


  Future<Either<void, List<StoreCustomer>>> getStoreCustomers(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/customers');
      final list = (response.data as List<dynamic>)
          .map((e) => StoreCustomer.fromJson(e))
          .toList();
      return Right(list);
    } catch (e) {
      debugPrint('Error getStoreCustomers: $e');
      return const Left(null);
    }
  }






  ///#### ///////



              ///  citys //

  Future<Either<void, List<StoreCity>>> getCities(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/cities');
      final list = (response.data as List<dynamic>)
          .map((e) => StoreCity.fromJson(e))
          .toList();
      return Right(list);
    } catch (e) {
      debugPrint('Error getCities: $e');
      return const Left(null);
    }
  }

  Future<Either<void, StoreCity>> getCity(int storeId, int cityId) async {
    try {
      final response = await _dio.get('/stores/$storeId/cities/$cityId');
      return Right(StoreCity.fromJson(response.data));
    } catch (e) {
      debugPrint('Error getCity: $e');
      return const Left(null);
    }
  }

  Future<Either<void, StoreCity>> saveCity(int storeId, StoreCity city) async {
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
    } catch (e) {
      debugPrint('Error saveCity: $e');
      return const Left(null);
    }
  }

  Future<Either<void, void>> deleteCity(int storeId, int cityId) async {
    try {
      await _dio.delete('/stores/$storeId/cities/$cityId');
      return const Right(null);
    } catch (e) {
      debugPrint('Error deleteCity: $e');
      return const Left(null);
    }
  }


   // FIM //


  Future<Either<void, List<StoreNeighborhood>>> getNeighborhoods(int cityId) async {
    try {
      final response = await _dio.get('/cities/$cityId/neighborhoods');
      final list = (response.data as List<dynamic>)
          .map((e) => StoreNeighborhood.fromJson(e))
          .toList();
      return Right(list);
    } catch (e) {
      debugPrint('Error getNeighborhoods: $e');
      return const Left(null);
    }
  }

  Future<Either<void, StoreNeighborhood>> getNeighborhood(int cityId, int neighborhoodId) async {
    try {
      final response = await _dio.get('/cities/$cityId/neighborhoods/$neighborhoodId');
      return Right(StoreNeighborhood.fromJson(response.data));
    } catch (e) {
      debugPrint('Error getNeighborhood: $e');
      return const Left(null);
    }
  }

  Future<Either<void, StoreNeighborhood>> saveNeighborhood(int cityId, StoreNeighborhood neighborhood) async {
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
    } catch (e) {
      debugPrint('Error saveNeighborhood: $e');
      return const Left(null);
    }
  }

  Future<Either<void, void>> deleteNeighborhood(int cityId, int neighborhoodId) async {
    try {
      await _dio.delete('/cities/$cityId/neighborhoods/$neighborhoodId');
      return const Right(null);
    } catch (e) {
      debugPrint('Error deleteNeighborhood: $e');
      return const Left(null);
    }
  }

   // FIM ///


  Future<Either<void, List<StorePayable>>> getPayables(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/payables');
      final list = (response.data as List)
          .map((e) => StorePayable.fromJson(e))
          .toList();
      return Right(list);
    } catch (e) {
      debugPrint('Error getPayables: $e');
      return const Left(null);
    }
  }

  Future<Either<void, StorePayable>> getPayable(int storeId, int payableId) async {
    try {
      final response = await _dio.get('/stores/$storeId/payables/$payableId');
      return Right(StorePayable.fromJson(response.data));
    } catch (e) {
      debugPrint('Error getPayable: $e');
      return const Left(null);
    }
  }

  Future<Either<void, StorePayable>> savePayable(int storeId, StorePayable payable) async {
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
    } catch (e) {
      debugPrint('Error savePayable: $e');
      return const Left(null);
    }
  }

  Future<Either<void, void>> deletePayable(int storeId, int payableId) async {
    try {
      await _dio.delete('/stores/$storeId/payables/$payableId');
      return const Right(null);
    } catch (e) {
      debugPrint('Error deletePayable: $e');
      return const Left(null);
    }
  }




//// CAIXA ///



  // SESSION //



  Future<Either<void, CashierSession>> getSession(int storeId,int id) async {
    try {
      final response = await _dio.get('/stores/$storeId/cashier-sessions/$id');
      return Right(CashierSession.fromJson(response.data));
    } catch (e) {
      debugPrint('Error getSession: $e');
      return const Left(null);
    }
  }


  Future<Either<void, void>> deleteSession(int storeId, int id) async {
    try {
      await _dio.delete('/stores/$storeId/cashier-sessions/$id');
      return const Right(null);
    } catch (e) {
      debugPrint('Error deleteSession: $e');
      return const Left(null);
    }
  }

  Future<Either<void, CashierSession>> closeSession(int storeId, int sessionId, double expectedAmount , double informedAmount, double cashDifference,) async {
    try {
      final response = await _dio.post('/stores/$storeId/cashier-sessions/$sessionId/close',
        data: {
          "expected_amount": expectedAmount,
          "informed_amount": informedAmount,
          "cash_difference": cashDifference
        },

      );
      return Right(CashierSession.fromJson(response.data));
    } catch (e) {
      debugPrint('Error closeSession: $e');
      return const Left(null);
    }
  }
  Future<Either<void, CashierTransaction>> addCash(int storeId, int sessionId, double amount, String description, int paymentMethodId,) async {
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
    } catch (e) {
      debugPrint('Error addCash: $e');
      return const Left(null);
    }
  }

  Future<Either<void, CashierTransaction>> removeCash(int storeId, int sessionId, double amount, String description, int paymentMethodId) async {
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
    } catch (e) {
      debugPrint('Error removeCash: $e');
      return const Left(null);
    }
  }

  Future<Either<void, List<CashierSession>>> listCashierSessions(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/cashier-sessions');
      final List<dynamic> data = response.data;
      final sessions = data.map((json) => CashierSession.fromJson(json)).toList();
      return Right(sessions);
    } on DioException catch (e) {
      debugPrint('Erro Dio listCashierSessions: $e');
      return Left(null);
    } catch (e) {
      debugPrint('Erro inesperado listCashierSessions: $e');
      return Left(null);
    }
  }

  Future<Either<void, CashierSession>> getCurrentCashierSession(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/cashier-sessions/current');
      final data = response.data;
      final session = CashierSession.fromJson(data);
      return Right(session);
    } on DioException catch (e) {
      debugPrint('Erro Dio getCurrentCashierSession: $e');
      return Left(null); // Ou você pode usar alguma estrutura de erro customizado
    } catch (e) {
      debugPrint('Erro inesperado getCurrentCashierSession: $e');
      return Left(null);
    }
  }




  Future<Either<void, List<CashierTransaction>>> listCashierTransactions(
      int storeId, int sessionId) async {
    try {
      final response = await _dio.get('/stores/$storeId/cashier-sessions/$sessionId/transactions');
      final List<dynamic> data = response.data;
      final transactions = data.map((json) => CashierTransaction.fromJson(json)).toList();
      return Right(transactions);
    } on DioException catch (e) {
      debugPrint('Erro Dio listCashierTransactions: $e');
      return Left(null);
    } catch (e) {
      debugPrint('Erro inesperado listCashierTransactions: $e');
      return Left(null);
    }
  }



  Future<Either<void, Map<String, double>>> getCashierSessionPaymentSummary(int storeId, int sessionId) async {
    try {
      final response = await _dio.get('/stores/$storeId/cashier-sessions/$sessionId/payment-summary');

      // Assume-se que response.data é um Map<String, dynamic>
      final Map<String, dynamic> rawSummary = response.data;

      final Map<String, double> summary = rawSummary.map((key, value) {
        // Garantir que o valor é um num e convertê-lo para double
        if (value is num) {
          return MapEntry(key, value.toDouble());
        }
        // Lidar com casos onde o valor pode não ser um número,
        // embora seu backend deva garantir que seja.
        // Poderia lançar um erro ou retornar um valor padrão.
        throw FormatException('Valor inesperado para o resumo de pagamento: $value');
      });

      return Right(summary);
    } catch (e) {
      debugPrint('Error getCashierSessionPaymentSummary: $e');
      // Para depuração, você pode querer retornar o erro como parte do Either
      // return Left(e.toString()); // Se o tipo de Left for String
      return const Left(null); // Conforme sua assinatura atual
    }
  }




  Future<Either<void, CashierSession>> openCashierSession(int storeId,int paymentMethodId, double initialBalance) async {
    try {
      final response = await _dio.post(
        '/stores/$storeId/cashier-sessions',
        data: {'opening_amount': initialBalance, 'payment_method_id': paymentMethodId },
      );

      final openedSession = CashierSession.fromJson(response.data);


      return Right(openedSession);
    } on DioException catch (e) {
      debugPrint('Erro Dio openCashierSession: $e');
      return const Left(null);
    } catch (e) {
      debugPrint('Erro inesperado openCashierSession: $e');
      return const Left(null);
    }
  }










  // FIM SESSION ///

















  // TRANSACTIONS

  Future<Either<void, List<CashierTransaction>>> listTransactions(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/cashier_transactions');
      final list = (response.data as List)
          .map((e) => CashierTransaction.fromJson(e))
          .toList();
      return Right(list);
    } catch (e) {
      debugPrint('Error listTransactions: $e');
      return const Left(null);
    }
  }

  Future<Either<void, CashierTransaction>> getTransaction(int storeId,int id) async {
    try {
      final response = await _dio.get('/stores/$storeId/cashier_transactions/$id');
      return Right(CashierTransaction.fromJson(response.data));
    } catch (e) {
      debugPrint('Error getTransaction: $e');
      return const Left(null);
    }
  }

  Future<Either<void, CashierTransaction>> saveTransaction(int storeId,CashierTransaction transaction) async {
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
    } catch (e) {
      debugPrint('Error saveTransaction: $e');
      return const Left(null);
    }
  }

  Future<Either<void, void>> deleteTransaction(int storeId,int id) async {
    try {
      await _dio.delete('/stores/$storeId/cashier_transactions/$id');
      return const Right(null);
    } catch (e) {
      debugPrint('Error deleteTransaction: $e');
      return const Left(null);
    }
  }



// ✅ Função Refatorada
  Future<Either<Failure, List<Plan>>> getPlans() async {
    try {
      final response = await _dio.get('/plans');

      // Verificação de segurança: garante que a resposta é uma lista
      if (response.data is! List) {
        return Left(Failure('Resposta inesperada do servidor.'));
      }

      // Mapeia a lista para os seus objetos Plan
      final plans = (response.data as List)
          .map<Plan>((json) => Plan.fromJson(json))
          .toList();

      return Right(plans);

    } on DioException catch (e) {
      // Erro específico de rede (sem internet, timeout, 404, 500, etc.)
      debugPrint('DioException em getPlans: $e');
      return Left(Failure('Erro de comunicação com o servidor. Tente novamente.'));

    } catch (e) {
      // Outros erros (ex: falha no parsing do JSON, erro de programação)
      debugPrint('Erro inesperado em getPlans: $e');
      return Left(Failure('Ocorreu um erro inesperado.'));
    }
  }



  /// Busca um endereço a partir do CEP.
  Future<Either<Failure, Address>> getZipcodeAddress(String zipcode) async {
    try {
      // Removemos o código de teste hardcoded.
      final response = await _dio.get(
        'https://viacep.com.br/ws/${UtilBrasilFields.removeCaracteres(zipcode)}/json/',
      );
      if (response.data['erro'] == true) {
        return Left(Failure('CEP não encontrado.'));
      }
      return Right(Address.fromJson(response.data));
    } on DioException catch (e) {
      debugPrint('DioException em getZipcodeAddress: $e');
      return Left(Failure('Não foi possível buscar o CEP.'));
    } catch (e) {
      debugPrint('Erro inesperado em getZipcodeAddress: $e');
      return Left(Failure('Ocorreu um erro inesperado.'));
    }
  }


// Gera um token de pagamento para um cartão de crédito.
  Future<Either<Failure, TokenizedCard>> generateCardToken(CreditCard card) async {
    // Substitua pelo seu ID de conta real, se necessário
    const accountId = 'b58c97a1ec95e962ec0ebc9d5098fd76';

    try {
      // ✅ VALIDAÇÃO ADICIONAL: Garante que a data de expiração não é nula
      if (card.expirationDate == null) {
        return Left(Failure('Data de vencimento do cartão é inválida.'));
      }

      // Lógica para determinar a bandeira do cartão deve ser implementada aqui
      // Por enquanto, usaremos 'visa' como placeholder
      final cardBrand = 'visa';

      final result = await PaymentToken.generate(
        {
          'brand': cardBrand,
          'number': UtilBrasilFields.removeCaracteres(card.number),
          'cvv': card.cvv,
          'expiration_month': card.expirationDate!.month.toString(),
          'expiration_year': card.expirationDate!.year.toString(),
          'reuse': true,
        },
        {'accountId': accountId, 'sandbox': false},
      );

      // ✅ CORREÇÃO PRINCIPAL: Verifica se o resultado da API é nulo
      if (result == null) {
        debugPrint('Erro: A API de geração de token retornou um valor nulo.');
        return Left(Failure('Falha ao comunicar com o serviço de pagamento. Tente novamente.'));
      }

      return Right(TokenizedCard.fromJson(result));

    } catch (e) {
      debugPrint('Erro ao gerar token do cartão: $e');
      return Left(Failure('Não foi possível validar o cartão. Verifique os dados e tente novamente.'));
    }
  }

  /// Cria a assinatura no backend.
  Future<Either<Failure, void>> createSubscription(
      int storeId,
      CreateSubscriptionPayload subscription, // ✅ Usa o payload correto
      ) async {
    try {
      await _dio.post(
        '/stores/$storeId/subscriptions',
        data: subscription.toJson(),
      );
      // await getStores(); // Opcional: Idealmente, o BLoC/Cubit decide quando recarregar
      return const Right(null);
    } on DioException catch (e) {
      debugPrint('DioException em createSubscription: $e');
      final errorMsg = e.response?.data?['detail'] ?? 'Falha ao criar assinatura.';
      return Left(Failure(errorMsg));
    } catch (e) {
      debugPrint('Erro inesperado em createSubscription: $e');
      return Left(Failure('Ocorreu um erro inesperado.'));
    }
  }
}
























