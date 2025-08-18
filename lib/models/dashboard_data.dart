import 'package:equatable/equatable.dart';

// ===================================================================
// CLASSE PRINCIPAL
// ===================================================================
class DashboardData extends Equatable {
  final DashboardKpi kpis;
  final List<SalesDataPoint> salesOverTime; // Para o gráfico de estatísticas
  final List<TopItem> topProducts;
  final List<TopItem> topCategories;
  final List<PaymentMethodSummary> paymentMethods; // NOVO
  final List<UserCard> userCards;                 // NOVO
  final List<CurrencyBalance> currencyBalances;

// NOVO

  const DashboardData({
    required this.kpis,
    required this.salesOverTime,
    required this.topProducts,
    required this.topCategories,
    required this.paymentMethods,
    required this.userCards,
    required this.currencyBalances,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      kpis: DashboardKpi.fromJson(json['kpis']),
      salesOverTime: (json['sales_over_time'] as List)
          .map((item) => SalesDataPoint.fromJson(item))
          .toList(),
      topProducts: (json['top_products'] as List)
          .map((item) => TopItem.fromJson(item))
          .toList(),
      topCategories: (json['top_categories'] as List)
          .map((item) => TopItem.fromJson(item))
          .toList(),
      paymentMethods: (json['payment_methods'] as List)
          .map((item) => PaymentMethodSummary.fromJson(item))
          .toList(),
      userCards: (json['user_cards'] as List)
          .map((item) => UserCard.fromJson(item))
          .toList(),
      currencyBalances: (json['currency_balances'] as List)
          .map((item) => CurrencyBalance.fromJson(item))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
    kpis,
    salesOverTime,
    topProducts,
    topCategories,
    paymentMethods,
    userCards,
    currencyBalances,
  ];
}

// ===================================================================
// KPIs (INDICADORES CHAVE)
// ===================================================================
class DashboardKpi extends Equatable {
  final double totalRevenue;        // Total faturado na plataforma
  final int transactionCount;       // Total de vendas/pedidos no mês
  final double averageTicket;
  final int newCustomers;
  final double totalCashback;       // ADICIONADO: Total de cashback
  final double totalSpent;          // ADICIONADO: Total gasto
  final double revenueChangePercentage; // ADICIONADO: Variação da receita em %
  final bool revenueIsUp;           // ADICIONADO: Flag se a receita subiu ou caiu

  const DashboardKpi({
    required this.totalRevenue,
    required this.transactionCount,
    required this.averageTicket,
    required this.newCustomers,
    required this.totalCashback,
    required this.totalSpent,
    required this.revenueChangePercentage,
    required this.revenueIsUp,
  });

  factory DashboardKpi.fromJson(Map<String, dynamic> json) {
    return DashboardKpi(
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      transactionCount: json['transaction_count'],
      averageTicket: (json['average_ticket'] as num).toDouble(),
      newCustomers: json['new_customers'],
      totalCashback: (json['total_cashback'] as num).toDouble(),
      totalSpent: (json['total_spent'] as num).toDouble(),
      revenueChangePercentage: (json['revenue_change_percentage'] as num).toDouble(),
      revenueIsUp: json['revenue_is_up'],
    );
  }

  @override
  List<Object?> get props => [
    totalRevenue,
    transactionCount,
    averageTicket,
    newCustomers,
    totalCashback,
    totalSpent,
    revenueChangePercentage,
    revenueIsUp,
  ];
}

// ===================================================================
// DADOS PARA GRÁFICOS
// ===================================================================
class SalesDataPoint extends Equatable {
  final DateTime period; // Mudei para DateTime para mais flexibilidade
  final double revenue;  // Ganho naquele dia/período

  const SalesDataPoint({required this.period, required this.revenue});

  factory SalesDataPoint.fromJson(Map<String, dynamic> json) {
    return SalesDataPoint(
      period: DateTime.parse(json['period']),
      revenue: (json['revenue'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [period, revenue];
}

// ===================================================================
// ITENS DE LISTAS "TOP 5"
// ===================================================================
class TopItem extends Equatable {
  final String name;
  final int count;       // Quantidade de vendas
  final double revenue;  // MELHORIA: Receita gerada pelo item

  const TopItem({required this.name, required this.count, required this.revenue});

  factory TopItem.fromJson(Map<String, dynamic> json) {
    return TopItem(
      name: json['name'],
      count: json['count'],
      revenue: (json['revenue'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [name, count, revenue];
}

// ===================================================================
// NOVAS CLASSES PARA OS WIDGETS
// ===================================================================

// NOVO: Para a seção "Total por formas de pagamento"
class PaymentMethodSummary extends Equatable {
  final String methodName; // Ex: "Cartão de Crédito", "PIX"
  final double totalAmount;

  const PaymentMethodSummary({required this.methodName, required this.totalAmount});

  factory PaymentMethodSummary.fromJson(Map<String, dynamic> json) {
    return PaymentMethodSummary(
      methodName: json['method_name'],
      totalAmount: (json['total_amount'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [methodName, totalAmount];
}

// NOVO: Para a seção "Card Lists"
class UserCard extends Equatable {
  final String cardLastFourDigits;
  final String cardType; // Ex: "Visa", "Mastercard"
  final double balance;
  final String cardArtUrl; // URL para a imagem do cartão

  const UserCard({
    required this.cardLastFourDigits,
    required this.cardType,
    required this.balance,
    required this.cardArtUrl,
  });

  factory UserCard.fromJson(Map<String, dynamic> json) {
    return UserCard(
      cardLastFourDigits: json['card_last_four_digits'],
      cardType: json['card_type'],
      balance: (json['balance'] as num).toDouble(),
      cardArtUrl: json['card_art_url'],
    );
  }

  @override
  List<Object?> get props => [cardLastFourDigits, cardType, balance, cardArtUrl];
}

// NOVO: Para a seção "Currency"
class CurrencyBalance extends Equatable {
  final String currencyCode; // Ex: "BRL", "USD", "EUR"
  final double amount;
  final String flagIconUrl; // URL para a imagem da bandeira

  const CurrencyBalance({
    required this.currencyCode,
    required this.amount,
    required this.flagIconUrl,
  });

  factory CurrencyBalance.fromJson(Map<String, dynamic> json) {
    return CurrencyBalance(
      currencyCode: json['currency_code'],
      amount: (json['amount'] as num).toDouble(),
      flagIconUrl: json['flag_icon_url'],
    );
  }




  @override
  List<Object?> get props => [currencyCode, amount, flagIconUrl];
}




// ===================================================================
// ITEM PARA PRODUTOS COM BAIXO GIRO
// ===================================================================
class LowTurnoverItem extends Equatable {
  final String name;
  final int daysSinceLastSale;
  final int stockQuantity;
  final String? imageUrl; // Opcional, para mostrar a foto do produto

  const LowTurnoverItem({
    required this.name,
    required this.daysSinceLastSale,
    required this.stockQuantity,
    this.imageUrl,
  });

  factory LowTurnoverItem.fromJson(Map<String, dynamic> json) {
    return LowTurnoverItem(
      name: json['name'],
      daysSinceLastSale: json['days_since_last_sale'],
      stockQuantity: json['stock_quantity'],
      imageUrl: json['image_url'],
    );
  }

  @override
  List<Object?> get props => [name, daysSinceLastSale, stockQuantity, imageUrl];
}