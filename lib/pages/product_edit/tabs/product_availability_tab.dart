import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/product_edit/cubit/edit_product_cubit.dart';

class ProductAvailabilityTab extends StatelessWidget {
  const ProductAvailabilityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProductCubit, EditProductState>(
      builder: (context, state) {
        final cubit = context.read<EditProductCubit>();
        final product = state.editedProduct;
        final isImported = product.masterProductId != null;

        return ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            SwitchListTile(
              title: const Text('Produto disponível no cardápio'),
              value: product.available,
              onChanged: (value) => cubit.availabilityChanged(value),
            ),
            // Adicione aqui os outros switches e campos de Opções Avançadas
            // Lembre-se de bloquear os campos com base no 'isImported'
            // Ex: onChanged: isImported ? null : (value) => cubit.featuredChanged(value),
          ],
        );
      },
    );
  }
}