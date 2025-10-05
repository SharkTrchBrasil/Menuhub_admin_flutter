import 'package:flutter/material.dart';

class PageTabBar extends StatelessWidget implements PreferredSizeWidget {
  // ✅ 1. Adiciona os parâmetros que estavam faltando
  final TabController controller;
  final bool isInWizard;

  const PageTabBar({
    super.key,
    required this.controller,
    this.isInWizard = false,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ 2. Define as abas com base no modo wizard
    final List<Widget> tabs = isInWizard
        ? [const Tab(text: 'Cardápio')]
        : [
      const Tab(text: 'Cardápio'),
      const Tab(text: 'Produtos'),
      const Tab(text: 'Complementos'), // Corrigido de "Complemento"
    ];

    return TabBar(
      // ✅ 3. Usa o controller recebido
      controller: controller,
      padding: EdgeInsets.zero,
      isScrollable: true, // Não precisa ser rolável com 3 itens
      tabAlignment: TabAlignment.start, // Preenche o espaço
      labelColor: Theme.of(context).colorScheme.primary,
      dividerColor: Colors.transparent,
      unselectedLabelColor: Colors.black54,
      indicatorColor: Theme.of(context).colorScheme.primary,
      indicatorWeight: 3.0,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      // ✅ 4. Usa a lista dinâmica de abas
      tabs: tabs,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}