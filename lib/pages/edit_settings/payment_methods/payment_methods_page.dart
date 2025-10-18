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
import '../../../core/responsive_builder.dart';
import '../../platform_payment_methods/gateway-payment.dart';

// O delegate permanece o mesmo, está correto.
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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

        // ✅ A ESTRUTURA É ENVOLVIDA POR UM ÚNICO DefaultTabController
        return DefaultTabController(
          length: tabs.length,
          child: Scaffold(
            // ✅ O CORPO AGORA É UM ÚNICO CUSTOMSCROLLVIEW
            body: CustomScrollView(
              slivers: [
                // ✅ 1. HEADER FIXO (FORA DA TABBARVIEW)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveBuilder.isDesktop(context) ? 38 : 28,
                      vertical: 16,
                    ),
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

                // ✅ 2. BARRA DE ABAS "PINADA" (FORA DA TABBARVIEW)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: tabs,
                      // ✅ Adicionado padding para alinhar com o conteúdo
                      padding: EdgeInsets.symmetric(horizontal: ResponsiveBuilder.isDesktop(context) ? 24 : 14),
                    ),
                  ),
                ),

                // ✅ 3. O CONTEÚDO QUE TROCA (A TABBARVIEW) VEM POR ÚLTIMO
                // Envolvemos a TabBarView em um SliverFillRemaining para que ela ocupe
                // o espaço restante e funcione dentro de um CustomScrollView.
                SliverFillRemaining(
                  child: TabBarView(
                    children: [
                      // Cada filho da TabBarView agora é apenas a lista de conteúdo.
                      _buildPaymentList(context, onlineGroups, storeId),
                      _buildPaymentList(context, offlineGroups, storeId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ MÉTODO SIMPLIFICADO: CONSTRÓI APENAS A LISTA DE CONTEÚDO PARA UMA ABA
  Widget _buildPaymentList(BuildContext context, List<PaymentMethodGroup> groups, int storeId) {
    if (groups.isEmpty) {
      return const Center(
        child: Text('Nenhum método deste tipo disponível.'),
      );
    }

    // Usamos um ListView aqui, pois ele já é rolável por si só.
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 88), // Espaçamento geral
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: PaymentGroupView(
            group: group,
            storeId: storeId,
          ),
        );
      },
    );
  }
}