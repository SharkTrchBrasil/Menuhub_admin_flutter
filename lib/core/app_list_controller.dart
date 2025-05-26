import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:totem_pro_admin/models/page_status.dart';

class AppListController<T> extends ChangeNotifier {

  AppListController({required this.fetch}) {
    _initialize();
  }

  final Future<Either<void, List<T>>> Function() fetch;

  PageStatus status = PageStatusIdle();

  Future<void> _initialize() async {
    status = PageStatusLoading();
    notifyListeners();

    final result = await fetch();


    // if(result.isLeft) {
    //   status = PageStatusError('Falha ao carregar!');
    // } else {
    //   // *** MUDANÇA AQUI: Remova a condição para PageStatusEmpty ***
    //   // Se a requisição foi um sucesso (result.isRight),
    //   // sempre definimos o status como PageStatusSuccess com os dados,
    //   // mesmo que a lista esteja vazia.
    //   status = PageStatusSuccess<List<T>>(result.right);
    // }


    if(result.isLeft) {
      status = PageStatusError('Falha ao carregar!');
    } else {
      if(result.right.isEmpty) {
        status = PageStatusEmpty('Nenhum item encontrado');
      } else {
        status = PageStatusSuccess<List<T>>(result.right);
      }
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await _initialize();
  }

  List<T> get items {
    if (status is PageStatusSuccess<List<T>>) {
      return (status as PageStatusSuccess<List<T>>).data;
    }
    return [];
  }

}