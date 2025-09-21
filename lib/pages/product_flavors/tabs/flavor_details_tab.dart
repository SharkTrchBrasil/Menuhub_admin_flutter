import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/product_details_form.dart';
import '../cubit/flavor_wizard_cubit.dart';

class FlavorDetailsTab extends StatelessWidget {
  const FlavorDetailsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FlavorWizardCubit, FlavorWizardState>(
      buildWhen: (prev, curr) => prev.product != curr.product,
      builder: (context, state) {
        final cubit = context.read<FlavorWizardCubit>();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(14.0),
          child: ProductDetailsForm(
            product: state.product,
            isImported: state.product.masterProductId != null,
            isForFlavor: true,

            // Conecta diretamente aos novos métodos do Cubit
            onNameChanged: cubit.nameChanged,
            onDescriptionChanged: cubit.descriptionChanged,
            images: state.product.images,
            videoFile: state.product.videoFile,
            onImagesChanged: cubit.imagesChanged,
            onVideoChanged: cubit.videoChanged,

            // Funções vazias para os campos que não são usados em "Sabores"
            onControlStockToggled: (_) {},
            onStockQuantityChanged: (_) {},
            onDietaryTagToggled: (_) {},
            onBeverageTagToggled: (_) {},
            onServesUpToChanged: (_) {},
            onWeightChanged: (_) {},
            onUnitChanged: (_) {},
            onVideoUrlChanged: (_) {},
          ),
        );
      },
    );
  }
}