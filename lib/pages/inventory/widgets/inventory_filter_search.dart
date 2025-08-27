import 'package:flutter/material.dart';

import '../../../core/responsive_builder.dart';

class InventoryFiltersAndSearch extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSearchChanged;

  const InventoryFiltersAndSearch({required this.activeFilter, required this.onFilterChanged, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(


      desktopBuilder: (BuildContext context, BoxConstraints constraints) { return  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilters(),
          _buildSearch(),
        ],
      ); }, mobileBuilder: (BuildContext context, BoxConstraints constraints) { return    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilters(),
        const SizedBox(height: 16),
        _buildSearch(),
      ],
    );
    },
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      children: ['Todos', 'Estoque Baixo', 'Esgotado'].map((filter) {
        return ChoiceChip(
          label: Text(filter),
          selected: activeFilter == filter,
          onSelected: (_) => onFilterChanged(filter),
          selectedColor: Colors.deepPurple, // Cor de destaque
          labelStyle: TextStyle(color: activeFilter == filter ? Colors.white : Colors.black87),
          backgroundColor: Colors.white,
          shape: const StadiumBorder(side: BorderSide(color: Colors.transparent)),
          elevation: 2,
        );
      }).toList(),
    );
  }

  Widget _buildSearch() {
    return SizedBox(
      width: 300,
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar por nome...',
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
      ),
    );
  }
}
