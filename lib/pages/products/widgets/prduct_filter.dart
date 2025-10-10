import 'package:flutter/material.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_tab.dart';

import '../../../core/responsive_builder.dart';


class ProductFilters extends StatelessWidget {
  // ... (código dos filtros responsivos)
  final TextEditingController searchController;
  final SortOption sortOption;
  final ValueChanged<SortOption?> onSortChanged;
  final VoidCallback onFilterTap;

  const ProductFilters({
    required this.searchController,
    required this.sortOption,
    required this.onSortChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 700;
        return isMobile ? _buildMobileLayout() : _buildDesktopLayout();
      },
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(child: _buildSearchField()),
        const SizedBox(width: 16),
        Expanded(child: SizedBox.shrink()),
        _buildSortDropdown(),
      ],
    );
  }




  Widget _buildMobileLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(child: _buildSearchField()),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onFilterTap,
              icon: const Icon(Icons.tune_outlined),
              tooltip: 'Filtrar',
            ),
            // IconButton(
            //   onPressed: () => _showReorderDialog(context, true),
            //   icon: const Icon(Icons.sort),
            //   tooltip: 'Reordenar',
            // ),
          ],
        ),

        // // Opcional: Mostrar o nome da categoria selecionada abaixo
        // if (widget.selectedValue != null)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 8.0),
        //     child: Chip(
        //       label: Text(widget.selectedValue!.name),
        //       onDeleted: () => widget.onCategoryChanged(null),
        //     ),
        //   )
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Buscar produto no cardápio',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButton<SortOption>(
        value: sortOption,
        underline: const SizedBox.shrink(),
        items: const [
          DropdownMenuItem(value: SortOption.nameAsc, child: Text("Ordenar por Nome A-Z")),
          DropdownMenuItem(value: SortOption.nameDesc, child: Text("Nome Z-A")),
          DropdownMenuItem(value: SortOption.priceAsc, child: Text("Menor Preço")),
          DropdownMenuItem(value: SortOption.priceDesc, child: Text("Maior Preço")),
        ],
        onChanged: onSortChanged,
      ),
    );
  }
}
