import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/product_flavors/cubit/flavor_wizard_cubit.dart';
import 'package:totem_pro_admin/pages/product_flavors/tabs/classification_tab.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

// Importe suas abas

import '../../widgets/ds_primary_button.dart';
import 'tabs/flavor_details_tab.dart';
import 'tabs/flavor_price_tab.dart';

class FlavorWizardPage extends StatefulWidget {
  final int storeId;
  final Category category;
  final Product? product;

  const FlavorWizardPage({
    super.key,
    required this.storeId,
    required this.category,
    this.product,
  });

  @override
  State<FlavorWizardPage> createState() => _FlavorWizardPageState();
}

class _FlavorWizardPageState extends State<FlavorWizardPage> with SingleTickerProviderStateMixin {
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
    return BlocProvider(
      create: (context) => FlavorWizardCubit(
        productRepository: getIt<ProductRepository>(),
        storeId: widget.storeId,
      )..startFlow(parentCategory: widget.category, product: widget.product),
      child: BlocListener<FlavorWizardCubit, FlavorWizardState>(
        listener: (context, state) {
          if (state.status == FormStatus.success || state.status == FormStatus.cancelled) {
            context.pop();
          }
        },
        child: BlocBuilder<FlavorWizardCubit, FlavorWizardState>(
          builder: (context, state) {
            final cubit = context.read<FlavorWizardCubit>();
            final isLastTab = _tabController.index == _tabCount - 1;
            final isFormValid = state.product.name.trim().isNotEmpty;
            final bool isLoading = state.status == FormStatus.loading;





            return Scaffold(
              appBar: AppBar(
                // O AppBar agora é simples, apenas com título e botão de voltar.
                title: Text(state.isEditMode ? "Editar Sabor" : "Novo Sabor"),
              ),
              body: Column(
                children: [
                  // 1. A TabBar fica aqui, no topo do corpo da tela.
                  TabBar(
                    controller: _tabController,

                    tabs: const [
                      Tab(text: 'Detalhes'),
                      Tab(text: 'Preço e PDV'),
                      Tab(text: 'Classificação'),
                    ],
                  ),
                  // 2. O TabBarView ocupa o espaço restante.
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        FlavorDetailsTab(product: state.product, onUpdate: cubit.updateProduct),
                        FlavorPriceTab(
                          product: state.product,
                          parentCategory: state.parentCategory,
                          onUpdate: cubit.updateProduct,
                        ),
                        FlavorClassificationTab(product: state.product, onUpdate: cubit.updateProduct),
                      ],
                    ),
                  ),
                ],
              ),
              // ✅ ATUALIZAMOS O RODAPÉ PARA USAR O ESTADO 'isLoading'
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DsButton(
                        style: DsButtonStyle.secondary,
                        requiresConnection: false,
                        // Desabilita o botão de cancelar durante o carregamento
                        onPressed: isLoading ? null : () => context.pop(),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DsButton(
                        // ✅ O botão é desabilitado se o form for inválido OU se já estiver carregando
                        onPressed: isFormValid && !isLoading
                            ? () {
                          if (isLastTab) {
                            cubit.submitFlavor();
                          } else {
                            _tabController.animateTo(_tabController.index + 1);
                          }
                        }
                            : null,

                        // ✅ O conteúdo do botão muda para um indicador de progresso
                        child: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : Text(isLastTab
                            ? (state.isEditMode ? 'Salvar Alterações' : 'Criar Sabor')
                            : 'Continuar'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}