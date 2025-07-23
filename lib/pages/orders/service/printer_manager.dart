import 'package:shared_preferences/shared_preferences.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart'; // Importe o modelo Store se ainda não estiver
import 'package:totem_pro_admin/pages/orders/service/print.dart';

class PrintManager {
  // REMOVIDO: A dependência do StoresManagerCubit foi removida.
  // final StoresManagerCubit _storesManager;

  final SharedPreferences _prefs;
  final Set<int> _printedOrderIds = {};
  bool _isPrinting = false;
  final PrinterService _printerService;

  PrintManager._({
    required SharedPreferences prefs,
    required PrinterService printerService,
  })  : _prefs = prefs,
        _printerService = printerService;

  // O construtor não precisa mais do StoresManagerCubit
  static Future<PrintManager> create({
    required SharedPreferences prefs,
    required PrinterService printerService,
  }) async {
    final manager = PrintManager._(
      prefs: prefs,
      printerService: printerService,
    );
    await manager._loadPrintedIds();
    return manager;
  }

  bool isOrderPrinted(int orderId) => _printedOrderIds.contains(orderId);

  Future<void> _loadPrintedIds() async {
    final ids = _prefs.getStringList('printedOrderIds') ?? [];
    _printedOrderIds.addAll(ids.map(int.parse));
    print('[PrintManager] IDs impressos carregados: $_printedOrderIds');
  }

  // AJUSTADO: O método agora recebe o objeto Store.
  Future<void> processOrder(OrderDetails order, Store store) async {
    print('[PrintManager] processOrder chamado para pedido ${order.id}');

    if (!await _shouldPrint(order, store)) {
      print('[PrintManager] Pedido ${order.id} já foi impresso ou não deve imprimir');
      return;
    }

    print('[PrintManager] Pedido ${order.id} vai ser impresso agora');

    if (_isPrinting) {
      print('[PrintManager] Impressora ocupada. Pedido ${order.id} aguardando.');
      return;
    }

    await _printWithRetry(order, store);
  }

  // AJUSTADO: O método agora recebe o objeto Store.
  Future<void> reprintOrder(OrderDetails order, Store store) async {
    _printedOrderIds.remove(order.id);
    await _savePrintedIds();
    await processOrder(order, store);
  }

  // AJUSTADO: O método agora recebe o objeto Store e não precisa mais do Cubit.
  Future<bool> _shouldPrint(OrderDetails order, Store store) async {
    if (_printedOrderIds.contains(order.id)) return false;

    // Acessa a configuração diretamente do objeto Store fornecido.
    return store.storeSettings?.autoPrintOrders == true;
  }

  // AJUSTADO: O método agora recebe o objeto Store.
  Future<void> _printWithRetry(OrderDetails order, Store store, {int retries = 3}) async {
    _isPrinting = true;
    try {
      for (var attempt = 0; attempt < retries; attempt++) {
        try {
          await _performPrint(order, store);
          print('[PrintManager] Impressão concluída para pedido ${order.id}');
          return;
        } catch (e) {
          print('[PrintManager] Erro ao imprimir pedido ${order.id} na tentativa $attempt: $e');
          if (attempt == retries - 1) rethrow;
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    } finally {
      _isPrinting = false;
    }
  }

  // AJUSTADO: O método agora recebe o objeto Store e não precisa mais do Cubit.
  Future<void> _performPrint(OrderDetails order, Store store) async {
    // Não precisa mais buscar a loja, ela já foi fornecida.
    await _printerService.printOrder(order, store);

    _printedOrderIds.add(order.id);
    await _savePrintedIds();
  }

  Future<void> _savePrintedIds() async {
    await _prefs.setStringList(
      'printedOrderIds',
      _printedOrderIds.map((id) => id.toString()).toList(),
    );
    print('[PrintManager] IDs impressos salvos: $_printedOrderIds');
  }
}