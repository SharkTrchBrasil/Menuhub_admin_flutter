import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/enums/form_status.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'cubit/edit_product_cubit.dart';
import 'tabs/product_details_tab.dart';
import 'tabs/product_pricing_tab.dart';
import 'tabs/product_availability_tab.dart';
import 'tabs/complement_tab.dart'; // Renomeado para ComplementGroupsTab




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
      child: const _EditProductView(),
    );
  }
}

// O _EditProductView agora é um StatefulWidget para gerenciar a aba ativa
class _EditProductView extends StatefulWidget {
  const _EditProductView();

  @override
  State<_EditProductView> createState() => _EditProductViewState();
}

class _EditProductViewState extends State<_EditProductView> {
  int _currentTab = 0;

  // Lista de widgets para o conteúdo das abas
  final List<Widget> _tabContents = const [
    ProductDetailsTab(),
    ComplementGroupsTab(),
    ProductAvailabilityTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditProductCubit, EditProductState>(
      listener: (context, state) {
        if (state.status == FormStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produto salvo com sucesso!"), backgroundColor: Colors.green));
        } else if (state.status == FormStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? "Erro ao salvar."), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5), // Um cinza claro de fundo
        // O body agora é um Column para conter Header, Tabs e Conteúdo
        body: Column(
          children: [
            // Seu Header customizado
            _buildHeader(context),
            // Sua TabBar customizada
            _buildTabBar(context),
            // O conteúdo da aba selecionada
            Expanded(
              child: Container(
                color: Colors.white,
                // IndexedStack é eficiente para manter o estado de cada aba
                child: IndexedStack(
                  index: _currentTab,
                  children: _tabContents,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // O Header que você criou
  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<EditProductCubit, EditProductState>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24), // Espaço para a status bar
              // Breadcrumb
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text("Cardápio", style: TextStyle(color: Theme.of(context).primaryColor)),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  const Text("Edição de produto", style: TextStyle(color: Colors.black)),
                ],
              ),
              const SizedBox(height: 16),
              // Título
              Text(
                state.editedProduct.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              // ... (adicionar o "Produto preparado" se quiser)
            ],
          ),
        );
      },
    );
  }

  // A TabBar customizada
  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildTab("Sobre o produto", 0),
          _buildTab("Grupo de complementos", 1),
          _buildTab("Disponibilidade", 2), // Removida a aba extra
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    final isActive = _currentTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFFEA1D2C) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? const Color(0xFFEA1D2C) : const Color(0xFF666666),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  // O rodapé que você já tinha, mas agora conectado ao CUBIT
  Widget _buildBottomBar() {
    return BlocBuilder<EditProductCubit, EditProductState>(
      builder: (context, state) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(onPressed: () => context.pop(), child: const Text("Cancelar")),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: (state.status == FormStatus.loading || !state.isDirty)
                    ? null
                    : () => context.read<EditProductCubit>().saveProduct(),
                child: state.status == FormStatus.loading
                    ? const CircularProgressIndicator()
                    : const Text("Salvar Alterações"),
              ),
            ],
          ),
        );
      },
    );
  }
}











//
//
//
//
//
// class EditProductPage extends StatelessWidget {
//   final int storeId;
//   final Product product;
//
//   const EditProductPage({super.key, required this.storeId, required this.product});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => EditProductCubit(
//         initialProduct: product,
//         productRepository: getIt<ProductRepository>(),
//         storeId: storeId,
//       ),
//       child: const _EditProductView(),
//     );
//   }
// }
//
// class _EditProductView extends StatelessWidget {
//   const _EditProductView();
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<EditProductCubit, EditProductState>(
//       listener: (context, state) {
//         if (state.status == FormStatus.success) {
//           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produto salvo com sucesso!"), backgroundColor: Colors.green));
//           // Opcional: fechar a tela após salvar com sucesso
//           // context.pop();
//         } else if (state.status == FormStatus.error) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? "Erro ao salvar."), backgroundColor: Colors.red));
//         }
//       },
//       child: DefaultTabController(
//         length: 3, // ✅ AGORA SÃO 3 ABAS
//         child: Scaffold(
//           appBar: AppBar(
//             title: BlocSelector<EditProductCubit, EditProductState, String>(
//               selector: (state) => state.editedProduct.name,
//               builder: (context, name) => Text(name.isEmpty ? "Editar Produto" : name),
//             ),
//             bottom: const TabBar(
//               isScrollable: true,
//               tabs: [
//                 Tab(text: 'Sobre o produto'),
//                 Tab(text: 'Grupo de complementos'),
//                 Tab(text: 'Disponibilidade e Opções'),
//               ],
//             ),
//           ),
//           body: const TabBarView(
//             children: [
//               ProductDetailsTab(),
//               ComplementGroupsTab(), // ✅ SEU WIDGET REATORADO
//               ProductAvailabilityTab(),
//             ],
//           ),
//           bottomNavigationBar: _buildBottomBar(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomBar() {
//     return BlocBuilder<EditProductCubit, EditProductState>(
//       builder: (context, state) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           color: Colors.white,
//           child: ElevatedButton(
//             // Habilita o botão apenas se houver mudanças e não estiver carregando
//             onPressed: (state.status == FormStatus.loading || !state.isDirty)
//                 ? null
//                 : () => context.read<EditProductCubit>().saveProduct(),
//             child: state.status == FormStatus.loading
//                 ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                 : const Text("Salvar Alterações"),
//           ),
//         );
//       },
//     );
//   }
// }