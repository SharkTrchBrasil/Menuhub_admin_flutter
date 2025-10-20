import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/products/product.dart';
import 'package:totem_pro_admin/pages/product_edit/cubit/edit_product_cubit.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

// Importe as abas que você já criou
import '../../../models/variant.dart';
import '../../product-wizard/steps/step4_categories.dart';
import '../../product_edit/tabs/complement_tab.dart';
import '../../product_edit/tabs/product_availability_tab.dart';
import '../../product_edit/tabs/product_cashback_tab.dart';
import '../../product_edit/tabs/product_details_tab.dart';


class ProductEditPanel extends StatelessWidget {
  final int storeId;
  final Product product;
  final VoidCallback onSaveSuccess;
  final VoidCallback onCancel;
  final List<Variant> allStoreVariants; // ✅ Adicione
  final List<Product> allStoreProducts; // ✅ Adicione

  const ProductEditPanel({
    super.key,
    required this.storeId,
    required this.product,
    required this.onSaveSuccess,
    required this.onCancel,
    required this.allStoreVariants, // ✅ Adicione
    required this.allStoreProducts, // ✅ Adicione
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditProductCubit(
        initialProduct: product,
        productRepository: getIt<ProductRepository>(),
        storeId: storeId,
      ),
      child: BlocListener<EditProductCubit, EditProductState>(
        listener: (context, state) {
          if (state.status == FormStatus.success) {
            onSaveSuccess();
          } else if (state.status == FormStatus.error) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? "Ocorreu um erro."),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        child: _EditProductPanelView(
          onCancel: onCancel,
          storeId: storeId, // ✅ Passe
          allStoreVariants: allStoreVariants, // ✅ Passe
          allStoreProducts: allStoreProducts, // ✅ Passe
        ),
      ),
    );
  }
}

class _EditProductPanelView extends StatelessWidget {
  final VoidCallback onCancel;
  final int storeId; // ✅ Adicione
  final List<Variant> allStoreVariants; // ✅ Adicione
  final List<Product> allStoreProducts; // ✅ Adicione

  const _EditProductPanelView({
    required this.onCancel,
    required this.storeId,
    required this.allStoreVariants,
    required this.allStoreProducts,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProductCubit, EditProductState>(
      builder: (context, state) {
        final cubit = context.read<EditProductCubit>();
        final isImported = state.editedProduct.masterProductId != null;

        final List<Widget> tabs = [
          const Tab(text: 'Sobre o produto'),
          if (!isImported) const Tab(text: 'Grupo de complementos'),
          const Tab(text: 'Disponibilidade'),
          const Tab(text: 'Cashback'),
        ];

        final List<Widget> tabViews = [
          const ProductDetailsTab(),
          if (!isImported) ComplementGroupsTab( // ✅ Passe os dados
            storeId: storeId,
            allStoreVariants: allStoreVariants,
            allStoreProducts: allStoreProducts,
          ),
          const ProductAvailabilityTab(),
          const ProductCashbackTab(),
        ];

        return DefaultTabController(
          length: tabs.length,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                child: TabBar(
                  tabs: tabs,
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: tabViews,
                ),
              ),


              Container(
                padding: const EdgeInsets.all(16),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: DsButton(
                        style: DsButtonStyle.secondary,
                        onPressed: (){
                          context.pop();
                        },
                        label: 'Cancelar',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: DsButton(
                        onPressed: (state.status == FormStatus.loading || !state.isDirty)
                            ? null
                            : cubit.saveProduct,
                        isLoading: state.status == FormStatus.loading,
                        label: "Salvar Alterações",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



