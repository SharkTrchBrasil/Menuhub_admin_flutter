import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/product_details_form.dart';

import '../../product-wizard/cubit/product_wizard_cubit.dart';
import '../../product-wizard/cubit/product_wizard_state.dart';


class FlavorDetailsTab extends StatelessWidget {
  const FlavorDetailsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      // Reconstrói apenas se o produto em si mudar
      buildWhen: (p, c) => p.productInCreation != c.productInCreation,
      builder: (context, state) {
        final cubit = context.read<ProductWizardCubit>();
        final product = state.productInCreation;

        // ✅ LÓGICA SIMPLIFICADA:
        // O formulário agora é direto, sem seletores de tipo.
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ProductDetailsForm(
            product: product,
            // Um sabor nunca é "importado" no seu fluxo
            isImported: false,
            // Sinaliza ao formulário para ocultar campos irrelevantes para sabores
            isForFlavor: true,
            onNameChanged: (name) => cubit.updateProduct(product.copyWith(name: name)),
            onDescriptionChanged: (desc) => cubit.updateProduct(product.copyWith(description: desc)),
            images: product.images,
            onImagesChanged: cubit.onImagesChanged,
            videoFile: product.videoFile,
            onVideoChanged: cubit.videoChanged,
            // Funções vazias para campos que não existem no fluxo de sabor
            onControlStockToggled: (_) {},
            onStockQuantityChanged: (_) {},
            onServesUpToChanged: (_) {},
            onWeightChanged: (_) {},
            onUnitChanged: (_) {},
            onDietaryTagToggled: cubit.toggleDietaryTag, // Mantemos a classificação
            onBeverageTagToggled: cubit.toggleBeverageTag,
            onVideoUrlChanged: (url) => cubit.updateProduct(product.copyWith(videoUrl: url)),
          ),
        );
      },
    );
  }
}