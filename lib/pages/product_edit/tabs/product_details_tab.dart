import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/product_edit/cubit/edit_product_cubit.dart';
import '../widgets/product_details_form.dart'; // ✅ Importe o novo formulário

class ProductDetailsTab extends StatelessWidget {
  const ProductDetailsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProductCubit, EditProductState>(
      builder: (context, state) {
        final cubit = context.read<EditProductCubit>();
        final product = state.editedProduct;
        // A aba agora só precisa construir o formulário e conectar os fios
        return Padding(
          padding: const EdgeInsets.all(14.0),
          child: ProductDetailsForm(
            product: state.editedProduct,
            isImported: state.editedProduct.masterProductId != null,
            onNameChanged: cubit.nameChanged,

            onDescriptionChanged: cubit.descriptionChanged,

            onControlStockToggled: cubit.controlStockToggled,
            onStockQuantityChanged: cubit.stockQuantityChanged,
            onServesUpToChanged: cubit.servesUpToChanged,
            onWeightChanged: cubit.weightChanged,
            onUnitChanged: cubit.unitChanged,
            onDietaryTagToggled: cubit.toggleDietaryTag,
            onBeverageTagToggled: cubit.toggleBeverageTag,

            // Callback para o vídeo
            videoUrl: product.videoUrl,
            onVideoUrlChanged: cubit.videoUrlChanged, // Conecta ao novo método

            // ✅ PARÂMETROS DA GALERIA UNIFICADA, IGUAL AO WIZARD
            images: product.images,
            onImagesChanged: cubit.imagesChanged, // Conecta ao novo método

          ),
        );
      },
    );
  }
}