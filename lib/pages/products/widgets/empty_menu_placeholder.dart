// lib/features/menu/widgets/empty_menu_placeholder.dart

import 'package:flutter/material.dart';

class EmptyMenuPlaceholder extends StatelessWidget {
  final String searchText;
  const EmptyMenuPlaceholder({super.key, required this.searchText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
            searchText.isNotEmpty
                ? 'Nenhum item encontrado para "$searchText".'
                : 'Nenhuma categoria cadastrada ainda.\nClique em "Adicionar Categoria" para começar.',
            textAlign: TextAlign.center),
      ),
    );
  }
}