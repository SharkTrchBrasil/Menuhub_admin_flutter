import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/models/store_access.dart';
import 'package:totem_pro_admin/models/store_theme.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';

import '../models/full_store_data_model.dart';
import '../models/store_city.dart';
import '../models/store_hour.dart';
import '../models/store_neig.dart';
import '../models/store_payable.dart';
import '../models/store_pix_config.dart';


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
      print('Resposta da API (getFullStore): ${response.data}'); // Log da resposta bruta
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
          data: payable.toFormData(),
        );
        return Right(StorePayable.fromJson(response.data));
      } else {
        final response = await _dio.post(
          '/stores/$storeId/payables',
          data: payable.toFormData(),
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


}