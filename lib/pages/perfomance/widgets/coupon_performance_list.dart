import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/performance_data.dart';

class CouponPerformanceList extends StatelessWidget {
  final List<CouponPerformance> coupons;
  const CouponPerformanceList({super.key, required this.coupons});

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Desempenho dos Cupons", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (coupons.isEmpty)
              const Text("Nenhum cupom utilizado neste dia.")
            else
              ...coupons.map((coupon) => ListTile(
                title: Text(coupon.couponCode, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${coupon.timesUsed}x usado | Desconto: ${_formatCurrency(coupon.totalDiscount)}"),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Receita Gerada", style: Theme.of(context).textTheme.bodySmall),
                    Text(_formatCurrency(coupon.revenueGenerated), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }
}