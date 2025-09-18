// lib/services/connectivity_service.dart

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // 1. Usamos um StreamController para gerenciar nosso próprio stream.
  //    O '.broadcast()' permite que ele tenha múltiplos ouvintes (como o .share() faria).
  final StreamController<ConnectivityResult> _controller = StreamController<ConnectivityResult>.broadcast();

  // 2. Expomos publicamente apenas a "parte de escuta" (a Stream) do nosso controller.
  Stream<ConnectivityResult> get onConnectivityChanged => _controller.stream;

  ConnectivityService() {
    // 3. No construtor, começamos a ouvir o stream original do pacote.
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // 4. Para cada lista de resultados que o pacote nos envia...
      if (results.isNotEmpty) {
        // ...pegamos o primeiro e mais relevante resultado...
        final primaryResult = results.first;
        // ...e o adicionamos ao nosso próprio stream, que é do tipo correto.
        _controller.add(primaryResult);
      }
    });
  }

  // É uma boa prática adicionar um método para fechar o controller quando o serviço não for mais necessário.
  void dispose() {
    _controller.close();
  }
}