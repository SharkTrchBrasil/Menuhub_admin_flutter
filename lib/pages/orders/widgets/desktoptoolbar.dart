import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../models/store/store.dart';
import '../../operation_configuration/cubit/operation_config_cubit.dart';
import '../orders_page.dart';
import '../../../services/print/printer_settings.dart';
import '../settings/orders_settings.dart';

class DesktopToolbar extends StatelessWidget {
  final Store? activeStore;

  const DesktopToolbar({super.key, required this.activeStore});

  // ✅ Função atualizada para fornecer o Cubit
  void _showSidePanel(BuildContext context, Widget panel) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // ✅ CORREÇÃO: Envolver o painel com BlocProvider
          return BlocProvider<OperationConfigCubit>(
            create: (context) => getIt<OperationConfigCubit>(),
            child: panel,
          );
        },
        opaque: false,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final curve = CurveTween(curve: Curves.easeOut);
          final tween = Tween(begin: begin, end: end).chain(curve);
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isStoreActive = activeStore != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Configurações de Impressão',
            onPressed: isStoreActive
                ? () {
              _showSidePanel(
                context,
                PrinterSettingsSidePanel(storeId: activeStore!.core.id!),
              );
            }
                : null,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações da Loja',
            onPressed: isStoreActive
                ? () {
              _showSidePanel(
                context,
                StoreSettingsSidePanel(storeId: activeStore!.core.id!),
              );
            }
                : null,
          ),
        ],
      ),
    );
  }
}