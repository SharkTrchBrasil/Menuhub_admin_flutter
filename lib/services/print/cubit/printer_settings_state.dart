import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import '../../../models/printer_config.dart';
import '../../../services/print/device_settings_service.dart';
import '../../../services/print/printer_mapping_service.dart';

@immutable
class PrinterSettingsState {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, PrinterConfig> mappings;
  final List<BluetoothInfo> availableBluetoothDevices;
  final List<Printer> availableDesktopPrinters;

  /// Agora armazena o estado dos destinos de impressão por impressora:
  /// chave = identificador da impressora (macAdress ou url)
  /// valor = conjunto de destinos ativos ('balcao', 'cozinha')
  final Map<String, Set<String>> deviceDestinationsPerPrinter;

  final bool autoPrintOrders;

  const PrinterSettingsState({
    this.isLoading = false,
    this.errorMessage,
    this.mappings = const {},
    this.availableBluetoothDevices = const [],
    this.availableDesktopPrinters = const [],
    this.deviceDestinationsPerPrinter = const {},
    this.autoPrintOrders = false,
  });

  PrinterSettingsState copyWith({
    bool? isLoading,
    String? errorMessage,
    Map<String, PrinterConfig>? mappings,
    List<BluetoothInfo>? availableBluetoothDevices,
    List<Printer>? availableDesktopPrinters,
    Map<String, Set<String>>? deviceDestinationsPerPrinter,
    bool? autoPrintOrders,
  }) {
    return PrinterSettingsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      mappings: mappings ?? this.mappings,
      availableBluetoothDevices: availableBluetoothDevices ?? this.availableBluetoothDevices,
      availableDesktopPrinters: availableDesktopPrinters ?? this.availableDesktopPrinters,
      deviceDestinationsPerPrinter: deviceDestinationsPerPrinter ?? this.deviceDestinationsPerPrinter,
      autoPrintOrders: autoPrintOrders ?? this.autoPrintOrders,
    );
  }
}

