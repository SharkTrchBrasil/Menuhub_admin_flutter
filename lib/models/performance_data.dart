// lib/models/performance_data.dart

class ComparativeMetric {
  final double current;
  final double previous;
  final double percentageChange;
  ComparativeMetric({required this.current, required this.previous, required this.percentageChange});
  factory ComparativeMetric.fromJson(Map<String, dynamic> json) => ComparativeMetric(
    current: (json['current'] as num).toDouble(),
    previous: (json['previous'] as num).toDouble(),
    percentageChange: (json['percentageChange'] as num).toDouble(),
  );
}

class DailySummary {
  final ComparativeMetric completedSales;
  final ComparativeMetric totalValue;
  final ComparativeMetric averageTicket;
  DailySummary({required this.completedSales, required this.totalValue, required this.averageTicket});
  factory DailySummary.fromJson(Map<String, dynamic> json) => DailySummary(
    completedSales: ComparativeMetric.fromJson(json['completedSales']),
    totalValue: ComparativeMetric.fromJson(json['totalValue']),
    averageTicket: ComparativeMetric.fromJson(json['averageTicket']),
  );
}

class CustomerAnalytics {
  final ComparativeMetric newCustomers;
  final ComparativeMetric returningCustomers;
  CustomerAnalytics({required this.newCustomers, required this.returningCustomers});
  factory CustomerAnalytics.fromJson(Map<String, dynamic> json) => CustomerAnalytics(
    newCustomers: ComparativeMetric.fromJson(json['newCustomers']),
    returningCustomers: ComparativeMetric.fromJson(json['returningCustomers']),
  );
}

class OrderStatusCounts {
  final int concluidos;
  final int cancelados;
  final int pendentes;
  OrderStatusCounts({required this.concluidos, required this.cancelados, required this.pendentes});
  factory OrderStatusCounts.fromJson(Map<String, dynamic> json) => OrderStatusCounts(
    concluidos: json['concluidos'],
    cancelados: json['cancelados'],
    pendentes: json['pendentes'],
  );
}

class SalesByHour {
  final int hour;
  final double totalValue;
  SalesByHour({required this.hour, required this.totalValue});
  factory SalesByHour.fromJson(Map<String, dynamic> json) => SalesByHour(
    hour: json['hour'],
    totalValue: (json['totalValue'] as num).toDouble(),
  );
}

class PaymentMethodSummary {
  final String methodName;
  final String? methodIcon; // Ícone pode ser nulo
  final double totalValue;
  final int transactionCount;
  PaymentMethodSummary({required this.methodName, this.methodIcon, required this.totalValue, required this.transactionCount});
  factory PaymentMethodSummary.fromJson(Map<String, dynamic> json) => PaymentMethodSummary(
    methodName: json['method_name'],
    methodIcon: json['method_icon'],
    totalValue: (json['total_value'] as num).toDouble(),
    transactionCount: json['transaction_count'],
  );
}

class TopSellingProduct {
  final int productId;
  final String productName;
  final int quantitySold;
  final double totalValue;
  TopSellingProduct({required this.productId, required this.productName, required this.quantitySold, required this.totalValue});
  factory TopSellingProduct.fromJson(Map<String, dynamic> json) => TopSellingProduct(
    productId: json['product_id'],
    productName: json['product_name'],
    quantitySold: json['quantity_sold'],
    totalValue: (json['total_value'] as num).toDouble(),
  );
}

class TopAddon {
  final String addonName;
  final int quantitySold;
  final double totalValue;
  TopAddon({required this.addonName, required this.quantitySold, required this.totalValue});
  factory TopAddon.fromJson(Map<String, dynamic> json) => TopAddon(
    addonName: json['addon_name'],
    quantitySold: json['quantity_sold'],
    totalValue: (json['total_value'] as num).toDouble(),
  );
}

class CouponPerformance {
  final String couponCode;
  final int timesUsed;
  final double totalDiscount;
  final double revenueGenerated;
  CouponPerformance({required this.couponCode, required this.timesUsed, required this.totalDiscount, required this.revenueGenerated});
  factory CouponPerformance.fromJson(Map<String, dynamic> json) => CouponPerformance(
    couponCode: json['coupon_code'],
    timesUsed: json['times_used'],
    totalDiscount: (json['total_discount'] as num).toDouble(),
    revenueGenerated: (json['revenue_generated'] as num).toDouble(),
  );
}

class CategoryPerformance {
  final int categoryId;
  final String categoryName;
  final double totalValue;
  final double grossProfit;
  final int itemsSold;
  CategoryPerformance({required this.categoryId, required this.categoryName, required this.totalValue, required this.grossProfit, required this.itemsSold});
  factory CategoryPerformance.fromJson(Map<String, dynamic> json) => CategoryPerformance(
    categoryId: json['category_id'],
    categoryName: json['category_name'],
    totalValue: (json['total_value'] as num).toDouble(),
    grossProfit: (json['gross_profit'] as num).toDouble(),
    itemsSold: json['items_sold'],
  );
}

class ProductFunnel {
  final int productId;
  final String productName;
  final int viewCount;
  final int salesCount;
  final int quantitySold;
  final double conversionRate;
  ProductFunnel({required this.productId, required this.productName, required this.viewCount, required this.salesCount, required this.quantitySold, required this.conversionRate});
  factory ProductFunnel.fromJson(Map<String, dynamic> json) => ProductFunnel(
    productId: json['product_id'],
    productName: json['product_name'],
    viewCount: json['view_count'],
    salesCount: json['sales_count'],
    quantitySold: json['quantity_sold'],
    conversionRate: (json['conversion_rate'] as num).toDouble(),
  );
}


class DailyTrendPoint {
  final DateTime date;
  final int salesCount;
  final double totalValue;
  final double averageTicket;
  final int newCustomers;

  DailyTrendPoint({
    required this.date,
    required this.salesCount,
    required this.totalValue,
    required this.averageTicket,
    required this.newCustomers,
  });


  factory DailyTrendPoint.fromJson(Map<String, dynamic> json) {
    return DailyTrendPoint(
      // A API envia a data como uma string (ex: "2025-08-23"),
      // então precisamos convertê-la para um objeto DateTime.
      date: DateTime.parse(json['date']),

      salesCount: json['sales_count'],
      totalValue: (json['total_value'] as num).toDouble(),
      averageTicket: (json['average_ticket'] as num).toDouble(),
      newCustomers: json['new_customers'],
    );
  }
}

class StorePerformance {
  final DateTime queryDate;
  final DateTime comparisonDate;
  final DailySummary summary;
  final ComparativeMetric grossProfit;
  final CustomerAnalytics customerAnalytics;
  final OrderStatusCounts orderStatusCounts;
  final List<SalesByHour> salesByHour;
  final List<PaymentMethodSummary> paymentMethods;
  final List<TopSellingProduct> topSellingProducts;
  final List<TopAddon> topSellingAddons;
  final List<CouponPerformance> couponPerformance;
  final List<CategoryPerformance> categoryPerformance;
  final List<ProductFunnel> productFunnel;
  final List<DailyTrendPoint> dailyTrend;


  StorePerformance({
    required this.queryDate,
    required this.comparisonDate,
    required this.summary,
    required this.grossProfit,
    required this.customerAnalytics,
    required this.orderStatusCounts,
    required this.salesByHour,
    required this.paymentMethods,
    required this.topSellingProducts,
    required this.topSellingAddons,
    required this.couponPerformance,
    required this.categoryPerformance,
    required this.productFunnel,
    required this.dailyTrend
  });

  factory StorePerformance.fromJson(Map<String, dynamic> json) => StorePerformance(
    queryDate: DateTime.parse(json['queryDate']),
    comparisonDate: DateTime.parse(json['comparisonDate']),
    summary: DailySummary.fromJson(json['summary']),
    grossProfit: ComparativeMetric.fromJson(json['grossProfit']),
    customerAnalytics: CustomerAnalytics.fromJson(json['customerAnalytics']),
    orderStatusCounts: OrderStatusCounts.fromJson(json['orderStatusCounts']),
    salesByHour: (json['salesByHour'] as List).map((i) => SalesByHour.fromJson(i)).toList(),
    paymentMethods: (json['paymentMethods'] as List).map((i) => PaymentMethodSummary.fromJson(i)).toList(),
    topSellingProducts: (json['topSellingProducts'] as List).map((i) => TopSellingProduct.fromJson(i)).toList(),
    topSellingAddons: (json['topSellingAddons'] as List).map((i) => TopAddon.fromJson(i)).toList(),
    couponPerformance: (json['couponPerformance'] as List).map((i) => CouponPerformance.fromJson(i)).toList(),
    categoryPerformance: (json['categoryPerformance'] as List).map((i) => CategoryPerformance.fromJson(i)).toList(),
    productFunnel: (json['productFunnel'] as List).map((i) => ProductFunnel.fromJson(i)).toList(),
    dailyTrend: (json['dailyTrend'] as List).map((i) => DailyTrendPoint.fromJson(i)).toList(),
  );
}