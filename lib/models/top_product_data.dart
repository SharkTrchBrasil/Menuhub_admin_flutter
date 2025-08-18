// Você pode colocar esta classe em um arquivo de modelos, ex: 'models/top_product.dart'

class TopProductData {
  final String name;
  final String? category; // Opcional, pode ser a categoria do produto
  final String imageUrl;
  final double totalRevenue;
  final int unitsSold;
  final double changePercentage; // Para a % de crescimento/queda
  final bool isUp; // Para saber se a % é positiva ou negativa

  TopProductData({
    required this.name,
    this.category,
    required this.imageUrl,
    required this.totalRevenue,
    required this.unitsSold,
    required this.changePercentage,
    required this.isUp,
  });
}