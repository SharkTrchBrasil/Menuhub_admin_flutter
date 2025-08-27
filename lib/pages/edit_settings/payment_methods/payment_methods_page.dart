import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/edit_settings/payment_methods/widgets/payment_group_view.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';

import '../../../core/helpers/sidepanel.dart';
import '../../../core/responsive_builder.dart';
import '../../platform_payment_methods/gateway-payment.dart';



class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key, required this.storeId});

  final int storeId;

  @override
  Widget build(BuildContext context) {
    // ✅ Não usamos mais o Padding aqui, pois o NestedScrollView controla o espaçamento interno.
    return Scaffold(
      body: BlocBuilder<StoresManagerCubit, StoresManagerState>(
        builder: (context, state) {
          if (state is! StoresManagerLoaded) {
            return const Center(child: DotLoading());
          }

          final store = state.activeStore;
          if (store == null) {
            return const Center(child: Text('Nenhuma loja ativa selecionada.'));
          }

          final paymentGroups = store.relations.paymentMethodGroups ?? [];

          if (paymentGroups.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Nenhuma forma de pagamento configurada na plataforma.'),
              ),
            );
          }

          // ✅ A estrutura agora é controlada pelo DefaultTabController e NestedScrollView
          return DefaultTabController(
            length: paymentGroups.length,
            child: NestedScrollView(
              // ✅ 1. O CONSTRUTOR DO CABEÇALHO ROlável
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  // Usamos um SliverAppBar, que é uma AppBar feita para rolar.
                  SliverAppBar(
                    // Removemos a sombra e cor de fundo para parecer parte do corpo
                    elevation: 0,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,

                    floating: true,

                     snap: true,


                    automaticallyImplyLeading: false,
                    // Altura do seu FixedHeader
                    toolbarHeight: 120,
                    titleSpacing: 0,

                    // ✅ SEU CABEÇALHO PERSONALIZADO VAI AQUI
                    title: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,
                      ),
                      child: FixedHeader(
                        title: 'Formas de pagamento',
                        subtitle: 'Escolha e consulte as formas de pagamento disponíveis para os seus clientes',
                        actions: [
                          DsButton(
                            label: 'Adicionar',
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

                    bottom: PreferredSize(
                      // A altura padrão para uma TabBar é kToolbarHeight
                      preferredSize: const Size.fromHeight(kToolbarHeight),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,
                          ),
                          tabs: paymentGroups.map((group) => Tab(text: group.name)).toList(),
                        ),
                      ),
                    ),
                  ),
                ];
              },
              // ✅ 2. O CORPO COM O CONTEÚDO DAS ABAS
              body: TabBarView(
                children: paymentGroups.map((group) {
                  return PaymentGroupView(
                    group: group,
                    storeId: storeId,
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}