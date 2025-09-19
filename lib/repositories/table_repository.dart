// repositories/table_repository.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class TableRepository {
  final String _baseUrl = "https://sua-api.com/api"; // Coloque sua URL base aqui

  Future<void> addItemToTable({
    required int tableId,
    required int storeId,
    required int productId,
    required int quantity,
    String? notes,
  }) async {
    final url = Uri.parse('$_baseUrl/tables/$tableId/items');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Adicione seu token de autenticação aqui
        // 'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'product_id': productId,
        'quantity': quantity,
        'notes': notes,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      // O ideal é tratar o erro de forma mais específica
      throw Exception('Falha ao adicionar item à mesa.');
    }
  }
}