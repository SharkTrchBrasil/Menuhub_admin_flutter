import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/di.dart';

import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/edit_product/groups/helper/side_panel_helper.dart';



import 'package:totem_pro_admin/repositories/product_repository.dart';

import '../../../../core/helpers/sidepanel.dart';
import '../../../../models/product_variant_link.dart';
import '../cubit/create_complement_cubit.dart';
import '../multi_step_panel_container.dart';

// ✅ A função é declarada como `async` e retorna um `Future<ProductVariantLink?>`
Future<ProductVariantLink?> showCreateGroupPanel(BuildContext context, {int? productId}) async {
  final storesState = context.read<StoresManagerCubit>().state;
  if (storesState is! StoresManagerLoaded) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dados da loja não carregados.")),
    );
    return null;
  }

  // ✅ Usa `await` para esperar o resultado do painel
  final result = await showResponsiveSidePanelGroup<ProductVariantLink>(
    context,
    panel: BlocProvider(
      create: (_) => CreateComplementGroupCubit(
        storeId: storesState.activeStore!.core.id!,
        productId: productId,
        productRepository: getIt<ProductRepository>(),
        allStoreVariants: storesState.activeStore!.relations.variants ?? [],
        allStoreProducts: storesState.activeStore!.relations.products ?? [],
      ),
      child: const MultiStepPanelContainer(),
    ),
  );

  // ✅ Retorna o resultado obtido
  return result;
}