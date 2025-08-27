// lib/widgets/dashboard/total_orders_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TotalOrdersCard extends StatelessWidget {
  final int totalOrders;
  final double averageTicket;
  final double percentage; // Ex: 0.65 para 65%

  const TotalOrdersCard({
    super.key,
    required this.totalOrders,
    required this.averageTicket,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String displayOrders = totalOrders > 999
        ? '${(totalOrders / 1000).toStringAsFixed(1)}k'
        : totalOrders.toString();
    final currencyFormat =
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final String displayTicket = currencyFormat.format(averageTicket);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pedidos', style: theme.textTheme.titleMedium),
                const Icon(Icons.more_vert, size: 18, color: Colors.grey),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gráfico Radial
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: SfRadialGauge(
                      axes: <RadialAxis>[
                        RadialAxis(
                          minimum: 0,
                          maximum: 100,
                          showLabels: false,
                          showTicks: false,
                          startAngle: 270,
                          endAngle: 270,
                          radiusFactor: 0.9,
                          axisLineStyle: AxisLineStyle(
                            thickness: 0.15,
                            color: Colors.grey[200],
                            thicknessUnit: GaugeSizeUnit.factor,
                          ),
                          pointers: <GaugePointer>[
                            RangePointer(
                              value: percentage * 100,
                              width: 0.15,
                              color: Colors.redAccent,
                              sizeUnit: GaugeSizeUnit.factor,
                              enableAnimation: true,
                              cornerStyle: CornerStyle.bothCurve,
                            ),
                          ],
                          annotations: <GaugeAnnotation>[
                            GaugeAnnotation(
                              widget: Text(
                                '${(percentage * 100).toInt()}%',
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // ✅ KPI 1: Total de Pedidos
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        displayOrders,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                  // ✅ KPI 2: Ticket Médio
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        displayTicket,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Ticket Médio',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}