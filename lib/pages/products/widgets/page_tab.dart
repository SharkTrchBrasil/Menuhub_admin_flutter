import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../themes/ds_theme_switcher.dart';

/// WIDGET: Barra de abas
class PageTabBar extends StatelessWidget implements PreferredSizeWidget {
  const PageTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<DsThemeSwitcher>().theme;

    return Container(
      color: Colors.white,
    //  padding: const EdgeInsets.symmetric(horizontal: 2),
      child:  TabBar( // ✅ O TabBar vai encontrar o controller do DefaultTabController
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: theme.primaryColor,
        dividerColor: Colors.transparent,
        unselectedLabelColor: Colors.black54,
        indicatorColor: theme.primaryColor,
        indicatorWeight: 3.0,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        tabs: [
          Tab(text: 'Cardápio'),
          Tab(text: 'Produtos'),
          Tab(text: 'Complemento'),

        ],
      ),
    );
  }

  // ✅ Adicione este getter para informar a altura da barra
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight); // Altura padrão de uma TabBar
}