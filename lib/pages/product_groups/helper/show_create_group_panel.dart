// No seu arquivo de helper (ex: lib/pages/product_edit/groups/helper/side_panel_helper.dart)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/product_groups/helper/side_panel_helper.dart';


import '../../../../core/di.dart';
import '../../../../cubits/store_manager_cubit.dart';
import '../../../../cubits/store_manager_state.dart';

import '../../../../models/variant_option.dart';
import '../../../../repositories/product_repository.dart';
import '../../../models/products/product_variant_link.dart';
import '../cubit/create_complement_cubit.dart';
import '../steps/step3_add_complements.dart';
import '../widgets/add_option_flow.dart';
import '../widgets/complement_creation_form.dart';
import '../widgets/multi_step_panel_container.dart';

Future<ProductVariantLink?> showCreateGroupPanel(
    BuildContext context, {
      int? productId,
      ProductVariantLink? linkToEdit, // Parâmetro opcional para o modo de edição
    }) async {
  final storesState = context.read<StoresManagerCubit>().state;
  if (storesState is! StoresManagerLoaded) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dados da loja não carregados.")),
    );
    return null;
  }

  // Define se estamos no modo de edição
  final bool isEditMode = linkToEdit != null;

  final result = await showResponsiveSidePanelGroup<ProductVariantLink>(
    context,
    panel: BlocProvider(
      create: (_) {
        // Cria a instância do Cubit
        final cubit = CreateComplementGroupCubit(
          storeId: storesState.activeStore!.core.id!,
          productId: productId,
          productRepository: getIt<ProductRepository>(),
          allStoreVariants: storesState.activeStore!.relations.variants ?? [],
          allStoreProducts: storesState.activeStore!.relations.products ?? [],
        );

        // ✅ 2. SE ESTIVER EM MODO DE EDIÇÃO, PRÉ-CARREGA O ESTADO
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
    panel: AddOptionFlow( // ✨ Usando o novo widget!
      onOptionCreated: (option) {
        // Quando uma opção é criada, fechamos o painel e retornamos a opção
        Navigator.of(context).pop(option);
      },
      onCancel: () {
        // Se o usuário cancelar, apenas fechamos o painel
        Navigator.of(context).pop();
      },
    ),
  );
  return newOption;
}