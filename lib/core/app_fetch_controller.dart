import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:totem_pro_admin/models/page_status.dart';

class AppFetchController<T> extends ChangeNotifier {
  AppFetchController({
    required this.id,
    required this.fetch,
    this.errorHandler,
  }) {
    _initialize();
  }

  final int? id;
  final Future<Either<String, T>> Function(int id) fetch;
  final Function(String error)? errorHandler;

  PageStatus status = PageStatusIdle();
  T? _data;

  T? get data => _data;

  Future<void> _initialize() async {
    if (id == null) return;

    status = PageStatusLoading();
    notifyListeners();

    final result = await fetch(id!);
    if (result.isRight) {
      _data = result.right;
      status = PageStatusSuccess(result.right);
    } else {
      status = PageStatusError(result.left);
      if (errorHandler != null) {
        errorHandler!(result.left);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
