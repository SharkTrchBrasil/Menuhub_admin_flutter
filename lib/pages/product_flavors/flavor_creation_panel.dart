import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';

import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import '../product-wizard/cubit/product_wizard_cubit.dart';
import '../product-wizard/cubit/product_wizard_state.dart';
import 'tabs/classification_tab.dart';
import 'tabs/flavor_details_tab.dart';
import 'tabs/flavor_price_tab.dart';

class FlavorCreationPanel extends StatelessWidget {
  final int storeId;
  final Category category;
  final VoidCallback onSaveSuccess;
  final VoidCallback onCancel;

  const FlavorCreationPanel({
    super.key,
    required this.storeId,
    required this.category,
    required this.onSaveSuccess,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductWizardCubit(
        storeId: storeId,
      )..startFlow(parentCategory: category),
      child: BlocListener<ProductWizardCubit, ProductWizardState>(
        listener: (context, state) {
          if (state.submissionStatus == FormStatus.success) {
            onSaveSuccess();
          } else if (state.submissionStatus == FormStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? "Erro"), backgroundColor: Colors.red),
            );
          }
        },
        child: _FlavorCreationPanelView(onCancel: onCancel),
      ),
    );
  }
}

class _FlavorCreationPanelView extends StatefulWidget {
  final VoidCallback onCancel;
  const _FlavorCreationPanelView({required this.onCancel});

  @override
  State<_FlavorCreationPanelView> createState() => _FlavorCreationPanelViewState();
}

class _FlavorCreationPanelViewState extends State<_FlavorCreationPanelView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final int _tabCount = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabCount, vsync: this);
    _tabController.addListener(() => setState(() {}));
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
        final isLastTab = _tabController.index == _tabCount - 1;
        final isFormValid = state.productInCreation.name.trim().isNotEmpty;
        final bool isLoading = state.submissionStatus == FormStatus.loading;

        return Column(
          children: [
            TabBar(
              controller: _tabController,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Detalhes e Tipo'),
                Tab(text: 'Preços'),
                Tab(text: 'Classificação'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  FlavorDetailsTab(),
                  FlavorPriceTab(),
                  ClassificationTab(),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DsButton(
                      style: DsButtonStyle.secondary,
                      onPressed: isLoading ? null : widget.onCancel,
                      label: 'Cancelar',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DsButton(
                      isLoading: isLoading,
                      onPressed: isFormValid && !isLoading
                          ? () {
                        if (isLastTab) {
                          cubit.saveProduct();
                        } else {
                          _tabController.animateTo(_tabController.index + 1);
                        }
                      }
                          : null,
                      label: isLastTab ? 'Concluir' : 'Continuar',
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