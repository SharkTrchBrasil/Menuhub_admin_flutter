// lib/pages/analytics/view/analytics_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/pages/analytics/widgets/customer_analytics_view.dart';
import 'package:totem_pro_admin/pages/analytics/widgets/product_analytics_view.dart';

import 'cubits/customer_analytics_cubit.dart';
import 'cubits/product_analytics_cubit.dart'; // Importe seu cubit principal


class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos o MultiBlocProvider para criar e fornecer nossos cubits de análise
    // para toda a árvore de widgets desta página.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ProductAnalyticsCubit(
            // Passamos o cubit principal que já tem os dados da loja
            storesManagerCubit: context.read<StoresManagerCubit>(),
          ),
        ),
        BlocProvider(
          create: (context) => CustomerAnalyticsCubit(
            // O mesmo para o cubit de clientes
            storesManagerCubit: context.read<StoresManagerCubit>(),
          ),
        ),
      ],
      child: DefaultTabController(
        length: 2, // O número de abas que planejamos
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Central de Análises"),
            bottom: const TabBar(
              isScrollable: true, // Bom para telas menores
              tabs: [
                Tab(text: "Análise de Produtos"),
                Tab(text: "Análise de Clientes"),
               // Tab(text: "Oportunidades"), // A aba futura
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              // Cada aba aponta para sua própria tela/view
              ProductAnalyticsView(),
              CustomerAnalyticsView(),
             // Center(child: Text("Em breve: Sugestão de Combos")), // Placeholder
            ],
          ),
        ),
      ),
    );
  }
}