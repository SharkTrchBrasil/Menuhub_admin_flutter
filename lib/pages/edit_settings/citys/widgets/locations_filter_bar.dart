// lib/pages/edit_settings/widgets/locations_filter_bar.dart

import 'package:flutter/material.dart';

// A Barra de Filtro em si
class LocationsFilterBar extends StatelessWidget {
  final TextEditingController searchController;

  const LocationsFilterBar({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      color: Theme.of(context).scaffoldBackgroundColor, // Garante que a barra tenha fundo ao flutuar
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar por bairro...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// O Delegate que faz a mágica de fixar a barra
class SliverFilterBarDelegate extends SliverPersistentHeaderDelegate {
  final LocationsFilterBar child;

  SliverFilterBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 80.0; // Altura total da barra

  @override
  double get minExtent => 80.0; // Altura da barra quando fixada

  @override
  bool shouldRebuild(covariant SliverFilterBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}