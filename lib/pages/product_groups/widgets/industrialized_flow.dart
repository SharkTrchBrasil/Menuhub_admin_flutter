import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/unifield_product_form.dart';

import '../../../widgets/ds_primary_button.dart';
import '../../products/widgets/product_image.dart';
import '../cubit/complement_form_cubit.dart';

class IndustrializedFlowView extends StatelessWidget {
  const IndustrializedFlowView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ComplementFormCubit>().state;

    return state.selectedCatalogProduct != null
        ? UnifiedProductForm(isPrepared: false)
        : _SearchInterfaceView();
  }
}

class _SearchInterfaceView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ComplementFormCubit>();
    final state = context.watch<ComplementFormCubit>().state;

    return Column(
      children: [
        TextField(
          onChanged: cubit.onSearchChanged,
          decoration: const InputDecoration(labelText: "Buscar no catálogo por nome ou EAN", prefixIcon: Icon(Icons.search)),
        ),
        const SizedBox(height: 16),
        if (state.isLoadingSearch) const Center(child: CircularProgressIndicator()),
        if (!state.isLoadingSearch && state.searchResults.isNotEmpty)
          ...state.searchResults.map((product) => ListTile(
            leading:
            ProductImage(imageUrl: product.imagePath?.url,),
            
            
            
          //  product.imagePath != null ? Image.network(product.imagePath!.url!, width: 40) : const Icon(Icons.image),
            title: Text(product.name),
            subtitle: Text(product.brand ?? ''),
            trailing: ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: () => cubit.selectCatalogProduct(product),
            ),
          )),
      ],
    );
  }
}

