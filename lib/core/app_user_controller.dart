import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

class AppUserController<E, T> extends ChangeNotifier {
  AppUserController({
    required this.fetch,
    required this.save,

    this.errorHandler,
  }) {
    initialize();
  }

  final Future<Either<E, T?>> Function() fetch; // Ajustado para não exigir id
  final Future<Either<E, T>> Function(T) save;

  final Function(E)? errorHandler;

  PageStatus status = PageStatusIdle();

  Future<void> initialize() async {
    status = PageStatusLoading();
    notifyListeners();

    final result = await fetch();
    if (result.isRight) {
      status = PageStatusSuccess(result.right);
    } else {
      status = PageStatusError('Falha ao carregar!');
    }
    notifyListeners();
  }

  void onChanged(T newData) {
    status = PageStatusSuccess(newData);
    notifyListeners();
  }

  Future<Either<void, T>> saveData() async {
    final l = showLoading();
    final result = await save((status as PageStatusSuccess).data);
    l();
    if (result.isLeft) {
      if (errorHandler != null) {
        errorHandler!.call(result.left);
      } else {
        showError('Falha ao salvar. Por favor, tente novamente!');
      }
      return Left(null);
    } else {
      showSuccess('Salvo com sucesso!');
      status = PageStatusSuccess(result.right);
      notifyListeners();
      return Right(result.right);
    }
  }
}
