import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/products/product.dart';
import 'package:totem_pro_admin/pages/product_flavors/cubit/flavor_wizard_cubit.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

// Importe as abas do wizard de sabores
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
      create: (context) => FlavorWizardCubit(
        productRepository: getIt<ProductRepository>(),
        storeId: storeId,
      )..startFlow(parentCategory: parentCategory, product: product),
      child: BlocListener<FlavorWizardCubit, FlavorWizardState>(
        listener: (context, state) {
          if (state.status == FormStatus.success) {
            onSaveSuccess();
          } else if (state.status == FormStatus.error) {
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

// UI extraída da `FlavorWizardPage`
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
    return BlocBuilder<FlavorWizardCubit, FlavorWizardState>(
      builder: (context, state) {
        final cubit = context.read<FlavorWizardCubit>();
        final isFormValid = state.product.name.trim().isNotEmpty;
        final isLoading = state.status == FormStatus.loading;

        return Column(
          children: [


            // Container para as tabs com background e borda
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: Theme.of(context).primaryColor,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: const [
                      Tab(text: 'Detalhes'),
                      Tab(text: 'Preço e PDV'),
                      Tab(text: 'Classificação'),
                    ],
                  ),
                  // Linha divisória sutil abaixo das tabs

                ],
              ),
            ),

            // Conteúdo das Abas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  FlavorDetailsTab(),
                  FlavorPriceTab(),
                  FlavorClassificationTab(),
                ],
              ),
            ),

            // Rodapé com Botões
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,

              ),
              child: Row(
                children: [
                  Flexible(
                    child: DsButton(
                      style: DsButtonStyle.secondary,
                      onPressed: (){
        context.pop();
        } ,
                      label: 'Cancelar',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: DsButton(
                      onPressed: isFormValid && !isLoading ? cubit.submitFlavor : null,
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