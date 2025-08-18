// dashboard_widgets.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

import '../../../ConstData/colorfile.dart';
import '../../../ConstData/colorprovider.dart';
import '../../../ConstData/staticdata.dart';
import '../../../ConstData/typography.dart';
import '../../../UI TEMP/widgets/card.dart';
import '../../../controller/mywalletscontroller.dart';
import '../../../core/enums/cashback_type.dart';
import '../../../models/dashboard_data.dart';
import '../cubit/dashboard_state.dart';


class BalanceCard extends StatelessWidget {
  final ColorNotifire notifire;
  final DashboardKpi kpis;

  const BalanceCard({super.key, required this.notifire, required this.kpis});

  @override
  Widget build(BuildContext context) {
    // Determina a cor e o ícone com base nos dados reais
    final bool isPositive = kpis.revenueIsUp;
    final Color trendColor = isPositive ? const Color(0xff22C55E) : Colors.red;
    final String trendIcon = isPositive
        ? "assets/images/heroicons-outline_trending-up.svg"
        : "assets/images/heroicons-outline_trending-down.svg"; // Crie um ícone de seta para baixo


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          padding: const EdgeInsets.all(24),
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: notifire.getGry700_300Color),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Text(
                    'Total faturado',
                    style: Typographyy.bodyLargeMedium
                        .copyWith(color: notifire.getGry500_600Color),
                  ),
                  const Spacer(),
                  SvgPicture.asset(
                    "assets/images/dots-vertical29.svg",
                    height: 20,
                    width: 20,
                    color: notifire.getGry500_600Color,
                  ),
                ],
              ),
              RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: kpis.totalRevenue.toCurrencyString(),
                        style: Typographyy.heading2
                            .copyWith(color: notifire.getTextColor)),
                    TextSpan(
                        text: "BRL",
                        style: Typographyy.heading5
                            .copyWith(color: notifire.getGry500_600Color)),
                  ])),
              Row(
                children: [
                  SvgPicture.asset(trendIcon, height: 20, width: 20, color: trendColor),

                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "${isPositive ? '+' : ''}${kpis.revenueChangePercentage.toStringAsFixed(2)}%",
                    style: Typographyy.bodyLargeMedium
                        .copyWith(color: const Color(0xff22C55E)),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    height: 5,
                    width: 5,
                    decoration: BoxDecoration(
                        color: notifire.getGry700_300Color,
                        shape: BoxShape.circle),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    child: Text(
                      "vs. período anterior",
                      overflow: TextOverflow.ellipsis,
                      style: Typographyy.bodyLargeMedium
                          .copyWith(color: notifire.getGry500_600Color),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

      ],
    );
  }
}


class QuickLinksGrid extends StatelessWidget {
  final ColorNotifire notifire;
  final double size;


  const QuickLinksGrid({
    super.key,
    required this.notifire,
    required this.size,

  });

  @override
  Widget build(BuildContext context) {
    final cardList = [
      "assets/images/wallet1.svg",
      "assets/images/card-send1.svg",
      "assets/images/card-receive1.svg",
      "assets/images/receipt1.svg",
      "assets/images/shop-add.svg",
    ];

    final carName = [
      "Deposit",
      "Send",
      "Receive",
      "Invoicing",
      "Checkout",
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Quick Links",
                  style: Typographyy.bodyLargeExtraBold
                      .copyWith(color: notifire.getTextColor),
                ),
                const Spacer(),
                SvgPicture.asset(
                  "assets/images/chevron-down.svg",
                  height: 20,
                  width: 20,
                  color: notifire.getGry500_600Color,
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              itemCount: carName.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size < 600 ? 2 : 5,
                  mainAxisExtent: 100,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {},
                  child: _QuickLinkCard(
                    icon: cardList[index],
                    title: carName[index],
                    notifire: notifire,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  final String icon;
  final String title;
  final ColorNotifire notifire;

  const _QuickLinkCard({
    required this.icon,
    required this.title,
    required this.notifire,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: notifire.getGry50_800Color,
            child: SvgPicture.asset(
              icon,
              height: 20,
              width: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Typographyy.bodySmallSemiBold
                .copyWith(color: notifire.getTextColor),
          ),
        ],
      ),
    );
  }
}




class StatsHeader extends StatelessWidget {
  final ColorNotifire notifire;
  final double size;
  final DashboardKpi kpis;
  final DateFilterRange selectedRange;
  final Function(DateFilterRange) onRangeSelected;

  const StatsHeader({
    super.key,
    required this.notifire,
    required this.size,
    required this.kpis,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Para telas menores, usamos um layout em coluna para os KPIs
    if (size < 800) {
      return Column(
        children: [
          Row(
            children: [
              // ✅ O seletor de data agora é um PopupMenuButton
              Expanded(flex: 2, child: _buildDateFilterDropdown(context)),
              const SizedBox(height: 80, child: VerticalDivider(width: 30)),
              // Exibe os 2 KPIs mais importantes no topo
              Expanded(flex: 3, child: _buildKpiItem('Vendas', kpis.transactionCount.toString())),
            ],
          ),
          const Divider(height: 30),
          // Exibe os outros KPIs em uma linha separada
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: _buildKpiItem('Ticket Médio', kpis.averageTicket.toCurrencyString(leadingSymbol: 'R\$ '))),
              const SizedBox(height: 60, child: VerticalDivider()),
              Expanded(child: _buildKpiItem('Novos Clientes', kpis.newCustomers.toString())),
              const SizedBox(height: 60, child: VerticalDivider()),
              Expanded(child: _buildKpiItem('Cashback Gerado', kpis.totalCashback.toCurrencyString(leadingSymbol: 'R\$ '))),
            ],
          ),
        ],
      );
    }

    // Layout completo para telas de desktop
    return Row(
      children: [
        // ✅ O seletor de data agora é um PopupMenuButton
        Expanded(flex: 2, child: _buildDateFilterDropdown(context)),
         SizedBox(height: 80, child: VerticalDivider(width: 60,     color: notifire.getGry700_300Color,)),
        Expanded(flex: 2, child: _buildKpiItem('Vendas', kpis.transactionCount.toString())),
         SizedBox(height: 80, child: VerticalDivider(width: 60,     color: notifire.getGry700_300Color,)),
        Expanded(flex: 2, child: _buildKpiItem('Ticket Médio', kpis.averageTicket.toCurrencyString(leadingSymbol: 'R\$ '))),
        SizedBox(height: 80, child: VerticalDivider(width: 60,     color: notifire.getGry700_300Color,)),
        Expanded(flex: 2, child: _buildKpiItem('Novos Clientes', kpis.newCustomers.toString())),
         SizedBox(height: 80, child: VerticalDivider(width: 60,     color: notifire.getGry700_300Color,)),
        Expanded(flex: 2, child: _buildKpiItem('Cashback Gerado', kpis.totalCashback.toCurrencyString(leadingSymbol: 'R\$ '))),
      ],
    );
  }

  /// ✅ NOVO: Widget que cria o menu dropdown para o filtro de data.
  Widget _buildDateFilterDropdown(BuildContext context) {
    final display = selectedRange.displayTexts;

    return PopupMenuButton<DateFilterRange>(
      onSelected: onRangeSelected, // Chama a função do Cubit quando um item é selecionado
      tooltip: "Selecionar período",
      itemBuilder: (BuildContext context) => <PopupMenuEntry<DateFilterRange>>[
        const PopupMenuItem<DateFilterRange>(
          value: DateFilterRange.today,
          child: Text('Hoje'),
        ),
        const PopupMenuItem<DateFilterRange>(
          value: DateFilterRange.last7Days,
          child: Text('Últimos 7 dias'),
        ),
        const PopupMenuItem<DateFilterRange>(
          value: DateFilterRange.last30Days,
          child: Text('Últimos 30 dias'),
        ),
      ],
      // O `child` é o que o usuário vê antes de clicar
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✅ A SOLUÇÃO: Envolvemos a Column com um Flexible.
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  display['line1']!,
                  style: Typographyy.bodyXLargeExtraBold.copyWith(color: notifire.getTextColor),
                  // Adicionado para evitar que o texto quebre de forma estranha
                  overflow: TextOverflow.ellipsis,
                ),
                if (display['line2']!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    display['line2']!,
                    style: Typographyy.bodyXLargeExtraBold.copyWith(color: notifire.getTextColor),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(width: 20),
          SvgPicture.asset(
            "assets/images/chevron-down.svg",
            height: 20,
            width: 20,
            color: notifire.getGry500_600Color,
          ),
        ],
      ),
    );
  }

  /// Widget auxiliar que constrói cada um dos itens de KPI com dados reais.
  Widget _buildKpiItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Typographyy.bodyXLargeExtraBold.copyWith(color: notifire.getTextColor),
        ),
      ],
    );
  }
}



/// Widget privado para os botões de filtro, para manter o código mais limpo.
class _FilterButton extends StatelessWidget {
  final String text;
  final DateFilterRange range;
  final DateFilterRange selectedRange;
  final VoidCallback onPressed;
  final ColorNotifire notifire;

  const _FilterButton({
    required this.text,
    required this.range,
    required this.selectedRange,
    required this.onPressed,
    required this.notifire,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = selectedRange == range;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? priMeryColor : notifire.getGry50_800Color,
        foregroundColor: isActive ? Colors.white : notifire.getTextColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(text),
    );
  }
}


class StatsHeaderMobile extends StatelessWidget {
  final ColorNotifire notifire;
  // ✅ ADICIONADO: Precisa receber os KPIs
  final DashboardKpi kpis;

  const StatsHeaderMobile({super.key, required this.notifire, required this.kpis});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Total faturado',
                  style: Typographyy.bodyMediumMedium
                      .copyWith(color: notifire.getGry500_600Color),
                ),
                const SizedBox(height: 8),
                Text(
                  kpis.totalSpent.toCurrencyString(leadingSymbol: 'R\$ '),
                  style: Typographyy.bodyXLargeExtraBold.copyWith(color: notifire.getTextColor),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: VerticalDivider(
            color: notifire.getGry700_300Color,
            width: 60,
          ),
        ),
        Expanded(
          child: SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Total Cashback',
                  style: Typographyy.bodyMediumMedium
                      .copyWith(color: notifire.getGry500_600Color),
                ),
                const SizedBox(height: 8),
                Text(
                  kpis.totalCashback.toCurrencyString(leadingSymbol: 'R\$ '),
                  style: Typographyy.bodyXLargeExtraBold.copyWith(color: notifire.getTextColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class StatisticsChart extends StatelessWidget {
  final ColorNotifire notifire;
  final double size;

  // ALTERADO: Recebemos a lista de dados reais
  final List<SalesDataPoint> salesData;

  const StatisticsChart({
    super.key,
    required this.notifire,
    required this.size,
    required this.salesData, // Adicionado
  });

  @override
  Widget build(BuildContext context) {
    // REMOVIDO: A lista de dados fixos foi removida.

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // UI simplificada para focar no gráfico
          Text(
            "Estatísticas de Faturamento",
            style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(height: 24),
          // O gráfico agora ocupa a altura disponível
          SizedBox(
            height: 300, // Defina uma altura para o gráfico
            child: SfCartesianChart(
              // Configurando o eixo X para entender DATAS
              primaryXAxis: DateTimeAxis(
                majorGridLines: const MajorGridLines(width: 0), // Remove linhas de grade verticais
                dateFormat: DateFormat.d('pt_BR'), // Formato do dia (ex: 7, 8, 9)
                intervalType: DateTimeIntervalType.days,
                interval: 1, // Mostra um rótulo para cada dia
              ),
              // Configurando o eixo Y
              primaryYAxis: NumericAxis(
                // Formata o rótulo do eixo Y para ser em moeda
                numberFormat: NumberFormat.compactCurrency(
                  locale: 'pt_BR',
                  symbol: 'R\$',
                ),
                axisLine: const AxisLine(width: 0), // Remove a linha do eixo Y
                majorTickLines: const MajorTickLines(size: 0), // Remove os "tiques" do eixo
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                // Formato do tooltip quando o usuário toca em uma barra
                header: '',
                format: 'point.x : R\$ point.y',
              ),
              series: <CartesianSeries<SalesDataPoint, DateTime>>[
                ColumnSeries<SalesDataPoint, DateTime>(
                  // ALTERADO: Fonte de dados agora é a lista real
                  dataSource: salesData,
                  // O eixo X agora mapeia o objeto DateTime
                  xValueMapper: (SalesDataPoint data, _) => data.period,
                  // O eixo Y mapeia o faturamento (revenue)
                  yValueMapper: (SalesDataPoint data, _) => data.revenue,
                  name: 'Faturamento',
                  color: priMeryColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// O widget _MonthDropdownMenu e a classe ChartData podem ser removidos deste arquivo
// se não forem mais usados em nenhum outro lugar.


class _MonthDropdownMenu extends StatelessWidget {
  final MyWalletsController controller;
  final ColorNotifire notifire;

  const _MonthDropdownMenu({
    required this.controller,
    required this.notifire,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      tooltip: "",
      offset: const Offset(0, 40),
      color: notifire.getContainerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onOpened: () => controller.setMenuOpen(true),
      onCanceled: () => controller.setMenuOpen(false),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            padding: const EdgeInsets.all(0),
            child: SizedBox(
              height: 70,
              width: 100,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.listOfMonths.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            controller.setListValue(index);
                            Get.back();
                          },
                          child: Text(
                            controller.listOfMonths[index],
                            style: Typographyy.bodySmallSemiBold
                                .copyWith(color: notifire.getTextColor),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ];
      },
      child: Container(
        height: 34,
        width: 121,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: notifire.getGry50_800Color,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.listOfMonths[controller.selectListIteam],
              style: Typographyy.bodySmallSemiBold
                  .copyWith(color: notifire.getTextColor),
            ),
            const SizedBox(width: 8),
            SvgPicture.asset(
              controller.isMenuOpen
                  ? "assets/images/chevron-up.svg"
                  : "assets/images/chevron-down.svg",
              color: controller.isMenuOpen
                  ? priMeryColor
                  : notifire.getGry500_600Color,
            ),
          ],
        ),
      ),
    );
  }
}

// Substitua seu antigo `CurrencySection` por este widget completo.

class PaymentMethodsSummaryCard extends StatelessWidget {
  final ColorNotifire notifire;
  // ✅ ALTERADO: O widget agora recebe a lista de dados reais da API.
  final List<PaymentMethodSummary> paymentMethods;

  const PaymentMethodsSummaryCard({
    super.key,
    required this.notifire,
    required this.paymentMethods,
  });

  @override
  Widget build(BuildContext context) {
    // Ordena a lista do maior valor para o menor para exibir os mais relevantes primeiro.
    final sortedMethods = List<PaymentMethodSummary>.from(paymentMethods)
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ ALTERADO: Título mais relevante para os dados.
          Text(
            "Faturamento por Pagamento",
            style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(height: 16),

          // ✅ LÓGICA: Constrói a lista dinamicamente a partir dos dados recebidos.
          if (sortedMethods.isEmpty)
            const Center(child: Text("Nenhum dado de pagamento no período."))
          else
            Column(
              children: sortedMethods.map((method) {
                // Usa o widget de item de lista adaptado.
                return _PaymentMethodItem(
                  notifire: notifire,
                  method: method,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

// ✅ RENOMEADO E ADAPTADO: O antigo `_CurrencyItem` agora é `_PaymentMethodItem`.
class _PaymentMethodItem extends StatelessWidget {
  final ColorNotifire notifire;
  // ✅ ALTERADO: Recebe o objeto completo com os dados.
  final PaymentMethodSummary method;

  const _PaymentMethodItem({
    required this.notifire,
    required this.method,
  });

  // ✅ NOVO: Função auxiliar para escolher o ícone certo.
  IconData _getIconForPaymentMethod(String methodName) {
    final lowerCaseName = methodName.toLowerCase();
    if (lowerCaseName.contains('crédito')) return Icons.credit_card;
    if (lowerCaseName.contains('débito')) return Icons.credit_card_outlined;
    if (lowerCaseName.contains('pix')) return Icons.qr_code_2;
    if (lowerCaseName.contains('dinheiro')) return Icons.money_rounded;
    return Icons.payment;
  }

  @override
  Widget build(BuildContext context) {
    // Mantivemos a estrutura do ListTile que você já tinha.
    return ListTile(
      contentPadding: EdgeInsets.zero, // Remove paddings extras
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: notifire.getGry50_800Color,
        // ✅ ALTERADO: O ícone agora é dinâmico.
        child: Icon(
          _getIconForPaymentMethod(method.methodName),
          color: notifire.getGry500_600Color,
          size: 20,
        ),
      ),
      // ✅ ALTERADO: O título agora é o nome do método.
      title: Text(
        method.methodName,
        style: Typographyy.bodyLargeExtraBold.copyWith(color: notifire.getTextColor),
      ),
      // ✅ ALTERADO: O valor agora é o total faturado, formatado.
      trailing: Text(
        method.totalAmount.toCurrencyString(leadingSymbol: 'R\$ '),
        style: Typographyy.bodyLargeMedium.copyWith(color: notifire.getTextColor),
      ),
    );
  }
}

class ConversionSection extends StatelessWidget {
  final ColorNotifire notifire;
  final MyWalletsController controller;

  const ConversionSection({
    super.key,
    required this.notifire,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Conversion",
            style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(height: 24),
          _ConversionInput(
            notifire: notifire,
            controller: controller,
            isFirst: true,
          ),
          const SizedBox(height: 20),
          _ConversionInput(
            notifire: notifire,
            controller: controller,
            isFirst: false,
          ),
        ],
      ),
    );
  }
}

class _ConversionInput extends StatelessWidget {
  final ColorNotifire notifire;
  final MyWalletsController controller;
  final bool isFirst;

  const _ConversionInput({
    required this.notifire,
    required this.controller,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: PopupMenuButton(
            onOpened: () =>
            isFirst
                ? controller.setMenuOpen1(true)
                : controller.setMenuOpen2(true),
            onCanceled: () =>
            isFirst
                ? controller.setMenuOpen1(false)
                : controller.setMenuOpen2(false),
            tooltip: "",
            offset: const Offset(0, 40),
            constraints: const BoxConstraints(maxWidth: 60, minWidth: 60),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            color: notifire.getContainerColor,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: notifire.getGry700_300Color)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isFirst
                        ? controller.menuIteam[controller.selectMenuIteam]
                        : controller.menuIteam[controller.selectMenuIteam1],
                    style: Typographyy.bodyMediumExtraBold
                        .copyWith(color: notifire.getTextColor),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    (isFirst ? controller.isMenuOpen1 : controller.isMenuOpen2)
                        ? "assets/images/chevron-up.svg"
                        : "assets/images/chevron-down.svg",
                    height: 20,
                    width: 20,
                  ),
                ],
              ),
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  padding: const EdgeInsets.all(0),
                  child: SizedBox(
                    height: 100,
                    width: 50,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.menuIteam.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            const SizedBox(height: 12),
                            InkWell(
                              onTap: () {
                                isFirst
                                    ? controller.setSelectMenuIteam(index)
                                    : controller.setSelectMenuIteam1(index);
                                Get.back();
                              },
                              child: Text(
                                controller.menuIteam[index],
                                style: Typographyy.bodyMediumExtraBold
                                    .copyWith(color: notifire.getTextColor),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ];
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: notifire.getGry700_300Color)),
            child: TextField(
              style: Typographyy.bodyLargeMedium
                  .copyWith(color: notifire.getTextColor),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 20),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.y1);

  final int x;
  final double y;
  final double y1;
}