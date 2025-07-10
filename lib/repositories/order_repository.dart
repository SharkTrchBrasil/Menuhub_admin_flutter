import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:totem_pro_admin/models/order.dart';
import 'package:totem_pro_admin/models/order_details.dart';

class OrderRepository {

  final Dio _dio;

  OrderRepository(this._dio);

  Future<Either<void, List<Order>>> getOrders(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/orders');
      return Right(
        response.data.map<Order>((c) => Order.fromJson(c)).toList(),
      );
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }

  Future<Either<void, OrderDetails>> getOrder(int storeId, int id) async {
    try {
      final response = await _dio.get('/stores/$storeId/orders/$id');
      return Right(OrderDetails.fromJson(response.data));
    } catch (e) {
      debugPrint('$e');
      return const Left(null);
    }
  }


}