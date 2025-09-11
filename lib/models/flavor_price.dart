import 'package:equatable/equatable.dart';

/// Representa a relação de preço entre um "sabor" (Product)
/// e um "tamanho" (OptionItem).
///
/// Esta classe é a ponte que permite que um mesmo sabor tenha
/// preços diferentes para cada tamanho disponível na categoria.
class FlavorPrice extends Equatable {
  final int? id;         // O ID do registro no banco de dados (nulo ao criar)
  final int sizeOptionId; // O ID do OptionItem que representa o tamanho
  final int price;        // O preço do sabor para este tamanho, em centavos
  final String? posCode;    // ✅ NOVO: Código para integração com o Ponto de Venda (PDV)
  final bool isAvailable; // ✅ NOVO: Status de disponibilidade (ativo/inativo)

  const FlavorPrice({
    this.id,
    required this.sizeOptionId,
    required this.price,
    this.posCode,            // ✅ NOVO
    this.isAvailable = true, // ✅ NOVO (com valor padrão)
  });

  @override
  List<Object?> get props => [id, sizeOptionId, price, posCode, isAvailable]; // ✅ NOVO

  /// Cria uma cópia do objeto, permitindo a alteração de campos específicos.
  /// Essencial para a atualização de estado imutável no CUBIT.
  FlavorPrice copyWith({
    int? id,
    int? sizeOptionId,
    int? price,
    String? posCode,     // ✅ NOVO
    bool? isAvailable,   // ✅ NOVO
  }) {
    return FlavorPrice(
      id: id ?? this.id,
      sizeOptionId: sizeOptionId ?? this.sizeOptionId,
      price: price ?? this.price,
      posCode: posCode ?? this.posCode,         // ✅ NOVO
      isAvailable: isAvailable ?? this.isAvailable, // ✅ NOVO
    );
  }

  /// Constrói um objeto `FlavorPrice` a partir de um mapa JSON vindo da API.
  factory FlavorPrice.fromJson(Map<String, dynamic> json) {
    return FlavorPrice(
      id: json['id'],
      sizeOptionId: json['size_option_id'],
      price: json['price'],
      posCode: json['pos_code'],                  // ✅ NOVO
      isAvailable: json['is_available'] ?? true, // ✅ NOVO (com fallback)
    );
  }

  /// Converte o objeto `FlavorPrice` em um mapa JSON para ser enviado à API.
  /// Usado na criação/atualização do sabor, dentro da lista `prices`.
  Map<String, dynamic> toJson() {
    return {
      'size_option_id': sizeOptionId,
      'price': price,
      'pos_code': posCode,         // ✅ NOVO
      'is_available': isAvailable, // ✅ NOVO
    };
  }
}