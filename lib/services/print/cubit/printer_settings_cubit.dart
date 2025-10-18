// ARQUIVO: cubit/printer_settings_cubit.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:collection/collection.dart';

import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';

import '../../../models/store/store_operation_config.dart';
import '../../../pages/operation_configuration/cubit/operation_config_cubit.dart';
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

  dynamic getPrinterById(String? printerId) {
    if (printerId == null) return null;
    return availablePrinters.firstWhereOrNull(
          (p) => (p is BluetoothInfo ? p.macAdress : (p as Printer).url) == printerId,
    );
  }

  PrinterSettingsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? availablePrinters,
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
  final OperationConfigCubit _operationConfigCubit; // ✅ ADICIONAR ESTE CAMPO
  final DeviceSettingsService _deviceSettingsService;

  // ✅ ATUALIZAR O CONSTRUTOR
  PrinterSettingsCubit(
      this._storesManagerCubit,
      this._operationConfigCubit, // ✅ ADICIONAR ESTE PARÂMETRO
      this._deviceSettingsService,
      ) : super(const PrinterSettingsState());

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

  // ✅ ATUALIZADO: Agora usa o OperationConfigCubit
  Future<void> updateAutoPrint(bool newValue, int storeId) async {
    emit(state.copyWith(autoPrintOrders: newValue));

    final storeState = _storesManagerCubit.state;
    if (storeState is StoresManagerLoaded) {
      final currentConfig = storeState.stores[storeId]?.store.relations.storeOperationConfig;
      if (currentConfig != null) {
        await _operationConfigCubit.updatePartialSettings(
          storeId,
          currentConfig,
          autoPrintOrders: newValue,
        );
      }
    }
  }

  // ✅ ATUALIZADO: Agora usa o OperationConfigCubit
  Future<void> setPrinterForDestination({
    required int storeId,
    required String destination,
    required String printerId,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final storeState = _storesManagerCubit.state;
      if (storeState is! StoresManagerLoaded) {
        throw Exception('Store state not loaded');
      }

      final currentConfig = storeState.stores[storeId]?.store.relations.storeOperationConfig;
      if (currentConfig == null) {
        throw Exception('Store configuration not found');
      }

      // 1. Atualiza o servidor
      await _operationConfigCubit.updatePartialSettings(
        storeId,
        currentConfig,
        mainPrinterDestination: destination == PrintDestinations.counter ? printerId : currentConfig.mainPrinterDestination,
        kitchenPrinterDestination: destination == PrintDestinations.kitchen ? printerId : currentConfig.kitchenPrinterDestination,
        barPrinterDestination: destination == PrintDestinations.bar ? printerId : currentConfig.barPrinterDestination,
      );

      // 2. Atualiza a configuração LOCAL do dispositivo
      await _deviceSettingsService.addPrinterDestinationForPrinter(printerId, destination);

      // 3. Atualiza a UI
      if (destination == PrintDestinations.counter) {
        emit(state.copyWith(isLoading: false, mainPrinterId: printerId));
      } else if (destination == PrintDestinations.kitchen) {
        emit(state.copyWith(isLoading: false, kitchenPrinterId: printerId));
      } else if (destination == PrintDestinations.bar) {
        emit(state.copyWith(isLoading: false, barPrinterId: printerId));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: "Falha ao definir impressora."));
      await initialize();
    }
  }

  // ✅ ATUALIZADO: Agora usa o OperationConfigCubit
  Future<void> clearPrinterForDestination({
    required int storeId,
    required String destination,
  }) async {
    emit(state.copyWith(isLoading: true));

    String? printerIdToRemove;
    if (destination == PrintDestinations.counter) printerIdToRemove = state.mainPrinterId;
    if (destination == PrintDestinations.kitchen) printerIdToRemove = state.kitchenPrinterId;
    if (destination == PrintDestinations.bar) printerIdToRemove = state.barPrinterId;

    try {
      final storeState = _storesManagerCubit.state;
      if (storeState is! StoresManagerLoaded) {
        throw Exception('Store state not loaded');
      }

      final currentConfig = storeState.stores[storeId]?.store.relations.storeOperationConfig;
      if (currentConfig == null) {
        throw Exception('Store configuration not found');
      }

      // 1. Atualiza o servidor
      await _operationConfigCubit.updatePartialSettings(
        storeId,
        currentConfig,
        mainPrinterDestination: destination == PrintDestinations.counter ? null : currentConfig.mainPrinterDestination,
        kitchenPrinterDestination: destination == PrintDestinations.kitchen ? null : currentConfig.kitchenPrinterDestination,
        barPrinterDestination: destination == PrintDestinations.bar ? null : currentConfig.barPrinterDestination,
      );

      // 2. Limpa a configuração LOCAL do dispositivo
      if (printerIdToRemove != null) {
        await _deviceSettingsService.removePrinterDestinationForPrinter(printerIdToRemove, destination);
      }

      // 3. Atualiza a UI
      if (destination == PrintDestinations.counter) {
        emit(state.copyWith(isLoading: false, forceNullMain: true));
      } else if (destination == PrintDestinations.kitchen) {
        emit(state.copyWith(isLoading: false, forceNullKitchen: true));
      } else if (destination == PrintDestinations.bar) {
        emit(state.copyWith(isLoading: false, forceNullBar: true));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: "Falha ao limpar impressora."));
      await initialize();
    }
  }

  Future<List<BluetoothInfo>> _fetchBluetoothPrinters() async {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) return [];
    if (!await Permission.bluetoothScan.request().isGranted ||
        !await Permission.bluetoothConnect.request().isGranted) return [];
    return PrintBluetoothThermal.pairedBluetooths;
  }

  Future<List<Printer>> _fetchDesktopPrinters() async {
    if (kIsWeb || Platform.isAndroid || Platform.isIOS) return [];
    return Printing.listPrinters();
  }
}