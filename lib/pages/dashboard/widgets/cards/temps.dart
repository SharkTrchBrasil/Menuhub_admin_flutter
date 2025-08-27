import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';


class DashboardScreen1 extends StatelessWidget {
  const DashboardScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F7),
      appBar: AppBar(
        title: const Text('Dashboard Completo'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Primeira linha com 3 cards
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  [
                      Expanded(child: AcmePlusCard()),
                     SizedBox(width: 16),
                     Expanded(child: AcmeAdvancedCard()),
                     SizedBox(width: 16),
                     Expanded(child: AcmeProfessionalCard()),
                    //  SizedBox(width: 16),
                    //  Expanded(child: OrdersStatisticsCard()),
                    //  const SizedBox(height: 16),
                   //   Expanded(child: StatisticsCard()),
                    ],
                  );
                } else if (constraints.maxWidth > 600) {
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Expanded(child: AcmePlusCard()),
                          SizedBox(width: 16),
                          Expanded(child: AcmeAdvancedCard()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const AcmeProfessionalCard(),
                    ],
                  );
                } else {
                  return Column(
                    children: const [
                      AcmePlusCard(),
                      SizedBox(height: 16),
                      AcmeAdvancedCard(),
                      SizedBox(height: 16),
                      AcmeProfessionalCard(),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // Segunda linha com 2 cards
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(flex: 2, child: DirectVsIndirectCard()),
                      SizedBox(width: 16),
                      Expanded(flex: 1, child: RealTimeValueCard()),
                    ],
                  );
                } else {
                  return Column(
                    children: const [
                      DirectVsIndirectCard(),
                      SizedBox(height: 16),
                      RealTimeValueCard(),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // Terceira linha com 2 cards
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(flex: 1, child: TopCountriesCard()),
                      SizedBox(width: 16),
                      Expanded(flex: 2, child: TopChannelsTable()),
                    ],
                  );
                } else {
                  return Column(
                    children: const [
                      TopCountriesCard(),
                      SizedBox(height: 16),
                      TopChannelsTable(),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // Quarta linha com 2 cards
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(child: SalesOverTimeCard()),
                      SizedBox(width: 16),
                      Expanded(child: SalesVsRefundsCard()),
                    ],
                  );
                } else {
                  return Column(
                    children: const [
                      SalesOverTimeCard(),
                      SizedBox(height: 16),
                      SalesVsRefundsCard(),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // Quinta linha com 2 cards
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(child: RecentActivityCard()),
                      SizedBox(width: 16),
                      Expanded(child: IncomeExpensesCard()),
                    ],
                  );
                } else {
                  return Column(
                    children: const [
                      RecentActivityCard(),
                      SizedBox(height: 16),
                      IncomeExpensesCard(),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Componentes do Dashboard

class AcmePlusCard extends StatelessWidget {
  const AcmePlusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Acme Plus',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(value: 'Option 1', child: Text('Option 1')),
                    const PopupMenuItem(value: 'Option 2', child: Text('Option 2')),
                    const PopupMenuItem(value: 'Remove', child: Text('Remove')),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Text(
              'Sales',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),
            Row(
              children: const [
                Text(
                  '\$24,780',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                BadgeWidget(percent: 49, isPositive: true),
              ],
            ),

            const SizedBox(height: 16),
            // Gráfico de linha simplificado
            SizedBox(
              height: 100,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(isVisible: false),
                primaryYAxis: NumericAxis(isVisible: false),
                series: <CartesianSeries<SalesData, String>>[
                  LineSeries<SalesData, String>(
                    dataSource: [
                      SalesData('Jan', 10),
                      SalesData('Feb', 35),
                      SalesData('Mar', 25),
                      SalesData('Apr', 50),
                      SalesData('May', 40),
                      SalesData('Jun', 65),
                    ],
                    xValueMapper: (SalesData sales, _) => sales.month,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    color: Colors.blue,
                    width: 2,
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

class AcmeAdvancedCard extends StatelessWidget {
  const AcmeAdvancedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Acme Advanced',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(value: 'Option 1', child: Text('Option 1')),
                    const PopupMenuItem(value: 'Option 2', child: Text('Option 2')),
                    const PopupMenuItem(value: 'Remove', child: Text('Remove')),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Text(
              'Sales',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),
            Row(
              children: const [
                Text(
                  '\$17,489',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                BadgeWidget(percent: 14, isPositive: false),
              ],
            ),

            const SizedBox(height: 16),
            // Gráfico de linha simplificado
            SizedBox(
              height: 100,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(isVisible: false),
                primaryYAxis: NumericAxis(isVisible: false),
                series: <CartesianSeries<SalesData, String>>[
                  LineSeries<SalesData, String>(
                    dataSource: [
                      SalesData('Jan', 40),
                      SalesData('Feb', 35),
                      SalesData('Mar', 30),
                      SalesData('Apr', 25),
                      SalesData('May', 20),
                      SalesData('Jun', 15),
                    ],
                    xValueMapper: (SalesData sales, _) => sales.month,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    color: Colors.red,
                    width: 2,
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

class AcmeProfessionalCard extends StatelessWidget {
  const AcmeProfessionalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Acme Professional',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 18),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(value: 'Option 1', child: Text('Option 1')),
                    const PopupMenuItem(value: 'Option 2', child: Text('Option 2')),
                    const PopupMenuItem(value: 'Remove', child: Text('Remove')),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Text(
              'Sales',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 8),
            Row(
              children: const [
                Text(
                  '\$9,962',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                BadgeWidget(percent: 29, isPositive: true),
              ],
            ),

            const SizedBox(height: 16),
            // Gráfico de linha simplificado
            SizedBox(
              height: 100,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(isVisible: false),
                primaryYAxis: NumericAxis(isVisible: false),
                series: <CartesianSeries<SalesData, String>>[
                  LineSeries<SalesData, String>(
                    dataSource: [
                      SalesData('Jan', 15),
                      SalesData('Feb', 25),
                      SalesData('Mar', 20),
                      SalesData('Apr', 35),
                      SalesData('May', 30),
                      SalesData('Jun', 40),
                    ],
                    xValueMapper: (SalesData sales, _) => sales.month,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    color: Colors.green,
                    width: 2,
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

class DirectVsIndirectCard extends StatelessWidget {
  const DirectVsIndirectCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Direct VS Indirect',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),
            // Legenda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('\$8.25K', 'Direct', Colors.blue),
                _buildLegendItem('\$27.7K', 'Indirect', Colors.purple),
              ],
            ),

            const SizedBox(height: 16),
            // Gráfico de barras
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
                series: <CartesianSeries<SalesData, String>>[
                  ColumnSeries<SalesData, String>(
                    dataSource: [
                      SalesData('Direct', 8.25),
                      SalesData('Indirect', 27.7),
                    ],
                    xValueMapper: (SalesData sales, _) => sales.month,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    color: Colors.blue,
                    width: 0.3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String value, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class RealTimeValueCard extends StatelessWidget {
  const RealTimeValueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Real Time Value',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 18),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: const [
                Text(
                  '\$55.22',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                BadgeWidget(percent: 5.06, isPositive: false),
              ],
            ),

            const SizedBox(height: 16),
            // Gráfico de linha em tempo real
            SizedBox(
              height: 100,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(isVisible: false),
                primaryYAxis: NumericAxis(isVisible: false),
                series: <CartesianSeries<SalesData, String>>[
                  LineSeries<SalesData, String>(
                    dataSource: [
                      SalesData('1', 50),
                      SalesData('2', 52),
                      SalesData('3', 55),
                      SalesData('4', 53),
                      SalesData('5', 51),
                      SalesData('6', 55),
                    ],
                    xValueMapper: (SalesData sales, _) => sales.month,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    color: Colors.orange,
                    width: 2,
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

class TopCountriesCard extends StatelessWidget {
  const TopCountriesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Countries',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),
            // Gráfico de pizza
            SizedBox(
              height: 200,
              child: SfCircularChart(
                series: <CircularSeries<CountryData, String>>[
                  PieSeries<CountryData, String>(
                    dataSource: [
                      CountryData('United States', 45, const Color(0xFF8470FF)),
                      CountryData('Italy', 30, const Color(0xFF67BFFF)),
                      CountryData('Other', 25, const Color(0xFF4634B1)),
                    ],
                    xValueMapper: (CountryData data, _) => data.country,
                    yValueMapper: (CountryData data, _) => data.percentage,
                    pointColorMapper: (CountryData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            // Legenda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCountryLegend('United States', const Color(0xFF8470FF)),
                _buildCountryLegend('Italy', const Color(0xFF67BFFF)),
                _buildCountryLegend('Other', const Color(0xFF4634B1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryLegend(String country, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          country,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class TopChannelsTable extends StatelessWidget {
  const TopChannelsTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        child: Padding(
        padding: const EdgeInsets.all(16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    'Top Channels',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    ),
    ),

    const SizedBox(height: 16),
    // Tabela
    SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(
    columns: const [
    DataColumn(label: Text('Source')),
    DataColumn(label: Text('Visitors')),
    DataColumn(label: Text('Revenues')),
    DataColumn(label: Text('Sales')),
    DataColumn(label: Text('Conversion')),
    ],
    rows: const [
    DataRow(cells: [
    DataCell(Text('Github.com')),
    DataCell(Text('2.4K')),
    DataCell(Text('\$3,877')),
    DataCell(Text('267')),
    DataCell(Text('4.7%')),
    ]),
    DataRow(cells: [
    DataCell(Text('Facebook')),
    DataCell(Text('2.2K')),
    DataCell(Text('\$3,426')),
    DataCell(Text('249')),
    DataCell(Text('4.4%')),
    ]),
    DataRow(cells: [
    DataCell(Text('Google (organic)')),
    DataCell(Text('2.0K')),
    DataCell(Text('\$2,444')),
    DataCell(Text('224')),
    DataCell(Text('4.2%')),
    ]),
    DataRow(cells: [
    DataCell(Text('Vimeo.com')),
    DataCell(Text('1.9K')),
    DataCell(Text('\$2,236')),
    DataCell(Text('220')),
    DataCell(Text('4.2%')),
    ]),
    DataRow(cells: [
    DataCell(Text('Indiehackers.com')),
    DataCell(Text('1.7K')),
    DataCell(Text('\$2,034')),
    DataCell(Text('204')),
    DataCell(Text('3.9%')),
    ]),
    ],
    ),
    ),
    ],
    )));

  }
}

class SalesOverTimeCard extends StatelessWidget {
  const SalesOverTimeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sales Over Time (all stores)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: const [
                Text(
                  '\$1,482',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                BadgeWidget(percent: 22, isPositive: false),
              ],
            ),

            const SizedBox(height: 16),
            // Legenda
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChartLegend('Current', Colors.purple),
                _buildChartLegend('Previous', Colors.blue),
              ],
            ),

            const SizedBox(height: 16),
            // Gráfico de linha
            SizedBox(
              height: 150,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
                series: <CartesianSeries<SalesData, String>>[
                  LineSeries<SalesData, String>(
                    dataSource: [
                      SalesData('Jan', 10),
                      SalesData('Feb', 25),
                      SalesData('Mar', 15),
                      SalesData('Apr', 30),
                      SalesData('May', 20),
                      SalesData('Jun', 35),
                    ],
                    xValueMapper: (SalesData sales, _) => sales.month,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    color: Colors.purple,
                    width: 2,
                  ),
                  LineSeries<SalesData, String>(
                    dataSource: [
                      SalesData('Jan', 15),
                      SalesData('Feb', 20),
                      SalesData('Mar', 25),
                      SalesData('Apr', 20),
                      SalesData('May', 25),
                      SalesData('Jun', 30),
                    ],
                    xValueMapper: (SalesData sales, _) => sales.month,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    color: Colors.blue,
                    width: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class SalesVsRefundsCard extends StatelessWidget {
  const SalesVsRefundsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sales VS Refunds',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 18),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),
            Row(
              children: const [
                Text(
                  '+\$6,796',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                BadgeWidget(percent: 34, isPositive: false),
              ],
            ),

            const SizedBox(height: 16),
            // Gráfico de barras
            SizedBox(
              height: 150,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
                series: <CartesianSeries<SalesData, String>>[
                  ColumnSeries<SalesData, String>(
                    dataSource: [
                      SalesData('Sales', 67.96),
                      SalesData('Refunds', 20.0),
                    ],
                    xValueMapper: (SalesData sales, _) => sales.month,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    color: Colors.blue,
                    width: 0.3,
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

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),
            // Grupo "Today"
            const Text(
              'Today',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              'Nick Mark mentioned Sara Smith in a new post',
              Colors.blue,
              Icons.chat,
            ),
            _buildActivityItem(
              'The post Post Name was removed by Nick Mark',
              Colors.red,
              Icons.delete,
            ),
            _buildActivityItem(
              'Patrick Sullivan published a new post',
              Colors.green,
              Icons.publish,
            ),

            const SizedBox(height: 16),
            // Grupo "Yesterday"
            const Text(
              'Yesterday',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _buildActivityItem(
              '240+ users have subscribed to Newsletter #1',
              Colors.orange,
              Icons.subscriptions,
            ),
            _buildActivityItem(
              'The post Post Name was suspended by Nick Mark',
              Colors.blue,
              Icons.chat,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String text, Color color, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: const Text(
        'View',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class IncomeExpensesCard extends StatelessWidget {
  const IncomeExpensesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Income/Expenses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),
            // Grupo "Today"
            const Text(
              'Today',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            _buildTransactionItem('Qonto billing', '-\$49.88', Colors.red, Icons.arrow_back),
            _buildTransactionItem('Cruip.com Market Ltd', '+\$249.88', Colors.green, Icons.arrow_forward),
            _buildTransactionItem('Notion Labs Inc', '+\$99.99', Colors.green, Icons.arrow_forward),
            _buildTransactionItem('Market Cap Ltd', '+\$1,200.88', Colors.green, Icons.arrow_forward),
            _buildTransactionItem('App.com Market Ltd', '+\$99.99', Colors.grey, Icons.help),
            _buildTransactionItem('App.com Market Ltd', '-\$49.88', Colors.red, Icons.arrow_back),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String text, String amount, Color color, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: Text(
        amount,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


class OrdersStatisticsCard extends StatelessWidget {
  OrdersStatisticsCard({super.key});

  // Dados fictícios para o gráfico de pizza
  final List<PieData> pieData = [
    PieData('Direct', 65, const Color(0xFF5B69BC), 965, false),
    PieData('Social', 14, const Color(0xFFFF8ACC), 75, true),
    PieData('Marketing', 10, const Color(0xFF10C469), 102, true),
    PieData('Affiliates', 45, const Color(0xFF35B8E0), 96, false),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Orders Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Row(
                    children: [
                      Text('Refresh'),
                      SizedBox(width: 4),
                      Icon(Icons.refresh, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Gráfico de pizza
            SizedBox(
              height: 250,
              child: SfCircularChart(
                series: <CircularSeries>[
                  DoughnutSeries<PieData, String>(
                    dataSource: pieData,
                    xValueMapper: (PieData data, _) => data.category,
                    yValueMapper: (PieData data, _) => data.value,
                    pointColorMapper: (PieData data, _) => data.color,
                    innerRadius: '70%',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
              ),
            ),

            // Estatísticas detalhadas
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildStatItem(pieData[0]),
                      const SizedBox(height: 8),
                      _buildStatItem(pieData[1]),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildStatItem(pieData[2]),
                      const SizedBox(height: 8),
                      _buildStatItem(pieData[3]),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(PieData data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 12, color: data.color),
            const SizedBox(width: 4),
            Text(
              data.category,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Row(
          children: [
            Icon(
              data.isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
              color: data.isIncrease ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Text(
              data.count.toString(),
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StatisticsCard extends StatelessWidget {
  StatisticsCard({super.key});

  // Dados fictícios para o gráfico de barras
  final List<BarData> barData = [
    BarData('2019', 89.25),
    BarData('2020', 98.58),
    BarData('2021', 68.74),
    BarData('2022', 108.87),
    BarData('2023', 77.54),
    BarData('2024', 84.03),
    BarData('2025', 51.24),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(value: 'Sales Report', child: Text('Sales Report')),
                    const PopupMenuItem(value: 'Export Report', child: Text('Export Report')),
                    const PopupMenuItem(value: 'Profit', child: Text('Profit')),
                    const PopupMenuItem(value: 'Action', child: Text('Action')),
                  ],
                ),
              ],
            ),

            // Gráfico de barras
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 120,
                  interval: 20,
                ),
                series: <CartesianSeries<BarData, String>>[
                  ColumnSeries<BarData, String>(
                    dataSource: barData,
                    xValueMapper: (BarData sales, _) => sales.year,
                    yValueMapper: (BarData sales, _) => sales.value,
                    color: const Color(0xFF188AE2).withOpacity(0.85),
                    width: 0.6,
                  ),
                ],
              ),
            ),

            // Estatísticas de receita/despesas
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Revenue',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_downward, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          const Text(
                            '\$29.5k',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.grey[300]!), right: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Expenses',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_upward, size: 16, color: Colors.red),
                            const SizedBox(width: 4),
                            const Text(
                              '\$15.07k',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Profit',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_downward, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          const Text(
                            '\$71.5k',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TotalRevenueCard extends StatelessWidget {
  TotalRevenueCard({super.key});

  // Dados fictícios para o gráfico de linhas
  final List<RevenueData> revenueData = [
    RevenueData('Jan', 46.65, 181.43),
    RevenueData('Feb', 38.88, 176.25),
    RevenueData('Mar', 77.76, 155.51),
    RevenueData('Apr', 25.92, 168.47),
    RevenueData('May', 64.80, 181.43),
    RevenueData('Jun', 57.02, 165.88),
    RevenueData('Jul', 90.71, 163.29),
    RevenueData('Aug', 129.59, 186.61),
    RevenueData('Sep', 72.57, 171.06),
    RevenueData('Oct', 103.67, 150.33),
    RevenueData('Nov', 51.84, 160.69),
    RevenueData('Dec', 77.76, 181.43),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Revenue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(value: 'Sales Report', child: Text('Sales Report')),
                    const PopupMenuItem(value: 'Export Report', child: Text('Export Report')),
                    const PopupMenuItem(value: 'Profit', child: Text('Profit')),
                    const PopupMenuItem(value: 'Action', child: Text('Action')),
                  ],
                ),
              ],
            ),

            // Gráfico de linhas
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 200,
                  interval: 40,
                ),
                series: <CartesianSeries<RevenueData, String>>[
                  LineSeries<RevenueData, String>(
                    dataSource: revenueData,
                    xValueMapper: (RevenueData revenue, _) => revenue.month,
                    yValueMapper: (RevenueData revenue, _) => revenue.income,
                    color: const Color(0xFF10C469),
                    width: 3,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<RevenueData, String>(
                    dataSource: revenueData,
                    xValueMapper: (RevenueData revenue, _) => revenue.month,
                    yValueMapper: (RevenueData revenue, _) => revenue.expenses,
                    color: const Color(0xFF35B8E0),
                    width: 3,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),

            // Informações de pagamento e estatísticas
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Payments',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      // Ícones de cartões (substituídos por ícones do Flutter)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.credit_card, size: 36, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Icon(Icons.credit_card, size: 36, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Icon(Icons.credit_card, size: 36, color: Colors.orange[700]),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: Colors.grey[300]!), right: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Expenses',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_upward, size: 16, color: Colors.red),
                            const SizedBox(width: 4),
                            const Text(
                              '\$15.07k',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Revenue',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_downward, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                          const Text(
                            '\$45.5k',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Modelos de dados
class PieData {
  final String category;
  final double value;
  final Color color;
  final int count;
  final bool isIncrease;

  PieData(this.category, this.value, this.color, this.count, this.isIncrease);
}

class BarData {
  final String year;
  final double value;

  BarData(this.year, this.value);
}

class RevenueData {
  final String month;
  final double income;
  final double expenses;

  RevenueData(this.month, this.income, this.expenses);
}




// Componentes auxiliares

class BadgeWidget extends StatelessWidget {
  final double percent;
  final bool isPositive;

  const BadgeWidget({
    super.key,
    required this.percent,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: isPositive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 2),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Modelos de dados

class SalesData {
  final String month;
  final double value;

  SalesData(this.month, this.value);
}

class CountryData {
  final String country;
  final double percentage;
  final Color color;

  CountryData(this.country, this.percentage, this.color);
}