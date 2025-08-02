// ARQUIVO: lib/repositories/payment_method_repository.dart (renomeado para clareza)

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show debugPrint;

// Importe os novos models que criamos
import '../models/payment_method.dart';

class PaymentMethodRepository {
  PaymentMethodRepository(this._dio);
  final Dio _dio;

  /*────────────────  1. BUSCAR TODA A CONFIGURAÇÃO DE PAGAMENTOS  ────────────────*/
  /// Busca a lista completa de métodos de pagamento da plataforma,
  /// já com as ativações e configurações da loja aninhadas.
  Future<Either<String, List<PaymentMethodGroup>>> getPaymentMethodsForStore(
      int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/payment-methods');

      // Converte a resposta (uma lista de JSONs) em uma lista de objetos PaymentMethodGroup
      return Right(
        (response.data as List)
            .map<PaymentMethodGroup>((e) => PaymentMethodGroup.fromJson(e))
            .toList(),
      );
    } catch (e) {
      debugPrint('Erro ao buscar métodos de pagamento: $e');
      return Left('Não foi possível carregar as formas de pagamento.');
    }
  }

  /*────────────────  2. ATIVAR / DESATIVAR / CONFIGURAR UM MÉTODO  ────────────────*/
  /// Atualiza a ativação de um método de pagamento específico para uma loja.
  /// O backend cuida de criar a ativação se ela não existir (lógica "upsert").
  Future<Either<String, StorePaymentMethodActivation>> updateActivation({
    required int storeId,
    required int platformMethodId,
    required StorePaymentMethodActivation activation,
  }) async {
    try {
      final response = await _dio.patch(
        '/stores/$storeId/payment-methods/$platformMethodId/activation',
        data: activation.toJson(), // Usa o método que acabamos de criar
      );

      // Retorna a ativação atualizada que o servidor enviou de volta
      return Right(StorePaymentMethodActivation.fromJson(response.data));
    } catch (e) {
      debugPrint('Erro ao atualizar ativação de pagamento: $e');
      return Left('Não foi possível salvar a configuração.');
    }
  }
}