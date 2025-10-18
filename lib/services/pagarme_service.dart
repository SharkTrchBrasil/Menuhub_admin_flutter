import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/pagar_me_config.dart';

class PagarmeService {
  static const String _publicKey = PagarmeConfig.publicKey;
  static const String _apiUrl = PagarmeConfig.apiUrl;

  final Dio _dio;

  PagarmeService({Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: _apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      )) {
    debugPrint('═' * 60);
    debugPrint('🔧 [PagarmeService] Inicializado');
    debugPrint('   Public Key: $_publicKey');
    debugPrint('   API URL: $_apiUrl');
    debugPrint('   Ambiente: ${PagarmeConfig.environment}');
    debugPrint('═' * 60);
  }

  /// Tokeniza um cartão de crédito via API Pagar.me
  ///
  /// Retorna [PagarmeTokenResult] com token, máscara e bandeira
  /// ou lança [PagarmeException] em caso de erro
  Future<PagarmeTokenResult> tokenizeCard({
    required String cardNumber,
    required String holderName,
    required String expirationMonth,
    required String expirationYear,
    required String cvv,
  }) async {
    try {
      debugPrint('🔐 [PagarmeService] Iniciando tokenização...');

// Remove espaços e caracteres especiais
      final cleanNumber = cardNumber.replaceAll(RegExp(r'\s+'), '');

      debugPrint(
          '   Número limpo: ${cleanNumber.substring(0, 4)}...${cleanNumber
              .substring(cleanNumber.length - 4)}');
      debugPrint('   Tamanho: ${cleanNumber.length}');
      debugPrint('   Bandeira detectada: ${_detectBrand(cleanNumber)}');

// ═══════════════════════════════════════════════════════════
// VALIDAÇÕES
// ═══════════════════════════════════════════════════════════

      if (cleanNumber.length < 13 || cleanNumber.length > 19) {
        throw PagarmeException('Número do cartão inválido');
      }

      if (cvv.length < 3 || cvv.length > 4) {
        throw PagarmeException('CVV inválido');
      }

      if (holderName
          .trim()
          .isEmpty) {
        throw PagarmeException('Nome do titular é obrigatório');
      }

// ═══════════════════════════════════════════════════════════
// MONTA PAYLOAD
// ═══════════════════════════════════════════════════════════

      final payload = {
        'type': 'card',
        'card': {
          'number': cleanNumber,
          'holder_name': holderName.toUpperCase(),
          'exp_month': int.parse(expirationMonth),
          'exp_year': int.parse(expirationYear),
          'cvv': cvv,
        }
      };

      debugPrint('📤 [PagarmeService] Enviando para API Pagar.me...');
      debugPrint('   URL: $_apiUrl/tokens?appId=$_publicKey');

// ═══════════════════════════════════════════════════════════
// ENVIA REQUISIÇÃO
// ═══════════════════════════════════════════════════════════

      final response = await _dio.post(
        '/tokens',
        queryParameters: {'appId': _publicKey},
        data: payload,
      );

      debugPrint('📥 [PagarmeService] Resposta recebida');
      debugPrint('   Status: ${response.statusCode}');

// ═══════════════════════════════════════════════════════════
// PROCESSA RESPOSTA
// ═══════════════════════════════════════════════════════════

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        debugPrint('✅ [PagarmeService] Token gerado com sucesso!');
        debugPrint('   Token: ${data['id']}');

        return PagarmeTokenResult(
          token: data['id'] as String,
          cardMask: _maskCardNumber(cleanNumber),
          brand: _detectBrand(cleanNumber),
        );
      } else {
        final errorMessage = response.data['message'] ?? 'Erro ao gerar token';
        debugPrint(
            '❌ [PagarmeService] Erro ${response.statusCode}: $errorMessage');
        throw PagarmeException(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('❌ [PagarmeService] DioException:');
      debugPrint('   Tipo: ${e.type}');
      debugPrint('   Mensagem: ${e.message}');
      debugPrint('   Status Code: ${e.response?.statusCode}');
      debugPrint('   Response: ${e.response?.data}');

      if (e.response?.data != null) {
        final errorData = e.response!.data;
        final message = errorData['message'] ??
            errorData['errors']?[0]?['message'] ??
            'Erro de comunicação';
        throw PagarmeException(message);
      }

      throw PagarmeException('Falha na conexão. Verifique sua internet.');
    } catch (e) {
      debugPrint('❌ [PagarmeService] Erro inesperado: $e');
      throw PagarmeException('Erro inesperado ao validar cartão');
    }
  }

  /// Detecta a bandeira do cartão pelo número
  String _detectBrand(String number) {
    final clean = number.replaceAll(RegExp(r'\s+'), '');

    if (RegExp(r'^4').hasMatch(clean)) return 'Visa';
    if (RegExp(r'^5[1-5]').hasMatch(clean)) return 'Mastercard';
    if (RegExp(r'^3[47]').hasMatch(clean)) return 'Amex';
    if (RegExp(r'^6(?:011|5)').hasMatch(clean)) return 'Discover';
    if (RegExp(r'^38|^60|^36').hasMatch(clean)) return 'Diners';
    if (RegExp(r'^35').hasMatch(clean)) return 'JCB';
    if (RegExp(r'^4011|^4312|^4389|^4514|^4576|^5067|^6277|^6362|^6363')
        .hasMatch(clean)) return 'Elo';
    if (RegExp(r'^606282').hasMatch(clean)) return 'Hipercard';

    return 'Desconhecida';
  }

  /// ✅ CORREÇÃO FINAL: Mascara o número do cartão
  ///
  /// Retorna sempre no formato: ************1234
  /// (12 asteriscos + 4 dígitos finais)
  String _maskCardNumber(String number) {
    if (number.length < 4) return '****';

    final lastFour = number.substring(number.length - 4);
    return '${'*' * 12}$lastFour';
  }
}

/// Resultado da tokenização
class PagarmeTokenResult {
  final String token;
  final String cardMask;
  final String brand;

  PagarmeTokenResult({
    required this.token,
    required this.cardMask,
    required this.brand,
  });

  @override
  String toString() =>
      'PagarmeTokenResult(token: ${token.substring(
          0, 10)}..., cardMask: $cardMask, brand: $brand)';
}

/// Exceção customizada para erros do Pagar.me
class PagarmeException implements Exception {
  final String message;

  PagarmeException(this.message);

  @override
  String toString() => message;
}