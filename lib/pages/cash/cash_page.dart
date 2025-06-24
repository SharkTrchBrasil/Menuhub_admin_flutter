import 'package:brasil_fields/brasil_fields.dart';
import 'package:either_dart/either.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/svg.dart';

import 'package:intl/intl.dart'; // Para formatar datas
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:totem_pro_admin/pages/base/BasePage.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';

import '../../ConstData/staticdata.dart';
import '../../ConstData/typography.dart';
import '../../core/di.dart';

import '../../core/responsive_builder.dart';
import '../../models/cash_session.dart';
import '../../models/cash_transaction.dart';

import '../../models/payment_method.dart';
import '../../repositories/payment_method_repository.dart';
import '../../repositories/store_repository.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../../widgets/app_primary_button.dart';
import '../../widgets/base_dialog.dart';

class CashPage extends StatefulWidget {
  final int storeId;

  const CashPage({super.key, required this.storeId});

  @override
  State<CashPage> createState() => _CashPageState();
}

class _CashPageState extends State<CashPage> {
  CashierSession? _cashierSession;
  List<CashierTransaction> _cashierTransactions = [];
  bool _loading = true;
  Map<String, double>? _paymentSummary;
  Map<String, int>? _paymentIdsSummary;

  double totalEntradasManuais = 0.0;
  double totalEntradasVendas = 0.0;
  double totalSaidas = 0.0;
  double totalFinal = 0.0;

  List<StorePaymentMethod> _storePaymentMethods = []; //

  List<ChartDataT> _currentDayInflowChartData = [];
  List<ChartDataT> _currentDayOutflowChartData = [];

  late int _cashPaymentMethodId;

  // Declare isso dentro da sua classe State
  final ValueNotifier<bool> dialIsOpen = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _loadAllCashData();
    _loadPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BasePage(
      mobileAppBar:
          ResponsiveBuilder.isMobile(context)
              ? AppBarCustom(
                title:
                    _cashierSession != null
                        ? 'Resumo do Caixa: #${_cashierSession!.id}'
                        : 'Caixa',
                actions: [
                  Row(
                    children: [
                      IconButton(
                        icon: SvgPicture.asset(
                          "assets/images/plus-.svg",
                          height: 20,
                          width: 20,
                          color: Colors.red,
                        ),
                        onPressed:
                            _cashierSession != null
                                ? () => _movementDialog('out')
                                : null,
                        tooltip: 'Retirar',
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: SvgPicture.asset(
                          "assets/images/plus+.svg",
                          height: 20,
                          width: 20,
                          color: Colors.green,
                        ),
                        onPressed:
                            _cashierSession != null
                                ? () => _movementDialog('in')
                                : null,
                        tooltip: 'Adicionar',
                      ),
                    ],
                  ),
                ],
              )
              : null,
      mobileBuilder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_cashierSession == null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/empty.json',
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhum caixa aberto',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      const SizedBox(height: 15),
                      _buildCompo1(width: MediaQuery.of(context).size.width),
                      const SizedBox(height: 15),
                      _buildCompo2(),
                      const SizedBox(height: 15),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
      desktopBuilder: (BuildContext context) {
        return Column(
          children: [
            ResponsiveBuilder.isDesktop(context)
                ? FixedHeader(
                  title:
                      _cashierSession != null
                          ? 'Resumo do Caixa: #${_cashierSession!.id}'
                          : 'Caixa',
                  actions: [
                    _cashierSession != null
                        ?
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            elevation: 0,
                            side: BorderSide(),
                            //color: notifire.getBgPrimaryColor),
                            fixedSize: const Size.fromHeight(40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(),
                            ),
                          ),

                          onPressed:
                              _cashierSession != null
                                  ? () => _movementDialog('out')
                                  : null,

                          child: Row(
                            children: [
                              Text(
                                "Retirar",
                                style: Typographyy.bodyMediumMedium.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(width: 10),
                              SvgPicture.asset(
                                "assets/images/plus-.svg",
                                height: 20,
                                width: 20,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fixedSize: const Size.fromHeight(40),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            _cashierSession != null
                                ? _movementDialog('in')
                                : null;
                          },

                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Adicionar",
                                style: Typographyy.bodyMediumMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              SvgPicture.asset(
                                "assets/images/plus+.svg",
                                height: 20,
                                width: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ) : SizedBox.shrink(),

                    const SizedBox(width: 10),
                    AppPrimaryButton(
                      label:
                          _cashierSession == null ||
                                  _cashierSession!.status != 'open'
                              ? "Abrir caixa"
                              : "Fechar caixa",
                      onPressed:
                          _cashierSession == null ||
                                  _cashierSession!.status != 'open'
                              ? _openCashRegisterDialog
                              : _closeCashRegister,
                    ),
                  ],
                )
                : SizedBox(),

            if (_cashierSession == null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/empty.json',
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum caixa aberto',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildCompo1(
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(flex: 1, child: _buildCompo2()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
      mobileBottomNavigationBar: AppPrimaryButton(
        label:
            _cashierSession == null || _cashierSession!.status != 'open'
                ? "Abrir caixa"
                : "Fechar caixa",

        onPressed:
            _cashierSession == null || _cashierSession!.status != 'open'
                ? _openCashRegisterDialog
                : _closeCashRegister,
      ),
    );
  }

  Future<void> _loadPaymentMethods() async {
    final paymentMethodsResult = await getIt<StorePaymentMethodRepository>()
        .getPaymentMethods(widget.storeId);

    if (paymentMethodsResult.isLeft) {
      debugPrint('Erro ao carregar métodos de pagamento.');
      _storePaymentMethods = [];
    } else {
      _storePaymentMethods = paymentMethodsResult.right;

      final cashMethod = _storePaymentMethods.firstWhere(
        (method) => method.paymentType == 'Cash',
        orElse: () => _storePaymentMethods.first,
      );

      _cashPaymentMethodId = cashMethod.id!;
      debugPrint(
        'Método de pagamento "Dinheiro" encontrado com ID: $_cashPaymentMethodId',
      );
    }
  }

  Future<void> _loadAllCashData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    debugPrint(
      'Iniciando carregamento de todos os dados do caixa para storeId: ${widget.storeId}',
    );

    // 1. Tenta buscar a sessão de caixa aberta (GET /current)
    final sessionResult = await getIt<StoreRepository>()
        .getCurrentCashierSession(widget.storeId);

    if (sessionResult.isLeft) {
      debugPrint('Nenhuma sessão de caixa aberta encontrada.');
      _cashierSession = null;
      _cashierTransactions = [];
      _paymentSummary = null;

      setState(() {
        _loading = false;
      });
    } else {
      _cashierSession = sessionResult.right;
      debugPrint(
        'Sessão de caixa aberta carregada: ID ${_cashierSession!.id}, Status ${_cashierSession!.status}',
      );

      // 3. Se a sessão de caixa estiver aberta e tiver ID, buscar resumo de pagamentos e transações
      if (_cashierSession!.id != null) {
        final summaryResult = await getIt<StoreRepository>()
            .getCashierSessionPaymentSummary(
              widget.storeId,
              _cashierSession!.id!,
            );

        if (summaryResult.isLeft) {
          debugPrint('Erro ao carregar resumo de pagamentos.');
          _paymentSummary = null;
        } else {
          _paymentSummary = summaryResult.right;
          debugPrint('Resumo de pagamentos carregado: $_paymentSummary');
        }

        final transactionsResult = await getIt<StoreRepository>()
            .listCashierTransactions(widget.storeId, _cashierSession!.id!);

        if (transactionsResult.isLeft) {
          debugPrint('Erro ao carregar transações.');
          _cashierTransactions = [];
        } else {
          _cashierTransactions = transactionsResult.right;
          // Ordenação das transações, se createdAt estiver disponível novamente
          // Se você ainda não tem createdAt no modelo Dart, esta linha precisa ser comentada ou removida.
          // Certifique-se de que o backend está enviando createdAt no CashierTransactionOut.
          // Se o backend enviar, então reative o campo createdAt no seu modelo CashierTransaction do Dart.
          _cashierTransactions.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          );
          debugPrint('Transações carregadas: ${_cashierTransactions.length}');
        }
      } else {
        debugPrint('Sessão de caixa aberta sem ID válido.');
        _cashierTransactions = [];
        _paymentSummary = null;
      }
    }

    if (!mounted || _cashierSession == null) return;

    setState(() {
      _loading = false;

      List<CashierTransaction> entradasManuais =
          _cashierTransactions
              .where((t) => t.type == 'inflow' && t.orderId == null)
              .toList();

      List<CashierTransaction> entradasVendas =
          _cashierTransactions
              .where((t) => t.type == 'inflow' && t.orderId != null)
              .toList();

      List<CashierTransaction> saidas =
          _cashierTransactions.where((t) => t.type == 'outflow').toList();

      totalEntradasManuais = entradasManuais.fold(0.0, (a, b) => a + b.amount);
      totalEntradasVendas = entradasVendas.fold(0.0, (a, b) => a + b.amount);
      totalSaidas = saidas.fold(0.0, (a, b) => a + b.amount);
      totalFinal =
          _cashierSession!.openingAmount +
          totalEntradasManuais +
          totalEntradasVendas -
          totalSaidas;

      // --- NOVA LÓGICA PARA O GRÁFICO DO DIA ATUAL ---
      final now = DateTime.now();
      // Cria um DateTime para o início do dia atual (sem informações de hora, minuto, segundo)
      final today = DateTime(now.year, now.month, now.day);

      double currentDayTotalInflows = 0.0;
      double currentDayTotalOutflows = 0.0;

      for (final tx in _cashierTransactions) {
        // Cria um DateTime para o início do dia da transação
        final transactionDate = DateTime(
          tx.createdAt.year,
          tx.createdAt.month,
          tx.createdAt.day,
        );

        // Compara apenas as datas (ignorando a hora)
        if (transactionDate.isAtSameMomentAs(today)) {
          if (tx.type == 'inflow') {
            currentDayTotalInflows += tx.amount;
          } else if (tx.type == 'outflow') {
            currentDayTotalOutflows += tx.amount;
          }
        }
      }

      // Limpa as listas antes de preencher
      _currentDayInflowChartData = [];
      _currentDayOutflowChartData = [];

      // Adiciona os dados se houver valores para o dia atual
      if (currentDayTotalInflows > 0) {
        _currentDayInflowChartData.add(
          ChartDataT('Hoje', currentDayTotalInflows, Colors.green, 'Entradas'),
        );
      }
      if (currentDayTotalOutflows > 0) {
        _currentDayOutflowChartData.add(
          ChartDataT('Hoje', currentDayTotalOutflows, Colors.red, 'Saídas'),
        );
      }
      // -------------------------------------------------
    });
  }

  Future<void> _openCashRegisterDialog() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Abrir Caixa'),
            content: TextField(
              controller: controller,

              decoration: const InputDecoration(labelText: 'Saldo Inicial'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),

              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                CentavosInputFormatter(moeda: true),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final rawText = controller.text
                      .replaceAll(RegExp(r'[^0-9,]'), '')
                      .replaceAll(',', '.');

                  final value = double.tryParse(rawText);
                  if (value == null || value < 0) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Por favor, insira um saldo inicial válido.',
                        ),
                      ),
                    );
                    return;
                  }

                  debugPrint('Tentando abrir sessão com saldo inicial: $value');

                  final result = await getIt<StoreRepository>()
                      .openCashierSession(
                        widget.storeId,
                        _cashPaymentMethodId,
                        value,
                        // Passa o ID do método de pagamento
                      );

                  if (!mounted) return;

                  if (result.isLeft) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('Erro ao abrir caixa.')),
                    );
                    debugPrint('Erro ao abrir caixa.');
                  } else {
                    Navigator.of(dialogContext).pop();
                    await _loadAllCashData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Caixa aberto com sucesso!'),
                      ),
                    );
                  }
                },
                child: const Text('Abrir Caixa'),
              ),
            ],
          ),
    );
  }

  Future<void> _closeCashRegister() async {
    final chartData12 = getChartDataFromSummary(
      _paymentSummary ?? {},
      _paymentIdsSummary ?? {},
    );
    chartData12.removeWhere((data) => data.y == 0.0);

    final double openingAmountExpected = _cashierSession?.openingAmount ?? 0.0;

    final removedAmountExpected = _cashierSession?.cashRemoved ?? 0.0;

    Map<String, double>? countedValues;
    bool? proceedToClose = false;

    do {
      // 1º diálogo: Formulário para digitar valores contados
      countedValues = await showDialog<Map<String, double>?>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          final controllers = <String, TextEditingController>{};
          final differences =
              <String, double?>{}; // Allows null for no input yet

          // Initialize controllers and differences
          for (final data in chartData12) {
            controllers[data.x] = TextEditingController(
              text:
                  countedValues != null && countedValues.containsKey(data.x)
                      ? NumberFormat.currency(
                        locale: 'pt_BR',
                        symbol: 'R\$',
                      ).format(countedValues[data.x])
                      : '',
            );

            // Initialize difference to null, so it's not shown initially
            if (countedValues != null &&
                countedValues.containsKey(data.x) &&
                controllers[data.x]!.text.isNotEmpty) {
              // If we have previous values, calculate and show the difference
              final rawText = controllers[data.x]!.text;
              final cleaned = rawText
                  .replaceAll('R\$', '')
                  .replaceAll(' ', '')
                  .replaceAll('.', '')
                  .replaceAll(',', '.');
              final value = double.tryParse(cleaned) ?? 0.0;
              differences[data.x] = value - data.y;
            } else {
              differences[data.x] = null; // Set to null if no input yet
            }
          }

          double getTotalEsperadoInternal() {
            final totalFormas = chartData12.fold<double>(
              0.0,
              (sum, e) => sum + e.y,
            );
            return totalFormas + openingAmountExpected - removedAmountExpected;
          }

          double getTotalDigitadoInternal() {
            double total = 0.0;
            for (final data in chartData12) {
              final c = controllers[data.x];
              final typed = c?.text
                  .replaceAll('R\$', '')
                  .replaceAll(' ', '')
                  .replaceAll('.', '')
                  .replaceAll(',', '.');
              total += double.tryParse(typed ?? '0.0') ?? 0.0;
            }
            total += openingAmountExpected - removedAmountExpected;
            return total;
          }

          // Use the `setState` function provided by StatefulBuilder for updates
          return StatefulBuilder(
            builder: (context, setStateOfDialog) {
              // Renamed setState to setStateOfDialog to avoid confusion
              void updateDifference(String name, String rawText) {
                final cleaned = rawText
                    .replaceAll('R\$', '')
                    .replaceAll(' ', '')
                    .replaceAll('.', '')
                    .replaceAll(',', '.');
                final value = double.tryParse(cleaned) ?? 0.0;
                final expected = chartData12.firstWhere((e) => e.x == name).y;

                setStateOfDialog(() {
                  // Use setStateOfDialog here
                  if (rawText.isEmpty) {
                    // If text field is empty, clear difference
                    differences[name] = null;
                  } else {
                    differences[name] = value - expected;
                  }
                });
              }

              final totalEsperado = getTotalEsperadoInternal();
              final totalDigitado = getTotalDigitadoInternal();
              final totalDiff = totalDigitado - totalEsperado;

              return BaseDialog(
                content: SizedBox(
                  width:
                      MediaQuery.of(context).size.width < 600
                          ? MediaQuery.of(context).size.width
                          : 500,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(3),
                            3: FlexColumnWidth(2),
                          },
                          children: [
                            // Cabeçalho
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Meio de pagamento",
                                      style: Typographyy.bodyMediumExtraBold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Movimentação",
                                      style: Typographyy.bodyMediumExtraBold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Valor informado",
                                      style: Typographyy.bodyMediumExtraBold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                if (MediaQuery.of(context).size.width >= 600)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "Quebra de Cx.",
                                        style: Typographyy.bodyMediumExtraBold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            // Espaçamento
                            TableRow(
                              children: List.generate(
                                MediaQuery.of(context).size.width >= 600
                                    ? 4
                                    : 3,
                                (_) => const SizedBox(height: 12),
                              ),
                            ),

                            // SALDO INICIAL
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Saldo inicial",
                                      style: Typographyy.bodyMediumMedium,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      NumberFormat.simpleCurrency(
                                        locale: 'pt_BR',
                                      ).format(_cashierSession!.openingAmount),
                                      style: Typographyy.bodyMediumExtraBold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      NumberFormat.simpleCurrency(
                                        locale: 'pt_BR',
                                      ).format(_cashierSession!.openingAmount),
                                      style: Typographyy.bodyMediumExtraBold
                                          .copyWith(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                if (MediaQuery.of(context).size.width >= 600)
                                  const SizedBox(),
                              ],
                            ),

                            if (totalSaidas > 0)
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Retiradas",
                                        style: Typographyy.bodyMediumMedium,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        NumberFormat.simpleCurrency(
                                          locale: 'pt_BR',
                                        ).format(totalSaidas),
                                        style: Typographyy.bodyMediumExtraBold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        NumberFormat.simpleCurrency(
                                          locale: 'pt_BR',
                                        ).format(totalSaidas),
                                        style: Typographyy.bodyMediumExtraBold
                                            .copyWith(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  if (MediaQuery.of(context).size.width >= 600)
                                    const SizedBox(),
                                ],
                              ),

                            // Espaço após saldo inicial/retirada
                            // Espaçamento
                            TableRow(
                              children: List.generate(
                                MediaQuery.of(context).size.width >= 600
                                    ? 4
                                    : 3,
                                (_) => const SizedBox(height: 12),
                              ),
                            ),

                            // LISTA DAS FORMAS DE PAGAMENTO

                            // Dados
                            ...chartData12.map((data) {
                              final controller = controllers[data.x]!;
                              final difference = differences[data.x];
                              final diffColor =
                                  difference == 0
                                      ? Colors.green
                                      : (difference != null && difference > 0
                                          ? Colors.orange
                                          : Colors.red);
                              final isMobile =
                                  MediaQuery.of(context).size.width < 600;

                              // MOBILE: Quebra vem abaixo
                              if (isMobile) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10,
                                        bottom: 10,
                                        right: 10,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          data.x,
                                          style: Typographyy.bodyMediumMedium,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          NumberFormat.simpleCurrency(
                                            locale: 'pt_BR',
                                          ).format(data.y),
                                          style:
                                              Typographyy.bodyMediumExtraBold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          TextField(
                                            controller: controller,
                                            textAlign: TextAlign.center,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              CentavosInputFormatter(
                                                moeda: true,
                                              ),
                                            ],
                                            decoration: const InputDecoration(
                                              hintText: 'R\$',
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    vertical: 12.0,
                                                    horizontal: 10.0,
                                                  ),
                                            ),
                                            onChanged: (text) {
                                              updateDifference(data.x, text);
                                            },
                                          ),
                                          const SizedBox(height: 4),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              difference != null
                                                  ? NumberFormat.currency(
                                                    locale: 'pt_BR',
                                                    symbol: 'R\$',
                                                  ).format(difference)
                                                  : '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: diffColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }

                              // DESKTOP: Quebra como quarta coluna
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        data.x,
                                        style: Typographyy.bodyMediumMedium,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        NumberFormat.simpleCurrency(
                                          locale: 'pt_BR',
                                        ).format(data.y),
                                        style: Typographyy.bodyMediumExtraBold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: TextField(
                                      controller: controller,
                                      textAlign: TextAlign.center,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        CentavosInputFormatter(moeda: true),
                                      ],
                                      decoration: const InputDecoration(
                                        hintText: 'R\$',
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 10.0,
                                        ),
                                      ),
                                      onChanged: (text) {
                                        updateDifference(data.x, text);
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        difference != null
                                            ? NumberFormat.currency(
                                              locale: 'pt_BR',
                                              symbol: 'R\$',
                                            ).format(difference)
                                            : '',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: diffColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),

                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Total Geral",
                                      style: Typographyy.bodyMediumExtraBold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      NumberFormat.simpleCurrency(
                                        locale: 'pt_BR',
                                      ).format(totalEsperado),
                                      style: Typographyy.bodyMediumExtraBold,
                                    ),
                                  ),
                                ),
                                const SizedBox(),
                                if (MediaQuery.of(context).size.width >= 600)
                                  const SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                title: 'Fechamanto de Caixa',
                onSave: () {
                  final result = <String, double>{};
                  result['__totalEsperado__'] = getTotalEsperadoInternal();
                  result['__totalDigitado__'] = getTotalDigitadoInternal();
                  result['__openingAmount__'] = openingAmountExpected;
                  for (final entry in controllers.entries) {
                    final cleanedText = entry.value.text
                        .replaceAll('.', '')
                        .replaceAll(',', '.');
                    result[entry.key] = double.tryParse(cleanedText) ?? 0.0;
                  }
                  Navigator.of(dialogContext).pop(result);
                },
                saveText: 'Fechar caixa',
              );
            },
          );
        },
      );

      if (countedValues == null) {
        return;
      }

      final double expectedTotalAmount =
          countedValues['__totalEsperado__'] ?? 0.0;
      final double informedTotalAmount =
          countedValues['__totalDigitado__'] ?? 0.0;
      final double totalDiff = informedTotalAmount - expectedTotalAmount;

      String message;
      Color messageColor;

      if (totalDiff.abs() < 0.01) {
        message = 'Todos os valores conferem.';
        messageColor = Colors.green;
      } else if (totalDiff > 0) {
        message =
            'Seu caixa está sobrando R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(totalDiff)}';
        messageColor = Colors.orange;
      } else {
        message =
            'Seu caixa está faltando R\$ ${NumberFormat.currency(locale: 'pt_BR', symbol: '').format(totalDiff.abs())}';
        messageColor = Colors.red;
      }

      proceedToClose = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: const Text(
                'Confirmação do Fechamento do Caixa',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                message,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: messageColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Voltar para conferir'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Fechar Caixa'),
                ),
              ],
            ),
      );
    } while (proceedToClose == false);

    final double finalExpectedTotalAmount =
        countedValues!['__totalEsperado__'] ?? 0.0;
    final double finalInformedTotalAmount =
        countedValues['__totalDigitado__'] ?? 0.0;
    final double finalTotalDiff =
        finalInformedTotalAmount - finalExpectedTotalAmount;

    debugPrint('Tentando fechar sessão com ID: ${_cashierSession!.id!}');

    final result = await getIt<StoreRepository>().closeSession(
      widget.storeId,
      _cashierSession!.id!,
      finalExpectedTotalAmount,
      finalInformedTotalAmount,
      finalTotalDiff,
    );

    if (!mounted) return;

    if (result is Left) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fechar o caixa: ${(result as Left).value}'),
        ),
      );
    } else {
      await _loadAllCashData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caixa fechado com sucesso!')),
      );
    }
  }

  Future<void> _movementDialog(String type) async {
    if (_cashierSession == null || _cashierSession!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhuma sessão aberta para registrar movimentação.'),
        ),
      );
      return;
    }

    final controller = TextEditingController();
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (BuildContext dialogContext) => StatefulBuilder(
            // Use StatefulBuilder para atualizar o dialog
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text(type == 'in' ? 'Adicionar Valor' : 'Retirar Valor'),
                content: SingleChildScrollView(
                  // Para evitar overflow se houver muitos métodos
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controller,
                        decoration: const InputDecoration(labelText: 'Valor'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),

                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CentavosInputFormatter(moeda: true),
                        ],
                      ),
                      SizedBox(height: 25),
                      TextField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          labelText: 'Observação (opcional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final rawText = controller.text
                          .replaceAll(RegExp(r'[^0-9,]'), '')
                          .replaceAll(',', '.');
                      final value = double.tryParse(rawText);

                      if (value == null || value <= 0) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text('Por favor, insira um valor válido.'),
                          ),
                        );
                        return;
                      }

                      Either<void, CashierTransaction> result;
                      if (type == 'in') {
                        result = await getIt<StoreRepository>().addCash(
                          widget.storeId,
                          _cashierSession!.id!,
                          value,
                          noteController.text.isNotEmpty
                              ? noteController.text
                              : "Entrada manual",
                          _cashPaymentMethodId,
                        );
                      } else {
                        result = await getIt<StoreRepository>().removeCash(
                          widget.storeId,
                          _cashierSession!.id!,
                          value,
                          noteController.text.isNotEmpty
                              ? noteController.text
                              : "Saída manual",
                          _cashPaymentMethodId,
                        );
                      }

                      if (!mounted) return;

                      if (result.isLeft) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                            content: Text('Erro na movimentação.'),
                          ),
                        );
                        debugPrint('Erro na movimentação.');
                      } else {
                        Navigator.of(dialogContext).pop();

                        if (!mounted) return; // 🛡️ Verifica antes do await

                        await _loadAllCashData();

                        if (!mounted)
                          return; // 🛡️ Verifica novamente após o await

                        // Aqui, use o `context` (pai) em vez do dialogContext, se já fechou o diálogo
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Movimento registrado com sucesso!'),
                          ),
                        );
                      }
                    },
                    child: const Text('Confirmar'),
                  ),
                ],
              );
            },
          ),
    );
  }

  List<ChartData12> getChartDataFromSummary(
    Map<String, double> summary,
    Map<String, int> paymentMethodIdMap,
  ) {
    final List<Color> defaultColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    int i = 0;

    return summary.entries.map((entry) {
      final color = defaultColors[i % defaultColors.length];
      // final methodId = paymentMethodIdMap[entry.key] ?? -1;
      i++;
      return ChartData12(entry.key, entry.value, color);
    }).toList();
  }

  Widget _buildCompo1({required double width}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  // color: notifire.getGry50_800Color,
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),

                    width < 500 ? const SizedBox(height: 10) : const SizedBox(),

                    const SizedBox(height: 24),

                    width < 1000
                        ? Column(
                          children: [
                            Row(
                              children: [
                                _buildCard(
                                  title: "Saldo inicial",
                                  price:
                                      _cashierSession != null
                                          ? _cashierSession!.openingAmount
                                              .toString()
                                          : '--',
                                  pr: "",
                                  color: Colors.green,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCard(
                                    title: "Retiradas",
                                    price:
                                        _cashierSession != null
                                            ? totalSaidas.toString()
                                            : '--',
                                    pr: "",
                                    color: Colors.red,
                                  ),
                                ),

                                Expanded(
                                  child: _buildCard(
                                    title: "Entradas",
                                    price:
                                        _cashierSession != null
                                            ? totalEntradasManuais.toString()
                                            : '--',
                                    pr: "",
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                _buildCard(
                                  title: "Total vendas",
                                  price:
                                      _cashierSession != null
                                          ? totalEntradasVendas.toString()
                                          : '--',
                                  pr: "",
                                  color: Colors.green,
                                ),

                                Spacer(),
                                _buildCard(
                                  title: "Saldo final",
                                  price:
                                      _cashierSession != null
                                          ? totalFinal.toString()
                                          : '--',
                                  pr: "",
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ],
                        )
                        : Row(
                          children: [
                            _buildCard(
                              title: "Saldo inicial",
                              price:
                                  _cashierSession != null
                                      ? _cashierSession!.openingAmount
                                          .toString()
                                      : '--',
                              pr: "",
                              color: Colors.green,
                            ),

                            const Spacer(),

                            _buildCard(
                              title: "Retiradas",
                              price:
                                  _cashierSession != null
                                      ? totalSaidas.toString()
                                      : '--',
                              pr: "",
                              color: Colors.red,
                            ),
                            const Spacer(),
                            _buildCard(
                              title: "Entradas",
                              price:
                                  _cashierSession != null
                                      ? totalEntradasManuais.toString()
                                      : '--',
                              pr: "",
                              color: Colors.green,
                            ),
                            const Spacer(),
                            _buildCard(
                              title: "Total Vendas",
                              price:
                                  _cashierSession != null
                                      ? totalEntradasVendas.toString()
                                      : '--',
                              pr: "",
                              color: Colors.green,
                            ),

                            const Spacer(),
                            _buildCard(
                              title: "Saldo final",
                              price:
                                  _cashierSession != null
                                      ? totalFinal.toString()
                                      : '--',
                              pr: "",
                              color: Colors.green,
                            ),
                          ],
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  //   color: notifire.getGry50_800Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            "Histórico de Movimentações",
                            overflow: TextOverflow.ellipsis,
                            style: Typographyy.heading5.copyWith(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // ... (dentro do seu método buildCompo1 ou onde o gráfico está)
                    Row(
                      children: [
                        Expanded(
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CartesianSeries<ChartDataT, String>>[
                              // Série para Entradas do Dia Atual
                              ColumnSeries<ChartDataT, String>(
                                dataSource: _currentDayInflowChartData,
                                // Dados de entradas
                                xValueMapper: (data, _) => data.x,
                                // Será 'Hoje'
                                yValueMapper: (data, _) => data.y,
                                // Valor total de entrada
                                pointColorMapper: (data, _) => data.color,
                                // Cor verde
                                dataLabelMapper:
                                    (data, _) =>
                                        'R\$ ${data.y.toStringAsFixed(2)}',
                                // Rótulo com o valor formatado
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                ),
                                name: 'Entradas do Dia', // Nome para a legenda
                              ),
                              // Série para Saídas do Dia Atual
                              ColumnSeries<ChartDataT, String>(
                                dataSource: _currentDayOutflowChartData,
                                // Dados de saídas
                                xValueMapper: (data, _) => data.x,
                                // Será 'Hoje'
                                yValueMapper: (data, _) => data.y,
                                // Valor total de saída
                                pointColorMapper: (data, _) => data.color,
                                // Cor vermelha
                                dataLabelMapper:
                                    (data, _) =>
                                        'R\$ ${data.y.toStringAsFixed(2)}',
                                // Rótulo com o valor formatado
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                ),
                                name: 'Saídas do Dia', // Nome para a legenda
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // ...
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildCompo2() {
    final chartData12 = getChartDataFromSummary(
      _paymentSummary ?? {},
      _paymentIdsSummary ?? {},
    );

    chartData12.removeWhere((data) => data.y == 0.0);

    // Se todos os dados forem zero ou vazios
    bool isEmptyData = chartData12.isEmpty;

    if (isEmptyData) {
      chartData12.add(
        ChartData12('Sem dados', 1, Colors.grey.withOpacity(0.4)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SfCircularChart(
            series: <CircularSeries>[
              DoughnutSeries<ChartData12, String>(
                dataSource: chartData12,
                xValueMapper: (ChartData12 data, _) => data.x,
                yValueMapper: (ChartData12 data, _) => data.y,
                pointColorMapper: (ChartData12 data, _) => data.color,
                dataLabelSettings: DataLabelSettings(
                  isVisible: !isEmptyData,
                  // não mostra label se for "Sem dados"
                  labelPosition: ChartDataLabelPosition.outside,
                  connectorLineSettings: ConnectorLineSettings(
                    type: ConnectorType.curve,
                  ),
                ),
                dataLabelMapper: (ChartData12 data, _) => data.x,
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (!isEmptyData)
            ...chartData12.map(
              (data) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.x,
                        style: TextStyle(
                          color: data.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      NumberFormat.simpleCurrency(
                        locale: 'pt_BR',
                      ).format(data.y),
                      style: Typographyy.bodyLargeExtraBold.copyWith(),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),

          Text(
            isEmptyData
                ? 'Nenhuma movimentação registrada'
                : 'Total: ${NumberFormat.simpleCurrency(locale: 'pt_BR').format(_paymentSummary?.values.fold(0.0, (a, b) => a + b) ?? 0.0)}',
            style: Typographyy.bodyLargeExtraBold.copyWith(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String price,
    required String pr,
    required Color color,
  }) {
    final precoFormatado = NumberFormat.simpleCurrency(
      locale: 'pt_BR',
    ).format(double.tryParse(price) ?? 0.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                title,
                style: Typographyy.bodyXLargeExtraBold.copyWith(),
                overflow: TextOverflow.ellipsis,
              ),
            ),


          ],
        ),
        const SizedBox(height: 8),
        RichText(
          textAlign: TextAlign.start,
          text: TextSpan(
            children: [
              TextSpan(
                text: _cashierSession != null ? precoFormatado : '--',
                style: Typographyy.bodyLargeExtraBold.copyWith(color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChartData12 {
  final String x; // Nome do método (ex: 'Dinheiro', 'Pix')
  final double y; // Valor esperado
  final Color color;

  // final int methodId; // <-- Adicionado para verificar com id

  ChartData12(this.x, this.y, this.color);
}

// Definição da classe ChartDataT
class ChartDataT {
  ChartDataT(this.x, this.y, this.color, this.label);

  final String x; // Ex: "Hoje" ou "29/05"
  final double y;
  final Color color;
  final String label; // Ex: "Entradas" ou "Saídas"
}

class PaymentSummary {
  final String name;
  final int id;
  final double totalAmount;

  PaymentSummary({
    required this.name,
    required this.id,
    required this.totalAmount,
  });
}

class ClosingCashData {
  final double openingAmount; // fundo de caixa
  final List<PaymentSummary> payments;

  ClosingCashData({required this.openingAmount, required this.payments});
}
