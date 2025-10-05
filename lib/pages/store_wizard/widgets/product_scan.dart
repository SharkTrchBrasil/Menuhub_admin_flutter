import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/di.dart';

import 'package:totem_pro_admin/repositories/product_repository.dart';

import '../../products_scan/cubit/menu_scan_cubit.dart';
import '../../products_scan/menu_scan_widget.dart';

class ProductScanStep extends StatelessWidget {
  final int storeId;
  const ProductScanStep({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MenuScanCubit(
        storeId: storeId,
        productRepository: getIt<ProductRepository>(), // Injeção de dependência
      ),
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: MenuScanWidget(), // Nosso novo widget reutilizável!
      ),
    );
  }
}