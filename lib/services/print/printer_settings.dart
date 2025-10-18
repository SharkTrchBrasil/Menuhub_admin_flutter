// ARQUIVO: printer_settings_side_panel.dart (Com melhorias)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';
import 'package:totem_pro_admin/pages/operation_configuration/cubit/operation_config_cubit.dart';

import '../../cubits/store_manager_cubit.dart';
import 'constants/print_destinations.dart';
import 'cubit/printer_settings_cubit.dart';
import 'device_settings_service.dart';

final getIt = GetIt.instance;

class PrinterSettingsSidePanel extends StatelessWidget {
  final int storeId;
  const PrinterSettingsSidePanel({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final panelWidth = isMobile ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.3;

    return BlocProvider(
      // DEPOIS
      create: (context) => PrinterSettingsCubit(
        getIt<StoresManagerCubit>(),
        getIt<OperationConfigCubit>(),
        getIt<DeviceSettingsService>(),

      )..initialize(),
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          elevation: 12,
          child: Container(
            width: panelWidth,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BlocBuilder<PrinterSettingsCubit, PrinterSettingsState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(context),

                    if (state.isLoading)
                      const Expanded(child: Center(child: CircularProgressIndicator()))
                    else if (state.errorMessage != null)
                      Expanded(child: Center(child: Text(state.errorMessage!)))
                    else
                      Expanded(child: _buildContentView(context, state)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Configurar Impressoras', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildContentView(BuildContext context, PrinterSettingsState state) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.power_settings_new_rounded),
          title: const Text('Imprimir pedidos automaticamente'),
          trailing: Switch(
            value: state.autoPrintOrders,
            onChanged: (newValue) => context.read<PrinterSettingsCubit>().updateAutoPrint(newValue, storeId),
          ),
        ),


        _buildDestinationSection(
          context,
          state: state,
          title: 'Impressora do Balcão',
          destinationKey: PrintDestinations.counter, // Em vez de 'balcao'
          icon: Icons.point_of_sale_outlined,
          assignedPrinterId: state.mainPrinterId,
        ),
        _buildDestinationSection(
          context,
          state: state,
          title: 'Impressora da Cozinha',
          destinationKey: PrintDestinations.kitchen, // Em vez de 'cozinha'
          icon: Icons.soup_kitchen_outlined,
          assignedPrinterId: state.kitchenPrinterId,
        ),
        _buildDestinationSection(
          context,
          state: state,
          title: 'Impressora do Bar',
          destinationKey: PrintDestinations.bar,
          icon: Icons.local_bar_outlined,
          assignedPrinterId: state.barPrinterId,
        ),
      ],
    );
  }

  Widget _buildDestinationSection(
      BuildContext context, {
        required PrinterSettingsState state,
        required String title,
        required String destinationKey,
        required IconData icon,
        required String? assignedPrinterId,
      }) {
    final cubit = context.read<PrinterSettingsCubit>();
    final assignedPrinter = state.getPrinterById(assignedPrinterId);
    final bool isAssigned = assignedPrinter != null;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            isAssigned
                ? ListTile(
              leading: Icon(
                assignedPrinter is BluetoothInfo ? Icons.bluetooth : Icons.print,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(assignedPrinter.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: "Remover Impressora",
                onPressed: () => cubit.clearPrinterForDestination(storeId: storeId, destination: destinationKey),
              ),
            )
                : ListTile(
              leading: Icon(icon, color: Colors.grey),
              title: const Text('Nenhuma impressora selecionada', style: TextStyle(color: Colors.grey)),
              trailing: ElevatedButton(
                child: const Text('Selecionar'),
                onPressed: () async {
                  if (state.availablePrinters.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Nenhuma impressora disponível para selecionar.")),
                    );
                    return;
                  }

                  final selectedPrinterId = await _showPrinterSelectionDialog(context, state, destinationKey);
                  if (selectedPrinterId != null) {
                    cubit.setPrinterForDestination(
                      storeId: storeId,
                      destination: destinationKey,
                      printerId: selectedPrinterId,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Adicionado 'currentDestinationKey' para uma melhor experiência de usuário
  Future<String?> _showPrinterSelectionDialog(BuildContext context, PrinterSettingsState state, String currentDestinationKey) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(

          title: const Text('Selecione uma Impressora'),
          content: SizedBox(
            width: 500,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: state.availablePrinters.length,
              itemBuilder: (context, index) {
                final printer = state.availablePrinters[index];
                final isBluetooth = printer is BluetoothInfo;
                final printerId = isBluetooth ? printer.macAdress : printer.url;
                final printerName = printer.name;

                final subtitle = _getPrinterUsageSubtitle(state, printerId);

                final isAlreadySelectedForThisDestination =
                    (currentDestinationKey == PrintDestinations.counter && state.mainPrinterId == printerId) ||
                        (currentDestinationKey == PrintDestinations.kitchen && state.kitchenPrinterId == printerId) ||
                        (currentDestinationKey == PrintDestinations.bar && state.barPrinterId == printerId);



                return ListTile(
                  enabled: !isAlreadySelectedForThisDestination, // Desabilita o clique se já estiver selecionada
                  leading: Icon(isBluetooth ? Icons.bluetooth : Icons.print),
                  title: Text(printerName),
                  subtitle: subtitle,
                  trailing: isAlreadySelectedForThisDestination
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () => Navigator.of(context).pop(printerId),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget? _getPrinterUsageSubtitle(PrinterSettingsState state, String printerId) {
    List<String> uses = [];
    if (state.mainPrinterId == printerId) uses.add(PrintDestinations.counter);
    if (state.kitchenPrinterId == printerId) uses.add(PrintDestinations.kitchen);
    if (state.barPrinterId == printerId) uses.add(PrintDestinations.bar);
    if (uses.isEmpty) return null;

    return Text("Usada em: ${uses.join(', ')}");
  }
}