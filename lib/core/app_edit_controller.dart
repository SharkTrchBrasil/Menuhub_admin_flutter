import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

class AppEditController<E, T> extends ChangeNotifier {
  AppEditController({
    this.id,
    this.fetch,
    this.initialData,
    required this.empty,
    required this.save,
    this.errorHandler,
  }) : assert(
  (id != null && fetch != null) || initialData != null || id == null,
  'Provide either (id and fetch) or initialData for editing, or neither for creating.'
  ) {
    _initialize();
  }

  final int? id;
  final Future<Either<E, T?>> Function(int)? fetch;
  final Future<Either<E, T>> Function(T) save;
  final T Function() empty;
  final T? initialData;
  final Function(E)? errorHandler;

  PageStatus status = PageStatusIdle();

  Future<void> _initialize() async {
    // Caso 1: Dados iniciais foram fornecidos (navegação da lista para edição)
    if (initialData != null) {
      status = PageStatusSuccess(initialData!);
      notifyListeners();
      return;
    }

    // Caso 2: Um ID foi fornecido, mas sem dados (link direto para a URL)
    if (id != null && fetch != null) {
      status = PageStatusLoading();
      notifyListeners();
      final result = await fetch!(id!);
      if (result.isRight) {
        status = PageStatusSuccess(result.right ?? empty());
      } else {
        status = PageStatusError('Falha ao carregar!');
      }
      notifyListeners();
      return;
    }

    // Caso 3: Nenhum ID nem dados iniciais (criando um novo item)
    status = PageStatusSuccess(empty());
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

  Future<void> reloadData() async {
    if (id == null) {
      status = PageStatusError('ID não disponível para recarregar.');
      notifyListeners();
      return;
    }

    status = PageStatusLoading();
    notifyListeners();

    final result = await fetch!(id!);
    if (result.isRight) {
      status = PageStatusSuccess(result.right ?? empty());
    } else {
      status = PageStatusError('Falha ao recarregar!');
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await _initialize();
  }

}