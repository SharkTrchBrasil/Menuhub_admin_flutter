// lib/models/paginated_response.dart

class PaginatedResponse<T> {
  /// A lista de itens para a página atual. O tipo <T> será definido
  /// no momento do uso (ex: List<OrderDetails>).
  final List<T> items;

  /// O número total de itens que correspondem à consulta,
  /// em todas as páginas.
  final int totalItems;

  /// O número total de páginas disponíveis.
  final int totalPages;

  /// O número da página atual (começando em 1).
  final int page;

  /// O número de itens por página.
  final int size;

  const PaginatedResponse({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.page,
    required this.size,
  });

  /// Construtor de fábrica para criar uma instância a partir de um JSON.
  ///
  /// Ele requer uma função `fromJsonT` que sabe como converter
  /// um único item do JSON para o tipo <T>.
  factory PaginatedResponse.fromJson(
      Map<String, dynamic> json,
      T Function(dynamic jsonItem) fromJsonT,
      ) {
    // Pega a lista de 'items' do JSON
    final itemsJson = json['items'] as List<dynamic>;

    // Usa a função 'fromJsonT' para converter cada item da lista
    final itemsList = itemsJson.map((item) => fromJsonT(item)).toList();

    return PaginatedResponse<T>(
      items: itemsList,
      totalItems: json['total_items'],
      totalPages: json['total_pages'],
      page: json['page'],
      size: json['size'],
    );
  }
}