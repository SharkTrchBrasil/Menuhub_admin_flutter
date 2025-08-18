// dentro de 'dashboard_widgets.dart'

import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:totem_pro_admin/models/dashboard_data.dart'; // Importe seu arquivo de modelos!
import 'package:flutter/material.dart';

import '../../../ConstData/colorfile.dart';
import '../../../ConstData/colorprovider.dart';
import '../../../ConstData/typography.dart';
class TopItemCard extends StatelessWidget {
  // ALTERADO: Agora recebe um objeto do seu modelo real `TopItem`
  final TopItem product;
  final ColorNotifire notifire;

  const TopItemCard({
    super.key,
    required this.product, // Alterado aqui
    required this.notifire,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16), // Um pouco menos de padding para caber melhor
      decoration: BoxDecoration(
          color: notifire.getGry50_800Color,
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround, // Melhora a distribuição
        children: [
          // --- SEÇÃO DO TÍTULO (PRODUTO) ---
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.transparent,
              // Usando um ícone de placeholder, já que não temos URL da imagem
              child: Icon(Icons.inventory_2_outlined),
            ),
            title: Text(
              product.name, // <- DADO REAL
              style: Typographyy.bodyLargeExtraBold.copyWith(color: notifire.getTextColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // --- SEÇÃO DE MÉTRICAS ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                _buildMetricRow(
                  context,
                  title: "Faturamento",
                  value: product.revenue.toCurrencyString(leadingSymbol: 'R\$ '), // <- DADO REAL
                  valueColor: notifire.getTextColor,
                ),
                const SizedBox(height: 12),
                _buildMetricRow(
                  context,
                  title: "Vendas",
                  value: product.count.toString(), // <- DADO REAL
                  valueColor: notifire.getTextColor,
                ),
              ],
            ),
          ),

          // --- SEÇÃO DE BOTÃO ---
          OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: priMeryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {},
              child: Text(
                "Ver Detalhes",
                style: Typographyy.bodyMediumExtraBold.copyWith(color: priMeryColor),
              )),
        ],
      ),
    );
  }

  // Widget auxiliar (sem alterações)
  Widget _buildMetricRow(BuildContext context, {required String title, required String value, required Color valueColor}) {
    return Row(
      children: [
        Text(title, style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color)),
        const Spacer(),
        Text(value, style: Typographyy.bodyLargeSemiBold.copyWith(color: valueColor)),
      ],
    );
  }
}