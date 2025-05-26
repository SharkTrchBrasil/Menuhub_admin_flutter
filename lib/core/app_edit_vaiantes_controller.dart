import 'package:flutter/foundation.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';
import 'package:either_dart/either.dart';

class AppEditSimpleController<T, E> extends ChangeNotifier {
  AppEditSimpleController({
    required T initialData,
    required this.save,
    this.errorHandler,
  }) {
    status = PageStatusSuccess(initialData);
  }

  final Future<Either<E, T>> Function(T) save;
  final Function(E)? errorHandler;

  PageStatus status = PageStatusIdle();

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
        errorHandler!(result.left);
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
