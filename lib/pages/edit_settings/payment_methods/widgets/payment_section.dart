import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../ConstData/colorfile.dart';
import '../../../../ConstData/typography.dart';
import '../../../../models/performance_data.dart';

class PaymentSection extends StatefulWidget {

  const PaymentSection({super.key,  required this.paymentData});


  final List<PaymentMethodSummary> paymentData;

  @override
  State<PaymentSection> createState() => _PaymentSectionState();
}

class _PaymentSectionState extends State<PaymentSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: notifire.getGry50_800Color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Formas de Pagamento",
            style: Typographyy.heading5.copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(height: 16),
          ...widget.paymentData.map(
                (p) =>
                ListTile(
                  // ✅ 1. Ícone à esquerda
                  leading: buildPaymentIcon(p.methodIcon),

                  // ✅ 2. Título principal com o nome do método
                  title: Text(
                    p.methodName,
                    style: TextStyle(

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // ✅ 3. Subtítulo com a contagem de vendas
                  subtitle: Text(
                    '${p.transactionCount} vendas',
                    style: TextStyle(),
                  ),

                  // ✅ 4. Valor total à direita
                  trailing: Text(
                    _formatCurrency(p.totalValue),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  dense: true, // Opcional: Deixa o ListTile um pouco mais compacto
                ),
          ),
        ],
      ),
    );
  }

  Widget buildPaymentIcon(String? iconKey) {
    if (iconKey != null && iconKey.isNotEmpty) {
      final String assetPath = 'assets/icons/$iconKey';

      return SizedBox(
        width: 24,

        height: 24,

        child: SvgPicture.asset(
          assetPath,

          placeholderBuilder: (context) => Icon(Icons.credit_card, size: 24),
        ),
      );
    }

    return Icon(Icons.payment, size: 24);
  }

  // Helper para formatar moeda
  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }
}