import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/pages/edit_settings/payment_methods/widgets/payment_group_view.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';

import '../../../core/helpers/sidepanel.dart';
import '../../platform_payment_methods/gateway-payment.dart';

// ✅ DELEGATE COPIADO DA delivery_locations_page.dart (ou pode ser movido para um arquivo comum)
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Container para dar a cor de fundo e garantir que a TabBar não fique transparente
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}


class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key, required this.storeId});

  final int storeId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return const Center(child: DotLoading());
        }

        final store = state.activeStore;
        if (store == null) {
          return const Center(child: Text('Nenhuma loja ativa selecionada.'));
        }

        final allPaymentGroups = store.relations.paymentMethodGroups;

        final onlineGroups = allPaymentGroups.where((group) {
          return ['credit_cards', 'debit_cards', 'digital_payments'].contains(group.name);
        }).toList();

        final offlineGroups = allPaymentGroups.where((group) {
          return ['cash_and_vouchers', 'offline_card'].contains(group.name);
        }).toList();

        final tabs = [
          const Tab(text: 'Pagamento pelo app'),
          const Tab(text: 'Pagamento na entrega'),
        ];

        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            // ✅ A ESTRUTURA AGORA É UM CUSTOMSCROLLVIEW ÚNICO DENTRO DO TABBARVIEW
            body: TabBarView(
              children: [
                // Cada aba tem seu próprio CustomScrollView
                _buildContentForTab(context, onlineGroups, storeId, tabs),
                _buildContentForTab(context, offlineGroups, storeId, tabs),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ NOVO MÉTODO PARA CONSTRUIR O CONTEÚDO DE CADA ABA
  Widget _buildContentForTab(BuildContext context, List<PaymentMethodGroup> groups, int storeId, List<Tab> tabs) {
    return CustomScrollView(
      slivers: [
        // ✅ 1. HEADER FIXO (SliverToBoxAdapter)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: FixedHeader(
              showActionsOnMobile: true,
              title: 'Formas de pagamento',
              subtitle: 'Ative e configure os métodos de pagamento para seus clientes.',
              actions: [
                DsButton(
                  label: 'Adicionar',
                  style: DsButtonStyle.secondary,
                  onPressed: () {
                    showResponsiveSidePanel(
                      context,
                      PlatformPaymentMethodsPage(
                        storeId: storeId,
                        isInSidePanel: true,
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ),

        // ✅ 2. BARRA DE ABAS "PINADA" (SliverPersistentHeader)
        SliverPersistentHeader(
          pinned: true, // A mágica acontece aqui!
          delegate: _SliverTabBarDelegate(
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: tabs,
            ),
          ),
        ),

        // ✅ 3. CONTEÚDO DA ABA (SliverList)
        if (groups.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text('Nenhum método deste tipo disponível.'),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88), // Espaço para o FAB (se houver)
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final group = groups[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: PaymentGroupView(
                      group: group,
                      storeId: storeId,
                    ),
                  );
                },
                childCount: groups.length,
              ),
            ),
          ),
      ],
    );
  }
}