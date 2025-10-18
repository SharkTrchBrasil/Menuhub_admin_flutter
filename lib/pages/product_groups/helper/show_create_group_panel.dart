import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/product_groups/helper/side_panel_helper.dart';

import '../../../../core/di.dart';
import '../../../../cubits/store_manager_cubit.dart';
import '../../../../cubits/store_manager_state.dart';
import '../../../../models/variant_option.dart';
import '../../../../repositories/product_repository.dart';
import '../../../models/products/product_variant_link.dart';
import '../../../models/variant.dart';
import '../../../models/products/product.dart';
import '../cubit/create_complement_cubit.dart';
import '../widgets/add_option_flow.dart';
import '../widgets/complement_creation_form.dart';
import '../widgets/multi_step_panel_container.dart';

/// ✅ VERSÃO CORRIGIDA: Recebe os dados necessários como parâmetros
Future<ProductVariantLink?> showCreateGroupPanel(
    BuildContext context, {
      required int storeId,
      required List<Variant> allStoreVariants,
      required List<Product> allStoreProducts,
      int? productId,
      ProductVariantLink? linkToEdit,
    }) async {

  // Define se estamos no modo de edição
  final bool isEditMode = linkToEdit != null;

  final result = await showResponsiveSidePanelGroup<ProductVariantLink>(
    context,
    panel: BlocProvider(
      create: (_) {
        // Cria a instância do Cubit com os dados passados como parâmetros
        final cubit = CreateComplementGroupCubit(
          storeId: storeId,
          productId: productId,
          productRepository: getIt<ProductRepository>(),
          allStoreVariants: allStoreVariants,
          allStoreProducts: allStoreProducts,
        );

        // ✅ SE ESTIVER EM MODO DE EDIÇÃO, PRÉ-CARREGA O ESTADO
        if (isEditMode) {
          cubit.startEditFlow(linkToEdit);
        }

        return cubit;
      },
      child: const MultiStepPanelContainer(),
    ),
  );

  return result;
}

Future<VariantOption?> showAddOptionToGroupPanel(BuildContext context) async {
  final newOption = await showResponsiveSidePanelGroup<VariantOption>(
    context,
    panel: AddOptionFlow(
      onOptionCreated: (option) {
        Navigator.of(context).pop(option);
      },
      onCancel: () {
        Navigator.of(context).pop();
      },
    ),
  );
  return newOption;
}