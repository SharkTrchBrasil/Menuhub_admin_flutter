import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class PaymentToken {
  static Future<dynamic> generate(Map card, dynamic config) async {
    final salt = await getTokenizer(config);
    card["salt"] = salt['data'];
    final key = await getKey(config);
    final encrypted = await encryptData(key['data'], json.encode(card));
    final result = await saveCard({'data': encrypted}, config);
    return result['data'];
  }

  static Future<dynamic> saveCard(dynamic body, dynamic config) async {
    String url = config["sandbox"]
        ? "https://sandbox.gerencianet.com.br/v1/card"
        : "https://tokenizer.gerencianet.com.br/card";
    final headers = <String, String>{
      'account-code': config['accountId'],
      'Content-Type': 'application/json',
    };
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to save card: ${response.body}');
    }
  }

  static Future<dynamic> getTokenizer(dynamic config) async {
    String url = 'https://tokenizer.gerencianet.com.br/salt';
    final headers = <String, String>{
      'account-code': config['accountId'],
    };
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get tokenizer: ${response.body}');
    }
  }

  static Future<dynamic> getKey(dynamic config) async {
    String url = '${config["sandbox"]
        ? "https://sandbox.gerencianet.com.br"
        : "https://api.gerencianet.com.br"}/v1/pubkey?code=${config["accountId"]}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get key: ${response.body} ${response.statusCode}');
    }
  }

  static Future<String> encryptData(String publicKeyString, String text) async {
    final parser = RSAKeyParser();
    final publicKey = parser.parse(publicKeyString) as RSAPublicKey;
    final encrypter = Encrypter(RSA(publicKey: publicKey));
    final encrypted = encrypter.encrypt(text);
    return encrypted.base64;
  }
}