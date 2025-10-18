// inventory_filter_search.dart
import 'package:flutter/material.dart';
import '../../../core/responsive_builder.dart';

class InventoryFiltersAndSearch extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSearchChanged;

  const InventoryFiltersAndSearch({
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      desktopBuilder: (context, constraints) => Row(
        children: [
          _buildFilters(),
          const Spacer(),
          _buildSearch(),
        ],
      ),
      mobileBuilder: (context, constraints) => Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 16),
          _buildSearch(),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ['Todos', 'Estoque Baixo', 'Esgotado'].map((filter) {
        final isSelected = activeFilter == filter;
        return FilterChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (_) => onFilterChanged(filter),
          backgroundColor: Colors.grey[100],
          selectedColor: _getFilterColor(filter),
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.grey[300]!,
            ),
          ),
          elevation: isSelected ? 2 : 0,
        );
      }).toList(),
    );
  }

  Widget _buildSearch() {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Buscar produto...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          suffixIcon: IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey[500]),
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'Estoque Baixo':
        return Colors.orange;
      case 'Esgotado':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}