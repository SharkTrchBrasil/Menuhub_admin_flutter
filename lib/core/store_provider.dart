import 'package:flutter/material.dart';
import 'package:either_dart/either.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/models/full_store_data_model.dart'; // Importe o model correto
import 'package:totem_pro_admin/repositories/store_repository.dart';

import 'di.dart';

class StoreProvider extends ChangeNotifier {
  FullStoreDataModel? _fullStoreData; // Tipo correto para os dados completos
  bool _isLoading = false;
  String? _errorMessage;

  FullStoreDataModel? get fullStoreData => _fullStoreData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final StoreRepository _storeRepository = getIt<StoreRepository>();

  Future<void> fetchFullStoreData(int storeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _storeRepository.getFullStore(storeId);

    print('Resultado da busca de dados completos da loja ($storeId): $result'); // Adicione este log

    if (result.isRight) {
      _fullStoreData = result.right;
      print('Dados completos da loja carregados: ${_fullStoreData?.paymentMethods}'); // Adicione este log
    } else {
      _errorMessage = result.left;
      _fullStoreData = null;
      print('Erro ao buscar dados completos da loja ($storeId): $_errorMessage'); // Adicione este log
    }
    _isLoading = false;
    notifyListeners();
  }
  void clearStoreData() {
    _fullStoreData = null;
    notifyListeners();
  }
}