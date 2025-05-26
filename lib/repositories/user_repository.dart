import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/models/store_access.dart';
import 'package:totem_pro_admin/models/store_theme.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';

import '../models/auth_tokens.dart';
import '../models/user.dart';

class UserRepository {

  UserRepository(this._dio);

  final Dio _dio;


  AuthTokens? _authTokens;
  AuthTokens? get authTokens => _authTokens;

  User? _user;
  User? get user => _user;





  Future<Either<void, User>> getUserInfo() async {
    try {
      final response = await _dio.get('/users/me');
      final user = User.fromJson(response.data);
      _user = user;
      return Right(user); // Agora retorna o User corretamente
    } catch (e) {
      return const Left(null);
    }
  }







  Future<Either<void, User>> updateUser(User user) async {
    try {
      final response = await _dio.patch(
        '/users/me',
        data: {
          'name': user.name,

        },
      );
      return Right(User.fromJson(response.data));
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }




}