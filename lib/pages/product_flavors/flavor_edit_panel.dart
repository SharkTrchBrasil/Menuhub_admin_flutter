import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/products/product.dart';

import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import '../product-wizard/cubit/product_wizard_cubit.dart';
import '../product-wizard/cubit/product_wizard_state.dart';
import 'tabs/classification_tab.dart';
import 'tabs/flavor_details_tab.dart';
import 'tabs/flavor_price_tab.dart';

class FlavorEditPanel extends StatelessWidget {
  final int storeId;
  final Product product;
  final Category parentCategory;
  final VoidCallback onSaveSuccess;
  final VoidCallback onCancel;

  const FlavorEditPanel({
    super.key,
    required this.storeId,
    required this.product,
    required this.parentCategory,
    required this.onSaveSuccess,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductWizardCubit(
        storeId: storeId,
      )..startFlow(product: product, parentCategory: parentCategory),
      child: BlocListener<ProductWizardCubit, ProductWizardState>(
        listener: (context, state) {
          if (state.submissionStatus == FormStatus.success) {
            onSaveSuccess();
          } else if (state.submissionStatus == FormStatus.error) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.errorMessage ?? "Ocorreu um erro."),
                backgroundColor: Colors.red,
              ));
          }
        },
        child: _FlavorEditPanelView(onCancel: onCancel),
      ),
    );
  }
}

class _FlavorEditPanelView extends StatefulWidget {
  final VoidCallback onCancel;
  const _FlavorEditPanelView({required this.onCancel});

  @override
  State<_FlavorEditPanelView> createState() => _FlavorEditPanelViewState();
}

class _FlavorEditPanelViewState extends State<_FlavorEditPanelView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      builder: (context, state) {
        final cubit = context.read<ProductWizardCubit>();
        final isFormValid = state.productInCreation.name.trim().isNotEmpty;
        final isLoading = state.submissionStatus == FormStatus.loading;

        return Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey[600],
                tabs: const [
                  Tab(text: 'Detalhes e Tipo'),
                  Tab(text: 'Preços'),
                  Tab(text: 'Classificação'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  FlavorDetailsTab(),
                  FlavorPriceTab(),
                  ClassificationTab(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  Flexible(
                    child: DsButton(
                      style: DsButtonStyle.secondary,
                      onPressed: () => context.pop(),
                      label: 'Cancelar',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: DsButton(
                      onPressed: isFormValid && !isLoading ? cubit.saveProduct : null,
                      isLoading: isLoading,
                      label: 'Salvar Alterações',
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}