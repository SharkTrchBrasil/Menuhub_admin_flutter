import 'package:flutter/material.dart';

class PageTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final bool isInWizard;

  const PageTabBar({
    super.key,
    required this.controller,
    this.isInWizard = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = isInWizard
        ? [const Tab(text: 'Cardápio')]
        : [
      const Tab(text: 'Cardápio'),
      const Tab(text: 'Produtos'),
      const Tab(text: 'Complementos'),
    ];

    return TabBar(
      controller: controller,

      // ✅ REMOVE TODO O PADDING/MARGIN
      padding: EdgeInsets.zero,
      indicatorPadding: EdgeInsets.zero,
      labelPadding: EdgeInsets.only(right: 14),



      // ✅ REMOVE ESPAÇAMENTO INTERNO DAS TABS
      tabAlignment: TabAlignment.start, // Preenche todo o espaço disponível

      // ✅ CONFIGURAÇÕES VISUAIS (mantenha as suas)
      isScrollable: true, // Com fill, não precisa ser scrollable
      labelColor: Theme.of(context).colorScheme.primary,
      dividerColor: Colors.transparent,
      unselectedLabelColor: Colors.black54,
      indicatorColor: Theme.of(context).colorScheme.primary,
      indicatorWeight: 3.0,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),

      // ✅ REMOVE O INDICATOR PADDING SE PRECISAR MAIS COMPACTO
      // indicator: BoxDecoration(
      //   border: Border(
      //     bottom: BorderSide(
      //       color: Theme.of(context).colorScheme.primary,
      //       width: 3.0,
      //     ),
      //   ),
      // ),

      tabs: tabs,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}