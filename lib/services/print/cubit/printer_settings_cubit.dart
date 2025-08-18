// ARQUIVO: cubit/printer_settings_cubit.dart (Corrigido)

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
// ✅ Recomendação: Adicione esta dependência no seu pubspec.yaml para usar o 'firstWhereOrNull'
// pubspec.yaml -> dependencies:
//   collection: ^1.18.0
import 'package:collection/collection.dart';
import 'package:totem_pro_admin/models/store_operation_config.dart';


import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';

import '../constants/print_destinations.dart';
import '../device_settings_service.dart';

@immutable
class PrinterSettingsState {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> availablePrinters;
  final String? mainPrinterId;
  final String? kitchenPrinterId;
  final String? barPrinterId;
  final bool autoPrintOrders;

  const PrinterSettingsState({
    this.isLoading = false,
    this.errorMessage,
    this.availablePrinters = const [],
    this.mainPrinterId,
    this.kitchenPrinterId,
    this.barPrinterId,
    this.autoPrintOrders = false,
  });

  // ✅ Helper melhorado para encontrar uma impressora pelo ID de forma segura
  dynamic getPrinterById(String? printerId) {
    if (printerId == null) return null;
    // 'firstWhereOrNull' do pacote 'collection' é a forma mais moderna e segura
    return availablePrinters.firstWhereOrNull(
          (p) => (p is BluetoothInfo ? p.macAdress : (p as Printer).url) == printerId,
    );
  }


  PrinterSettingsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? availablePrinters,
    // Usaremos os parâmetros forceNull para garantir que o null seja aplicado
    bool forceNullMain = false,
    bool forceNullKitchen = false,
    bool forceNullBar = false,
    String? mainPrinterId,
    String? kitchenPrinterId,
    String? barPrinterId,
    bool? autoPrintOrders,
  }) {
    return PrinterSettingsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      availablePrinters: availablePrinters ?? this.availablePrinters,
      mainPrinterId: forceNullMain ? null : mainPrinterId ?? this.mainPrinterId,
      kitchenPrinterId: forceNullKitchen ? null : kitchenPrinterId ?? this.kitchenPrinterId,
      barPrinterId: forceNullBar ? null : barPrinterId ?? this.barPrinterId,
      autoPrintOrders: autoPrintOrders ?? this.autoPrintOrders,
    );
  }
}

class PrinterSettingsCubit extends Cubit<PrinterSettingsState> {
  final StoresManagerCubit _storesManagerCubit;
  final DeviceSettingsService _deviceSettingsService;

  PrinterSettingsCubit(this._storesManagerCubit, this._deviceSettingsService) : super(const PrinterSettingsState());

  // 'initialize' continua igual
  Future<void> initialize() async {
    emit(state.copyWith(isLoading: true));
    try {
      final bluetoothPrinters = await _fetchBluetoothPrinters();
      final desktopPrinters = await _fetchDesktopPrinters();
      final allPrinters = [...bluetoothPrinters, ...desktopPrinters];

      StoreOperationConfig? settings;
      final storeState = _storesManagerCubit.state;
      if (storeState is StoresManagerLoaded) {
        settings = storeState.stores[storeState.activeStoreId]?.store.relations.storeOperationConfig;
      }

      emit(state.copyWith(
        isLoading: false,
        availablePrinters: allPrinters,
        mainPrinterId: settings?.mainPrinterDestination,
        kitchenPrinterId: settings?.kitchenPrinterDestination,
        barPrinterId: settings?.barPrinterDestination,
        autoPrintOrders: settings?.autoPrintOrders ?? false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: "Erro ao carregar impressoras."));
    }
  }

  // 'updateAutoPrint' continua similar
  Future<void> updateAutoPrint(bool newValue, int storeId) async {
    // Para consistência, vamos usar a mesma lógica de atualização local
    emit(state.copyWith(autoPrintOrders: newValue));
    await _storesManagerCubit.updateStoreSettings(storeId, autoPrintOrders: newValue);
  }

// 🔄 ATUALIZADO: Agora gerencia o estado do servidor E o local
  Future<void> setPrinterForDestination({
    required int storeId,
    required String destination,
    required String printerId,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      // 1. Atualiza o servidor
      await _storesManagerCubit.updateStoreSettings(
        storeId,
        // ✅ Usa as constantes para a comparação
        mainPrinterDestination: destination == PrintDestinations.counter ? printerId : state.mainPrinterId,
        kitchenPrinterDestination: destination == PrintDestinations.kitchen ? printerId : state.kitchenPrinterId,
        barPrinterDestination: destination == PrintDestinations.bar ? printerId : state.barPrinterId,
      );

      // 2. Atualiza a configuração LOCAL do dispositivo
      await _deviceSettingsService.addPrinterDestinationForPrinter(printerId, destination);

      // 3. Atualiza a UI
      // ✅ Usa as constantes para a comparação
      if (destination == PrintDestinations.counter) {
        emit(state.copyWith(isLoading: false, mainPrinterId: printerId));
      } else if (destination == PrintDestinations.kitchen) {
        emit(state.copyWith(isLoading: false, kitchenPrinterId: printerId));
      } else if (destination == PrintDestinations.bar) {
        emit(state.copyWith(isLoading: false, barPrinterId: printerId));
      }

    } catch(e) {
      emit(state.copyWith(isLoading: false, errorMessage: "Falha ao definir impressora."));
      await initialize();
    }
  }

// 🔄 ATUALIZADO: Agora gerencia o estado do servidor E o local
  Future<void> clearPrinterForDestination({
    required int storeId,
    required String destination,
  }) async {
    emit(state.copyWith(isLoading: true));

    // Precisamos saber qual printer ID está sendo removido para limpar a configuração local
    String? printerIdToRemove;
    // ✅ Usa as constantes para a comparação
    if (destination == PrintDestinations.counter) printerIdToRemove = state.mainPrinterId;
    if (destination == PrintDestinations.kitchen) printerIdToRemove = state.kitchenPrinterId;
    if (destination == PrintDestinations.bar) printerIdToRemove = state.barPrinterId;

    try {
      // 1. Atualiza o servidor
      await _storesManagerCubit.updateStoreSettings(
        storeId,
        // ✅ Usa as constantes para a comparação
        mainPrinterDestination: destination == PrintDestinations.counter ? null : state.mainPrinterId,
        kitchenPrinterDestination: destination == PrintDestinations.kitchen ? null : state.kitchenPrinterId,
        barPrinterDestination: destination == PrintDestinations.bar ? null : state.barPrinterId,
      );

      // 2. Limpa a configuração LOCAL do dispositivo
      if (printerIdToRemove != null) {
        await _deviceSettingsService.removePrinterDestinationForPrinter(printerIdToRemove, destination);
      }

      // 3. Atualiza a UI
      // ✅ Usa as constantes para a comparação
      if (destination == PrintDestinations.counter) {
        emit(state.copyWith(isLoading: false, forceNullMain: true));
      } else if (destination == PrintDestinations.kitchen) {
        emit(state.copyWith(isLoading: false, forceNullKitchen: true));
      } else if (destination == PrintDestinations.bar) {
        emit(state.copyWith(isLoading: false, forceNullBar: true));
      }

    } catch(e) {
      emit(state.copyWith(isLoading: false, errorMessage: "Falha ao limpar impressora."));
      await initialize();
    }
  }

  // Funções de busca de impressoras (sem alteração)
  Future<List<BluetoothInfo>> _fetchBluetoothPrinters() async {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) return [];
    if (!await Permission.bluetoothScan.request().isGranted || !await Permission.bluetoothConnect.request().isGranted) return [];
    return PrintBluetoothThermal.pairedBluetooths;
  }

  Future<List<Printer>> _fetchDesktopPrinters() async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) return [];
    return Printing.listPrinters();
  }
}