import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/product_edit/tabs/product_cashback_tab.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'cubit/edit_product_cubit.dart';
import 'tabs/product_details_tab.dart';
import 'tabs/product_availability_tab.dart';
import 'tabs/complement_tab.dart';

class EditProductPage extends StatelessWidget {
  final int storeId;
  final Product product;

  const EditProductPage({super.key, required this.storeId, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditProductCubit(
        initialProduct: product,
        productRepository: getIt<ProductRepository>(),
        storeId: storeId,
      ),
      child:  _EditProductView(storeId),
    );
  }
}

class _EditProductView extends StatelessWidget {
  const _EditProductView(this.storeId);
  final int storeId;

  @override
  Widget build(BuildContext context) {
    // Usamos BlocConsumer para ter um listener e um builder
    return BlocConsumer<EditProductCubit, EditProductState>(
      listener: (context, state) {
        if (state.status == FormStatus.success) {
          // Ação #1: Mostra o feedback de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Produto salvo com sucesso!"), backgroundColor: Colors.green),
          );
          // Ação #2: Fecha a tela de edição e volta para a lista
          context.goNamed(
            'products',
            pathParameters: {'storeId': storeId.toString()},
          );
        }
        else if (state.status == FormStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? "Erro ao salvar."), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        // O builder agora pode ser mais simples.
        // Não precisamos mais de um `BlocListener` aninhado aqui.
        return ResponsiveBuilder(
          mobileBuilder: (ctx, constraints) => _buildMobileLayout(ctx),
          desktopBuilder: (ctx, constraints) => _buildDesktopLayout(ctx),
        );
      },
    );
  }

  // ✅ NOVO LAYOUT PARA MOBILE: Simples, com AppBar padrão e TabBar
  Widget _buildMobileLayout(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          // ✅ ADICIONE ESTE BLOCO DE CÓDIGO
          leading: BackButton(
            onPressed: () => context.goNamed(
              'products',
              pathParameters: {'storeId': storeId.toString()},
            ),
          ),
          title: BlocSelector<EditProductCubit, EditProductState, String>(
            selector: (state) => state.editedProduct.name,
            builder: (context, name) => Text(
              name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              overflow: TextOverflow.ellipsis,

            ),
          ),
          // A TabBar agora fica na parte de baixo da AppBar
          bottom: const TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            tabs: [
              Tab(text: 'Sobre o produto'),
              Tab(text: 'Grupo de complementos'),
              Tab(text: 'Disponivel em'),
              Tab(text: 'Cashback'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProductDetailsTab(),
            ComplementGroupsTab(),
            ProductPricingTab(),
            ProductCashbackTab(),
          ],
        ),
        // O BottomBar é o mesmo para ambos os layouts
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // ✅ LAYOUT PARA DESKTOP: Mantém a estrutura que você criou
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _EditProductViewDesktop(), // Extraído para um widget separado para limpeza
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // O rodapé é compartilhado
  Widget _buildBottomBar() {
    return BlocBuilder<EditProductCubit, EditProductState>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(child: DsButton(style:DsButtonStyle.secondary, onPressed: () =>
                  context.goNamed(
                'products',
                pathParameters: {'storeId': storeId.toString()},
              )
                  , label: 'Cancelar')),
              const SizedBox(width: 16),
              Flexible(
                child: DsButton(
                  onPressed: (state.status == FormStatus.loading || !state.isDirty)
                      ? null
                      : () => context.read<EditProductCubit>().saveProduct(),
                  isLoading: state.status == FormStatus.loading,
                  label: "Salvar Alterações",
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget auxiliar para o conteúdo do Desktop, para manter o código organizado
class _EditProductViewDesktop extends StatefulWidget {
  const _EditProductViewDesktop();

  @override
  State<_EditProductViewDesktop> createState() => _EditProductViewDesktopState();
}

class _EditProductViewDesktopState extends State<_EditProductViewDesktop> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // O Header customizado
        BlocBuilder<EditProductCubit, EditProductState>(
          builder: (context, state) {
            return Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column( /* ... Cole seu _buildHeader aqui ... */ ),
            );
          },
        ),
        // A TabBar customizada
        Container(
          color: Colors.white,
          child: Row(
            children: [
              _buildTab("Sobre o produto", 0),
              _buildTab("Grupo de complementos", 1),
              _buildTab("Disponibilidade", 2),
              _buildTab("Cashback", 3),
            ],
          ),
        ),
        // O conteúdo da aba
        Expanded(
          child: Container(
            color: Colors.white,
            child: IndexedStack(
              index: _currentTab,
              children: const [
                ProductDetailsTab(),
                ComplementGroupsTab(),
                ProductPricingTab(),
                ProductCashbackTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // O _buildTab que você já tinha
  Widget _buildTab(String text, int index) {
    final isActive = _currentTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade300,
                width: 2,
              ),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade700,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}